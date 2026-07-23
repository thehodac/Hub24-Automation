# Friday stand-up — End-to-end demo run sheet (NIT-5145)

**Goal:** show the working end-to-end QC automation: Functional Spec → test cases →
run → bug report → Jira ticket → visual regression. ~5–7 minutes.

## Before the meeting (prep)
- [ ] Cowork app open (scheduled task 07:00 already ran, so test cases exist).
- [ ] Confluence open on: **Functional Specs → App Header**, and **QC & Testing Tools → App Header: Test Cases**.
- [ ] VS Code open on `Hub24-Automation`, folder `test-cases/` visible, terminal ready.
- [ ] `.env` has JIRA + CHROMATIC tokens; the demo Jira story (e.g. NIT-5186) open in a tab.

## Demo flow

**1. The problem (30s)**
> "The goal was an end-to-end QC pipeline: from a functional spec in Confluence, automatically generate test cases, run them, and turn any failure into a bug ticket — with AI doing the repetitive work."

**2. Spec → Test Cases (1.5 min)**
- Show a Functional Spec page (e.g. *App Header | Help*) — the User Story + Acceptance Criteria.
- Show the matching **Test Case | Help (Excel+Json)** page it generated (Gherkin table + JSON + summary).
- Show the local `test-cases/app-header/help.feature` + `.json`.
> "A scheduled job runs at 7am daily: it reads each spec, generates the test cases, publishes them to Confluence, and saves runnable `.feature` + `.json` into the repo. New or updated specs are picked up automatically."

![Spec → Test Case page on Confluence](../demo-assets/02-testcase-page.png)
<!-- CAPTURE: the "Test Case | Help (Excel+Json)" Confluence page (table + JSON). -->
![Local test-cases folder](../demo-assets/02-local-testcases.png)
<!-- CAPTURE: VS Code showing test-cases/app-header/ with .feature + .json. -->

**3. Run tests + bug report (1.5 min)**
- In the terminal, run one failing demo test:
  `npx playwright test tests/e2e/_demo-fail.e2e.spec.ts --project=e2e`
- Show the console summary, then open `bug-report/e2e/[FAIL][ISSUE-01] ....docx`.
> "On any failure the reporter builds a bug report — reason, steps, expected vs actual — with the screenshot and video attached, organised by test type (e2e / api / accessibility / chromatic)."

![Console summary of the run](../demo-assets/03-console.png)
<!-- CAPTURE: terminal after the run (📊 Total | Passed | Failed + ❌ line). -->
![Bug report .docx](../demo-assets/03-bug-report-docx.png)
<!-- CAPTURE: the opened .docx showing reason/steps/screenshot. -->

**4. Auto Jira ticket (1 min)**
- Open the Jira story and show the auto-created **Sub-task** `[Bug] E2E demo - ...` with screenshot + video attached.
> "If enabled, each failure creates a Jira bug — a Sub-task under the parent story (or a Bug under the Epic), `[Bug]` prefix, deduped by label so no duplicates. When the test passes again it can auto-move the ticket to Done."

![Auto-created Jira sub-task](../demo-assets/04-jira-ticket.png)
<!-- CAPTURE: the Jira sub-task [Bug] ... with attachments (e.g. NIT-5212/5213). -->

**5. Visual regression with Chromatic (1.5 min)**
- Run: `npm run test:visual:chromatic`
- Open `bug-report/chromatic/[FAIL][ISSUE-02] ....docx` — show **Before / After / Diff** + the **Chromatic build link**; click the link to the Chromatic build.
> "Visual changes are caught with Playwright's pixel diff locally — before/after/diff go straight into the report — and we also push a Chromatic build so the team can review and Accept/Deny on the dashboard."

Real console output from a run (Build 35):
```text
  ✘  3 [visual] › _demo-visual.spec.ts › workspace header looks unchanged
    Error: expect(page).toHaveScreenshot(expected) failed
      4313 pixels (ratio 0.01 of all image pixels) are different.
...
Started build 35
    → View build details at https://www.chromatic.com/build?appId=6a3ca3a3f01bb1d996cc7aca&number=35
Chromatic build URL saved -> https://www.chromatic.com/build?appId=6a3ca3a3f01bb1d996cc7aca&number=35
❌ chromatic/[FAIL][ISSUE-02] Visual regression demo - workspace header looks unchanged
```

![Visual report: Before/After/Diff + Chromatic link](../demo-assets/05-visual-report-docx.png)
<!-- CAPTURE: the chromatic .docx showing the 3 images + "Chromatic build:" line. -->
![Chromatic build page](../demo-assets/05-chromatic-build.png)
<!-- CAPTURE: the Chromatic build page (before/after review). -->

**6. Close (30s)**
> "So end to end: spec → auto test cases → run across e2e, API, accessibility and visual → auto bug reports and Jira tickets, with AI generating the test cases and analysing failures. This maps directly to the QA/QC strategy — Playwright, API testing, Chromatic visual regression, WCAG accessibility, and P1–P4 defect tracking."

## If asked / backup
- Coverage target 80% — this pipeline is the engine to get there.
- Next: severity labels (P1–P4) on auto tickets; deep-link to the exact Chromatic change; wiring `.feature` into runnable step definitions.
