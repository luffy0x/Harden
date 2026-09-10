# UI Polish Checklist

> Benchmark: Apple / Linear / Vercel class detail quality. Each item notes how to verify: **[eye]** screenshot inspection / **[measure]** read computed styles or DOM / **[act]** interact and observe.
>
> Project-detected tokens and rules always override the generic numbers below. The numbers are the fallback standard when the project defines nothing.

## 1. Typography

- [ ] Restrained type scale: at most ~7 distinct sizes site-wide, with coherent ratios (1.2–1.33 between steps). [measure]
- [ ] Weight hierarchy: display/label/body roles are distinct; 700 is not sprayed everywhere; large display type may sit at 600–650. [measure]
- [ ] Line height: body 1.5–1.7; headings tightened to 1.1–1.3; no long paragraphs stuck at a browser default. [measure]
- [ ] Tracking: slight negative tracking (≈ -0.02em) on large display sizes; body untouched. [measure]
- [ ] Long-form line length capped (≈ 65–75ch); text never stretches full-width on ultrawide screens. [measure]
- [ ] Mixed CJK/Latin text: natural spacing around numbers and Latin words; punctuation does not hang or misalign. [eye]
- [ ] Numeric data (counters, prices, timestamps) uses tabular figures so columns do not jitter. [measure]
- [ ] Truncation strategy: overlong text ellipsizes or wraps by design, never overflows its container. [eye]
- [ ] No webfont FOUT/layout shift; if the project forbids remote fonts, confirm none are requested. [measure]

## 2. Spacing & Grid

- [ ] All margin/padding values land on the project's spacing tokens (commonly a 4px-base scale: 4/8/12/16/24/32/48); no one-off values like 13px or 17px. [measure]
- [ ] Sibling lists/cards have exactly equal gaps; related elements sit closer together than unrelated ones (proximity principle). [eye]
- [ ] In-component padding feels intentional: text blocks often want slightly less vertical than horizontal padding, or token-consistent groups. [eye]
- [ ] Page-level rhythm: breathing room between sections is consistent; nothing suddenly cramped or suddenly empty. [eye]
- [ ] Edge alignment: left edges of headings, right edges of buttons, and content boundaries across sections share axes. [eye]

## 3. Color & Contrast

- [ ] Body text on background ≥ 4.5:1; muted text ≥ 4.5:1 (or ≥ 3:1 for large text). [measure]
- [ ] Accent discipline: the primary accent appears a countable number of times per screen; semantic colors (red = error, green = success) are not reused as decoration. [eye]
- [ ] State is never conveyed by color alone: shape, icon, or text changes accompany it. [eye]
- [ ] Every theme (light/dark/others) passes this entire checklist independently; theme switching causes no flash and no unstyled hard-coded color. [eye][act]
- [ ] Borders and dividers have restrained, layered luminance — present but never harsh. [eye]

## 4. Interaction & Accessibility

- [ ] Every pointer target ≥ 44×44px including icon-only buttons; use transparent hit-area expansion where visual size must stay small. [measure]
- [ ] Keyboard Tab order matches visual order; no lost focus, no focus traps outside modals. [act]
- [ ] Focus ring is visible and speaks the design language (not a naked browser-default outline, and never `outline: none` without a replacement). [eye][act]
- [ ] Hover feedback is clear but quiet: subtle background/border/luminance shifts, not translation or heavy shadow. [act]
- [ ] Pressed/active state exists (e.g. scale ~0.97 or luminance dip). [act]
- [ ] Disabled state stays legible, not just faded to unreadable. [eye]
- [ ] Images and icons carry alt or aria-label; purely decorative elements are aria-hidden. [measure]
- [ ] Touch: no feature is discoverable only via hover; no 300ms tap delay. [act]

## 5. Motion

- [ ] Durations: micro-interactions 150–250ms; panel/page transitions 250–400ms; nothing drags past 500ms. [measure]
- [ ] Easing: ease-out family for entrances/exits (e.g. cubic-bezier(0.16,1,0.3,1)); no bounce, no linear. [measure]
- [ ] No `transition: all` — transition properties are listed explicitly. [measure]
- [ ] Layout properties (width/height/top/left) are not animated; use transform/opacity. [measure]
- [ ] `prefers-reduced-motion` degrades or skips animation while preserving the final state. [measure]
- [ ] Non-essential looping animations pause when the document is hidden. [measure]
- [ ] Scroll-triggered motion never blocks or fights the scroll. [act]

## 6. Component States

- [ ] Loading: skeleton or spinner instead of blank flashes; appear only after ~300ms to avoid flicker. [act]
- [ ] Empty: an illustration or explanation plus a clear next action, not a bare "No data". [eye]
- [ ] Error: messages speak plainly and offer recovery; form errors anchor to the field. [eye][act]
- [ ] Success: actions confirm with feedback (toast or state change). [act]
- [ ] Extreme content: the layout survives an overlong title, zero items, and a hundred items. [eye][measure]

## 7. Responsive

- [ ] Audit every detected test breakpoint (fallback: 375 / 768 / 1024 / 1440px); no horizontal scrollbar at any of them. [eye][measure]
- [ ] Layout does not collapse or overlap at breakpoint boundaries (e.g. 767px vs 769px). [eye]
- [ ] Mobile: nav reachable, body text ≥ 14px, comfortable line length. Desktop: content never stretches unreadably wide. [eye]
- [ ] Notch/home-indicator safe areas handled with `env(safe-area-inset-*)`. [measure]
- [ ] Landscape / short viewports (e.g. 812×375) keep key actions reachable. [eye]

## 8. Fit & Finish

- [ ] Icons come from one family with consistent stroke weight and optically aligned sizes (identical px values are not enough). [eye]
- [ ] Corner radii are consistent per level; nested containers use outer radius > inner radius. [eye]
- [ ] Depth follows the project's strategy (luminance steps, restrained shadows, etc.) rather than ad-hoc shadows. [measure]
- [ ] Dividers: 1px, low contrast, and only where whitespace alone cannot separate. [eye]
- [ ] Images/avatars: failure fallback exists; aspect ratios enforced with `aspect-ratio`, never stretched. [eye]
- [ ] Cursors: pointer on clickable, text in inputs, grab/grabbing on draggables. [act]
- [ ] `::selection` styling coordinates with the theme. [eye]
- [ ] Scrollbars: custom scrollbars stay quiet; overflow appears only where expected. [eye]

## 9. Consistency

- [ ] Same-kind components look identical across pages: buttons, inputs, cards, tags. [eye]
- [ ] Copy: consistent voice, consistent punctuation conventions (no mixed full/half-width), consistent capitalization rules. [eye]
- [ ] A component keeps identical structure and spacing across themes; only colors change. [eye]
