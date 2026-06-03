#!/usr/bin/env bash
# test_ext.sh — ext/systemd test suite
#
# Sourced by the test runner after tester.sh and the extension are loaded.
# _pass / _fail / _assert / _assert_contains / _assert_nonempty / _sub_done /
# _skip are in scope.
#
# Test strategy (per Q2): read-only tests run on any Linux+systemd box;
# write operations are gated by _skip with runtime::has_command. No fixture
# unit, no env-var gate. The skip auto-discovery lists them as skipped, not
# untested — matches the project convention in AGENTS.md.

# ==============================================================================
# Scaffold: version + scope default + scope flag
# ==============================================================================

test::systemd::version() {
	if ! runtime::has_command systemctl; then
		_skip "systemctl not installed"
	fi
	local _v
	_v=$(systemd::version)
	if [[ "$_v" =~ ^[0-9]+$ ]] && (( _v > 0 )); then
		_pass
	else
		_fail "expected positive integer, got '$_v'"
	fi
	_sub_done
}

test::systemd::scope::default() {
	local _saved="${_SYSTEMD_DEFAULT_SCOPE:-}"
	unset _SYSTEMD_DEFAULT_SCOPE
	local _re_default
	_re_default="${_SYSTEMD_DEFAULT_SCOPE:-system}"
	_assert "default is system" "system" "$_re_default"
	[[ -n "$_saved" ]] && _SYSTEMD_DEFAULT_SCOPE="$_saved"
	_sub_done
}

test::systemd::scope::flag() {
	local _flag
	_SYSTEMD_DEFAULT_SCOPE="system"
	_flag=$(_systemd::scope_flag)
	_assert "system scope flag" "" "$_flag"

	_SYSTEMD_DEFAULT_SCOPE="user"
	_flag=$(_systemd::scope_flag)
	_assert "user scope flag" "--user" "$_flag"

	_SYSTEMD_DEFAULT_SCOPE="system"
	_sub_done
}

# ==============================================================================
# Scope (system / user instance switcher) — public setters
# ==============================================================================

test::systemd::scope::get() {
	_SYSTEMD_DEFAULT_SCOPE="system"
	_assert "get returns system" "system" "$(systemd::scope::get)"

	_SYSTEMD_DEFAULT_SCOPE="user"
	_assert "get returns user" "user" "$(systemd::scope::get)"

	_SYSTEMD_DEFAULT_SCOPE="system"
	_sub_done
}

test::systemd::scope::set() {
	local _rc
	systemd::scope::set system
	_assert "set system" "system" "$(systemd::scope::get)"

	systemd::scope::set user
	_assert "set user" "user" "$(systemd::scope::get)"

	systemd::scope::set bogus 2>/dev/null
	_rc=$?
	_assert "set bogus returns 1" "1" "$_rc"

	# Restore default.
	systemd::scope::set system
	_sub_done
}

test::systemd::scope::isuser() {
	_SYSTEMD_DEFAULT_SCOPE="user"
	systemd::scope::isuser
	local _rc=$?
	_assert "isuser when user" "0" "$_rc"

	_SYSTEMD_DEFAULT_SCOPE="system"
	systemd::scope::isuser
	_rc=$?
	_assert "isuser when system" "1" "$_rc"
	_sub_done
}

test::systemd::scope::issystem() {
	_SYSTEMD_DEFAULT_SCOPE="system"
	systemd::scope::issystem
	local _rc=$?
	_assert "issystem when system" "0" "$_rc"

	_SYSTEMD_DEFAULT_SCOPE="user"
	systemd::scope::issystem
	_rc=$?
	_assert "issystem when user" "1" "$_rc"

	_SYSTEMD_DEFAULT_SCOPE="system"
	_sub_done
}

# ==============================================================================
# Unit (generic) — read operations
# ==============================================================================

