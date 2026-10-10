# Later website

An isolated Vite + React + TypeScript frontend with Framer Motion. It does not change the Flutter app. The UI uses locally served Inter/Manrope fonts, Lucide icons, CSS illustrations, and an explicitly illustrative app mockup with sample records. Android and iOS are **Coming soon**: no store badge, fake download, waitlist, or release date.

## Local use

Requires Node 24 (at least 22.12).

```sh
cd website
npm ci
npm run dev
# http://127.0.0.1:5173/later/
npm run build
npm run preview -- --port 4173
# http://127.0.0.1:4173/later/
```

`BASE_PATH=/` can override the project prefix for a root-domain build. The production build defaults to `/later/`. CI derives the base from the repository name and uses `/` for an owner.github.io repository. Custom domains need an explicit root base and a reviewed domain configuration; none is assumed here.

The build emits real HTML entry points for `/later/`, `/later/privacy-policy/`, and `/later/terms-and-conditions/`. Direct requests and reloads work on GitHub Pages without a single-page-app rewrite or a custom 404 redirect. Legal heading anchors and links back to landing sections are ordinary URLs. Keyboard tabs support Left/Right/Home/End, and both the footer’s Reduce motion control and `prefers-reduced-motion` disable reveals, floating motion, the blinking cursor, and smooth scrolling.

## Branch-based GitHub Pages

`.github/workflows/deploy-website.yml` runs on website/workflow changes pushed to `main` (the inspected default branch) or manual dispatch on the default branch. If the default branch is renamed, update the push branch filter. The workflow uses SHA-pinned official GitHub actions, `npm ci`, a read-only build job, and a separate publication job with only `contents: write` and `pages: write`. Runs queue to avoid concurrent branch writes. Only `dist/` is copied to a separate `gh-pages` checkout; publication preserves history and does not force-push or rewrite the source branch. `.nojekyll` is included in the artifact.

After this change is committed/pushed by the owner:

1. Run **Actions → Deploy Later website → Run workflow** on `main`. The first run creates `gh-pages`; if Pages is not configured, the final step fails with setup instructions after saving the generated branch.
2. Open **Repository Settings → Pages → Build and deployment**.
3. Set **Source: Deploy from a branch**.
4. Choose **Branch: gh-pages**, **Folder: /(root)**, then **Save**.
5. Rerun the workflow. Inspect both **Deploy Later website** and GitHub's **pages build and deployment** for completion. The website URL should be `https://nani-samireddy.github.io/later/`.

The unauthenticated Pages API returned 404 during development; this does not distinguish unconfigured Pages from a private/inaccessible repository. Existing settings could not be confirmed. No settings were changed, and no commit, push, or live deployment was performed.

### Why request a build explicitly?

[GitHub's publishing-source documentation](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site) says that a push made with `GITHUB_TOKEN` does not automatically trigger a branch-based Pages build. Therefore this workflow explicitly calls `POST /repos/{owner}/{repo}/pages/builds` after publication. The [current REST documentation](https://docs.github.com/en/rest/pages/pages#request-a-github-pages-build) supports GitHub App installation access tokens and requires Pages write permission. The workflow grants that permission and verifies that the configured source is the generated branch before requesting the build. It does not deploy an artifact with `actions/deploy-pages` or switch the source to GitHub Actions.

This API path cannot be exercised locally without publishing authorization. Confirm it on the first repository workflow run; a successful branch push alone is not proof of a live deployment. If repository or organization policy rejects the automatic token for the explicit build endpoint (403), use a fine-grained owner token restricted to **this repository**, with **Pages: read and write** (Metadata read is implicit), stored as an Actions secret such as `PAGES_BUILD_TOKEN`, and change only the request-build step's `GH_TOKEN` to that secret. The branch push can still use `GITHUB_TOKEN`. No PAT or deploy key is required by the initial workflow, and no secret should be pasted into chat or committed. Branch rules must allow the publication identity to update `gh-pages`; do not disable unrelated protections.

## Copy and publishing information

App statements were checked against the current repository implementation: SQLite/Drift storage, private attachment copies, local notifications and permissions, camera/file intake, sherpa-onnx voice models, ML Kit payment OCR, optional local Qwen inference, repayment/currency tracking, archive/search, and compressed local backup/restore. Optional voice/AI downloads request files from Hugging Face; inference is local. Current optional local AI is unsupported on iOS. Backups are compressed, **not encrypted**, and restore replaces the existing records. OS backups and user-selected cloud folders are distinguished from app cloud sync.

The legal pages describe the pre-release implementation rather than certify a store submission. The publisher must supply their actual responsible person/entity and a dedicated privacy/support contact before store distribution, confirm jurisdiction-specific terms, and reconcile disclosures with the exact shipped SDKs/platform behavior. No company, address, analytics system, account, cloud backend, legal jurisdiction, or store availability was invented. The repository is offered as the existing public project route; users are told not to post sensitive records there.

Primary platform references used when drafting:

- [Google Play User Data policy](https://support.google.com/googleplay/android-developer/answer/10144311): privacy policy, developer/app identity, contact, access, use, retention, and deletion disclosures.
- [Apple App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/): distinction between local-only processing and off-device collection; review SDK behavior for the released build.
- [GitHub Privacy Statement](https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement): the website's host is separate from app record storage.

## Verification

Build/type-check, visual viewport checks, legal routes/navigation, capture tab interaction, keyboard behavior, and reduced-motion checks are recorded in `VERIFICATION.md`. Local screenshots are kept in ignored `.verification/` to avoid adding generated output to source control.
