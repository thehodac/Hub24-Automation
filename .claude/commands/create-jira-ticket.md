---
description: Create a Jira ticket (and optional subtask) in ANY project, following the team convention. Confirms before creating.
---

# Create a Jira ticket (multi-project)

Reusable step to create a Jira issue. Works for ANY project (pass the project key).
Two ways to run it:

- **Script (recommended, works everywhere):**
  `npm run jira:ticket -- --project <KEY> --summary "<title>" [--type Bug] [--parent <EPIC-or-ticket>] [--subtask "<title>"]`
  Add `--yes` to skip the confirmation prompt in automated runs.

- **Via chat:** ask Claude to "create a Jira ticket" and provide project + summary;
  Claude uses the Atlassian tools directly.

## Rules (follow exactly)
1. **Site**: cloudId = `classltd.atlassian.net`. **Project** = whatever the user passes (`--project`); do NOT hard-code one.
2. **Issue type**: default **Bug**. Use another type only if asked. A child of a Story/Bug must be **Sub-task**.
3. **Summary**: format `<Func Spec Name> - <short description>`; keep any prefix the user asks for (e.g. `[QC-test] ...`).
4. **Parent**: use the parent the user gives (Epic key, or a ticket key to make a sub-task). If none is given, **ASK first** — never default to a real Epic (e.g. NIT-5006), to avoid mixing test tickets into real work.
5. **Confirmation gate (REQUIRED)**: show the exact fields (project, type, parent, summary) and get a clear "yes" before creating. The script prompts by default; `--yes` disables it only for automation.
6. **After creating**: return the key + browse URL. If it was a test, remind the user they can delete it (More actions → Delete).
7. **Never hard-delete** tickets on the user's behalf — deletion is the user's action.

## Credentials
Read from `.env`: `JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` (never committed).
