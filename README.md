# aidlc-sbx-kits

[Docker Sandboxes](https://docs.docker.com/ai/sandboxes/) kits that run
AWS's [AI-Driven Development Lifecycle](https://github.com/awslabs/aidlc-workflows)
(AI-DLC), in two shapes, each holding only the credentials and egress its
phase actually needs. Not scoped to any one customer or engagement — a
generally-applicable reference integration between the two projects.

```
aidlc-quickstart/       ALL phases, ONE sandbox — fast trial, no phase isolation
aidlc-common/           floor: steering files, bolt log, preflight, GitHub egress
aidlc-inception/        Mob Elaboration — documents only, registries denied
aidlc-construction/     Mob Construction — code, tests, package registries
aidlc-operations/       deploy + telemetry — the only write credential
```

Authored against `schemaVersion: "2"` and verified directly against a real
installed `sbx` binary (v0.39.0 at time of writing) — `sbx kit validate` and
a real `sbx run --kit ...` compose against the embedded `claude` agent kit
both pass clean for every combination below. See "Known limits" for what's
still not shipped or not enforced by the engine.

## Install

Remote kit sources are allowlisted by `sbx` — by default only `docker.io/`
is trusted. Allow this repo once, verified directly against a real `sbx`
binary (attempting the pull below without this step fails with `its source
is not in your allowlist`):

```sh
sbx settings set kit.allowedSources '["docker.io/","github.com/markmaxwell-Docker/"]'
```

Then each kit here is consumed directly from this repo, pinned to a tag —
verified live against the tags this repo actually publishes:

```sh
sbx run --kit "git+https://github.com/markmaxwell-Docker/aidlc-sbx-kits.git#ref=aidlc-quickstart-v0.2.0&dir=aidlc-quickstart" claude .
```

Or clone locally and reference by path — convenient for trying changes before pinning:

```sh
git clone https://github.com/markmaxwell-Docker/aidlc-sbx-kits.git
sbx run --kit ./aidlc-sbx-kits/aidlc-quickstart claude .
```

## Run it

**Fast trial — one kit, one sandbox, every phase:**
```sh
sbx run --kit ./aidlc-quickstart claude .
```

**Governed — phase isolation, least privilege, always exactly two mixins:**
```sh
sbx run --name inception    --kit ./aidlc-common --kit ./aidlc-inception    claude .
sbx run --name construction --kit ./aidlc-common --kit ./aidlc-construction claude .
sbx run --name operations   --kit ./aidlc-common --kit ./aidlc-operations   claude .
```

Same steering files, same method, same bolt log in both shapes. The `.aidlc/`
directory is how context moves forward between phases (or within the one
quickstart sandbox) — commit it.

## Why both exist

This isn't indecision between two competing designs — it's a deliberate
crawl-then-walk pair aimed at two different moments in an org's adoption
curve:

| | Quickstart | Governed (common + phase mixins) |
| --- | --- | --- |
| Setup | One kit, one command | Three `sbx run` invocations, mixin composition |
| Privilege | Everything, always | Least privilege, subtractive deny per phase |
| Fits | First trial, a demo, a short sprint | Anything regulated, production, real customer data |
| The pitch | "AI-DLC seamlessly, quicker" | "Governance around the agents" |

Ship the quickstart kit to try AI-DLC's loop fast. Move to the governed set
the moment a security reviewer enters the room, or the workload touches
anything real.

## The privilege matrix — the governed set's whole argument

| | Inception | Construction | Operations |
| --- | --- | --- | --- |
| Anthropic API | yes (via the `claude` agent kit) | yes | yes |
| GitHub | yes | yes | yes |
| npm / PyPI | **denied** | yes | **denied** |
| Registry push token | no | no | **yes** |
| Writes code | no | yes | no |
| Can deploy | no | no | yes |

Run all three, then `sbx exec <name> -- env | grep AIDLC_PHASE` and
`sbx policy log <name>`. The blast radius of a compromised Inception agent is
a markdown file.

The quickstart kit has none of these boundaries by design — don't let the two
shapes blur together.

## Why deny, not a narrower allow

`permissions.network.allow` **unions** across composed kits and cannot be
narrowed by a later kit — but `permissions.network.deny` wins over `allow`.
So `aidlc-common` carries only the floor every phase needs, phase kits add
what they need, and Inception/Operations use explicit `deny` to subtract the
package registries.

The honest limit: deny only covers domains you enumerate. A phase kit cannot
express "nothing except the floor." If your threat model needs that, split
the floor further rather than relying on subtraction.

## Per-domain credential schemes

`credentials[].apiKey.inject` is a **list**, and each entry gets its own
`domain` + `header`/`format` (or the `scheme: bearer` / `scheme: basic`
sugar) independently, not one auth style per service. `aidlc-common`'s
GitHub credential uses this directly: `api.github.com` and
`raw.githubusercontent.com` (REST API / raw content) get `scheme: bearer`,
while `github.com` (the HTTPS git clone/push apex — a different protocol
than the REST API) gets `scheme: basic` with `username: x-access-token` —
GitHub's own documented convention for token-authenticated git-over-HTTPS.

## Real, enforced constraints (verified against a live `sbx` binary)

- **`requires.agent: claude` is enforced at compose time.** Composing any of
  these kits onto a different base agent fails with `kit "<name>" requires
  base agent "<X>" but was composed with "<Y>"`.
- **A duplicate credential source across composed kits is a hard compose
  error.** The `claude` agent kit already owns the `anthropic` credential
  service — declaring it again fails with `credential for service
  "anthropic" defined in both "claude" and "<kit>"`. This is why
  `aidlc-common` only adds `github`, never `anthropic`.

## Known limits — state these honestly

1. Kits are experimental. The spec, the CLI, and the kit management
   experience are subject to change. **Pin every remote reference** — by
   tag (what this README's own examples use, since we own the tags on this
   repo and don't move them) or a 40-hex commit SHA for the strictest
   guarantee. This is a hard requirement, not a suggestion: CI's
   `lint-pinned-refs` job fails the build on any `git+https://` reference in
   a tracked markdown file that has no `#ref=` fragment at all — see
   [CONTRIBUTING.md](./CONTRIBUTING.md).
2. **`args:` (installer-supplied kit parameters) is documented in the kit
   spec but not shipped in any released `sbx` as of this writing** — probe-
   tested directly against v0.38.0 and v0.39.0, both reject it. That's why
   `registry-1.docker.io` / `auth.docker.io` in `aidlc-operations` and
   `aidlc-quickstart` are still a plain literal: replace them with your org's
   registry mirror before using either kit beyond a trial.
3. **All-egress-declared is a discipline, not an enforced check.** The spec
   says every `credentials[].apiKey.inject[].domain` MUST appear in
   `permissions.network.allow` — verified directly that neither `sbx kit
   validate` nor real sandbox composition actually rejects a spec that
   violates this. Get it right by review, not by tooling.
4. The network allowlist is a strong default, not an unbreakable control — a
   developer can widen it with `sbx policy allow`. Audit with `sbx policy log`.
5. Workspace-level MCP configuration can override what a kit installs.
6. `preflight.sh` runs with `|| true`. The phase gate is a loud signal to the
   agent and the operator, not a hard control. Real enforcement belongs in
   CI, where an unmet gate can fail a build.
7. The bolt log records intent, not attestation. It is not provenance.
8. **Single-agent scope.** These kits target `claude` only, enforced via
   `requires.agent`. AI-DLC's own steering-rule layer already supports other
   agents (Kiro, Cursor, Codex, ...); the sandbox-kit layer here doesn't
   duplicate that yet. A Kiro/Cursor/Codex variant is a plausible follow-on
   once there's a concrete need, not a v1 gap being hidden.

What the sandbox boundary genuinely enforces is the credential and egress
split, plus the two compose-time checks above. Those are not advisory.

## Versioning

Each kit is tagged independently, e.g. `aidlc-common-v0.4.0`, since they're
composed (and can be pinned) independently. See each kit's own header
comment for its current version and minimum required schema.

## Verifying changes

```sh
sbx kit validate ./aidlc-common && sbx kit inspect ./aidlc-common
sbx run --detached --name probe --kit ./aidlc-common --kit ./aidlc-inception claude <workspace>
sbx exec probe -- env | grep AIDLC_PHASE
sbx policy log probe
sbx rm -f probe
```

Run this for every real run configuration above, not just one — composing
cleanly with one phase mixin says nothing about the others. See
[CONTRIBUTING.md](./CONTRIBUTING.md) for the full contribution checklist and
what CI actually covers (schema validation) vs. what still needs a manual
compose smoke test before tagging a release.

## License

Apache-2.0. See [LICENSE](./LICENSE).
