---
name: ui-implementation
description: Use when building or changing user-facing UI — components, pages, layouts — to keep it consistent, accessible, and aligned with the design system.
---

# UI Implementation

Use this for any user-facing change. Framework-neutral: the principles hold whether it's React, Vue,
Svelte, server-rendered, or native.

## Inputs
- The spec/design intent, the existing component library / design tokens, and `quality-attributes.md` (a11y bar).

## Steps
1. **Reuse first.** Find existing components, tokens, and patterns before creating new ones. Match them.
2. **Structure:** keep state/logic separable from presentation per this project's convention. One responsibility per component.
3. **State coverage:** handle loading, empty, error, and success — not just the happy path. Design for the data being absent.
4. **Accessibility:** semantic markup, keyboard navigability, labels/roles, visible focus, sufficient contrast.
   Target the a11y level in `quality-attributes.md`.
5. **Responsive & resilient:** test the relevant breakpoints; don't break on long text, slow networks, or RTL if supported.
6. **Verify visually and in tests** where the project supports it; run `./scripts/verify.sh`.

## Outputs
- A UI change consistent with the design system, accessible by default, with all interaction states handled.

## Constraints
- Don't fork the design system or hardcode values that should be tokens.
- Don't ship a happy-path-only component. Empty/error/loading states are part of "done".
- Avoid adding a UI dependency without a decision in `docs/product/decisions.md`.
