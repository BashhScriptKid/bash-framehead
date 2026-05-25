#!/usr/bin/env bash
# ext/yaml/benchmark.sh — YAML conformance benchmark using yaml-test-suite
#
# Clones the yaml/yaml-test-suite data branch (if not present) and runs
# yaml::to_json against each test case.  Compares output to the expected
# JSON (normalised via python3) and reports pass/fail/mismatch.
#
# Usage: cd <framehead> && bash ext/yaml/benchmark.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_DIR="${YAML_TEST_DIR:-/tmp/yaml-test-suite}"

# ---- Clone test suite if not present ----
if [[ ! -d "$TEST_DIR" ]]; then
		echo "Cloning yaml-test-suite (data branch) to $TEST_DIR..."
		git clone --branch data --depth 1 https://github.com/yaml/yaml-test-suite.git "$TEST_DIR"
fi

# ---- Load framework and extensions ----
source "$SCRIPT_DIR/../../bash-framehead.sh"
source "$SCRIPT_DIR/yaml.sh"
source "$SCRIPT_DIR/../json/json.sh"

# ---- Helper: normalise JSON for comparison ----
normalise() {
		python3 -c "
import sys, json
data = json.loads(sys.stdin.read())
print(json.dumps(data, separators=(',',':'), sort_keys=True))
" 2>/dev/null
}

# ---- Find test directories ----
# Each test dir contains: === (label), in.yaml, in.json / test.event / error
echo "Discovering test cases..."
declare -a test_dirs=()
while IFS= read -r -d '' dir; do
		[[ -f "$dir/in.yaml" ]] || continue
		test_dirs+=("$dir")
done < <(find "$TEST_DIR" -type d -name '[A-Z0-9]*' -print0 | head -200)

# If there are subdirectories (multi-test format), add those too
# Pattern: data/XXXX/00/  data/XXXX/01/
while IFS= read -r -d '' dir; do
		[[ -f "$dir/in.yaml" ]] || continue
		test_dirs+=("$dir")
done < <(find "$TEST_DIR" -type d -name '[0-9][0-9]' -print0 2>/dev/null | head -200)

echo "  Found ${#test_dirs[@]} test cases"

# ---- Run tests ----
valid=0 mism=0 invalid=0 skipped=0 total=0
declare -a fail_ids=()
verbose="${YAML_BENCH_VERBOSE:-0}"
[[ -n "${YAML_BENCH_VERBOSE+set}" ]] || { [[ -t 1 ]] || verbose=0; }

# Sort test dirs for stable output
readarray -t test_dirs < <(printf '%s\n' "${test_dirs[@]}" | sort)

for dir in "${test_dirs[@]}"; do
		[[ -f "$dir/in.yaml" ]] || continue
		((total++))

		# Skip error tests (should fail to parse)
		if [[ -f "$dir/error" ]]; then
				((skipped++))
				((verbose)) && printf '  %-45s %6s\n' "${dir#$TEST_DIR/}" "SKIP (error)"
				continue
		fi

		# Skip if no expected JSON
		if [[ ! -f "$dir/in.json" ]]; then
				((skipped++))
				((verbose)) && printf '  %-45s %6s\n' "${dir#$TEST_DIR/}" "SKIP (no json)"
				continue
		fi

		yaml_input="$(< "$dir/in.yaml")"
		json_expected="$(normalise < "$dir/in.json")"

		t0=$(date +%s%3N 2>/dev/null || echo 0)
		json_result="$(yaml::to_json "$yaml_input" 2>/dev/null)" || {
				((invalid++))
				t1=$(date +%s%3N 2>/dev/null || echo 0)
				(( ${#fail_ids[@]} < 15 )) && fail_ids+=("${dir#$TEST_DIR/}")
				((verbose)) && printf '  %-45s %6s %4dms\n' "${dir#$TEST_DIR/}" "INVALID" $((t1-t0))
				continue
		}
		t1=$(date +%s%3N 2>/dev/null || echo 0)

		# Validate result is parseable JSON and normalise
		json_norm="$(echo "$json_result" | normalise 2>/dev/null)" || {
				((invalid++))
				(( ${#fail_ids[@]} < 15 )) && fail_ids+=("${dir#$TEST_DIR/}")
				((verbose)) && printf '  %-45s %6s %4dms (bad json)\n' "${dir#$TEST_DIR/}" "INVALID" $((t1-t0))
				continue
		}

		if [[ "$json_expected" == "$json_norm" ]]; then
				((valid++))
				((verbose)) && printf '  %-45s %6s %4dms\n' "${dir#$TEST_DIR/}" "PASS" $((t1-t0))
		else
				((mism++))
				(( ${#fail_ids[@]} < 15 )) && fail_ids+=("${dir#$TEST_DIR/}")
				if ((verbose)); then
						printf '  %-45s %6s %4dms\n' "${dir#$TEST_DIR/}" "MISMATCH" $((t1-t0))
						((verbose > 1)) && {
								echo "    expected: ${json_expected:0:120}"
								echo "    got:      ${json_norm:0:120}"
						}
				fi
		fi

		if (( total % 50 == 0 )) && ! ((verbose)); then
				echo "  $total  v=$valid m=$mism i=$invalid"
		fi
done

echo ""
echo "=== YAML conformance ($total total) ==="
echo "Pass:      $valid"
echo "Mismatch:  $mism"
echo "Invalid:   $invalid"
echo "Skipped:   $skipped"
echo "Rate:      $(( valid * 100 / (total - skipped) ))% (of $(($total - $skipped)) testable)"
echo ""
echo "Sample failures:"
for f in "${fail_ids[@]}"; do echo "  $f"; done
