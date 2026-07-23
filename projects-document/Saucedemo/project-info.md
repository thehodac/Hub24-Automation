# Saucedemo — project info

> Read this whole folder before working on Saucedemo. Secrets live in `.env`.

## 1. Overview
- **Project / client:** Saucedemo (public demo app — used as the sample project)
- **Status:** active (demo / reference)
- **Contacts:** —

## 2. Work tool (ticket destination)
- [ ] Jira · [ ] Asana · [ ] Azure DevOps · [ ] Basecamp
> Not decided — public demo. Set in `.env` if auto-ticketing is needed.

## 3. App under test
- **BASE_URL:** https://www.saucedemo.com
- **API_URL:** —
- **Test account (public, well-known demo creds):** username `standard_user` (+ other users: `locked_out_user`, `problem_user`, `performance_glitch_user`, `error_user`, `visual_user`); password `secret_sauce`.
- **Login notes:** simple username/password form; no real auth / no secrets needed.

## 4. Functional Spec / test cases
- Source doc: `Saucedemo_TestCase.doc` (Confluence export) in this folder.
- **36 test cases across 5 modules:** Login (8), Inventory/Product List (10), Cart (6), Checkout (11), Navigation (3). Gherkin format (Scenario ID / Tags / Scenario / BDD steps).

## 5. Repo & CI
- Demo suite lives in the repo: `tests/e2e/saucedemo-*`, `pages/saucedemo/`.
- CI: same framework (CloudBees / GitHub Actions) — demo only.

## 6. Conventions / notes
- Public demo used to prove the framework end-to-end; not a client project.
- Known risks (from the test-case doc): `problem_user` (broken images/form bugs),
  `error_user` (action-specific errors), `visual_user` (needs Chromatic visual diff),
  TC_CHK_007 tax should be verified against the site's real tax rate.
