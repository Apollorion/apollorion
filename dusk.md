---
dusk: v1alpha1
namespace: stout
kind: repository
name: TheOutdoorProgrammer
title: Profile README
attributes:
  visibility: public
  role: profile-readme
---

The repository whose `README.md` renders on the GitHub profile page.
GitHub gives that slot to the repository named after the account, which is the only reason this one exists.
Nothing here is a library or a service, and somebody finding a `dusk.md` in it is looking at a profile page, not a project.

`README.md` is generated, not written.
`.github/workflows/update_readme.sh` rebuilds it in five passes: social badges, technology badges, an HCL "introduction" block, the latest BlueSky posts, then the link categories.
`update_readme.yaml` runs the script daily at midnight UTC, and on demand, committing the result with `git-auto-commit-action`.
Editing `README.md` by hand accomplishes nothing, because the next scheduled run overwrites it.
Change the script.

The content is not local either.
The script curls `_data/links.yml` and `_data/social.yml` from the `profile` repository, along with its `blog/_posts` listing, so the profile is a rendering of the website's data and a change there appears here on the next run.
The BlueSky block is the exception, coming straight from the public `app.bsky.feed.getAuthorFeed` API.
Everything else in the repository is static assets referenced by raw.githubusercontent.com URLs: logos, headshots, favicons, a resume and a CKA certificate.

## Gotchas

**Everything above the BlueSky block has been broken since April 2026.** `_data/links.yml` now 404s in the `profile` repository, which silently deletes every category-driven section (Projects, Blog Posts, Spacelift) because the loop over `.buttons` runs zero times instead of failing. `_data/social.yml` still exists but changed shape, from a list of `{name, url, icon}` objects to a plain `name: url` map: `yq '. | length'` still returns five, so the badge loop still runs five times and emits five badges captioned `null`, each carrying the base64 of Iconify's "Not found" response as its logo. Fixing it means reconciling the script with the current shape of those two files. Re-running the workflow will not help.

**The script's dependencies are assumed, not installed.** It needs `yq`, `jq`, `curl` and `base64`, and the workflow installs none of them, so it rests entirely on what the `ubuntu-latest` image happens to ship.
