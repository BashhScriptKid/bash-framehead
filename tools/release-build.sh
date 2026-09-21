#!/usr/bin/env bash
# release-build.sh — build the release artifact matrix.
#
# Naming: bfh.[o][f][m][e].sh, flags applied in that order
#   o  optimized  (helpers inlined)
#   f  obfuscated (implies minified — obfuscation minifies internally)
#   m  minified
#   e  extended   (core + every ext/ module)
#
# The matrix is the 3-rung ladder (plain / optimized / optimized+minified)
# for both the core and extended bundles, plus one obfuscated product build.
# Shipping the full powerset would mostly be redundant: `m` without `o` has
# no consumer, and `f` already implies `m`.
#
# Usage:
#   BFH_VERSION=0.2 tools/release-build.sh [output-dir]     # default ./dist
#
# Requires the toolchain in this repo (main.sh, tools/*.sh).

set -u

_tools_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_repo_dir="$(dirname "$_tools_dir")"
_out_dir="${1:-$_repo_dir/dist}"
_version="${BFH_VERSION:-$(git -C "$_repo_dir" describe --tags --abbrev=0 2>/dev/null || echo 0.0.0)}"

mkdir -p "$_out_dir" || exit 1
echo "Building release matrix for $_version into $_out_dir"

# build <name> <optimize> <minify> <extended>
build() {
    local name="$1" opt="$2" min="$3" ext="$4" cmd="compile"
    (( ext )) && cmd="compile_extended"
    echo ">>> $name  (OPTIMIZE=$opt MINIFY=$min EXTENDED=$ext)"
    BFH_VERSION="$_version" OPTIMIZE="$opt" MINIFY="$min" \
        bash "$_repo_dir/main.sh" "$cmd" "$_out_dir/$name" <<< '' || return 1
    bash -n "$_out_dir/$name" || { echo "syntax check failed: $name" >&2; return 1; }
}

build bfh.sh     0 0 0 || exit 1
build bfh.o.sh   1 0 0 || exit 1
build bfh.om.sh  1 1 0 || exit 1
build bfh.e.sh   0 0 1 || exit 1
build bfh.oe.sh  1 0 1 || exit 1
build bfh.ome.sh 1 1 1 || exit 1

# Product build: opt-in and currently UNRELIABLE. tools/obfuscate.sh corrupts
# '##' comment blocks and emits malformed local declarations on the full
# library, so the result fails at runtime (`local: : not a valid identifier`).
# The recipe below works around the comment bug (split the header off and
# restore it verbatim), but not the declaration bug. Enable once obfuscate.sh
# is fixed: RELEASE_OBFUSCATE=1 tools/release-build.sh
if [[ "${RELEASE_OBFUSCATE:-0}" == 1 ]]; then
    echo ">>> bfh.ofe.sh  (obfuscate minified body --skip-minifier)"
    _header=$(mktemp)
    _body=$(mktemp)
    awk -v h="$_header" -v b="$_body" '
        BEGIN { in_hdr = 1 }
        in_hdr && (/^#/ || /^[[:space:]]*$/) { print > h; next }
        { in_hdr = 0; print > b }
    ' "$_out_dir/bfh.ome.sh"
    LC_ALL=C bash "$_repo_dir/tools/obfuscate.sh" --skip-minifier \
        "$_body" "$_body.obf" || exit 1
    cat "$_header" "$_body.obf" > "$_out_dir/bfh.ofe.sh"
    rm -f "$_header" "$_body" "$_body.obf"
    if ! bash -n "$_out_dir/bfh.ofe.sh" 2>/dev/null; then
        echo "syntax check failed: bfh.ofe.sh" >&2
        exit 1
    fi
else
    echo ">>> bfh.ofe.sh  skipped (obfuscator unreliable; RELEASE_OBFUSCATE=1 to try)"
fi

echo
echo "Done — $_version artifacts in $_out_dir:"
ls -l "$_out_dir"/bfh*.sh
