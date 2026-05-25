#!/usr/bin/env bash
# benchmark.sh — run the TOML test suite against our parser.
#
# Usage: cd <framehead> && bash ext/toml/benchmark.sh
#
# Requires: python3 (for JSON normalisation and type-tag stripping)
# Test data: https://github.com/toml-lang/toml-test

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_DIR="${TOML_TEST_DIR:-/tmp/toml-tests/tests}"

# ---- Download test suite if not present ----
if [[ ! -d "$TEST_DIR" ]]; then
		echo "Cloning toml-test to /tmp/toml-tests..."
		git clone --depth 1 https://github.com/toml-lang/toml-test.git /tmp/toml-tests
fi

source "$SCRIPT_DIR/../../bash-framehead.sh"
source "$SCRIPT_DIR/toml.sh"

# ---- Strip TOML test suite type tags ----
# The suite wraps every value as {"type":"...","value":X}.  We unwrap to bare JSON.
untag() {
		python3 -c "
import sys,json
def strip(v):
		if isinstance(v, dict) and set(v.keys()) == {'type','value'}:
				t, vv = v['type'], v['value']
				if t == 'integer': return int(vv)
				if t == 'float':   return float(vv)
				if t == 'bool':    return vv == 'true'
				if t in ('string','array','table'): return strip(vv)
				return str(vv)  # datetime, etc.
		elif isinstance(v, dict):
				return {k: strip(vv) for k, vv in v.items()}
		elif isinstance(v, list):
				return [strip(vv) for vv in v]
		return v
print(json.dumps(strip(json.loads(sys.stdin.read())), separators=(',',':'), sort_keys=True))
" 2>/dev/null
}

# ---- Run valid tests ----
valid_dir="$TEST_DIR/valid"
valid=0 invalid=0 mismatch=0 total=0
declare -a fail_ids=()
verbose="${TOML_BENCH_VERBOSE:-0}"
# Auto-disable when piped unless explicitly requested
[[ -n "${TOML_BENCH_VERBOSE+set}" ]] || { [[ -t 1 ]] || verbose=0; }

while IFS= read -r -d '' toml_file; do
		json_file="${toml_file%.toml}.json"
		[[ -f "$json_file" ]] || continue
		((total++))

		toml="$(< "$toml_file")"
		expected="$(untag < "$json_file")"

		t0=$(date +%s%3N 2>/dev/null || echo 0)
		result="$(toml::to_json "$toml" 2>/dev/null)" || { ((invalid++)); t1=$(date +%s%3N 2>/dev/null || echo 0); ((verbose)) && printf '  %-45s %6s %4dms\n' "$(basename "$(dirname "$toml_file")")/$(basename "$toml_file")" "INVALID" $((t1-t0)); continue; }
		t1=$(date +%s%3N 2>/dev/null || echo 0)

		if echo "$result" | python3 -c 'import sys,json; json.loads(sys.stdin.read())' 2>/dev/null; then
				na="$(echo "$result" | python3 -c 'import sys,json; print(json.dumps(json.loads(sys.stdin.read()), separators=(",",":"), sort_keys=True))' 2>/dev/null)"
				if [[ "$expected" == "$na" ]]; then
						((valid++))
						((verbose)) && printf '  %-45s %6s %4dms\n' "$(basename "$(dirname "$toml_file")")/$(basename "$toml_file")" "PASS" $((t1-t0))
				else
						((mismatch++))
						(( ${#fail_ids[@]} < 10 )) && fail_ids+=("$(basename "$(dirname "$toml_file")")/$(basename "$toml_file")")
						((verbose)) && printf '  %-45s %6s %4dms\n' "$(basename "$(dirname "$toml_file")")/$(basename "$toml_file")" "MISMATCH" $((t1-t0))
				fi
		else
				((invalid++))
				(( ${#fail_ids[@]} < 10 )) && fail_ids+=("$(basename "$(dirname "$toml_file")")/$(basename "$toml_file")")
				((verbose)) && printf '  %-45s %6s %4dms\n' "$(basename "$(dirname "$toml_file")")/$(basename "$toml_file")" "INVALID" $((t1-t0))
		fi

		if (( total % 50 == 0 )) && ! ((verbose)); then
				echo "  $total/266 v=$valid i=$invalid m=$mismatch"
		fi
done < <(find "$valid_dir" -name '*.toml' -print0)

echo ""
echo "=== Valid tests (266 total) ==="
echo "Match:    $valid"
echo "Mismatch: $mismatch"
echo "Invalid:  $invalid"
echo "Rate:     $(( valid * 100 / total ))%"
echo ""
echo "Sample failures:"
for f in "${fail_ids[@]}"; do echo "  $f"; done
