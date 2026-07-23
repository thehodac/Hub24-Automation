# Hub24 Automation

E2E test automation with [Playwright](https://playwright.dev) + TypeScript, using the Page Object Model.

## Setup

```bash
npm install
npx playwright install
```

## Configure target

Tests run against `BASE_URL` (defaults to the Playwright docs site for the sample). Copy `.env.example` to `.env` or export the variable:

```bash
export BASE_URL=https://your-app.example.com
```

## Run

```bash
npm test            # all browsers, headless
npm run test:headed # headed
npm run test:ui     # interactive UI mode
npm run report      # open last HTML report
npm run codegen     # record a new test
```

## Structure

```
pages/        Page objects (BasePage + one per page)
tests/        Spec files
test-cases/   Gherkin test cases generated from the Confluence Functional Specs
plans/        One HTML plan per task (required — see CLAUDE.md)
.cloudbees/   CI workflow (runs on push to main/master)
```

## Writing a test

Add a page object under `pages/` extending `BasePage`, then drive it from a spec in `tests/`. See `pages/hub24/ExamplePage.ts` and `tests/UI/home.spec.ts` for the pattern.

## Visual regression (Chromatic)

Visual tests live in `tests/visual.spec.ts` and import `test`/`expect` from
`@chromatic-com/playwright`, which auto-archives each page. Run them, then
publish the archives to Chromatic for cross-browser visual diffing.

```bash
export CHROMATIC_PROJECT_TOKEN=<your-token>   # from chromatic.com project settings
npm run test:visual    # generate archives
npm run chromatic      # upload + diff
```

Config lives in `chromatic.config.json`. In CI, add `CHROMATIC_PROJECT_TOKEN` as a
CloudBees secret (Configurations → Properties) and add a step to
`.cloudbees/workflows/test.yaml` that runs `npm run test:visual` + `npm run chromatic`.
Visual runs are manual-only today (see commit `eff04f3`).

## BDD / Cucumber (playwright-bdd)

Write scenarios in Gherkin (`features/*.feature`), implement steps in
`steps/*.ts` (reusing the page objects), and run them through the Playwright
runner via [playwright-bdd](https://vitalets.github.io/playwright-bdd/).

```
features/   .feature files (Gherkin)
steps/      step definitions -> call page objects
```

Run:

```bash
npm run bddgen     # generate Playwright specs into .features-gen/ from features + steps
npm run bdd        # bddgen + run the "bdd" project 
```

`bddgen` runs automatically as part of `npm run bdd`. The generated `.features-gen/`
folder is git-ignored. Step text in `.feature` files must match the `Given/When/Then`
patterns in `steps/` or playwright-bdd reports the step as undefined.

> Note: `playwright-bdd` bundles the `@cucumber/*` Gherkin parser it needs, so a
> separate `@cucumber/cucumber` dependency is not required for this setup.

## CI on Cloudbees (Jenkins)

The `Jenkinsfile` runs the suite in the official Playwright Docker image
(browsers pre-installed) and publishes JUnit results + the HTML report.

One-time Cloudbees setup:

- Credential `hub24-login` (Username with password) → exposed to tests as
  `TEST_USER` / `TEST_PASSWORD`.
- (optional) Credential `chromatic-project-token` for visual uploads.
- Set the `BASE_URL` build parameter to the HUB24 environment.

Pick the suite to run via the `TEST_COMMAND` build parameter
(`npm run test:e2e` by default). Results appear in the build's Tests tab;
the HTML report + traces are archived as artifacts.

> Keep the Playwright image tag in the `Jenkinsfile` in sync with the
> `@playwright/test` version in `package.json`.

## API testing (Playwright request)

API tests live in `tests/api/` and use Playwright's built-in `request` API —
no browser needed. They call endpoints and assert status codes, headers and
JSON bodies. Point them at the HUB24 API via `API_URL`.

```bash
API_URL=https://api.uat.hub24.example npm run test:api
```

The sample `tests/api/example.api.spec.ts` runs offline against a tiny in-memory
server; replace it with real HUB24 endpoints (a commented real-usage example is
included in that file). Optional contract testing (Pact) / Postman can be added
later if data-sovereignty permissions allow.

<!-- CI test: verifying Jenkins Poll SCM auto-build trigger. -->


## Cloud testing on BrowserStack

Run the Playwright suite on BrowserStack's real cloud browsers/devices via the
BrowserStack SDK. Config lives in `browserstack.yml` (platforms, reporting).

```bash
npm install -D browserstack-node-sdk@latest   # one-time
# set credentials (never commit them):
#   BROWSERSTACK_USERNAME / BROWSERSTACK_ACCESS_KEY  (from browserstack.com)
npm run test:browserstack
```

Results appear on the BrowserStack Automate dashboard. Edit the `platforms`
list in `browserstack.yml` to change which browsers/OS are covered. Set
`browserstackLocal: true` only when testing an internal/private URL.
