# Hub24-Automation — guide for Claude Code

Conventions for generating tests in this repo. Follow these so generated
regression/E2E tests are consistent and runnable.

## Per-project docs (READ FIRST)

Context for each project lives in **`projects-document/<project>/`**. When the user tells
you which project they're working on, **read the whole `projects-document/<project>/`
folder first** (start with `project-info.md`) — it tells you the work tool
(Jira/Asana/Azure DevOps/Basecamp), the app URL, the Functional Spec links, the
CI, the test-case location, and any project-specific conventions. Use that to
drive setup (ticket destination, BASE_URL, spec source) instead of asking again
or assuming.

Starting a new project: copy `projects-document/_template/` to `projects-document/<project>/` and
fill in `project-info.md`; put extra specs/designs into `projects-document/<project>/docs/`.
Never put secrets in these files — those stay in `.env`.

## Planning workflow (REQUIRED — do this first)

Before implementing ANY task (adding/changing tests, editing config, building a
feature, fixing a bug, wiring CI, etc.), you MUST first create a plan document
and only start the work after it exists.

- **Where:** save the plan in the `plans/` folder.
- **Format:** **HTML (`.html`) — never Markdown.**
- **One file per task**, named `plans/<short-task-name>.html` (kebab-case).
- **Contents:** at minimum — Goal, Scope, Step-by-step approach, Files to
  create/change, and How to verify.
- Do not begin editing code until the plan file is written.
- Start from `plans/_template.html`.
- **Approval gate:** after writing the plan, STOP and present it. Wait for the
  user's explicit approval (an "OK"/"approve") before making any code changes.
  Never auto-proceed from plan to implementation.

## Current state (read this before planning work)

- **No HUB24 test environment yet.** `BASE_URL` is still a placeholder
  (`https://playwright.dev`) and there are no test credentials. This is the
  blocker (row 8 of the QC backlog) that gates real test execution.
- Because of that, `tests/auth.setup.ts` and `pages/hub24/ExamplePage.ts` are
  still templates (`TODO(HUB24)`), and no real HUB24 page object exists yet.
- `tests/e2e/saucedemo-*` + `pages/saucedemo/` are a **demo-only** suite against
  the public saucedemo.com — not HUB24 work. Ignore them unless asked.

## Where the work comes from

`test-cases/` holds the test cases generated from the Confluence Functional
Specs — 18 features, ~384 Gherkin scenarios, grouped as `app-header/`,
`workspace/`, `main-page-workspace/`. Each feature has a `.json` (source of
truth) and a derived `.feature`. **This is the backlog to automate.** Tagged
`@gap` = a spec gap; those are not automatable — flag them, don't test them.

## Before generating test cases (REQUIRED workflow)

Before generating any test case, ASK the user what source material is available
and collect it — do NOT assume or invent inputs. Ask for things like:

- the **Functional Spec** — a Confluence page URL, or a file path/link;
- the **web/app URL** under test (if any);
- any other references — designs, API contracts, existing tickets/pages.

The Functional Spec is the single source of the **acceptance criteria** (owned
by BA). The pipeline does NOT create or duplicate acceptance criteria — it
**reads the AC already in the spec** and converts them into Gherkin test cases.

Only once the user has provided the inputs, read them and generate the test
cases from that material, so the output matches the real spec. If a needed
input is missing, ask for it rather than guessing.

## Publishing generated test cases (REQUIRED workflow)

After the test cases are generated and approved, do NOT push them anywhere
automatically. Follow these steps, asking the user each time:

1. **Ask the destination:** "Push the test cases to **Asana** or
   **Confluence/Jira**?" (choose based on the project's tool).
2. **Ask for the storage link:** the user must provide the target link — the
   Asana project/ticket location, or the Confluence page URL. Never guess it.
3. **Publish the two files (Excel `.xlsx` + JSON `.json`):**
   - **Asana** → create a ticket at the provided link, then attach the test
     cases as **two separate files** (Excel + JSON) on that ticket.
   - **Confluence** → push to the page at the provided link, with **both files
     (Excel + JSON) on the same page**.
4. Publishing is side-effectful — confirm the destination + link with the user
   before doing it (see the safety rules on sending/creating content).

The repo copy (`test-cases/` as `.feature` + `.json`) stays the source of
truth regardless of where it's published.

## Configuring the ticket destination (REQUIRED before auto-ticket)

Each project uses a different work tool. Before enabling auto-ticket creation,
ASK the user which tool this project uses — **Jira, Asana, Azure DevOps, or
Basecamp** (may be more than one) — and have them fill the matching `.env` vars
(`*_CREATE_TICKETS=true` + credentials). Do NOT assume Jira.

