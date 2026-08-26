# aidlc-quickstart

All three AI-DLC phases in one sandbox, zero setup. The fast-trial path, not
the governed one — no phase isolation, one shared credential and network
privilege set. Graduate to `aidlc-common` + the phase mixins for anything
regulated, production-bound, or touching real customer data.

## Usage

```sh
sbx run --kit ./aidlc-quickstart claude .
```

## Before you use this beyond a trial

`registry-1.docker.io` / `auth.docker.io` are placeholder values — replace
with your organization's registry mirror:

```sh
../scripts/set-registry.sh myregistry.example.com [auth.myregistry.example.com]
```

This can't be a kit `args:` parameter yet (see the repo README's "Known
limits"), so the script edits both the network allowlist and the credential
inject domain directly and re-validates the result. Safe to re-run if you
change your mind about the host later.

## Cleanup

No host-side state. `sbx rm` the sandbox when done.
