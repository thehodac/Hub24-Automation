# projects-document/ — per-project documentation

One folder per project. Everything the automation needs to work on a project
lives here, so that when you start on a project you (or Claude Code) just read
the whole `projects-document/<project>/` folder to get all the context.

## Convention

```
projects-document/
  _template/
    project-info.md      <- copy this for a new project and fill it in
  hub24/
    project-info.md      <- the key context (tool, URLs, spec links, CI, conventions)
    docs/                <- drop any extra docs here (specs, PDFs, designs, notes)
  <another-project>/
    project-info.md
    docs/
```

## How to use

- **Starting a new project:** copy `projects-document/_template/` to `projects-document/<project>/`
  and fill in `project-info.md`. Drop any specs/designs/notes into
  `projects-document/<project>/docs/`.
- **Working on a project:** read the **whole** `projects-document/<project>/` folder first
  (start with `project-info.md`) — it tells you the work tool (Jira/Asana/Azure
  DevOps/Basecamp), the app URL, the Functional Spec links, the CI, and any
  project-specific conventions.

## Important

- **Never put secrets/tokens here.** Tokens, passwords and PATs go in `.env`
  (gitignored). `project-info.md` only *names* which `.env` vars a project uses.
- The Functional Spec on Confluence is the single source of the acceptance
  criteria — link it here, don't duplicate it.