Guide the user on how to obtain each value (token/PAT, project id, list/section
id, etc.) — the full step-by-step per tool is in
`docs/ticket-destination-setup.html`. Never ask for or handle real tokens in
chat; the user fills them into `.env` (gitignored) themselves.

Reporters run in parallel and are independent: a tool stays off while its
`*_CREATE_TICKETS` is not `true`. Confirm the destination + a test run before
relying on it.

**Interaction flow:** ask the tool → show which `.env` vars to fill + how to get
each value → wait for the user to fill `.env`. **When the user says "Done",
first VERIFY `.env`** — read it (or run `node scripts/check-ticket-env.mjs`) and
confirm that every enabled destination (`*_CREATE_TICKETS=true`) has all its
required vars filled. If anything is missing, tell the user exactly which vars
are still empty and wait. **Only when the config is complete**, reply that setup
is complete and they can now run the tests to auto-create tickets — give the run
commands (e.g., `npm run test:e2e` / `test:api` / `test:a11y` /
`test:visual:chromatic` / `test:browserstack`). Do not run them; just confirm ready.

## Skills

- `spec-to-testcase-pipeline` — regenerate test cases from the Confluence specs
  (needs the Atlassian connector). Run when specs change.
- `playwright-bug-to-jira` — the failure → .docx bug report → Jira ticket
  reporter. Already installed (`reporters/`); use the skill to change it.
- `/create-jira-ticket` — create a Jira ticket by hand, with a confirmation gate.

## Stack

- Playwright + TypeScript
- Page Object Model (`pages/`)
- Shared fixtures inject page objects (`fixtures.ts`)
- BDD via `playwright-bdd` (`features/` + `steps/`)
- Accessibility: `@axe-core/playwright` (`utils/a11y.ts`)
- Visual regression: Chromatic (`@chromatic-com/playwright`)

## Folder layout

```
pages/                Page objects. Extend BasePage. One class per page.
  hub24/              HUB24 page objects (start from ExamplePage.ts).
fixtures.ts           Extends Playwright `test` with page object fixtures.
tests/
  UI/                 Generic UI specs.
  accessibility/      axe-core specs.
  chromatic/          Visual specs.
  api/                API tests: data, schema, security checks (Playwright request).
  e2e/                Regression / E2E business-flow specs.
  auth.setup.ts       Logs in once, saves storageState.
features/             Gherkin .feature files.
steps/                Step definitions (call page objects).
utils/                Helpers (e.g. checkA11y).
paths.ts              Shared path constants (e.g. STORAGE_STATE).
plans/                REQUIRED: one HTML plan per task (see Planning workflow).
test-cases/           Gherkin test cases generated from the Confluence specs.
reporters/            Bug-report + Jira reporter (runs on every failure).
.claude/skills/       Project skills (see Skills above).
```

## Rules for generating tests

1. **Import `test`/`expect` from the fixtures** (`../../fixtures`), not
   `@playwright/test`, for E2E specs so page objects are injected:
   `async ({ examplePage }) => { ... }`.
2. **Never instantiate page objects** with `new XxxPage(page)` inside e2e
   specs — use the fixture. (Setup/auth files may still use `new`.)
3. **Put page interactions in a page object** under `pages/hub24/`, not inline.
   Locators live in the page object constructor.
4. **Selectors:** prefer `data-test`/`data-testid` attributes, then role-based
   locators (`getByRole`/`getByLabel`). Avoid brittle CSS/text.
5. **E2E specs go in `tests/e2e/`** and run authenticated (storageState) —
   start on the target page, don't re-login.
6. **Use `baseURL`-relative paths**: `await page.goto('/...')`. Set `BASE_URL`
   to the HUB24 environment.
7. **Assertions** use web-first `expect(locator).toBeVisible()` etc. — no
   manual waits / `waitForTimeout`.

## Commands

```bash
npm test            # default cross-browser suite (chromium/firefox/webkit)
npm run test:e2e    # regression/E2E project (auth via storageState)
npm run test:a11y   # accessibility
npm run test:visual # visual archives for Chromatic
npm run bdd         # generate + run Cucumber/BDD specs
npm run test:api    # API tests (Playwright request)
```

## Playwright projects (see playwright.config.ts)

- `chromium` / `firefox` / `webkit` — UI / a11y / visual specs
- `setup` — auth, produces storageState
- `e2e` — regression suite, depends on `setup`
- `api` — API tests (Playwright request, no browser); baseURL = API_URL
- `bdd` — generated from features/steps
