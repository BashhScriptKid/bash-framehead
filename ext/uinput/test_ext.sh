#!/usr/bin/env bash
# test_ext.sh — ext/uinput test suite
#
# Sourced by the test runner after tester.sh and the extension are loaded.
# _pass / _fail / _skip are already in scope.

# --- Read-only tests ---

test::uinput::is_ready() {
		uinput::is_ready && _pass || _skip "uinput_helper not compiled"
}

# --- Write APIs (unsafe to test) ---

test::uinput::create()    { _skip "Performs write operation to live kernel; unsafe to test"; }
test::uinput::destroy()   { _skip "Performs write operation to live kernel; unsafe to test"; }
test::uinput::key()       { _skip "Performs write operation to live kernel; unsafe to test"; }
test::uinput::mouse()     { _skip "Performs write operation to live kernel; unsafe to test"; }
test::uinput::abs()       { _skip "Performs write operation to live kernel; unsafe to test"; }
test::uinput::event()     { _skip "Performs write operation to live kernel; unsafe to test"; }
