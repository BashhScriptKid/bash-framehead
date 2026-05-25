#!/usr/bin/env bash
# ext/json/benchmark.sh — JSON benchmark using nativejson-benchmark data
#
# Downloads 3 real-world JSON files (canada, citm_catalog, twitter) and runs
# json::get, json::keys, json::len, json::type operations against them.
#
# Usage: cd <framehead> && bash ext/json/benchmark.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="${JSON_BENCH_DIR:-/tmp/json-bench}"

# ---- Download data files if not present ----
mkdir -p "$DATA_DIR"

download() {
		local url="$1" file="$2"
		local dest="$DATA_DIR/$file"
		if [[ -f "$dest" ]]; then
				echo "  [cached] $file"
				return
		fi
		echo "  downloading $file (${3:-unknown})..."
		curl -sSL "$url" -o "$dest" || { echo "  FAILED to download $file"; rm -f "$dest"; }
}

echo "=== Preparing JSON benchmark data ==="
download "https://raw.githubusercontent.com/miloyip/nativejson-benchmark/master/data/canada.json" \
				"canada.json" "2.2 MB"
download "https://raw.githubusercontent.com/miloyip/nativejson-benchmark/master/data/citm_catalog.json" \
				"citm_catalog.json" "1.7 MB"
download "https://raw.githubusercontent.com/miloyip/nativejson-benchmark/master/data/twitter.json" \
				"twitter.json" "632 KB"

# ---- Load framework and extension ----
source "$SCRIPT_DIR/../../bash-framehead.sh"
source "$SCRIPT_DIR/json.sh"

# ---- Compliance test ----
echo ""
echo "=== JSON Spec Compliance (RFC 8259) ==="

compliant=0 noncompliant=0
check_pass() { ((compliant++)); }
check_fail() { echo "  FAIL  $1"; ((noncompliant++)); }
# Helper that preserves trailing newlines in command substitution
_get() { local v; v="$(json::get "$1" "$2" 2>/dev/null; printf x)"; printf '%s' "${v%x}"; }

