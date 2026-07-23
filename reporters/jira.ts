/**
 * Auto-create Jira bug tickets from failed Playwright tests.
 *
 * Per team convention (Paulo):
 *   - Ticket name = "<Func Spec Name> - <short bug description>".
 *   - The bug is attached under a parent. The parent's type decides the kind:
 *       parent is an Epic        -> create a Bug      (child of the epic)
 *       parent is a Story/Task   -> create a Sub-task (child of the story)
 *   - EXCEPTION for Chromatic (visual) bugs: under an Epic they become a
 *       Story (not a Bug); under a Story they stay a Sub-task.
 *       Override the Epic-child type with JIRA_CHROMATIC_ISSUE_TYPE (default "Story").
 *
 * The "Func Spec Name" is taken from the outermost describe() block of the
 * test, so name your top-level describe after the functional spec.
 *
 * Enable with:  JIRA_CREATE_TICKETS=true
 * Credentials (env vars, NEVER commit):
 *   JIRA_BASE_URL     e.g. https://classltd.atlassian.net
 *   JIRA_EMAIL        your Atlassian account email
 *   JIRA_API_TOKEN    id.atlassian.com/manage-profile/security/api-tokens
 *   JIRA_PROJECT_KEY  e.g. NIT
 *   JIRA_PARENT_KEY   parent to attach under (Epic or Story), e.g. NIT-5186.
 *                     Falls back to JIRA_EPIC_KEY if not set.
 *   JIRA_ISSUE_TYPE   (optional) type when parent is an Epic, default "Bug"
 *   JIRA_SUBTASK_TYPE (optional) type when parent is a Story, default "Sub-task"
 *   JIRA_CHROMATIC_ISSUE_TYPE    (optional) Chromatic + Epic parent, default "Story"
 *   JIRA_CHROMATIC_SUBTASK_TYPE  (optional) Chromatic + Story parent, default "Sub-task"
 *   JIRA_CHROMATIC_TITLE_PREFIX  (optional) title prefix for Chromatic, default "[Visual]"
 *   JIRA_PASS_TRANSITION (optional) status to move a fixed ticket to when its
 *                     test passes on a later run, default "Done".
 *
 * Flow: test fails -> create ticket (status "New").
 *       test passes on re-run -> transition that ticket to "Done".
 */
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

export interface JiraBug {
  title: string;      // short bug description (the failing test's title)
  funcSpec: string;   // functional spec name (outermost describe)
  suite: string;
  file: string;
  project: string;
  /** Test category (e2e / api / accessibility / chromatic / ...) — drives issue type for visual bugs. */
  category?: string;
  reason: string;
  failedStep: string;
  stepsToReproduce: { text: string; failed: boolean }[];
  actual: string;
  expected: string;
  screenshot?: string;
  video?: string;
  /** Severity Jira label: blocker (P1) / critical (P2) / major (P3) / minor (P4). */
  severity?: string;
  /** Visual (Chromatic) evidence — before/after/diff image paths (no video). */
  visual?: { before?: string; after?: string; diff?: string };
  /** Chromatic build URL for visual changes. */
  chromaticUrl?: string;
  /** BrowserStack session dashboard URL (links the ticket to the exact run). */
  browserstackUrl?: string;
  /** Where the test ran: device (Desktop / phone model), OS, and browser. */
  environment?: { device?: string; os?: string; browser?: string };
  /** Test parameters / user inputs used (e.g. "username=standard_user; password=***"). */
  parameters?: string;
}

interface JiraConfig {
  baseUrl: string;
  email: string;
  token: string;
  projectKey: string;
  parentKey?: string;
  issueType: string;            // used when parent is an Epic (standalone Bug)
  subtaskType: string;          // used when parent is a Story/Task (child sub-task)
  chromaticIssueType: string;   // Chromatic + Epic parent  -> Story (not a Bug)
  chromaticSubtaskType: string; // Chromatic + Story parent -> plain Sub-task
}

