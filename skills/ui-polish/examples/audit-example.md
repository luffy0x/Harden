# Audit Example — Knowledge Frontier (Next.js 16 + Tailwind CSS 4)

Real output from running this skill on a Chinese job-search knowledge base. All values are measured in-browser (computed styles / bounding boxes), not estimated. Contrast ratios computed mathematically from the OKLCH tokens (OKLCH → linear sRGB → WCAG 2.x formula).

**Context detected in Phase 0**: design tokens in `src/app/globals.css` (`--background`, `--primary`, spacing/radius vars); dual theme via `.dark` class + next-themes; test breakpoints 375/768/1024/1440; verification commands `pnpm lint` / `pnpm typecheck` / `pnpm test:e2e`; pages audited: home, category listing (with forced empty state), content detail, submission directory, submission form.

---

## Audit Report — home + shared shell, 2026-09-10

### P0 (broken experience / hard rule violation)

- [ ] **Global focus ring never renders.** `:focus-visible { outline: 2px solid var(--primary) }` is defined but has specificity 0-1-0 — Tailwind v4 preflight resets win on `a`/`button`. Computed outline on keyboard-focused nav link: `none 0px`.
      Evidence: `el.matches(":focus")` true after Tab, computed `outlineStyle: none`
      Location: `src/app/globals.css:117`
      Fix: `a:focus-visible, button:focus-visible, [tabindex]:focus-visible { ... }`

- [ ] **Mobile nav links collapse to 44×90px vertical strips.** At 375px the opened nav panel renders each link one character per line, 90px tall. Cause: `.mobile-nav__panel` is in normal flow inside a flex header, so its width is the trigger button's width (44px), not the header's.
      Evidence: bounding boxes `面经记录 44x90`, `学习资料 44x90`, ... ×5; panel total height 483px
      Location: `src/app/globals.css` `.mobile-nav__panel`
      Fix: `position: absolute; left: 0; right: 0; top: 100%` (offset parent is the sticky header) + `min-width: 0` on links

- [ ] **11px horizontal overflow at 375px on every page.** `scrollWidth - clientWidth = 11`. Source: `.site-header__inner` gap 10px + brand 175px + toggle 44px + submit 66px = 295px + 32px container margins > 328px container.
      Evidence: element scan → `.site-header__actions` right edge at x=371 (viewport 360)
      Location: `src/app/globals.css:335-352`
      Fix: gap 10px → 8px at ≤640px

### P1 (visibly rough)

- [ ] Header primary CTA ("投稿") has no `:hover` rule at all — the one primary action is inert.
- [ ] Interactive elements (theme toggle, nav links, card title links) have no explicit `transition` — hover color changes snap instantly.
- [ ] `.category-filters` keeps 18px card padding at 375px, cramped against the viewport edge. → 14px.
- [ ] Submission form: empty submit relies on browser-native bubbles but focus is not moved to the first invalid field. → `formEl.checkValidity()` guard + `formEl.querySelector(":invalid").focus()`.

### P2 (polish-level)

- [ ] Hero h1 `letter-spacing: -0.03em` at 48px — slightly aggressive for CJK-heavy text. → `-0.02em`.
- [ ] `.home-hero__actions { margin-top: 30px }` — the only non-token spacing value site-wide. → `32px`.

### Verified clean

- Contrast (mathematical, both themes): 5.11–16.98 across 10 fg/bg pairs, all ≥ WCAG AA 4.5:1
- Type scale restrained (13/14/16/17/20/28/48px), weights 400–700 with clear roles
- 768px and 1024px: zero horizontal overflow; category grid adapts 3→4 columns correctly
- All primary touch targets ≥ 44×44px; empty states include recovery actions; search dialog autofocuses and closes on Escape
- Motion: consistent `cubic-bezier(0.16,1,0.3,1)`, 120–160ms, `prefers-reduced-motion` global fallback present
- No remote fonts; single restrained `backdrop-filter` on sticky header

---

## After-fix verification (excerpt)

| Finding | Before | After |
|---|---|---|
| 375px horizontal overflow | 11px | 0px |
| Mobile nav link box | 44×90 (vertical text) | 328×48 |
| focus-visible rule in served CSS | absent from cascade | matches `a`, `button`, `[tabindex]` |

`pnpm lint`: 0 errors · `pnpm typecheck`: pass
