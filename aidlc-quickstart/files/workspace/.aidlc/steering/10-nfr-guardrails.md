# Steering: non-functional requirements and guardrails

AI-DLC treats NFRs as first-class Inception artifacts rather than as
late-stage review findings. Every Unit of Work inherits these unless its
`nfr.md` explicitly and deliberately overrides one.

## Supply chain

- Base images come from the organization's hardened catalog. If a Dockerfile
  needs a base image not in that catalog, stop and ask.
- No dependency is added without a human approving it in the same bolt.
- Lockfiles are committed. A build that regenerates a lockfile silently is a
  defect, not a convenience.

## Secrets

- No credential is ever written to a file in the workspace, a log, a test
  fixture, or a comment.
- The sandbox holds sentinels, not secrets. If a value looks like a real key,
  that is a finding — report it rather than using it.
- Configuration reads secrets from the environment at runtime. Never at build
  time, never baked into an image layer.

## Egress

- The kit declares the full allowlist. If a Unit needs a domain that is not
  allowed, that is an architecture conversation, not a policy exception.
- A network denial in the proxy log is evidence, not noise. Surface it.

## Testability

- Every Unit ships with tests written before or alongside the implementation.
- Tests that assert on generated output must assert on behavior, not on the
  exact text the model produced.

## Traceability

Every artifact under `.aidlc/` is committed to git. The question a regulator
or an incident reviewer will ask is "what did the agent do, and who approved
it?" — the answer lives in the commit history plus `~/.aidlc/bolts/*.jsonl`,
not in anyone's memory of the session.

## Known limits of this kit — state these honestly

- The network allowlist is a strong default, not an unbreakable control. A
  developer can widen it with `sbx policy allow`.
- Workspace-level MCP configuration can override what this kit installs.
- The bolt log records what the agent was *asked* to do. It is not an
  attestation that the artifact was produced by this agent in this sandbox.
