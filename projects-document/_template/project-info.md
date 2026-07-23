# <PROJECT NAME> — project info

> Read this whole folder (`projects-document/<project>/`) before working on the project.
> Never put secrets/tokens here — those live in `.env`. This file only *names*
> which vars a project uses.

## 1. Overview
- **Project / client:**
- **Status:** active | on hold
- **Contacts:** BA: … · Dev lead: … · QC lead: …

## 2. Work tool (ticket destination)
Which tool does this project use for bugs/tasks? (may be more than one)
- [ ] **Jira** — project key: `…` · parent (Epic/Story): `…`
- [ ] **Asana** — project GID: `…` · section GID: `…`
- [ ] **Azure DevOps** — org: `…` · project: `…`
- [ ] **Basecamp** — account: `…` · project: `…` · todolist: `…`
> Tokens go in `.env` (`*_CREATE_TICKETS=true` + creds). See `docs/ticket-destination-setup.html`.

## 3. App under test
- **BASE_URL (test/UAT):**
- **API_URL:**
- **Test account:** stored in `.env` as `TEST_USER` / `TEST_PASSWORD` (do NOT write the values here)
- **Login flow notes:**

## 4. Functional Spec (source of Acceptance Criteria)
- **Confluence space / pages:**
- **or file path(s):**
> The spec is the single source of the AC — link it, don't duplicate it.

## 5. Repo & CI
- **Repo / branch:**
- **CI:** CloudBees | GitHub Actions | Bamboo
- **Chromatic project:**
- **BrowserStack:** platforms / `browserstack.yml` notes

## 6. Test cases
- **Location (repo):** `test-cases/…`
- **Published to:** Confluence page / Asana / …

## 7. Conventions / notes
- (anything project-specific: selectors, data, quirks, do/don't)
