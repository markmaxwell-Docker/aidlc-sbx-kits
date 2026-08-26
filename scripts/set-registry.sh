#!/usr/bin/env bash
# Repoint aidlc-operations/ and aidlc-quickstart/ at your org's registry
# mirror instead of the default (registry-1.docker.io / auth.docker.io).
#
# This exists because schemaVersion "2"'s `args:` block — the mechanism
# that would otherwise make this a --kit-arg flag instead of a file edit —
# has not shipped in any released sbx binary yet (probe-tested against
# v0.38.0 and v0.39.0, both reject it). See README.md "Known limits" #2.
#
# Replaces the exact literal default hostnames only, in their real config
# forms (a quoted allow-list entry, or a `domain: <host>` credential-inject
# entry) — not any substring match. A plain prose comment mentioning
# "registry-1.docker.io" (e.g. this file's own header) does not count as
# "still configured" and must not trip the already-customized check; an
# earlier version of this script checked for the bare substring anywhere in
# the file, which matched that comment and made a real re-run silently
# no-op while claiming success.
set -euo pipefail

usage() {
  echo "Usage: $0 <registry-host> [<auth-host>]" >&2
  echo "  e.g. $0 myregistry.example.com auth.myregistry.example.com" >&2
  exit 1
}

[[ $# -ge 1 ]] || usage
NEW_REGISTRY="$1"
NEW_AUTH="${2:-$1}"

OLD_REGISTRY="registry-1.docker.io"
OLD_AUTH="auth.docker.io"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

is_configured() {
  # $1: spec file, $2: host to check for in real config form (quoted
  # allow-list entry or `domain:` inject entry) — never a bare substring.
  grep -qE "\"${2}\"|domain: ${2}\$" "$1"
}

found_any=0
for kit in aidlc-operations aidlc-quickstart; do
  spec="$REPO_ROOT/$kit/spec.yaml"
  [[ -f "$spec" ]] || { echo "missing $spec" >&2; exit 1; }

  if ! is_configured "$spec" "$OLD_REGISTRY" && ! is_configured "$spec" "$OLD_AUTH"; then
    echo "$kit: $OLD_REGISTRY / $OLD_AUTH not found in real config form — already customized, or already run. Not touching it." >&2
    continue
  fi

  sed -i '' \
    -e "s/\"$OLD_REGISTRY\"/\"$NEW_REGISTRY\"/g" \
    -e "s/\"$OLD_AUTH\"/\"$NEW_AUTH\"/g" \
    -e "s/domain: $OLD_REGISTRY\$/domain: $NEW_REGISTRY/g" \
    -e "s/domain: $OLD_AUTH\$/domain: $NEW_AUTH/g" \
    "$spec"

  echo "$kit: $OLD_REGISTRY -> $NEW_REGISTRY, $OLD_AUTH -> $NEW_AUTH"
  found_any=1
done

if [[ "$found_any" -eq 0 ]]; then
  echo "Nothing to do — neither kit still has the default registry host in a real config field (comments mentioning it don't count)." >&2
  exit 1
fi

echo
echo "Validating the result against a real sbx binary..."
for kit in aidlc-operations aidlc-quickstart; do
  sbx kit validate "$REPO_ROOT/$kit"
done
