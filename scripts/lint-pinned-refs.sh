#!/usr/bin/env bash
# Fail if any git+https:// kit reference in a tracked markdown file is
# missing a #ref= fragment — an unpinned reference resolves to whatever the
# default branch's HEAD happens to be at pull time, which is exactly the
# "nothing pins remote refs" failure mode the repo's own README and
# CONTRIBUTING.md call a hard requirement, not a suggestion.
set -euo pipefail

fail=0
while IFS=: read -r file line url; do
  if [[ "$url" != *"#ref="* ]]; then
    echo "UNPINNED: $file:$line: $url"
    fail=1
  fi
done < <(grep -rnoE 'git\+https://[^"'"'"'\`) ]+' --include='*.md' . -- 2>/dev/null)

if [[ "$fail" -eq 1 ]]; then
  echo
  echo "One or more git+https:// references above have no #ref=<tag|sha> fragment."
  echo "Pin every reference — see README.md 'Known limits' and CONTRIBUTING.md."
  exit 1
fi

echo "All git+https:// references are pinned."