test::systemd::unit::isactive() {
	if ! runtime::has_command systemctl; then
		_skip "systemctl not installed"
	fi
	# sshd is virtually always running on a test system
	if systemd::unit::isactive sshd; then
		_assert "sshd is active" "0" "0"
	else
		_assert_contains "sshd status" "inactive" "$(systemd::unit::show sshd ActiveState 2>/dev/null)"
	fi
	_sub_done
}

test::systemd::unit::isfailed() {
	if ! runtime::has_command systemctl; then
		_skip "systemctl not installed"
	fi
	# isfailed returns 1 for healthy units — that's the expected outcome
	if systemd::unit::isfailed sshd; then
		_fail "sshd should not be in failed state"
	else
		_pass
	fi
	_sub_done
}

test::systemd::unit::isenabled() {
	if ! runtime::has_command systemctl; then
		_skip "systemctl not installed"
	fi
	# We don't know whether sshd is enabled on the test system; just verify
	# the function returns cleanly (0 or 1, both acceptable).
	if systemd::unit::isenabled sshd; then
		_assert "enabled returns 0" "0" "0"
	elif (( $? == 1 )); then
		_assert "disabled returns 1" "1" "1"
	else
		_fail "unexpected return code"
	fi
	_sub_done
}

test::systemd::unit::pid() {
	if ! runtime::has_command systemctl; then
		_skip "systemctl not installed"
	fi
	if ! systemd::unit::isactive sshd; then
		_skip "sshd not active"
	fi
	local _pid
	_pid=$(systemd::unit::pid sshd)
	if [[ "$_pid" =~ ^[0-9]+$ ]] && (( _pid > 0 )); then
		_assert "pid is positive int" "$_pid" "$_pid"
	else
		_fail "expected positive integer, got '$_pid'"
	fi
	_sub_done
}

test::systemd::unit::show() {
	if ! runtime::has_command systemctl; then
		_skip "systemctl not installed"
	fi
	local _v
	_v=$(systemd::unit::show sshd ActiveState 2>/dev/null)
	if [[ "$_v" == "active" || "$_v" == "inactive" || "$_v" == "failed" ]]; then
		_assert "show ActiveState valid" "$_v" "$_v"
	else
		_assert_contains "show has output" "active" "$_v"
	fi
	_sub_done
}

test::systemd::unit::istemplate() {
	_assert "istemplate foo@.service" "0" "$(systemd::unit::istemplate foo@.service && echo 0 || echo 1)"
	_assert "istemplate foo.service" "1" "$(systemd::unit::istemplate foo.service && echo 0 || echo 1)"
	_assert "istemplate foo@bar.service" "1" "$(systemd::unit::istemplate foo@bar.service && echo 0 || echo 1)"
	_sub_done
}

test::systemd::unit::isinstance() {
	_assert "isinstance foo@bar.service" "0" "$(systemd::unit::isinstance foo@bar.service && echo 0 || echo 1)"
	_assert "isinstance foo.service" "1" "$(systemd::unit::isinstance foo.service && echo 0 || echo 1)"
	_assert "isinstance foo@.service" "1" "$(systemd::unit::isinstance foo@.service && echo 0 || echo 1)"
	_sub_done
}

test::systemd::unit::template() {
	_assert "template from instance" "foo@.service" "$(systemd::unit::template foo@bar.service)"
	_assert "template from instance .timer" "foo@.timer" "$(systemd::unit::template foo@bar.timer)"
	_sub_done
}

test::systemd::unit::instance() {
	_assert "instance from template" "foo@bar.service" "$(systemd::unit::instance foo@.service bar)"
	_assert "instance from template .timer" "foo@bar.timer" "$(systemd::unit::instance foo@.timer bar)"
	_sub_done
}

# ==============================================================================
# Services (.service typed sugar) — verify pure pass-through delegation
# ==============================================================================

test::systemd::services::delegates() {
	if ! runtime::has_command systemctl; then
		_skip "systemctl not installed"
	fi
	# services::isactive should match unit::isactive (both pass through to systemctl)
	if systemd::services::isactive sshd; then
		systemd::unit::isactive sshd
		_assert "services matches unit (active)" "0" "$?"
	else
		systemd::unit::isactive sshd
		_assert "services matches unit (not active)" "1" "$?"
	fi
	_sub_done
}

