# Steering: AI-DLC method

This file is loaded by the agent on every bolt. It is the persistent context
that survives session boundaries. Edit it deliberately — it is a governance
artifact, not scratch space.

## Vocabulary

| AI-DLC term  | Traditional equivalent | Meaning here                                  |
| ------------ | ---------------------- | --------------------------------------------- |
| Intent       | Business goal          | One line. "Customers can log in with SSO."    |
| Unit of Work | Epic                   | Self-contained deliverable from an Intent.    |
| Bolt         | Sprint                 | One iteration. Hours or days, never weeks.    |
| Mob Elaboration | Backlog grooming    | Team answers the AI's clarifying questions.   |
| Mob Construction | Pairing            | Team steers the AI at checkpoints during build.|

## Phase gates

**Inception → Construction** requires, in `.aidlc/inception/`:
- `intent.md` — the one-line intent plus accepted clarifications
- `units.md` — decomposed Units of Work, each independently testable
- `nfr.md` — non-functional requirements (see `10-nfr-guardrails.md`)
- a human sign-off line at the bottom of each, with a name and date

**Construction → Operations** requires, in `.aidlc/construction/`:
- `design.md` — domain model and logical architecture
- test coverage for every Unit marked complete
- no `TODO` or `FIXME` in code paths marked done

The agent MUST refuse to advance a phase whose gate is unmet, and MUST say
which specific artifact is missing.

## Human validation points

The AI proposes; the human disposes. At minimum, a human validates:
1. The clarifying questions themselves (are we solving the right problem?)
2. The Unit decomposition (is the slicing sane?)
3. The domain model, before any code is generated
4. Every dependency addition
5. Anything touching auth, secrets, data retention, or external egress

## What "done" means for a bolt

A bolt is done when the Unit's tests pass, the bolt log has an entry, and a
human has looked at the diff. Not when the agent says it is done.
