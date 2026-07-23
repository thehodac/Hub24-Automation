# Handoff / Context — Hub24-Automation QC framework

> Purpose: give another AI (or teammate) enough context to continue the work without re-reading the whole chat history. Date: 2026-07-21.

## 1. What this project is
A Playwright + TypeScript **QC automation framework** for **Project NITRO / HUB24** (client of MPF — The Project Factory). It generates test cases from Functional Specs, runs multiple test types, and auto-files bug tickets. Jira project key is **NIT** (site `classltd.atlassian.net`, Confluence space **PN1 / Project Nitro**).

Stack: Playwright + TypeScript · Page Object Model (`pages/`) · shared fixtures (`fixtures.ts`) · BDD (`playwright-bdd`) · accessibility (`@axe-core/playwright`) · visual regression (Chromatic) · cross-browser (BrowserStack) · CI (CloudBees + GitHub Actions; Bamboo required by HUB24 docs).

## 2. Current state (important)
- **BLOCKER: no HUB24 test environment yet.** `BASE_URL` is a placeholder (`https://playwright.dev`); no test credentials. This gates ALL real HUB24 e2e/UI/regression execution.
- Because of that, `tests/auth.setup.ts` and `pages/hub24/ExamplePage.ts` are still templates (`TODO(HUB24)`); no real HUB24 page object exists yet.
- The framework is **proven on a public sample project, SauceDemo** (`tests/e2e/saucedemo-*`, `pages/saucedemo/`). This is demo-only, not HUB24 work.

## 3. What has been built (working)
- **Test-case generation** from Confluence Functional Specs → `.feature` + `.json` in `test-cases/` (source of truth). Skills: `generate-testcase`, `spec-to-testcase-pipeline`.
- **Auto bug reporting** (`reporters/`): on test failure, auto-creates a ticket with enriched content — clear human-readable error reason (not "element not found"), plain-language steps, Test parameters (no password), Environment/Device (real browser names: Chrome/Firefox/Safari). Dedup by label `autobug-<hash>` + `statusCategory != Done`; auto-closes on pass.
  - Destinations implemented, each toggled by `*_CREATE_TICKETS=true` in `.env`: **Jira** (`reporters/jira.ts`), **Asana** (`reporters/asana.ts`), **Azure DevOps** (`reporters/azuredevops.ts`), **Basecamp** (`reporters/basecamp.ts`). Verify with `node scripts/check-ticket-env.mjs`.
  - Category title prefixes: `[E2E-Bug]`, `[API-Bug]`, `[Accessibility-Bug]`, `[BrowserStack-Bug]`, and `[Chromatic-Issue]` (Chromatic tickets are Story/Sub-task, NOT Bug — a visual change may be intentional).
- **Test types**: e2e (`npm run test:e2e`), api (`test:api`), accessibility (`test:a11y`), visual/Chromatic (`test:visual:chromatic` — uses `--force-rebuild`), cross-browser (`test:browserstack`).
- **CI**: CloudBees (`.cloudbees/workflows/test.yaml`) and GitHub Actions (`.github/workflows/test.yml`). Stage 1 = e2e+api+a11y+chromatic (always run); stage 2 = BrowserStack, gated to run only if stage 1 passed 100% (`if: steps.X.outcome == 'success'`). Memory fix: `CI=true` + `--workers=1`. Bamboo config exists (`bamboo-specs/bamboo.yml`) but needs a self-hosted Bamboo server.

## 4. Per-project docs + skill
- **`projects-document/<project>/`** holds per-project context. `CLAUDE.md` rule: before working on a project, read the whole folder (start with `project-info.md`). Template in `projects-document/_template/`. Existing: `hub24/`, `Saucedemo/` (has `project-info.md` + `Saucedemo_TestCase.doc`), plus empty `MQB/`, `Pave/`, `WFC/`.
- **Skill `read-project-docs`** (a.k.a. `read-document-project`): asks which project → lists projects in `projects-document/` → reads that folder → if empty, tells user "I currently can't find any information..." and asks them to BOTH provide link(s) (Confluence/web URL) AND add files, then "Done" → after reading, always asks if they want to add more docs → hands off to test-case generation. The editable source is `outputs/read-project-docs-SKILL.md`; the installed skill is a read-only cache (edit via skill-creator).