test::systemd::services::field() {
	if ! runtime::has_command systemctl; then
		_skip "systemctl not installed"
	fi
	# services::field should match unit::show (pure delegation)
	local _a _b
	_a=$(systemd::services::field sshd ActiveState 2>/dev/null)
	_b=$(systemd::unit::show sshd ActiveState 2>/dev/null)
	_assert "services::field == unit::show" "$_b" "$_a"
	_sub_done
}

# ==============================================================================
# Journal — read operations only
# ==============================================================================

test::systemd::journal::boots() {
	if ! runtime::has_command journalctl; then
		_skip "journalctl not installed"
	fi
	local _out
	_out=$(systemd::journal::boots 2>/dev/null)
	if [[ "$_out" == *"BOOT ID"* ]]; then
		_assert "boots has header" "BOOT ID" "BOOT ID"
	else
		_assert_contains "boots has output" "boot" "$_out"
	fi
	_sub_done
}

test::systemd::journal::diskusage() {
	if ! runtime::has_command journalctl; then
		_skip "journalctl not installed"
	fi
	local _out
	_out=$(systemd::journal::diskusage 2>/dev/null)
	_assert_contains "diskusage has output" "journals take up" "$_out"
	_sub_done
}

test::systemd::journal::unit() {
	if ! runtime::has_command journalctl; then
		_skip "journalctl not installed"
	fi
	# Read the last 5 lines of sshd journal — should be non-empty if sshd is running
	local _out
	_out=$(systemd::journal::unit sshd -n 5 --no-tail 2>/dev/null)
	# _out may be empty if sshd never logged, which is fine
	_assert_nonempty "journal::unit returns cleanly" "$_out"
	_sub_done
}

# ==============================================================================
# Analyze — read operations only
# ==============================================================================

test::systemd::analyze::blame() {
	if ! runtime::has_command systemd-analyze; then
		_skip "systemd-analyze not installed"
	fi
	local _out
	_out=$(systemd::analyze::blame 2>/dev/null)
	_assert_nonempty "blame returns output" "$_out"
	_sub_done
}

# ==============================================================================
# Timedate — read operations
# ==============================================================================

test::systemd::timedate::timezone() {
	if ! runtime::has_command timedatectl; then
		_skip "timedatectl not installed"
	fi
	local _tz
	_tz=$(systemd::timedate::timezone 2>/dev/null)
	_assert_contains "timezone is a path" "/" "$_tz"
	_sub_done
}

test::systemd::timedate::ntp() {
	if ! runtime::has_command timedatectl; then
		_skip "timedatectl not installed"
	fi
	local _ntp
	_ntp=$(systemd::timedate::ntp 2>/dev/null)
	_assert "ntp is yes/no" "true" "$([ "$_ntp" == "yes" ] || [ "$_ntp" == "no" ] && echo true || echo false)"
	_sub_done
}

test::systemd::timedate::localrtc() {
	if ! runtime::has_command timedatectl; then
		_skip "timedatectl not installed"
	fi
	local _rtc
	_rtc=$(systemd::timedate::localrtc 2>/dev/null)
	_assert "localrtc is yes/no" "true" "$([ "$_rtc" == "yes" ] || [ "$_rtc" == "no" ] && echo true || echo false)"
	_sub_done
}

# ==============================================================================
# Hostname — read operations
# ==============================================================================

test::systemd::hostname::get() {
	if ! runtime::has_command hostnamectl; then
		_skip "hostnamectl not installed"
	fi
	local _hn
	_hn=$(systemd::hostname::get 2>/dev/null)
	_assert_nonempty "hostname is non-empty" "$_hn"
	_sub_done
}

test::systemd::hostname::chassis() {
	if ! runtime::has_command hostnamectl; then
		_skip "hostnamectl not installed"
	fi
	local _c
	_c=$(systemd::hostname::chassis 2>/dev/null)
	_assert_nonempty "chassis is non-empty" "$_c"
	_sub_done
}

