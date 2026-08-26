# aidlc-inception

AI-DLC Inception phase — "Mob Elaboration." Turns business intent into Units
of Work and NFRs. Compose with `aidlc-common`.

## Usage

```sh
sbx run --name inception --kit ./aidlc-common --kit ./aidlc-inception claude .
```

## What it denies

`registry.npmjs.org`, `pypi.org`, `files.pythonhosted.org` — no package
registries. This phase produces documents, not code; it has no build
toolchain and no deploy credentials.

## Cleanup

No host-side state. `sbx rm` the sandbox when done.
