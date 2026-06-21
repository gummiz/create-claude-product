# Interfaces & Contracts

> The seams where parts of the system meet. Contracts change carefully — they break callers.
> Framework-neutral: describe the contract, link to the canonical definition.

## Public / external interfaces
<!-- APIs, webhooks, CLIs, or UIs that outside parties depend on. These are the hardest to change. -->
| Interface | Consumers | Canonical definition | Versioning policy |
|---|---|---|---|
| TODO | TODO | TODO | TODO |

## Internal contracts
<!-- Module boundaries, shared types, events, message schemas. -->
- TODO

## Data contracts
<!-- Schemas, DB tables, event payloads. Where the schema lives and how it's validated. -->
- TODO

## Compatibility rules
<!-- What counts as a breaking change here? How do we deprecate? -->
- Backward-compatible: TODO
- Breaking (requires version bump + migration): TODO

## Error & response conventions
<!-- Standard error shape, status codes, pagination, idempotency. Uniformity matters. -->
- TODO