echo "--- Strings ---"
# Use $'...' for JSON sources containing escapes, so bash translates
# $'\\t' → literal \t in JSON, which the parser decodes to a tab.
# Empty string: decoded "" produces no stdout.  json::get succeeds, output is
# zero bytes — command substitution naturally yields an empty variable.
r="$(json::get '{"k":""}' k 2>/dev/null)" && [[ -z "$r" ]] && { ((compliant++)); true; } || { echo "  FAIL  empty string: [$r]"; ((noncompliant++)); }
[[ -z "$r" ]] && ((compliant++)) || { echo "  FAIL  empty string: got [$r]"; ((noncompliant++)); }
r=$(_get '{"k":"abc"}' k);    [[ "$r" == 'abc' ]]   && check_pass || check_fail "basic: [$r]"
r=$(_get $'{"k":"a\\"b"}' k); [[ "$r" == 'a"b' ]]   && check_pass || check_fail "escaped quote: [$r]"
r=$(_get $'{"k":"a\\\\b"}' k); [[ "$r" == 'a\b' ]]  && check_pass || check_fail "escaped backslash: [$r]"
r=$(_get $'{"k":"a\\/b"}' k); [[ "$r" == 'a/b' ]]   && check_pass || check_fail "escaped slash: [$r]"
r=$(_get $'{"k":"a\\tb"}' k); [[ "$r" == $'a\tb' ]] && check_pass || check_fail "escaped tab: [$r]"
r=$(_get $'{"k":"a\\nb"}' k); [[ "$r" == $'a\nb' ]] && check_pass || check_fail "escaped newline: [$r]"
r=$(_get $'{"k":"a\\rb"}' k); [[ "$r" == $'a\rb' ]] && check_pass || check_fail "escaped CR: [$r]"
r=$(_get $'{"k":"\\\\"}' k);   [[ "$r" == '\' ]]     && check_pass || check_fail "backslash only: [$r]"
r=$(_get '{"k":"A"}' k);      [[ "$r" == 'A' ]]     && check_pass || check_fail "utf-8 ASCII: [$r]"
r=$(_get '{"k":"é"}' k);      [[ "$r" == 'é' ]]     && check_pass || check_fail "utf-8 latin: [$r]"

echo "--- Numbers: valid ---"
for num in 0 42 -17 3.14 -0.5 1e10 1E5 1e-5 1.5e2 0.5 0e0 1E+5; do
		r="$(json::get "{\"k\":$num}" k 2>/dev/null)"
		[[ "$r" == "$num" ]] && check_pass || check_fail "valid $num: got [$r]"
done

echo "--- Numbers: invalid (must reject) ---"
for num in 01 +1 1. 1e - 1.2.3 1e+ 00 .5 -.5 1e1.5; do
		json::get "{\"k\":$num}" k >/dev/null 2>&1 \
				&& check_fail "invalid '$num' was accepted" \
				|| check_pass
done

echo "--- Literals ---"
json::get '{"k":true}'  k 2>/dev/null | grep -qx 'true'  && check_pass || check_fail "true"
json::get '{"k":false}' k 2>/dev/null | grep -qx 'false' && check_pass || check_fail "false"
json::get '{"k":null}'  k 2>/dev/null | grep -qx 'null'  && check_pass || check_fail "null"

echo "--- Trailing commas (must reject) ---"
json::get '{"a":1,}' a        >/dev/null 2>&1 && check_fail "trailing comma obj" || check_pass
json::get '{"a":1,"b":2,}' b  >/dev/null 2>&1 && check_fail "trailing comma obj multi" || check_pass
json::get '[1,]' 0            >/dev/null 2>&1 && check_fail "trailing comma arr" || check_pass
json::get '[1,2,]' 1          >/dev/null 2>&1 && check_fail "trailing comma arr multi" || check_pass

echo "--- Objects ---"
r="$(json::get '{"a":{"b":"deep"}}' a 2>/dev/null)"
[[ "$r" == '{"b":"deep"}' ]] && check_pass || check_fail "nested object: [$r]"
r="$(json::get '{"a":{}}' a 2>/dev/null)"
[[ "$r" == '{}' ]] && check_pass || check_fail "empty object: [$r]"
json::len '{"a":1,"b":2,"c":3}' '' | grep -qx '3' && check_pass || check_fail "obj len=3"

echo "--- Arrays ---"
r="$(json::get '{"a":[1,2,3]}' a 2>/dev/null)"
[[ "$r" == '[1,2,3]' ]] && check_pass || check_fail "simple array: [$r]"
r="$(json::get '{"a":[]}' a 2>/dev/null)"
[[ "$r" == '[]' ]] && check_pass || check_fail "empty array: [$r]"
json::len '[10,20,30]' '' | grep -qx '3' && check_pass || check_fail "arr len=3"

echo "--- Deep nesting ---"
deep='{"a":'
for i in $(seq 1 20); do deep+='{"a":'; done
deep+='"deep"'
for i in $(seq 1 21); do deep+='}'; done
path=''
for i in $(seq 1 20); do [[ -n "$path" ]] && path+='.'; path+='a'; done
r="$(json::get "$deep" "$path.a" 2>/dev/null)"
[[ "$r" == 'deep' ]] && check_pass || check_fail "21-level nesting: [$r]"

echo "--- Root values ---"
json::type '[1,2,3]' '' | grep -qx 'array'  && check_pass || check_fail "root array type"
json::type '{"a":1}' '' | grep -qx 'object' && check_pass || check_fail "root object type"
json::type '"hi"' ''    | grep -qx 'string' && check_pass || check_fail "root string type"
json::type '42' ''      | grep -qx 'number' && check_pass || check_fail "root number type"

echo "  Compliance: $compliant passed, $noncompliant failed"

# ---- Check for jq ----
HAS_JQ=0
command -v jq &>/dev/null && HAS_JQ=1

timer() { date +%s%3N 2>/dev/null || printf '%d' $(( $(printf '%(%s)T' -1) * 1000 )); }

bench_file() {
		local label="$1" file="$2"
		local json t0 t1 result

		json="$(< "$file")"
		local size_kb=$(( ${#json} / 1024 ))

		echo ""
		echo "--- $label ($size_kb KB) ---"

		# Discover a sample key and structure
		local root_type
		root_type="$(json::type "$json" '')"
		echo "  root type: $root_type"

		local sample_key="" sample_path=""
		if [[ "$root_type" == "object" ]]; then
				sample_key="$(json::keys "$json" '' | head -1)"
				sample_path="$sample_key"
				local key_type
				key_type="$(json::type "$json" "$sample_key")"
				echo "  sample key: '$sample_key' (type: $key_type)"
				# If it's an object, find a nested key
				if [[ "$key_type" == "object" ]]; then
						local nested
						nested="$(json::keys "$json" "$sample_key" | head -1)"
						sample_path="$sample_key.$nested"
				elif [[ "$key_type" == "array" ]]; then
						sample_path="$sample_key.0"
				fi
		elif [[ "$root_type" == "array" ]]; then
				sample_path="0"
				local arr_len
				arr_len="$(json::len "$json" '')"
				echo "  array length: $arr_len"
		fi

		# --- Bench 1: json::get at sample path ---
		if [[ -n "$sample_path" ]]; then
				echo -n "  json::get '$sample_path' (10x): "
				t0=$(timer)
				for ((i=0; i<10; i++)); do json::get "$json" "$sample_path" >/dev/null 2>&1 || true; done
				t1=$(timer)
				echo "$(( t1 - t0 )) ms"

				if (( HAS_JQ )); then
						echo -n "  jq equivalent (10x):            "
						t0=$(timer)
						for ((i=0; i<10; i++)); do echo "$json" | jq ".$sample_path" >/dev/null 2>&1 || true; done
						t1=$(timer)
						echo "$(( t1 - t0 )) ms"
				fi
		fi

		# --- Bench 2: json::keys at root ---
		if [[ "$root_type" == "object" || "$root_type" == "array" ]]; then
				echo -n "  json::keys '' (1x):             "
				t0=$(timer)
				json::keys "$json" '' >/dev/null 2>&1
				t1=$(timer)
				echo "$(( t1 - t0 )) ms"

				if (( HAS_JQ )); then
						echo -n "  jq equivalent (1x):             "
						t0=$(timer)
						echo "$json" | jq 'keys' >/dev/null 2>&1 || echo "$json" | jq '.[]' >/dev/null 2>&1 || true
						t1=$(timer)
						echo "$(( t1 - t0 )) ms"
				fi
		fi

		# --- Bench 3: json::len ---
		if [[ "$root_type" == "object" || "$root_type" == "array" ]]; then
				echo -n "  json::len '' (1x):              "
				t0=$(timer)
				result="$(json::len "$json" '')"
				t1=$(timer)
				echo "$(( t1 - t0 )) ms  (result: $result)"

				if (( HAS_JQ )); then
						echo -n "  jq equivalent (1x):             "
						t0=$(timer)
						echo "$json" | jq 'length' >/dev/null 2>&1 || true
						t1=$(timer)
						echo "$(( t1 - t0 )) ms"
				fi
		fi

		# --- Bench 4: json::type at root ---
		echo -n "  json::type '' (1x):             "
		t0=$(timer)
		json::type "$json" '' >/dev/null
		t1=$(timer)
		echo "$(( t1 - t0 )) ms"

		# --- Bench 5: Deep path lookup if nesting exists ---
		if [[ -n "$sample_path" && "$sample_path" =~ \. ]]; then
				echo -n "  json::get deep path (10x):       "
				t0=$(timer)
				for ((i=0; i<10; i++)); do json::get "$json" "$sample_path" >/dev/null 2>&1 || true; done
				t1=$(timer)
				echo "$(( t1 - t0 )) ms"
		fi
}

for datafile in "$DATA_DIR"/{canada,citm_catalog,twitter}.json; do
		[[ -f "$datafile" ]] || { echo "Skipping missing: $datafile"; continue; }
		bench_file "$(basename "$datafile" .json)" "$datafile"
done

echo ""
echo "=== JSON benchmark complete ==="