function getConfig(): JiraConfig | null {
  const baseUrl = process.env.JIRA_BASE_URL?.replace(/\/+$/, '');
  const email = process.env.JIRA_EMAIL;
  const token = process.env.JIRA_API_TOKEN;
  const projectKey = process.env.JIRA_PROJECT_KEY;
  if (!baseUrl || !email || !token || !projectKey) return null;
  return {
    baseUrl,
    email,
    token,
    projectKey,
    // Parent to attach under. JIRA_PARENT_KEY (a container ticket, for subtasks)
    // takes precedence over JIRA_EPIC_KEY (an Epic, for standalone Bugs).
    parentKey: process.env.JIRA_PARENT_KEY || process.env.JIRA_EPIC_KEY || undefined,
    issueType: process.env.JIRA_ISSUE_TYPE || 'Bug',
    subtaskType: process.env.JIRA_SUBTASK_TYPE || 'Bug Fixing (in-sprint) Sub-task',
    // Chromatic/visual tickets are NOT bugs by default (a visual change may be
    // intentional). Under an Epic -> Story; under a Story -> plain Sub-task.
    chromaticIssueType: process.env.JIRA_CHROMATIC_ISSUE_TYPE || 'Story',
    chromaticSubtaskType: process.env.JIRA_CHROMATIC_SUBTASK_TYPE || 'Sub-task',
  };
}

function authHeader(cfg: JiraConfig): string {
  return 'Basic ' + Buffer.from(`${cfg.email}:${cfg.token}`).toString('base64');
}

/** Stable label per test so repeat failures reuse the same open ticket. */
function bugLabel(bug: JiraBug): string {
  const h = crypto.createHash('md5').update(`${bug.file}::${bug.title}`).digest('hex').slice(0, 10);
  return `autobug-${h}`;
}

/**
 * Title prefix per test category (Paulo's naming convention):
 *   e2e -> [E2E-Bug], api -> [API-Bug], accessibility -> [Accessibility-Bug],
 *   browserstack -> [BrowserStack-Bug].
 *   chromatic -> [Chromatic-Issue] (NOT "-Bug": a visual change may not be a defect).
 *   anything else -> [Bug]. Each is overridable via env.
 */
export function titlePrefix(bug: JiraBug): string {
  switch (bug.category) {
    case 'e2e':
      return process.env.JIRA_E2E_TITLE_PREFIX || '[E2E-Bug]';
    case 'api':
      return process.env.JIRA_API_TITLE_PREFIX || '[API-Bug]';
    case 'accessibility':
      return process.env.JIRA_A11Y_TITLE_PREFIX || '[Accessibility-Bug]';
    case 'chromatic':
      return process.env.JIRA_CHROMATIC_TITLE_PREFIX || '[Chromatic-Issue]';
    case 'browserstack':
      return process.env.JIRA_BROWSERSTACK_TITLE_PREFIX || '[BrowserStack-Bug]';
    default:
      return process.env.JIRA_TITLE_PREFIX || '[Bug]';
  }
}

function ticketSummary(bug: JiraBug): string {
  const spec = bug.funcSpec || bug.suite || 'Test';
  return `${titlePrefix(bug)} ${spec} - ${bug.title}`.slice(0, 240);
}

/** Atlassian Document Format (ADF) description for the ticket. */
function buildAdf(bug: JiraBug): unknown {
  const p = (text: string) => ({ type: 'paragraph', content: text ? [{ type: 'text', text }] : [] });
  const h = (text: string) => ({ type: 'heading', attrs: { level: 3 }, content: [{ type: 'text', text }] });
  const steps =
    bug.stepsToReproduce.length > 0
      ? bug.stepsToReproduce.map((s) => ({
          type: 'listItem',
          content: [p(`${s.failed ? '[FAILED HERE] ' : ''}${s.text}`)],
        }))
      : [{ type: 'listItem', content: [p('(no steps recorded)')] }];

  return {
    type: 'doc',
    version: 1,
    content: [
      h('Reason (why it failed)'),
      p(bug.reason),
      h('Failed at step'),
      p(bug.failedStep),
      h('Steps to reproduce'),
      { type: 'orderedList', content: steps },
      h('Actual result (current)'),
      p(bug.actual),
      h('Expected result (to pass)'),
      p(bug.expected),
      ...(bug.environment && (bug.environment.device || bug.environment.os || bug.environment.browser)
        ? [
            h('Environment / Device'),
            p(
              `Device: ${bug.environment.device ?? '-'} · OS: ${bug.environment.os ?? '-'} · ` +
                `Browser: ${bug.environment.browser ?? '-'}`,
            ),
          ]
        : []),
      ...(bug.parameters ? [h('Test parameters (user inputs)'), p(bug.parameters)] : []),
      p(`Test file: ${bug.file}`),
      ...(bug.chromaticUrl ? [p(`Chromatic build: ${bug.chromaticUrl}`)] : []),
      ...(bug.browserstackUrl ? [p(`BrowserStack session: ${bug.browserstackUrl}`)] : []),
      ...(bug.visual && (bug.visual.before || bug.visual.after)
        ? [p('Visual evidence: before + current (after) images attached.')]
        : []),
      p('Created automatically by the HUB24 Bug Report reporter.'),
    ],
  };
}

