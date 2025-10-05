# ADR-0001: Submodules vs Links-Only

## Context
We need a meta-repo to provide a single pane of glass without moving code.

## Decision
Use Git submodules under `modules/` to reference service repos.

## Consequences
- Pros: Discoverability, fixed SHAs possible.
- Cons: Some devs dislike submodule UX.
