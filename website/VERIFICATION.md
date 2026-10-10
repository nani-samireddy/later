# Website verification — 10 October 2026

## Build and isolation

- `npm ci --offline --cache /private/tmp/later-website-npm`: clean locked installation succeeded; npm reported no known vulnerabilities in the installed dependency tree.
- `npm run build`: TypeScript check and Vite production build succeeded. Generated landing, privacy, and terms HTML entry points, self-hosted font assets, favicon, font license notices, and `.nojekyll`.
- Production JS approximately 380 kB / 121 kB gzip; CSS approximately 29 kB / 7 kB gzip. Optional model files and app attachments are not website assets.
- Publication shell simulated against a temporary local bare Git repository: initial `gh-pages` creation, updated build, and unchanged build all succeeded; exactly two commits remained, and legal HTML plus `.nojekyll` were preserved. No GitHub remote was contacted by this simulation.
- Workflow YAML parsed with Ruby's YAML parser. Every embedded shell step passed `bash -n`. Pinned checkout/setup-node/upload-artifact/download-artifact refs were resolved against their official GitHub repositories.
- Only `website/**` and `.github/workflows/deploy-website.yml` were created/modified by this task. Existing app work was preserved. No manual commit/push/deployment or hosting settings mutation occurred.

## Browser checks

Used the production Vite preview in the Codex browser at `http://127.0.0.1:4173/later/`.

| Viewport              | Result                                                                                                                                                  |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1280 × 720 desktop    | Hero, layered phone mockup, three feature cards, capture controls, and legal layout visually inspected. Document width matched viewport.                |
| 768 × 1024 tablet     | Hero layout and spacing inspected. Document width 768 px; no horizontal page overflow.                                                                  |
| 390 × 844 phone       | Hero, stacked features, capture panel, download/footer, and both legal pages inspected. Document width 390 px after fixing a decorative orbit overflow. |
| 320 × 740 small phone | Heading wraps and navigation inspected. Document width 320 px; no horizontal page overflow.                                                             |

- Capture tabs: clicking Say it changed the panel to the voice explanation; ArrowRight moved focus/selection to Capture it and changed the panel to local photo/OCR explanation.
- Legal navigation: footer links open `/later/privacy-policy/` and `/later/terms-and-conditions/`; document titles correct; 10 privacy sections and 8 terms sections present. Both pages survived reload. Privacy table-of-contents link produced `#section-6`; legal header Features link returned to `/later/#features`.
- Motion: Reduce motion control sets `aria-pressed=true` and the same shared reduced state used for system preferences. Verified rendered reveal opacity 1, cursor `animation-name: none`, and document `scroll-behavior: auto`. Source also uses Framer Motion `reducedMotion` and `useReducedMotion` to honor the operating system. The browser interface did not expose an OS media-emulation control; the shared manual path was exercised, and the system hook/media rules were inspected.
- Browser error/warning log check returned an empty array after landing/legal interaction.
- Android and iOS display Coming soon, with no actionable download link or fake store availability.

Screenshots in ignored `.verification/`: `desktop-hero.jpg`, `desktop-features.jpg`, `desktop-privacy.jpg`, `mobile-hero.jpg`, `mobile-features.jpg`, `mobile-capture.jpg`, `mobile-download.jpg`, `mobile-privacy.jpg`, and `mobile-terms.jpg`. Screenshots are local verification artifacts, not source for the gh-pages branch.

## Deployment boundary

The workflow's remote branch publication and explicit Pages build request were not executed: that would publish externally, and the task expressly prohibited manual pushes. The current primary REST docs support the installation-token / Pages-write request used here; confirm its acceptance and the separate Pages deployment result on the first owner-triggered workflow run. See README for exact Pages settings, first-run behavior, and a narrowly scoped optional token fallback if repository policy returns 403. An unauthenticated Pages API 404 could not confirm the current repository configuration.