/** Best-effort: find an existing open ticket for this test. Returns key or null. */
async function findExisting(cfg: JiraConfig, label: string): Promise<string | null> {
  try {
    const jql = `project = "${cfg.projectKey}" AND labels = "${label}" AND statusCategory != Done ORDER BY created DESC`;
    const url = `${cfg.baseUrl}/rest/api/3/search/jql?jql=${encodeURIComponent(jql)}&maxResults=1&fields=key`;
    const res = await fetch(url, { headers: { Authorization: authHeader(cfg), Accept: 'application/json' } });
    if (!res.ok) return null;
    const data = (await res.json()) as { issues?: { key: string }[] };
    return data.issues?.[0]?.key ?? null;
  } catch {
    return null;
  }
}

/**
 * Look up the parent's issue type so we know how to attach the bug:
 *   'epic'     -> parent is an Epic  -> create a standalone Bug under it
 *   'standard' -> parent is Story/Task -> create a Sub-task under it
 * Returns null if it can't be determined.
 */
async function fetchParentKind(cfg: JiraConfig, key: string): Promise<'epic' | 'standard' | null> {
  try {
    const url = `${cfg.baseUrl}/rest/api/3/issue/${key}?fields=issuetype`;
    const res = await fetch(url, { headers: { Authorization: authHeader(cfg), Accept: 'application/json' } });
    if (!res.ok) return null;
    const data = (await res.json()) as {
      fields?: { issuetype?: { name?: string; hierarchyLevel?: number; subtask?: boolean } };
    };
    const it = data.fields?.issuetype;
    if (!it) return null;
    if (it.name === 'Epic' || (typeof it.hierarchyLevel === 'number' && it.hierarchyLevel >= 1)) return 'epic';
    return 'standard';
  } catch {
    return null;
  }
}

/**
 * Pick the Jira issue type from the parent's kind AND the test category.
 *   Chromatic (visual): Epic parent  -> Story        (NOT a Bug),
 *                       Story parent -> plain Sub-task.
 *   Everything else:    Epic parent  -> Bug,
 *                       Story parent -> Bug-Fixing Sub-task.
 * A null parentKind (couldn't read parent) is treated as Epic.
 */
function issueTypeFor(cfg: JiraConfig, bug: JiraBug, parentKind: 'epic' | 'standard' | null): string {
  const isChromatic = bug.category === 'chromatic';
  if (parentKind === 'standard') {
    return isChromatic ? cfg.chromaticSubtaskType : cfg.subtaskType;
  }
  return isChromatic ? cfg.chromaticIssueType : cfg.issueType;
}

