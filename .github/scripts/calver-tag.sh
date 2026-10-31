#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Beslogic Inc.

# Tags GITHUB_SHA with the next CalVer version: YYYY.MM.DD, then YYYY.MM.DD.N for same-day pushes.
# Run from .github/workflows/calver-tag.yml. Expects GH_TOKEN and the default GitHub Actions env vars.
set -euo pipefail

# Format must stay parseable by setuptools-scm's calver-by-date scheme, see pyproject.toml
base="$(date -u +%Y.%m.%d)"
# All tags in one request, annotated ones peeled to their commit (^{} suffix)
tags="$(git ls-remote --tags "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY" | sed 's/\^{}$//')"

# Workflow re-run on an already tagged commit, even from a previous day
# || true: no match is the normal case, but fails under pipefail
already="$(grep -m1 -E "^$GITHUB_SHA"$'\t'"refs/tags/[0-9]{4}\.[0-9]{2}\.[0-9]{2}(\.[0-9]+)?$" <<<"$tags" | cut -f2 || true)"
if [ -n "$already" ]; then
  echo "$GITHUB_SHA is already tagged as ${already#refs/tags/}"
  exit 0
fi

refs="$(cut -f2 <<<"$tags")"
tag="$base"
n=0
while grep -qxF "refs/tags/$tag" <<<"$refs"; do
  n=$((n + 1))
  tag="$base.$n"
done

gh api "repos/$GITHUB_REPOSITORY/git/refs" -f "ref=refs/tags/$tag" -f "sha=$GITHUB_SHA"
echo "Tagged $GITHUB_SHA as $tag" >>"$GITHUB_STEP_SUMMARY"