## 5. Backlog / sprint plan (the current focus)
Master file: **"Hub24 Teams Backlog planning"**, tab **New QC** (Didier is consolidating all teams' tabs). A working copy is `QC-backlog-draft.xlsx`. Columns: Feature | Task | Est (days) | Main Resource | Description | Output | Tool | Dependency | status.

Structure: framework rows (Done) → Figma-comment rows (Done) → **Sprint 1 (Workflow + Tooling)** → Sprint 2/3 → Back Log. Sprint 1 highlights:
- **Workflow (rows 32–34)**: polish the FigJam workflow, review with team, (guideline — see note in §7).
- **Tooling (rows 35–54)**: select HUB24 tool, then per-tool blocks (Jira, Confluence, Chromatic, CloudBees, GitHub Actions, BrowserStack), each = setup → integrate/check → guidelines, with chained dependencies (#row).
- **Back Log**: Research; **Load testing** (k6 / JMeter); **Pen testing** (Snyk / DeepCode AI only — OWASP ZAP was dropped per user); Bamboo; Work-tool integrations (Asana/Azure/Basecamp enable + publish + demo).
- Tasks already finished are left in the plan with **no estimate** and status **Done** so dependencies stay visible.

## 6. Workflow (FigJam) — being finalised this week
End-to-end QC flow lives on **FigJam (source of truth)**. Nodes/process steps: Test Case Generator (Cucumber) → Generate E2E tests → API testing → Accessibility (axe-core) → Visual regression (Chromatic) → Regression runner (CloudBees) → CI runner (GitHub Actions) → Cross-browser (BrowserStack); then release flow: Prepare to release → Smoke test UAT (manual) → Release → Smoke test PROD (manual) → Announce. Fail branches → create bug ticket in Jira → dev fixes → re-run.

Changes to make on FigJam this week: add **Integration Testing** phase; add **Performance testing** (Kat flagged it missing); expand **Prepare for UAT Release** and **Production Release**; add **Perform Manual Testing** step; move inline notes out. Non-functional gates to place **after UAT smoke test passes, before Production Release**: **Load/Performance testing** (k6/JMeter) and **Security/Pen testing** (Snyk DeepCode AI; Snyk SAST also plugs into PR/CI).

## 7. Team context & open feedback
- **Didier Esparza** (lead): wants planning FIRST, execution later. Repeatedly demanded a "solid, reviewed, stress-tested, cross-checked QC plan listing ALL tasks + dependencies for HUB24 delivery", delivered fast. Do NOT start execution (e.g. enabling Asana tickets) until the plan is finalised.
- **Kat Robinson**: handed all MPF work to Thong (roles switched with "The"; The now leads communication; keep including Paulo in daily meetings). Kat's key reversal: **do NOT create large guideline documentation — FigJam is the source of truth** as it keeps evolving. Kat left Figma comments tagging "Thong Ho missing" on optional-extra nodes:
  - Load testing + Pen testing (→ DeepCode.io / Snyk) — added to backlog.
  - UX/UI tools to validate design + Browser stacks (→ Visual Testing) — already covered by **Chromatic** (visual) + **BrowserStack** (cross-browser).
  - Client Feedback collector tool (→ Marker.io / Lucia.ai / BugFender / Sentry user feedback) — new area to explore, not yet in backlog.
- Other reviewers (Paulo, Ha, CY Lim) earlier Figma comments are all actioned (Done rows in the backlog).

## 8. Publishing done on Confluence (space PN1)
- **"Saucedemo — Test Cases"** child page under QA/QC Technical Specifications (page id 2195947542) — 41 test cases (38 functional + 3 @gap) as tables.
- **"QC Automation — Workflow Guideline"** page in a PN1 folder (page id 2196570179) — the 8 process nodes. Note: the Confluence connector CANNOT attach binary files (.docx/.xlsx); content is embedded as tables/lists. Repo copies stay source of truth.

## 9. Key conventions (from CLAUDE.md)
- **Plan first**: before any task, write an HTML plan in `plans/` (from `plans/_template.html`); present for approval; no code changes until approved.
- **Before generating test cases**: ask the user for the source material (Functional Spec URL/file, app URL); never invent acceptance criteria — read the AC already in the spec.
- **Publishing test cases**: never auto-push. Ask destination (Asana or Confluence/Jira) + ask for the target link; publish Excel + JSON.
- **Ticket destination setup**: ask which tool the project uses; guide the user to fill `.env` (never handle tokens in chat); after they say "Done", VERIFY with `node scripts/check-ticket-env.mjs`, then give run commands.
- **Secrets** live only in `.env` (gitignored); never in `projects-document/` or committed.

## 10. Pending / next steps
1. Finalise the FigJam workflow (add Integration Testing + Performance testing, expand UAT/Production Release, add Manual Testing, remove notes).
2. Keep the QC backlog as the single full task list + 3-week sprint plan for HUB24; ensure ALL tasks + dependencies are listed (Hub team asked for a full project-duration list).
3. Do NOT produce large standalone guideline docs (Kat) — keep FigJam as source of truth.
4. HUB24 env (BASE_URL + credentials) from Dev/Infra — the blocker that unlocks real HUB24 test writing/execution.
5. Optional/explore: Client feedback collector tool; mobile testing (BrowserStack App Automate / Maestro for Flutter & React Native, per CY).
6. User should commit + push repo changes and run `npx tsc --noEmit` locally (the sandbox can't run tsc/Playwright reliably).

## 11. Important gotchas
- Chromatic skips rebuilds → must pass `--force-rebuild`.
- Playwright devices set `defaultBrowserType`, not `browserName` (reporter maps chromium→Chrome, webkit→Safari, firefox→Firefox).
- Ticket dedup is by label `autobug-<hash>` + `statusCategory != Done` — NOT by title or local report files. To get a new ticket for the same test, close the old one (move to Done).
- CloudBees errors if a workflow references a secret that hasn't been created; empty GitHub Actions secrets don't error.
