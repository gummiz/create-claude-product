---
name: api-design
description: Use when adding or changing an API, endpoint, or service contract — keep it consistent, versioned safely, and backward-compatible where it matters.
---

# API Design

Use this for any change to an interface others depend on (HTTP/RPC/CLI/library boundary). Contracts are
expensive to change — design them deliberately. Framework-neutral.

## Inputs
- The need, the existing API conventions, and `docs/architecture/interfaces.md` (contracts + compatibility rules).

## Steps
1. **Match existing conventions:** naming, resource shape, error format, status codes, pagination, auth, idempotency.
2. **Define the contract first:** request/response schema, validation, error cases. Write it down before coding.
3. **Compatibility:** is this additive (safe) or breaking? Breaking changes need versioning + a migration path per `interfaces.md`.
4. **Validate inputs at the boundary.** Never trust the caller. Fail with clear, consistent errors.
5. **Consider failure & scale:** timeouts, retries/idempotency, rate limits, partial failure. Note them in the spec.
6. **Document & test the contract.** Update `interfaces.md`; add tests that pin the contract.

## Outputs
- A consistent, validated, documented endpoint/contract with tests, and a clear compatibility classification.

## Constraints
- No silent breaking changes. If callers break, it's versioned and migrated — not shipped quietly.
- Don't leak internal models directly; shape responses intentionally.
- Keep error responses uniform with the rest of the API.
- New external surface area is a decision — record notable ones in `docs/product/decisions.md`.