async function createIssue(cfg: JiraConfig, bug: JiraBug, label: string, issueType: string): Promise<string> {
  const fields: Record<string, unknown> = {
    project: { key: cfg.projectKey },
    summary: ticketSummary(bug),
    issuetype: { name: issueType },
    labels: bug.severity ? ['automation', label, bug.severity] : ['automation', label],
    description: buildAdf(bug),
  };
  // Epic parent -> Bug child; Story/Task parent -> Sub-task child.
  if (cfg.parentKey) fields.parent = { key: cfg.parentKey };

  const res = await fetch(`${cfg.baseUrl}/rest/api/3/issue`, {
    method: 'POST',
    headers: { Authorization: authHeader(cfg), Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify({ fields }),
  });
  if (!res.ok) throw new Error(`create issue failed (${res.status}): ${await res.text()}`);
  const data = (await res.json()) as { key: string };
  return data.key;
}

async function attachFile(cfg: JiraConfig, key: string, file: string): Promise<void> {
  if (!file || !fs.existsSync(file)) return;
  const form = new FormData();
  form.append('file', new Blob([fs.readFileSync(file)]), path.basename(file));
  const res = await fetch(`${cfg.baseUrl}/rest/api/3/issue/${key}/attachments`, {
    method: 'POST',
    headers: { Authorization: authHeader(cfg), 'X-Atlassian-Token': 'no-check' },
    body: form,
  });
  if (!res.ok) console.log(`   ⚠️  Could not attach screenshot to ${key} (${res.status}).`);
}

/**
 * Create Jira tickets for the given failed cases.
 * No-op unless JIRA_CREATE_TICKETS=true and credentials are present.
 */
export async function createBugTickets(bugs: JiraBug[]): Promise<void> {
  if (process.env.JIRA_CREATE_TICKETS !== 'true') return;
  if (bugs.length === 0) return;

  const cfg = getConfig();
  if (!cfg) {
    console.log(
      '\n⚠️  JIRA_CREATE_TICKETS=true but Jira credentials are missing ' +
        '(need JIRA_BASE_URL, JIRA_EMAIL, JIRA_API_TOKEN, JIRA_PROJECT_KEY). Skipping.'
    );
    return;
  }

  // Read the parent's kind once (Epic vs Story/Task). The issue type then
  // depends on BOTH the parent kind and each test's category (see issueTypeFor).
  let parentKind: 'epic' | 'standard' | null = null;
  if (cfg.parentKey) {
    parentKind = await fetchParentKind(cfg, cfg.parentKey);
    if (parentKind === null)
      console.log(`   ⚠️  Could not read parent ${cfg.parentKey} type — assuming Epic.`);
  }

  console.log(
    `\n🎫 Creating Jira tickets in ${cfg.projectKey}` +
      (cfg.parentKey ? ` under ${cfg.parentKey}` : '') +
      ' ...'
  );
  for (const bug of bugs) {
    const label = bugLabel(bug);
    const issueType = issueTypeFor(cfg, bug, parentKind);
    try {
      const existing = await findExisting(cfg, label);
      if (existing) {
        console.log(`   ↩︎  "${ticketSummary(bug)}" already open as ${existing}, skipped.`);
        continue;
      }
      const key = await createIssue(cfg, bug, label, issueType);
      // Chromatic (visual): attach before + after images (no video).
      // Everything else: attach screenshot + video.
      if (bug.visual && (bug.visual.before || bug.visual.after)) {
        await attachFile(cfg, key, bug.visual.before ?? '');
        await attachFile(cfg, key, bug.visual.after ?? '');
      } else {
        await attachFile(cfg, key, bug.screenshot ?? '');
        await attachFile(cfg, key, bug.video ?? '');
      }
      console.log(`   ✅ Created ${key} — ${ticketSummary(bug)}`);
    } catch (e) {
      console.log(`   ❌ Failed to create ticket for "${bug.title}": ${String(e)}`);
    }
  }
}

/** Find the transition id whose name (or target status) matches `target`. */
async function findTransitionId(cfg: JiraConfig, key: string, target: string): Promise<string | null> {
  try {
    const res = await fetch(`${cfg.baseUrl}/rest/api/3/issue/${key}/transitions`, {
      headers: { Authorization: authHeader(cfg), Accept: 'application/json' },
    });
    if (!res.ok) return null;
    const data = (await res.json()) as {
      transitions?: { id: string; name: string; to?: { name?: string } }[];
    };
    const t = data.transitions?.find(
      (x) =>
        x.name.toLowerCase() === target.toLowerCase() ||
        x.to?.name?.toLowerCase() === target.toLowerCase(),
    );
    return t?.id ?? null;
  } catch {
    return null;
  }
}

/**
 * When a previously-failing test now passes, move its Jira ticket to a target
 * status (default "Committed", override with JIRA_PASS_TRANSITION).
 * No-op unless JIRA_CREATE_TICKETS=true and an open ticket exists for the test.
 */
export async function resolveFixedTicket(bug: JiraBug): Promise<void> {
  if (process.env.JIRA_CREATE_TICKETS !== 'true') return;
  const cfg = getConfig();
  if (!cfg) return;
  // When a previously-failing test now passes, move its ticket to "Done".
  const target = process.env.JIRA_PASS_TRANSITION || 'Done';
  const label = bugLabel(bug);
  try {
    const key = await findExisting(cfg, label);
    if (!key) return; // no open ticket for this test — nothing to move
    const tid = await findTransitionId(cfg, key, target);
    if (!tid) {
      console.log(`   ⚠️  ${key}: no transition to "${target}" available from its current status.`);
      return;
    }
    const res = await fetch(`${cfg.baseUrl}/rest/api/3/issue/${key}/transitions`, {
      method: 'POST',
      headers: { Authorization: authHeader(cfg), Accept: 'application/json', 'Content-Type': 'application/json' },
      body: JSON.stringify({ transition: { id: tid } }),
    });
    if (res.ok) console.log(`   ✅ ${key} → "${target}" (test now passes).`);
    else console.log(`   ❌ ${key}: transition failed (${res.status}): ${await res.text()}`);
  } catch (e) {
    console.log(`   ❌ Transition error for "${bug.title}": ${String(e)}`);
  }
}
