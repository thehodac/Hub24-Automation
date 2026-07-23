# HUB24 — project info

> Read this whole folder before working on HUB24. Secrets live in `.env`.

## 1. Overview
- **Project / client:** HUB24
- **Status:** active (framework proven on a SauceDemo demo; HUB24 app tests pending an environment)
- **Contacts:** BA: … · Dev lead: … · QC lead: Thong Ho

## 2. Work tool (ticket destination)
- [x] **Jira** — project key: `NIT` · parent (Epic/Story): `NIT-6655`
- [ ] Asana — (code ready; enable per need)
- [ ] Azure DevOps
- [ ] Basecamp
> Bamboo is required by HUB24 docs for CI — see section 5.

## 3. App under test
- **BASE_URL (test/UAT):** NOT set yet — currently `https://playwright.dev` placeholder. **Blocker.**
- **API_URL:** —
- **Test account:** to be stored in `.env` as `TEST_USER` / `TEST_PASSWORD` (once the env exists)
- **Login flow notes:** `tests/auth.setup.ts` is still a template (`TODO(HUB24)`); real HUB24 login + page objects not built yet.

## 4. Functional Spec (source of Acceptance Criteria)
- **Confluence:** space `PN1` (Functional Specs) — 18 features, ~384 Gherkin scenarios.
- Test cases generated from these live in `test-cases/` (`app-header/`, `workspace/`, `main-page-workspace/`).

## 5. Repo & CI
- **Repo / branch:** `thong-maker/Hub24-Automation` · `master`
- **CI:** CloudBees (`.cloudbees/workflows/test.yaml`) + GitHub Actions (`.github/workflows/test.yml`). **Bamboo required by HUB24 docs** (`bamboo-specs/bamboo.yml`) — needs a Bamboo server + access.
- **Chromatic project:** configured (`chromatic.config.json`); token in `.env`.
- **BrowserStack:** `playwright.bs.config.ts` + `browserstack.yml` (Windows Chrome, macOS WebKit, Windows Firefox).

## 6. Test cases
- **Location (repo):** `test-cases/` (`.feature` + `.json`, source of truth).
- **Published to:** Confluence / Asana (publish step — token + allow-listing pending).

## 7. Conventions / notes
- Demo suite (`tests/e2e/saucedemo-*`, `pages/saucedemo/`) is demo-only — not HUB24 work.
- Selectors: prefer `data-test` / role-based; page objects under `pages/hub24/`.
- Real HUB24 e2e/UI/regression are blocked until the HUB24 test env (BASE_URL + credentials) is provided.
