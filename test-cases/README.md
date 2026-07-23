# test-cases/

Local copies of the test cases generated from the HUB24 Functional Specs
(Confluence → "QC & Testing Tools"). This is the **"push to local"** output for
NITRO ticket **NIT-5137**.

Structure — one folder per feature group, two files per feature:

```
test-cases/
  <group-slug>/
    <feature-slug>.json      # array of { scenario_id, tags, scenario, description }
    <feature-slug>.feature   # Cucumber/Gherkin, runnable by the test framework
```

## How it is produced
- Run the `spec-to-testcase-pipeline` skill in Claude Code whenever the
  Functional Specs change. It reads each spec, generates the test cases,
  publishes them to Confluence, **and writes the matching `.json` + `.feature`
  files here.** There is no scheduled run — invoke it on demand.
- To (re)generate the `.feature` files from the `.json` files at any time:

  ```bash
  node scripts/json-to-feature.mjs
  ```

The `.json` is the source of truth; the `.feature` is derived from it.
