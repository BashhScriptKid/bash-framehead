#!/usr/bin/env bash
# test_ext.sh — ext/csv test suite
#
# Sourced by the test runner after tester.sh and the extension are loaded.
# _pass / _fail / _assert / _assert_contains / _sub_done / _skip are in scope.
#
# Naming: test::csv::<fn> — the runner discovers the public function csv::<fn>,
# prepends test::, and calls test::csv::<fn>.

# ==============================================================================
# csv::get
# ==============================================================================

test::csv::get() {
		local data=$'name,age,city\nAlice,30,NYC\nBob,25,LA'

		_assert "by index"      'Alice' "$(csv::get "$data" 0 0)"
		_assert "by index row1" '30'    "$(csv::get "$data" 0 1)"
		_assert "row2"          'Bob'   "$(csv::get "$data" 1 0)"
		_assert "row2 col2"     'LA'    "$(csv::get "$data" 1 2)"
		_assert "by header"     'Alice' "$(csv::get "$data" 0 name)"
		_assert "header col2"   '30'    "$(csv::get "$data" 0 age)"
		_assert "header row2"   'LA'    "$(csv::get "$data" 1 city)"

		# Quoted fields with commas
		local qdata='"Smith, John",30,"New York, NY"'
		CSV_NOHEADER=1
		_assert "comma in name" 'Smith, John'  "$(csv::get "$qdata" 0 0)"
		_assert "comma in city" 'New York, NY' "$(csv::get "$qdata" 0 2)"
		unset CSV_NOHEADER

		# Escaped (doubled) quotes
		local edata='"He said ""hello""",yes'
		CSV_NOHEADER=1
		_assert "escaped quotes" 'He said "hello"' "$(csv::get "$edata" 0 0)"
		unset CSV_NOHEADER

		# No-header mode
		local ndata=$'Alice,30,NYC\nBob,25,LA'
		CSV_NOHEADER=1
		_assert "noheader row0" 'Alice' "$(csv::get "$ndata" 0 0)"
		_assert "noheader row1" 'Bob'   "$(csv::get "$ndata" 1 0)"
		unset CSV_NOHEADER

		# Error handling
		if ! csv::get "$data" 5 0 >/dev/null 2>&1; then _sub_pass "row OOB"; else _sub_fail "row OOB"; fi
		if ! csv::get "$data" 0 99 >/dev/null 2>&1; then _sub_pass "col OOB"; else _sub_fail "col OOB"; fi
		if ! csv::get "$data" 0 unknown >/dev/null 2>&1; then _sub_pass "bad header"; else _sub_fail "bad header"; fi

		_sub_done
}

# ==============================================================================
# csv::row
# ==============================================================================

test::csv::row() {
		local data=$'name,age,city\nAlice,30,NYC\nBob,25,LA'

		_assert "row0" $'Alice\t30\tNYC' "$(csv::row "$data" 0)"
		_assert "row1" $'Bob\t25\tLA'    "$(csv::row "$data" 1)"
		_sub_done
}

# ==============================================================================
# csv::headers
# ==============================================================================

test::csv::headers() {
		local data=$'name,age,city\nAlice,30,NYC'

		_assert "header names" $'name\nage\ncity' "$(csv::headers "$data")"
		_sub_done
}

# ==============================================================================
# csv::numrows
# ==============================================================================

test::csv::numrows() {
		local data=$'h1,h2\na,b\nc,d\ne,f\n'
		_assert "3 data rows" '3' "$(csv::numrows "$data")"

		local no_nl=$'h1,h2\na,b'
		_assert "no trailing nl" '1' "$(csv::numrows "$no_nl")"

		_assert "empty csv" '0' "$(csv::numrows '')"

		local nohdr=$'a,b\nc,d\ne,f'
		CSV_NOHEADER=1
		_assert "noheader mode" '3' "$(csv::numrows "$nohdr")"
		unset CSV_NOHEADER
		_sub_done
}

# ==============================================================================
# csv::numcols
# ==============================================================================

test::csv::numcols() {
		local data=$'name,age,city,country\nAlice,30,NYC,US\nBob,25,LA,US'
		_assert "4 cols" '4' "$(csv::numcols "$data")"
		_sub_done
}

# ==============================================================================
# csv::get_file
# ==============================================================================

test::csv::get_file() {
		printf 'name,age\nPat,28\n' > /tmp/csv-test-file.csv
		_assert "from file" '28' "$(csv::get_file /tmp/csv-test-file.csv 0 age)"
		_sub_done
}

# ==============================================================================
# csv::global — edge cases
# ==============================================================================

test::csv::global() {
		# Empty unquoted field
		local data='a,,c'
		CSV_NOHEADER=1
		_assert "empty field" '' "$(csv::get "$data" 0 1)"
		unset CSV_NOHEADER

		# Quoted empty string
		local qdata='a,"",c'
		CSV_NOHEADER=1
		_assert "quoted empty" '' "$(csv::get "$qdata" 0 1)"
		unset CSV_NOHEADER

		# CRLF line endings
		local crlf=$'h1,h2\r\na,b\r\nc,d\r\n'
		_assert "crlf row0" 'a' "$(csv::get "$crlf" 0 0)"
		_assert "crlf row1" 'c' "$(csv::get "$crlf" 1 0)"

		# Custom delimiter (semicolon)
		local semi='a;b;c'
		CSV_DELIMITER=';'
		CSV_NOHEADER=1
		_assert "semicolon" 'b' "$(csv::get "$semi" 0 1)"
		unset CSV_NOHEADER
		unset CSV_DELIMITER

		# Single field, no delimiter
		local single='hello'
		CSV_NOHEADER=1
		_assert "single field" 'hello' "$(csv::get "$single" 0 0)"
		unset CSV_NOHEADER

		_sub_done
}

test::csv::col() {
		local _csv=$'name,age,city\nAlice,30,NYC\nBob,25,LA'
		local out; out=$(csv::col "$_csv" "name")
		_assert "col by name" $'Alice\nBob' "$out"

		local out2; out2=$(csv::col "$_csv" 1)
		_assert "col by index" $'30\n25' "$out2"

		CSV_NOHEADER=1
		local out3; out3=$(csv::col "a,b,c" 0)
		_assert "col noheader" $'a' "$out3"
		unset CSV_NOHEADER
		_sub_done
}

test::csv::to_json() {
		local _csv=$'name,age\nAlice,30\nBob,25'
		local json; json=$(csv::to_json "$_csv")
		_assert_contains "json array open" "[" "$json"
		_assert_contains "json name key" '"name"' "$json"
		_assert_contains "json value" '"Alice"' "$json"

		CSV_NOHEADER=1
		local json2; json2=$(csv::to_json $'a,b\nc,d')
		_assert_contains "noheader array" '[["a","b"],["c","d"]]' "$json2"
		unset CSV_NOHEADER
		_sub_done
}
