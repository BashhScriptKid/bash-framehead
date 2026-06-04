#!/usr/bin/env bash
# test_ext.sh -- ext/dbus test suite
#
# Sourced by the test runner after tester.sh and the extension are loaded.
# _pass / _fail / _assert / _sub_done / _skip are already in scope.
#
# Most dbus tests require a live bus and are _skip'd by default.
# Parser tests (fromsig) run unconditionally.

# --- Busctl presence gate (helper) ---
_have_busctl() { command -v busctl &>/dev/null; }
_have_session_bus() { [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; }

# ==============================================================================
# Connection: dbus::bus::get / dbus::bus::set
# ==============================================================================

test::dbus::bus::get() {
		if _have_busctl; then
				_assert "default" "session" "$(dbus::bus::get)"
		else
				_skip "busctl not installed"
		fi
}

test::dbus::bus::set() {
		if _have_busctl; then
				dbus::bus::set session
				_assert "session"  "session" "$(dbus::bus::get)"
				dbus::bus::set system
				_assert "system"   "system"  "$(dbus::bus::get)"
				dbus::bus::set session    # restore
		else
				_skip "busctl not installed"
		fi
}

# ==============================================================================
# Listing: dbus::list::session / ::system / ::list
# ==============================================================================

test::dbus::list::session() {
		if _have_busctl && _have_session_bus; then
				local n
				n=$(dbus::list::session | wc -l)
				(( n > 0 )) && _pass || _fail "expected > 0 names, got $n"
		else
				_skip "no session bus or busctl"
		fi
}

test::dbus::list() {
		if _have_busctl && _have_session_bus; then
				local out
				out=$(dbus::list | head -1)
				[[ "$out" == session* || "$out" == system* ]] && _pass || \
						_fail "expected '<bus>\\t<name>' format, got '$out'"
		else
				_skip "no session bus or busctl"
		fi
}

# ==============================================================================
# Name resolution: dbus::pinpoint / dbus::owned
# ==============================================================================

test::dbus::pinpoint() {
		if _have_busctl && _have_session_bus; then
				local p
				p=$(dbus::pinpoint org.freedesktop.DBus)
				[[ -n "$p" ]] && _pass || _fail "pinpoint returned empty"
		else
				_skip "no session bus or busctl"
		fi
}

test::dbus::owned() {
		if _have_busctl && _have_session_bus; then
				# DBus daemon is always present on a live session bus.
				dbus::owned org.freedesktop.DBus && _pass || _fail "expected claimed"
		else
				_skip "no session bus or busctl"
		fi
}

# ==============================================================================
# Method calls: dbus::call + dbus::fromsig
# ==============================================================================

test::dbus::call() {
		if _have_busctl && _have_session_bus; then
				local raw
				raw=$(dbus::call org.freedesktop.DBus /org/freedesktop/DBus \
						org.freedesktop.DBus GetId)
				[[ "$raw" == s* ]] && _pass || _fail "expected s..., got '$raw'"
		else
				_skip "no session bus or busctl"
		fi
}

test::dbus::call::with_args() {
		if _have_busctl && _have_session_bus; then
				local raw
				raw=$(dbus::call org.freedesktop.DBus /org/freedesktop/DBus \
						org.freedesktop.DBus GetConnectionUnixProcessID s "org.freedesktop.DBus")
				[[ "$raw" == u* ]] && _pass || _fail "expected u..., got '$raw'"
		else
				_skip "no session bus or busctl"
		fi
}

# ==============================================================================
# Properties: dbus::get / dbus::get::all
# ==============================================================================

test::dbus::get() {
		if _have_busctl && _have_session_bus; then
				local raw
				raw=$(dbus::get org.freedesktop.DBus /org/freedesktop/DBus \
						org.freedesktop.DBus Features)
				[[ -n "$raw" ]] && _pass || _fail "expected non-empty"
		else
				_skip "no session bus or busctl"
		fi
}

test::dbus::get::all() {
		if _have_busctl && _have_session_bus; then
				local raw
				raw=$(dbus::get::all org.freedesktop.DBus /org/freedesktop/DBus \
						org.freedesktop.DBus)
				[[ "$raw" == a\{sv\}* ]] && _pass || _fail "expected a{sv}..., got '$raw'"
		else
				_skip "no session bus or busctl"
		fi
}

# ==============================================================================
# Introspection
# ==============================================================================

test::dbus::interfaces() {
		if _have_busctl && _have_session_bus; then
				local n
				n=$(dbus::interfaces org.freedesktop.DBus /org/freedesktop/DBus | wc -l)
				(( n > 0 )) && _pass || _fail "expected > 0 interfaces, got $n"
		else
				_skip "no session bus or busctl"
		fi
}

test::dbus::methods() {
		if _have_busctl && _have_session_bus; then
				local n
				n=$(dbus::methods org.freedesktop.DBus /org/freedesktop/DBus \
						org.freedesktop.DBus | wc -l)
				(( n > 0 )) && _pass || _fail "expected > 0 methods, got $n"
		else
				_skip "no session bus or busctl"
		fi
}

test::dbus::signals() {
		if _have_busctl && _have_session_bus; then
				local n
				n=$(dbus::signals org.freedesktop.DBus /org/freedesktop/DBus \
						org.freedesktop.DBus | wc -l)
				(( n > 0 )) && _pass || _fail "expected > 0 signals, got $n"
		else
				_skip "no session bus or busctl"
		fi
}

test::dbus::properties() {
		if _have_busctl && _have_session_bus; then
				local n
				n=$(dbus::properties org.freedesktop.DBus /org/freedesktop/DBus \
						org.freedesktop.DBus | wc -l)
				(( n > 0 )) && _pass || _fail "expected > 0 properties, got $n"
		else
				_skip "no session bus or busctl"
		fi
}

# ==============================================================================
# Sig parser: dbus::fromsig
# (Pure unit tests -- no bus required, run in CI.)
# ==============================================================================

test::dbus::fromsig() {
		local -A _ctx

		# Scalars
		echo 's "hello world"' | dbus::fromsig > /tmp/dbus_test_1
		_assert "string"        'hello world'               "$(< /tmp/dbus_test_1)"
		echo 'u 766' | dbus::fromsig > /tmp/dbus_test_2
		_assert "uint"           '766'                       "$(< /tmp/dbus_test_2)"
		echo 'b true' | dbus::fromsig > /tmp/dbus_test_3
		_assert "bool"           'true'                      "$(< /tmp/dbus_test_3)"
		echo 'i -42' | dbus::fromsig > /tmp/dbus_test_4
		_assert "int negative"   '-42'                       "$(< /tmp/dbus_test_4)"
		echo 'd 3.14' | dbus::fromsig > /tmp/dbus_test_5
		_assert "double"         '3.14'                      "$(< /tmp/dbus_test_5)"

		# Flat arrays
		echo 'as 3 "alpha" "beta" "gamma"' | dbus::fromsig > /tmp/dbus_test_6
		_assert "string array"   $'alpha\nbeta\ngamma'      "$(< /tmp/dbus_test_6)"
		echo 'ai 4 10 20 30 40' | dbus::fromsig > /tmp/dbus_test_7
		_assert "int array"      $'10\n20\n30\n40'          "$(< /tmp/dbus_test_7)"
		echo 'as 0' | dbus::fromsig > /tmp/dbus_test_8
		_assert "empty array"    ''                          "$(< /tmp/dbus_test_8)"

		# Dicts
		echo 'a{ss} 2 "k1" "v1" "k2" "v2"' | dbus::fromsig > /tmp/dbus_test_9
		_assert "dict ss"        $'k1\tv1\nk2\tv2'           "$(< /tmp/dbus_test_9)"
		echo 'a{sv} 3 "K1" s "v" "K2" b true "K3" i 7' | \
				dbus::fromsig > /tmp/dbus_test_10
		_assert "dict sv"        $'K1\tv\nK2\ttrue\nK3\t7'  "$(< /tmp/dbus_test_10)"

		# Struct
		echo '(ss) "a" "b"' | dbus::fromsig > /tmp/dbus_test_11
		_assert "struct"         $'a\nb'                    "$(< /tmp/dbus_test_11)"

		# Multi-return
		echo 'ss "first" "second"' | dbus::fromsig > /tmp/dbus_test_12
		_assert "multi-return"   $'first\nsecond'           "$(< /tmp/dbus_test_12)"

		# String with escape
		echo 's "a\nb\tc"' | dbus::fromsig > /tmp/dbus_test_13
		_assert "escapes"        $'a\nb\tc'                 "$(< /tmp/dbus_test_13)"

		# Direct arg form
		rm -f /tmp/dbus_test_14
		dbus::fromsig 's "directly passed"' > /tmp/dbus_test_14
		_assert "arg form"       'directly passed'          "$(< /tmp/dbus_test_14)"

		rm -f /tmp/dbus_test_*
		_sub_done
}

# ==============================================================================
# Signal handling: wait / watch / subscribe -- require live bus
# ==============================================================================

test::dbus::wait() {
		if _have_busctl && _have_session_bus; then
				# Time-bounded wait: should hit 124 in 1s
				local rc=0
				dbus::wait org.example.Nothing NeverFires 1 || rc=$?
				(( rc == 124 )) && _pass || _fail "expected exit 124, got $rc"
		else
				_skip "no session bus or busctl"
		fi
}

test::dbus::watch() {
		if _have_busctl && _have_session_bus; then
				# Verify watch starts and emits at least one line within 60s.
				# We use the ambient NameOwnerChanged signal that fires
				# whenever any tool connects/disconnects from the bus.
				local out
				out=$(timeout 60 dbus::watch org.freedesktop.DBus NameOwnerChanged 2>/dev/null | head -1)
				[[ "$out" == *$'\t'* ]] && _pass || _fail "expected TSV line, got '$out'"
		else
				_skip "no session bus or busctl"
		fi
}
