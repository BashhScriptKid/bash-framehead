#!/usr/bin/env bash
# test_ext.sh — ext/tui test suite

declare -f 'tui::is_available' &>/dev/null || {
	echo "${BASH_SOURCE[0]}: tui.sh not found — source it first" >&2
	return 1
}

# ==============================================================================
# tui::is_available / tui::backend
# ==============================================================================

test::tui::is_available() {
	[[ "$(tui::is_available)" == "true" ]] && _pass || _skip "dialog/whiptail not installed"
}

test::tui::backend() {
	local _b
	_b=$(tui::backend)
	[[ -n "$_b" ]] && _pass || _skip "no TUI backend"
}

# ==============================================================================
# tui::storage (testable without terminal)
# ==============================================================================

test::tui::storage::set() {
	local -A _ctx
	tui::storage::set _ctx "device" "/dev/event7"
	local _val
	_val=$(tui::storage::get _ctx "device")
	if [[ "$_val" == "/dev/event7" ]]; then _sub_pass "set+get roundtrip"; else _sub_fail "set+get roundtrip" "/dev/event7" "$_val"; fi

	tui::storage::set _ctx "key" "val1"
	tui::storage::set _ctx "key" "val2"
	_val=$(tui::storage::get _ctx "key")
	if [[ "$_val" == "val2" ]]; then _sub_pass "set overwrites"; else _sub_fail "set overwrites" "val2" "$_val"; fi
	_sub_done
}

test::tui::storage::get() {
	local -A _ctx
	local _val
	_val=$(tui::storage::get _ctx "nonexistent")
	if [[ -z "$_val" ]]; then _sub_pass "get on empty"; else _sub_fail "get on empty" "" "$_val"; fi
	_sub_done
}

test::tui::storage::unset() {
	local -A _ctx
	tui::storage::set _ctx "key" "value"
	tui::storage::unset _ctx "key"
	local _val
	_val=$(tui::storage::get _ctx "key")
	[[ -z "$_val" ]] && _pass || _fail
}

test::tui::storage::keys() {
	local -A _ctx
	tui::storage::set _ctx "a" "1"
	tui::storage::set _ctx "b" "2"
	local _keys
	_keys=$(tui::storage::keys _ctx | sort | tr '\n' ',')
	[[ "$_keys" == "a,b," ]] && _pass || _fail
}

test::tui::storage::dump() {
	local -A _ctx
	tui::storage::set _ctx "x" "10"
	tui::storage::set _ctx "y" "20"
	local _dump
	_dump=$(tui::storage::dump _ctx | sort | tr '\n' ',')
	[[ "$_dump" == "x=10,y=20," ]] && _pass || _fail
}

# ==============================================================================
# Interactive widgets — skip in automated tests
# ==============================================================================

test::tui::msgbox()         { _skip "Requires interactive terminal"; }
test::tui::yesno()          { _skip "Requires interactive terminal"; }
test::tui::inputbox()       { _skip "Requires interactive terminal"; }
test::tui::passwordbox()    { _skip "Requires interactive terminal"; }
test::tui::menu()           { _skip "Requires interactive terminal"; }
test::tui::checklist()      { _skip "Requires interactive terminal"; }
test::tui::radiolist()      { _skip "Requires interactive terminal"; }
test::tui::gauge()          { _skip "Requires interactive terminal"; }
test::tui::infobox()        { _skip "Requires interactive terminal"; }
test::tui::textbox()        { _skip "Requires interactive terminal"; }

# ==============================================================================
# Dialog-only — skip if dialog not available
# ==============================================================================

test::tui::dialog::calendar()    { _skip "Requires interactive terminal"; }
test::tui::dialog::fselect()     { _skip "Requires interactive terminal"; }
test::tui::dialog::timebox()     { _skip "Requires interactive terminal"; }
test::tui::dialog::form()        { _skip "Requires interactive terminal"; }
test::tui::dialog::mixedform()   { _skip "Requires interactive terminal"; }
test::tui::dialog::editbox()     { _skip "Requires interactive terminal"; }
test::tui::dialog::treeview()    { _skip "Requires interactive terminal"; }
test::tui::dialog::buildlist()   { _skip "Requires interactive terminal"; }
test::tui::dialog::rangebox()    { _skip "Requires interactive terminal"; }
test::tui::dialog::mixedgauge()  { _skip "Requires interactive terminal"; }
test::tui::dialog::tailbox()     { _skip "Requires interactive terminal"; }