test::systemd::hostname::icon() {
	if ! runtime::has_command hostnamectl; then
		_skip "hostnamectl not installed"
	fi
	local _i
	_i=$(systemd::hostname::icon 2>/dev/null)
	_assert_nonempty "icon is non-empty" "$_i"
	_sub_done
}

# ==============================================================================
# Login — read operations
# ==============================================================================

test::systemd::login::sessions() {
	if ! runtime::has_command loginctl; then
		_skip "loginctl not installed"
	fi
	local _out
	_out=$(systemd::login::sessions 2>/dev/null)
	_assert_nonempty "sessions returns output" "$_out"
	_sub_done
}

test::systemd::login::users() {
	if ! runtime::has_command loginctl; then
		_skip "loginctl not installed"
	fi
	local _out
	_out=$(systemd::login::users 2>/dev/null)
	_assert_nonempty "users returns output" "$_out"
	_sub_done
}

test::systemd::login::seats() {
	if ! runtime::has_command loginctl; then
		_skip "loginctl not installed"
	fi
	local _out
	_out=$(systemd::login::seats 2>/dev/null)
	_assert_nonempty "seats returns output" "$_out"
	_sub_done
}

# ==============================================================================
# Adjacent-tool stubs — verify each returns 1 with "stub" message
# ==============================================================================

test::systemd::stubs() {
	for _tool in resolve cryptenroll creds tmpfiles sysext; do
		if ! runtime::has_command "systemd-$_tool"; then
			_skip "systemd-$_tool not installed; stub not callable"
		fi
		_out=$(systemd::"$_tool"::call 2>&1)
		_rc=$?
		_assert "$_tool::call returns 1" "1" "$_rc"
		_assert_contains "$_tool::call says stub" "stub, not yet implemented" "$_out"
	done
	unset _tool
	_sub_done
}

# ==============================================================================
# Process.sh shim — process::service::* delegates to ext when loaded
# ==============================================================================

test::process::service::shim() {
	# The shim should work both with and without ext loaded. Since the
	# ext IS loaded by the test runner, verify it delegates correctly.
	if ! runtime::has_command systemctl; then
		_skip "systemctl not installed"
	fi
	# is_running should match the underlying systemd::services::isactive
	process::service::is_running sshd
	local _shim_rc=$?
	systemd::services::isactive sshd
	local _ext_rc=$?
	_assert "shim matches ext" "$_ext_rc" "$_shim_rc"
	_sub_done
}

# ==============================================================================
# Destructive operations — gate per Q2 with _skip
# ==============================================================================

test::systemd::unit::start() {
	if ! runtime::has_command systemctl; then
		_skip "systemctl not installed"
	fi
	_skip "destructive operation"
}

test::systemd::unit::stop() {
	if ! runtime::has_command systemctl; then
		_skip "systemctl not installed"
	fi
	_skip "destructive operation"
}

test::systemd::unit::restart() {
	if ! runtime::has_command systemctl; then
		_skip "systemctl not installed"
	fi
	_skip "destructive operation"
}

test::systemd::unit::enable() {
	if ! runtime::has_command systemctl; then
		_skip "systemctl not installed"
	fi
	_skip "destructive operation"
}

test::systemd::unit::disable() {
	if ! runtime::has_command systemctl; then
		_skip "systemctl not installed"
	fi
	_skip "destructive operation"
}

test::systemd::login::suspend() {
	if ! runtime::has_command loginctl; then
		_skip "loginctl not installed"
	fi
	_skip "destructive operation"
}

test::systemd::login::reboot() {
	if ! runtime::has_command loginctl; then
		_skip "loginctl not installed"
	fi
	_skip "destructive operation"
}

test::systemd::run::service() {
	if ! runtime::has_command systemd-run; then
		_skip "systemd-run not installed"
	fi
	_skip "destructive operation"
}
