# Frontend Project Rules

## Architecture

- Do not create ad-hoc request wrappers or raw fetch calls.
- All API requests must go through @/utils/request unless the project explicitly defines another client.
- Do not hand-roll debounce or throttle logic. Use existing project hooks or ahooks, such as useDebounce.

## State and UI Separation

- Keep JSX focused on rendering.
- If a component grows beyond roughly 100 lines or contains complex useState, useEffect, derived state, or side effects, extract the logic into a dedicated useXxx custom hook.
- Custom hooks should contain state, effects, data loading, event orchestration, and derived logic.
- Components should primarily compose hooks and render UI.

## Styling

- Do not use inline styles unless there is a strong technical reason.
- Do not add traditional .css files unless the project already uses them for that module.
- Use Tailwind CSS as the default styling system.
- Use theme tokens defined in tailwind.config.js instead of hard-coded colors.
- Prefer classes such as text-primary-500 over arbitrary color values.

## Auth and Token Safety

- Do not read tokens directly inside React components.
- Do not call localStorage.getItem('token'), sessionStorage.getItem('token'), or similar token reads from UI components.
- Authentication state must come from the approved global store, auth provider, or useAuth hook.
- Do not expose tokens in logs, errors, snapshots, or UI state.
