---
name: ui-polish
description: "Apple-grade detail polish and experience audit for prototype UI pages that already look acceptable but need to feel first-class. Use when users ask 打磨细节/优化体验/设计走查/设计评审/对标Apple/提升质感/polish UI/design audit/UX review, or when a quickly-built frontend page needs refinement before shipping. Audits typography, spacing, color contrast, interaction, motion, component states, responsive behavior, and dual-theme consistency against the project's own design tokens; produces a prioritized evidence-backed issue list, then fixes and verifies. Not for building new UI from scratch (use a design skill), not for debugging broken behavior (use a debugging skill). Triggers: 打磨, 抛光, 细节优化, 体验优化, 设计走查, 走查, 设计评审, 对标Apple, 质感, 粗糙, 不够精致, polish, design audit, UI review, UX review, fit and finish Intent: prototype page refinement, detail-level UI quality audit, pre-ship experience pass"
---

# UI Polish: Prototype to First-Class

Prefix your first line with 🥷 inline, not as its own paragraph.

You are not redesigning. The user is broadly happy with the page; your job is to bring every pixel, transition, breakpoint, and state up to the standard of a company that sweats details (Apple, Linear, Vercel). The target feeling is "can't say what's better, but everything is right."

## Outcome Contract

- Outcome: an evidence-backed audit report, then verified fixes for the approved findings.
- Done when: every fixed item has been re-checked in the affected viewport and theme, and the project's own checks (lint / typecheck / layout tests) still pass.
- Evidence: screenshots or computed-style values per finding, not opinions from memory.
- Output: a P0/P1/P2 report first; fixes only after user approval (or immediately if the user said "just fix everything").

## Two Iron Rules

1. **Audit before edit.** Never polish from memory or from reading code alone. Produce a report where every finding carries evidence: viewport, theme, and a screenshot or computed value.
2. **The project's own design system is the highest law.** Detected tokens, scales, and explicit forbids override every generic standard in this skill. When a fix would conflict with the project's design system, stop and surface the conflict instead of deciding unilaterally.

## Phase 0: Detect Project Context (once, before auditing)

Run this detection pass and write down what you found. Generic standards apply only where detection finds nothing.

- **Design system docs**: look for `design-system/`, `DESIGN.md`, `docs/design*`, `STYLEGUIDE*`, design sections in README/AGENTS/CLAUDE files. If found, read fully. Page-level overrides may only narrow master rules.
- **Tokens**: read `tailwind.config.*`, CSS custom properties in global stylesheets, `theme.*` files. Record the spacing scale, color palette, radius tokens, and type scale actually in use.
- **Dev server**: from `package.json` scripts (`dev`/`start`), Makefile, or README. Reuse a running server if one responds.
- **Verification commands**: `lint`, `typecheck`/`tsc`, `test`, `test:e2e` from package scripts or CI config. You will need them in the Fix phase.
- **Test breakpoints**: from existing e2e/viewport tests or design docs. Default when nothing is found: 375 / 768 / 1024 / 1440 px.
- **Theme modes**: look for `next-themes`, `data-theme`, `.dark` selectors, media `prefers-color-scheme`. If the site has both light and dark, audit both.
- **Forbidden patterns**: many design systems list explicit don'ts (e.g. no remote fonts, no backdrop blur, no gradient text). Record and obey them.

## Phase 1: Audit

Start the dev server, open the page in a browser automation tool, and walk the full checklist in [references/checklist.md](references/checklist.md) at every detected breakpoint, in every theme. Read the checklist file before starting. A Chinese translation is available at [references/checklist.zh-CN.md](references/checklist.zh-CN.md) — use it when the user works in Chinese.

Coverage order: typography, spacing, color/contrast, interaction/a11y, motion, component states, responsive, fit & finish, consistency. Do not skip "boring" states: empty, loading, error, disabled, extreme content lengths.

Note what is already good, not only what is broken. The report should give the user certainty about which areas need nothing.

## Phase 2: Report

Produce a prioritized list. Every item must carry evidence.

```markdown
## Audit Report — <page> <date>

### P0 (broken experience / violates a hard project rule)
- [ ] Bottom sheet is clipped by the iOS home indicator at 375px
      Evidence: screenshot <ref>; computed `padding-bottom: 0`, no `env(safe-area-inset-bottom)`
      Location: src/components/Sheet.tsx:88
      Suggestion: `pb-[max(16px,env(safe-area-inset-bottom))]`

### P1 (visibly rough)
...

### P2 (only visible side by side)
...

### Verified clean (no action needed)
- ...
```

Priority definitions: P0 = function impaired or a hard design-system rule violated; P1 = rough at a glance; P2 = visible only in direct comparison.

Items that require a direction change (palette, typeface, navigation structure, new decorative elements) go in a separate "Directional suggestions — needs your decision" section. Never just do them.

## Phase 3: Fix

- Work P0 → P1 → P2 after the user approves. If the user already said "fix all", do not wait.
- Change details only. Do not touch information architecture or the approved visual direction.
- Match existing code style: naming, comment density, utility-class conventions.
- Use tokens and semantic variables, not magic values. If a needed value has no token, say so and propose one instead of scattering raw numbers.
- Every change must hold in all detected themes.

## Phase 4: Verify

- Re-screenshot every fixed item in the viewport and theme where it was found; tick the checklist items off.
- Run the project's detected checks (lint, typecheck, layout/e2e tests). All must pass; if a check was already failing before your changes, say so explicitly rather than claiming it.
- Close with a before/after summary the user can skim in 30 seconds.

## Boundaries

- No silent redesign: palette direction, typeface choice, nav structure, and decorative additions are user decisions.
- Do not break existing tests or the build.
- Do not manufacture findings to seem thorough; a short report with strong evidence beats a long speculative one.

## Related skills

Building a new page or a new visual direction from scratch is upstream of this skill and belongs to a design skill (e.g. `design` / `frontend-design`). Debugging broken behavior belongs to a debugging skill (e.g. `hunt`). This skill owns the space in between: the page works, the direction is approved, and the details need to be world-class.
