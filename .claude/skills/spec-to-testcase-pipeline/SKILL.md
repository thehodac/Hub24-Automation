---
name: spec-to-testcase-pipeline
description: >-
  Automate generating test cases from Functional Specifications in Confluence
  and saving them both to Confluence and to the local repo. Use when a team
  wants: read each Functional Spec (User Story + Acceptance Criteria) → generate
  Gherkin/Cucumber test cases → publish one "Test Case | <feature> (Excel+Json)"
  page per feature under a "<Group>: Test Cases" parent, with a summary table
  → and write matching .json + .feature files into a local test-cases/ folder.
  Trigger on: "generate test cases from spec", "sinh test case từ functional spec",
  "auto test cases to Confluence", "push test cases to local", "test case pipeline".
---

# Functional Spec → Test Case pipeline

Read Functional Specs from Confluence, generate test cases, and write them to
BOTH Confluence and the local repo. Read-only on the specs; only create/update
test-case pages and local files. Never edit/rename/delete any spec page.

## Inputs to confirm with the user (per project)
- Confluence site + cloudId, and space key/id.
- The "Functional Specs" container (folder/page id) holding the spec pages.
- The "QC & Testing Tools" container (folder id) where test-case pages live.
- One existing sample "…: Test Cases" page to copy the exact format from.
- The local folder to write to (default: `test-cases/`).

## How specs are organised (typical)
- Specs are leaf pages titled `<Group> | <Feature>` (e.g. `App Header | Help`),
  grouped under group pages (e.g. `App Header`) inside the Functional Specs folder.
- Container pages (the group pages) have no acceptance criteria — skip them
  (i.e. only process pages whose title contains " | ").

## Steps (each run)
1. List every feature-spec page under the Functional Specs container
   (`getConfluencePageDescendants`, keep pages with " | " in the title).
2. Group by `<Group>` = text before " | "; `<Feature>` = text after.
3. For each group, ensure a `<Group>: Test Cases` page exists under the QC
   container (create if missing).
4. For each feature: read the spec's User Story + Acceptance Criteria. Find the
   `Test Case | <Feature> (Excel+Json)` child page.
   - none → CREATE · spec modified after the page → UPDATE · else → SKIP.
5. Test-case content (match the sample page exactly):
   - `## Test Case Table (Excel format)` — columns Scenario ID (`TC_<CODE>_NNN`),
     Tags, Scenario, Description (Given/When/Then, one clause per line).
   - `## JSON Export` — a ```json array of {scenario_id, tags, scenario, description}.
   - Cover positive/happy, negative, edge, accessibility, mobile, analytics, and
     `@gap` scenarios (spec contradictions/omissions).
6. Write local files (create folders as needed). slug = lowercase, replace
   spaces and `| ( ) /` with `-`:
   - `test-cases/<group-slug>/<feature-slug>.json` — the JSON array.
   - `test-cases/<group-slug>/<feature-slug>.feature` — Cucumber/Gherkin:
     `Feature: <Feature>` then per scenario a tags line, `Scenario: <name>`, and
     the Given/When/Then lines indented 4 spaces.
7. Rebuild the `<Group>: Test Cases` summary page (use HTML content format so
   links render as inline smart cards): intro line + a table of every child
   (inline-card link | test-case count | Draft status) sorted by count desc +
   a TOTAL row + a tag legend.

## Confluence how-to
- Read pages/descendants: `getConfluencePage` (markdown), `getConfluencePageDescendants`.
- Create/update: `createConfluencePage` / `updateConfluencePage`.
  - Test-case child pages: `contentFormat=markdown`.
  - Group summary page: `contentFormat=html`, links as
    `<a href="URL" data-card-appearance="inline">…</a>`, status as
    `<span data-type="status" data-color="yellow">Draft</span>`.

## Running it
- Run on demand: invoke this skill (`/spec-to-testcase-pipeline`) whenever specs
  change. There is **no scheduled run** — specs don't change daily.
- Requires the Atlassian (Confluence/Jira) connector to be connected — it comes
  from the claude.ai account, not from this repo. If the Confluence tools aren't
  available, stop and tell the user rather than guessing.

## Guardrails
- Never modify Functional Specs. Skip container pages and archived pages.
- Don't touch unrelated folders (e.g. a "TECHNICAL REPORT" folder).
- Specs are the single source of truth; test cases are derived — updating a
  spec and re-running updates its test cases.
- A standalone `scripts/json-to-feature.mjs` can regenerate all `.feature`
  files from the `.json` files at any time.
