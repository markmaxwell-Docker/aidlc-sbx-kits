# aidlc-construction

AI-DLC Construction phase — "Mob Construction." Domain model, code, tests.
Compose with `aidlc-common`.

## Usage

```sh
sbx run --name construction --kit ./aidlc-common --kit ./aidlc-construction claude .
```

## What it adds

Package-registry egress (`registry.npmjs.org`, `*.npmjs.org`, `pypi.org`,
`files.pythonhosted.org`) so approved installs work. No deploy credentials,
no production egress — that's Operations' job.

## Cleanup

No host-side state. `sbx rm` the sandbox when done.
