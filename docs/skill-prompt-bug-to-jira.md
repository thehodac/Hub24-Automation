---
name: playwright-bug-to-jira
description: >-
  Set up (or extend) an automated bug-report + Jira workflow for a
  Playwright + TypeScript test project. Use when failing tests should
  auto-generate per-issue .docx bug reports with screenshot/video, organized
  by test category, with FAIL/PASS history in Vietnam time, and auto-create /
  transition Jira tickets (Bug under an Epic, or Sub-task under a Story,
  with a [Bug] title prefix, status New on create and Done when the test passes).
  Trigger on: "bug report reporter", "auto create jira ticket from test",
  "create jira ticket when test fails", "move ticket to Done when it passes".
---

# Playwright → Bug Report → Jira workflow

You are setting up a custom Playwright reporter that turns test failures into
bug reports and Jira tickets, and updates them when tests pass again.

## Files to create / touch
- `reporters/bug-report.ts` — the Reporter (onBegin/onTestEnd/onEnd).
- `reporters/jira.ts` — Jira REST helpers (create ticket, transition, dedup).
- `utils/apiEvidence.ts` — helper to attach API request/response to a test.
- `playwright.config.ts` — register the reporter in the `reporter` array
  (all projects), and set `use.screenshot = 'only-on-failure'`,
  `use.video = 'retain-on-failure'`.

## Behaviour — when a test FAILS
1. Print a console summary: `📊 Total | Passed | Failed`, then one line per
   failing case.
2. Category = the folder under `tests/` (e2e, api, accessibility, chromatic, UI…).
   All outputs go into a sub-folder named after that category.
3. Write ONE .docx per issue:
   `bug-report/<category>/[FAIL][ISSUE-NN] <FuncSpec> - <title>.docx`
   - `<FuncSpec>` = outermost `describe()` title.
   - `ISSUE-NN` is stable across runs (numbered per category).
   - Content: File, Reason, Failed step, Steps to reproduce, Actual, Expected,
     Screenshot (embedded), Video (name), Change history.
4. Copy screenshot → `bug-image/<category>/[FAIL][ISSUE-NN] ....png` and video →
   `bug-video/<category>/[FAIL][ISSUE-NN] ....webm`.
5. API tests (no browser): read an attachment named `api-evidence`
   (method, URL, status, request/response) — put it in the .docx AND render it
   to a PNG via Playwright's chromium (graceful fallback if no browser).
6. Change history is stored in `bug-report/<category>/.history/ISSUE-NN.json`
   and printed in the .docx as `- FAIL on <date>` lines. Use Vietnam time
   (`Asia/Ho_Chi_Minh`, format `YYYY-MM-DD HH:mm (GMT+7)`). Append one entry
   EVERY run. History lives only in the file — never in the Jira ticket.
7. Create a Jira ticket (see Jira rules). Store it dedup'd by a stable label.

## Behaviour — when the test PASSES on a later run
1. Find the existing issue for that test (same `<FuncSpec> - <title>`).
2. Rename the file prefix `[FAIL]` → `[PASS]` for .docx/.png/.webm and
   KEEP ALL CONTENT (do not wipe the report).
3. Append a `PASS on <date>` history entry and regenerate the .docx.
4. Transition its Jira ticket to the pass status (default `Done`).

## Jira rules (reporters/jira.ts)
- No-op unless `JIRA_CREATE_TICKETS=true` and credentials exist.
- Title = `<JIRA_TITLE_PREFIX> <FuncSpec> - <title>` (prefix default `[Bug]`).
- Attach parent by detecting the parent issue type at runtime:
  - parent is an **Epic** → create a **Bug** (type = `JIRA_ISSUE_TYPE`, default `Bug`).
  - parent is a **Story/Task** → create a **Sub-task** (type = `JIRA_SUBTASK_TYPE`, default `Bug Fixing (in-sprint) Sub-task`).
- New tickets keep the workflow's initial status (`New`).
- Attach screenshot + video to the ticket.
- **Severity label (auto):** add a Jira label per the test's category/tags —
  `@security` → `P1-blocker`; e2e / api / accessibility / `@smoke` → `P2-critical`;
  chromatic (visual) → `P4-minor`; everything else → `P3-major`. Also shown in the
  .docx as "Severity: … — auto-assigned, QC to confirm".
- Dedup: label `autobug-<md5(file::title)>`; if an open (non-Done) ticket with
  that label exists, skip creating a duplicate.
- On pass: `GET /issue/{key}/transitions`, find the transition whose name OR
  target status equals `JIRA_PASS_TRANSITION` (default `Done`), then POST it.
- Use Jira Cloud REST v3, Basic auth (email + API token). ADF for description.

## Config (.env — never commit secrets)
```
JIRA_CREATE_TICKETS=false          # master switch
JIRA_BASE_URL=                     # https://<site>.atlassian.net
JIRA_EMAIL=
JIRA_API_TOKEN=
JIRA_PROJECT_KEY=                  # e.g. NIT
JIRA_PARENT_KEY=                   # Epic or Story to attach under (falls back to JIRA_EPIC_KEY)
JIRA_EPIC_KEY=                     # optional legacy fallback
JIRA_ISSUE_TYPE=Bug                # when parent is an Epic
JIRA_SUBTASK_TYPE=Bug Fixing (in-sprint) Sub-task   # when parent is a Story
JIRA_TITLE_PREFIX=[Bug]
JIRA_PASS_TRANSITION=Done
```

## Output folder layout
```
bug-report/<cat>/[FAIL|PASS][ISSUE-NN] <FuncSpec> - <title>.docx
bug-report/<cat>/.history/ISSUE-NN.json
bug-image/<cat>/[FAIL|PASS][ISSUE-NN] ....png
bug-video/<cat>/[FAIL|PASS][ISSUE-NN] ....webm
```
Add `bug-report/`, `bug-image/`, `bug-video/` and `.env` to `.gitignore`.

## Constraints / gotchas
- Requires `docx` (`npm i -D docx`). Rendering the API PNG needs chromium installed.
- Strip ANSI + control chars from error text before writing to .docx.
- Sanitize file names (remove `\ / : * ? " < > |`, trim, cap length).
- Keep `describe()` names aligned with functional-spec names.
- Never create tickets or change statuses without `JIRA_CREATE_TICKETS=true`;
  confirm with the user before enabling on a real project.
