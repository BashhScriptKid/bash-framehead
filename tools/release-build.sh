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

# Product build: obfuscate the optimized extended artifact (obfuscation
# also minifies, hence the implied `m` in the name).
echo ">>> bfh.ofe.sh  (obfuscate bfh.oe.sh)"
bash "$_repo_dir/main.sh" obfuscate "$_out_dir/bfh.oe.sh" "$_out_dir/bfh.ofe.sh" || exit 1
bash -n "$_out_dir/bfh.ofe.sh" || { echo "syntax check failed: bfh.ofe.sh" >&2; exit 1; }

echo
echo "Done — $_version artifacts in $_out_dir:"
ls -l "$_out_dir"/bfh*.sh
