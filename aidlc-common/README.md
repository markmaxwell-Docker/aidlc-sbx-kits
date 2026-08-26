# aidlc-common

Shared AI-DLC floor. Pairs with the `claude` agent kit (`requires.agent:
claude`, enforced at compose time). Layer exactly one phase kit on top —
`aidlc-inception`, `aidlc-construction`, or `aidlc-operations` — or use
`aidlc-quickstart` alone for a single-sandbox trial.

## Usage

```sh
sbx run --name inception --kit ./aidlc-common --kit ./aidlc-inception claude .
```

(See the repo README for the full three-phase governed set.)

## What it provides

- Steering files under `files/workspace/.aidlc/steering/` — method
  vocabulary, phase gates, human validation points, and NFR guardrails.
  Loaded by the agent on every bolt.
- `~/.aidlc/bolt-log.sh` — append-only JSONL record of phase, intent,
  timestamp, and git SHA, written at the start of every bolt.
- `~/.aidlc/preflight.sh` — the phase-gate check phase kits call in their own
  `startup` command to verify the prior phase's artifacts exist.
- GitHub egress and credential, scoped to what installs/clones need — see
  the repo README's "Per-domain credential schemes" section for why
  `github.com` uses Basic auth while `api.github.com` uses Bearer.

## Why this doesn't declare an Anthropic credential

The `claude` agent kit this composes onto already owns the `anthropic`
credential service. Declaring it again here is a hard compose error, not
redundancy — verified directly against a real `sbx` binary. If you fork this
kit, don't add a `credentials:` entry for a service the base agent kit
already provides; check first.

## Cleanup

No host-side state. `sbx rm` the sandbox when done.
