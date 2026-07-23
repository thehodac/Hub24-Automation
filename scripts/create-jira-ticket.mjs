#!/usr/bin/env node
/**
 * Reusable, multi-project Jira ticket creator.
 *
 * Usage:
 *   node scripts/create-jira-ticket.mjs --project NIT --summary "App Header - Login button missing"
 *   node scripts/create-jira-ticket.mjs --project HUB --type Bug --parent NIT-5186 --subtask "repro step"
 *   npm run jira:ticket -- --project NIT --summary "..." --yes
 *
 * Flags:
 *   --project <KEY>    Jira project key (any project)          [required]
 *   --summary <TEXT>   Ticket title                            [required]
 *   --type <NAME>      Issue type (Bug, Story, Task, ...)      [default: Bug]
 *   --parent <KEY>     Epic key or parent ticket key           [optional]
 *   --subtask <TEXT>   Also create a Sub-task with this title  [optional]
 *   --yes              Skip the confirmation prompt            [optional]
 *
 * Credentials come from .env (or the shell):
 *   JIRA_BASE_URL, JIRA_EMAIL, JIRA_API_TOKEN
 */
import fs from 'node:fs';
import path from 'node:path';
import readline from 'node:readline';

// --- tiny .env loader (no dependency) ---
function loadEnv() {
  const p = path.resolve('.env');
  if (!fs.existsSync(p)) return;
  for (const line of fs.readFileSync(p, 'utf8').split('\n')) {
    const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/i);
    if (!m) continue;
    const key = m[1];
    let val = m[2].replace(/^["']|["']$/g, '');
    if (process.env[key] === undefined || process.env[key] === '') process.env[key] = val;
  }
}
loadEnv();

// --- parse args ---
function parseArgs(argv) {
  const out = { type: 'Bug', yes: false };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--yes') out.yes = true;
    else if (a.startsWith('--')) out[a.slice(2)] = argv[++i];
  }
  return out;
}
const args = parseArgs(process.argv.slice(2));

// --- validate ---
const { JIRA_BASE_URL, JIRA_EMAIL, JIRA_API_TOKEN } = process.env;
function fail(msg) { console.error(`\n❌ ${msg}`); process.exit(1); }
if (!JIRA_BASE_URL || !JIRA_EMAIL || !JIRA_API_TOKEN)
  fail('Missing Jira credentials. Set JIRA_BASE_URL, JIRA_EMAIL, JIRA_API_TOKEN in .env');
if (!args.project) fail('Missing --project <KEY>');
if (!args.summary) fail('Missing --summary "<text>"');

const baseUrl = JIRA_BASE_URL.replace(/\/+$/, '');
const auth = 'Basic ' + Buffer.from(`${JIRA_EMAIL}:${JIRA_API_TOKEN}`).toString('base64');

function adf(text) {
  return { type: 'doc', version: 1, content: [{ type: 'paragraph', content: text ? [{ type: 'text', text }] : [] }] };
}

async function createIssue({ project, type, summary, parent, description }) {
  const fields = { project: { key: project }, summary, issuetype: { name: type } };
  if (parent) fields.parent = { key: parent };
  if (description) fields.description = adf(description);
  const res = await fetch(`${baseUrl}/rest/api/3/issue`, {
    method: 'POST',
    headers: { Authorization: auth, Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify({ fields }),
  });
  if (!res.ok) throw new Error(`create failed (${res.status}): ${await res.text()}`);
  return (await res.json()).key;
}

function confirm(question) {
  return new Promise((resolve) => {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
    rl.question(question, (ans) => { rl.close(); resolve(/^y(es)?$/i.test(ans.trim())); });
  });
}

(async () => {
  console.log('\nAbout to create this Jira issue:');
  console.log(`  Project : ${args.project}`);
  console.log(`  Type    : ${args.type}`);
  console.log(`  Summary : ${args.summary}`);
  console.log(`  Parent  : ${args.parent || '(none)'}`);
  if (args.subtask) console.log(`  Subtask : ${args.subtask}`);

  if (!args.yes) {
    const ok = await confirm('\nCreate it? (y/N) ');
    if (!ok) { console.log('Cancelled — nothing created.'); process.exit(0); }
  }

  try {
    const key = await createIssue({
      project: args.project, type: args.type, summary: args.summary,
      parent: args.parent, description: args.description,
    });
    console.log(`\n✅ Created ${key} — ${baseUrl}/browse/${key}`);

    if (args.subtask) {
      const subKey = await createIssue({
        project: args.project, type: 'Sub-task', summary: args.subtask, parent: key,
      });
      console.log(`✅ Created sub-task ${subKey} — ${baseUrl}/browse/${subKey}`);
    }
  } catch (e) {
    fail(String(e));
  }
})();
