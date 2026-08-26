# aidlc-operations

AI-DLC Operations phase — deployment and telemetry. Holds the only deploy
credential in the set. Compose with `aidlc-common`.

## Usage

```sh
sbx run --name operations --kit ./aidlc-common --kit ./aidlc-operations claude .
```

## Before you use this beyond a trial

`registry-1.docker.io` / `auth.docker.io` are placeholder values — replace
with your organization's registry mirror. This can't be a kit `args:`
parameter yet; see the repo README's "Known limits" for why.

## What it denies

`registry.npmjs.org`, `pypi.org`, `files.pythonhosted.org` — deploy time is
not install time.

## Cleanup

No host-side state. `sbx rm` the sandbox when done.
