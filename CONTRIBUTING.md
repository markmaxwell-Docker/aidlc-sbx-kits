# Contributing

Kits are experimental — the `sbx` kit spec, CLI, and management experience
are subject to change. This project has already been broken once by
trusting an unverified schema; see each kit's header comment history and
`aidlc-common/spec.yaml`'s comment for context. **Trust a live probe against
a real installed `sbx` binary over any document, including this one.**

## Before opening a PR

```sh
# Per-kit schema validation
sbx kit validate ./aidlc-common
sbx kit inspect ./aidlc-common

# Real compose smoke test — this is the one that actually matters.
# Per-kit validation cannot catch a cross-kit conflict (e.g. a duplicate
# credential source, or a requires.agent mismatch); only composing against
# the real embedded claude agent kit can.
mkdir -p /tmp/probe-ws && cd /tmp/probe-ws && git init -q
sbx run --detached --name probe --kit ./aidlc-common --kit ./aidlc-inception claude /tmp/probe-ws
sbx exec probe -- env | grep AIDLC_PHASE
sbx policy log probe
sbx rm -f probe
```

Run the compose smoke test for **every** real run configuration in the
README, not just one you touched — composing cleanly with one phase mixin
says nothing about the others.

## What CI actually checks (and what it doesn't)

CI (`.github/workflows/validate.yml`) runs `sbx kit validate` against every
kit on every PR, on a macOS runner (the `sbx` CLI installs via
`brew install docker/tap/sbx`). This catches schema errors per kit.

**CI does not run the real compose smoke test above.** That requires Docker
Desktop's sandboxing runtime, which isn't available on hosted GitHub Actions
runners as of this writing. Until that's wired up (self-hosted runner, or
whatever `sbx-kits-contrib`'s own e2e CI uses — worth checking directly
rather than assuming), **the compose smoke test is a manual, required step
before merging or tagging a release.** Don't treat a green CI check on a PR
as proof of successful composition — it isn't, yet. Say so plainly in review
rather than let it be assumed.

## Versioning and tagging

Each kit is tagged independently: `<kit-name>-v<semver>`, e.g.
`aidlc-common-v0.4.0`. Bump the version in the kit's own header comment
before tagging. A consumer may pin `aidlc-common` and `aidlc-construction`
at different points, so keep tags independent even when a PR touches
multiple kits.

## Per-kit README

Every kit ships a `README.md`: what it does, what agent it pairs with, the
`sbx run` invocation, and any non-obvious decisions in the spec (so the next
reviewer doesn't have to reverse-engineer the YAML).

## Network policy

`permissions.network.allow` is the complete outbound contract for a kit.
Every domain a credential injects into
(`credentials[].apiKey.inject[].domain`) should also appear here — the
engine does not enforce this cross-reference (see README "Known limits"),
so get it right by review.

## Compatibility review cadence

The `sbx` kit schema moves — it already has, once, inside this project's own
build window (see `aidlc-common`'s header comment history). All five kits
should be re-validated against the current `sbx` release **at least
quarterly**, not only when someone files an issue. If a kit hasn't been
re-verified within 90 days of a schema-breaking `sbx` release, mark it
`[unmaintained]` in its README until it has been.
