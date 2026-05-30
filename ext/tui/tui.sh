# shellcheck shell=bash
# ext/tui.sh — TUI primitives via dialog/whiptail
# Requires: runtime (runtime::has_command)
#
# Provides high-level wrappers for dialog boxes, menus, progress bars,
# and input forms. Uses dialog (ncurses) when available, falls back to
# whiptail (newt), then to plain bash I/O.
#
# Usage:
#   source ext/tui/tui.sh
#
#   local -A _ctx
#   _ctx[title]="Confirm"
#   tui::yesno _ctx "Continue?"

# --- Guard ---

declare -f 'runtime::bash_version' &>/dev/null || {
	echo "${BASH_SOURCE[0]}: runtime not found — source bash-framehead.sh first" >&2
	return 1
}

# --- Backend detection ---

_tui_backend=""

_tui::_detect() {
	[[ -n "$_tui_backend" ]] && return 0
	if runtime::has_command dialog; then
		_tui_backend="dialog"
	elif runtime::has_command whiptail; then
		_tui_backend="whiptail"
	else
		_tui_backend=""
	fi
}

tui::is_available() {
	_tui::_detect
	[[ -n "$_tui_backend" ]]
}

tui::backend() {
	_tui::_detect
	echo "$_tui_backend"
}

# --- Helpers ---

# Build common args from context nameref
# Usage: _tui::_build_args _ctx
# Sets _tui_args array
_tui::_build_args() {
	local -n _ref="$1"
	_tui_args=()
	[[ -n "${_ref[title]:-}" ]] && _tui_args+=(--title "${_ref[title]}")
	[[ -n "${_ref[backtitle]:-}" ]] && _tui_args+=(--backtitle "${_ref[backtitle]}")
	[[ "${_ref[clear_on_exit]:-}" == "1" ]] && _tui_args+=(--clear)
	[[ "${_ref[defaultno]:-}" == "1" ]] && _tui_args+=(--defaultno)
	[[ "${_ref[nocancel]:-}" == "1" ]] && _tui_args+=(--nocancel)
	[[ "${_ref[scroll]:-}" == "1" ]] && _tui_args+=(--scrolltext)
	[[ "${_ref[topleft]:-}" == "1" ]] && _tui_args+=(--topleft)
	[[ -n "${_ref[output_fd]:-}" ]] && _tui_args+=(--output-fd "${_ref[output_fd]}")
	[[ "${_ref[separate]:-}" == "1" ]] && _tui_args+=(--separate-output)
	[[ -n "${_ref[ok_txt]:-}" ]] && _tui_args+=(--ok-button "${_ref[ok_txt]}")
	[[ -n "${_ref[cancel_txt]:-}" ]] && _tui_args+=(--cancel-button "${_ref[cancel_txt]}")
	[[ -n "${_ref[yes_txt]:-}" ]] && _tui_args+=(--yes-button "${_ref[yes_txt]}")
	[[ -n "${_ref[no_txt]:-}" ]] && _tui_args+=(--no-button "${_ref[no_txt]}")
	[[ -n "${_ref[default_item]:-}" ]] && _tui_args+=(--default-item "${_ref[default_item]}")
}

# Get height/width from context with defaults
_tui::_get_dims() {
	local -n _ref="$1"
	local _def_h="${2:-8}" _def_w="${3:-60}"
	_tui_h="${_ref[height]:-$_def_h}"
	_tui_w="${_ref[width]:-$_def_w}"
}

# --- FALLBACK FUNCTIONS ---

# Fallback msgbox: echo text
_tui::_fallback_msgbox() {
	local _text="$1"
	echo "$_text"
	return 0
}

# Fallback yesno: prompt [y/N]
_tui::_fallback_yesno() {
	local _text="$1"
	echo -n "$_text [y/N] "
	local _ans
	read -rs _ans
	echo
	[[ "$_ans" == "y" || "$_ans" == "Y" ]]
}

# Fallback inputbox: prompt with default
_tui::_fallback_inputbox() {
	local _text="$1" _init="${2:-}"
	echo -n "$_text"
	[[ -n "$_init" ]] && echo -n " [$_init]"
	echo -n ": "
	local _val
	read -r _val
	echo "${_val:-$_init}"
}

# Fallback passwordbox: hidden prompt
_tui::_fallback_passwordbox() {
	local _text="$1"
	echo -n "$_text: "
	local _val
	read -rs _val
	echo
	echo "$_val"
}

# Fallback menu: numbered list
_tui::_fallback_menu() {
	local -n _items="$1"
	local _def_h="${2:-15}"
	local _i=1
	while (( _i < ${#_items[@]} )); do
		echo "  $_i) ${_items[$_i]}"
		(( _i += 2 ))
	done
	echo -n "Choice [1-$((_i / 2))]: "
	local _choice
	read -r _choice
	local _idx=$(( (_choice - 1) * 2 ))
	echo "${_items[$_idx]}"
}

# Fallback checklist: numbered list with comma-separated selection
_tui::_fallback_checklist() {
	local -n _items="$1"
	local _i=1
	while (( _i < ${#_items[@]} )); do
		[[ "${_items[$((_i + 1))]}" == "on" ]] && echo "  [x] ${_items[$_i]}" || echo "  [ ] ${_items[$_i]}"
		(( _i += 3 ))
	done
	echo -n "Choices (comma-separated): "
	local _result
	read -r _result
	echo "$_result"
}

# Fallback radiolist: numbered list with single selection
_tui::_fallback_radiolist() {
	local -n _items="$1"
	local _i=1
	while (( _i < ${#_items[@]} )); do
		echo "  $_i) ${_items[$_i]}"
		(( _i += 3 ))
	done
	echo -n "Choice [1-$((_i / 3))]: "
	local _choice
	read -r _choice
	local _idx=$(( (_choice - 1) * 3 ))
	echo "${_items[$_idx]}"
}

# Fallback infobox: echo text
_tui::_fallback_infobox() {
	echo "$1"
}

# Fallback textbox: cat file
_tui::_fallback_textbox() {
	local _file="$1"
	[[ -f "$_file" ]] && cat "$_file"
}

# Fallback gauge: echo percentage
_tui::_fallback_gauge() {
	echo "[${2:-0}%] ${1:-}"
}

# --- COMMON FUNCTIONS ---

tui::msgbox() {
	local -n _ctx="$1"; shift
	local _text="$1"
	_tui::_detect || { _tui::_fallback_msgbox "$_text"; return; }
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 8 60
	"$_tui_backend" --msgbox "$_text" "$_tui_h" "$_tui_w" "${_tui_args[@]}" 2>/dev/null
}

tui::yesno() {
	local -n _ctx="$1"; shift
	local _text="$1"
	_tui::_detect || { _tui::_fallback_yesno "$_text"; return; }
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 8 60
	"$_tui_backend" --yesno "$_text" "$_tui_h" "$_tui_w" "${_tui_args[@]}" 2>/dev/null
}

tui::inputbox() {
	local -n _ctx="$1"; shift
	local _text="$1" _init="${2:-}"
	_tui::_detect || { _tui::_fallback_inputbox "$_text" "$_init"; return; }
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 8 60
	"$_tui_backend" --inputbox "$_text" "$_tui_h" "$_tui_w" "$_init" "${_tui_args[@]}" 2>&1 1>/dev/tty
}

tui::passwordbox() {
	local -n _ctx="$1"; shift
	local _text="$1"
	_tui::_detect || { _tui::_fallback_passwordbox "$_text"; return; }
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 8 60
	"$_tui_backend" --passwordbox "$_text" "$_tui_h" "$_tui_w" "${_tui_args[@]}" 2>&1 1>/dev/tty
}

tui::infobox() {
	local -n _ctx="$1"; shift
	local _text="$1"
	_tui::_detect || { _tui::_fallback_infobox "$_text"; return; }
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 8 60
	"$_tui_backend" --infobox "$_text" "$_tui_h" "$_tui_w" "${_tui_args[@]}" 2>/dev/null
}

tui::textbox() {
	local -n _ctx="$1"; shift
	local _file="$1"
	_tui::_detect || { _tui::_fallback_textbox "$_file"; return; }
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 20 70
	"$_tui_backend" --textbox "$_file" "$_tui_h" "$_tui_w" "${_tui_args[@]}" 2>/dev/null
}

tui::menu() {
	local -n _ctx="$1"
	local -n _items="$2"
	_tui::_detect || { _tui::_fallback_menu _items; return; }
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 15 60
	local _lh="${_ctx[listheight]:-8}"
	local -a _args=()
	local _i=0
	while (( _i < ${#_items[@]} )); do
		_args+=("${_items[$_i]}" "${_items[$((_i + 1))]}")
		(( _i += 2 ))
	done
	"$_tui_backend" --menu "" "$_tui_h" "$_tui_w" "$_lh" "${_args[@]}" "${_tui_args[@]}" 2>&1 1>/dev/tty
}

tui::checklist() {
	local -n _ctx="$1"
	local -n _items="$2"
	_tui::_detect || { _tui::_fallback_checklist _items; return; }
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 15 60
	local _lh="${_ctx[listheight]:-8}"
	"$_tui_backend" --checklist "" "$_tui_h" "$_tui_w" "$_lh" "${_items[@]}" "${_tui_args[@]}" 2>&1 1>/dev/tty
}

tui::radiolist() {
	local -n _ctx="$1"
	local -n _items="$2"
	_tui::_detect || { _tui::_fallback_radiolist _items; return; }
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 15 60
	local _lh="${_ctx[listheight]:-8}"
	"$_tui_backend" --radiolist "" "$_tui_h" "$_tui_w" "$_lh" "${_items[@]}" "${_tui_args[@]}" 2>&1 1>/dev/tty
}

tui::gauge() {
	local -n _ctx="$1"; shift
	local _text="$1" _pct="${2:-0}"
	_tui::_detect || { _tui::_fallback_gauge "$_text" "$_pct"; return; }
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 8 60
	echo "$_pct" | "$_tui_backend" --gauge "$_text" "$_tui_h" "$_tui_w" "${_tui_args[@]}" 2>/dev/null
}

# --- DIALOG-ONLY FUNCTIONS ---

tui::dialog::calendar() {
	local -n _ctx="$1"; shift
	local _day="$1" _month="$2" _year="$3"
	[[ "$_tui_backend" == "dialog" ]] || return 1
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 10 50
	dialog --calendar "" "$_tui_h" "$_tui_w" "$_day" "$_month" "$_year" "${_tui_args[@]}" 2>&1 1>/dev/tty
}

tui::dialog::fselect() {
	local -n _ctx="$1"; shift
	local _path="$1"
	[[ "$_tui_backend" == "dialog" ]] || return 1
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 15 60
	dialog --fselect "$_path" "$_tui_h" "$_tui_w" "${_tui_args[@]}" 2>&1 1>/dev/tty
}

tui::dialog::timebox() {
	local -n _ctx="$1"; shift
	local _hour="$1" _min="$2" _sec="$3"
	[[ "$_tui_backend" == "dialog" ]] || return 1
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 10 40
	dialog --timebox "" "$_tui_h" "$_tui_w" "$_hour" "$_min" "$_sec" "${_tui_args[@]}" 2>&1 1>/dev/tty
}

tui::dialog::form() {
	local -n _ctx="$1"
	local -n _labels="$2"
	local -n _types="$3"
	local -n _inits="$4"
	[[ "$_tui_backend" == "dialog" ]] || return 1
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 15 60
	local _lh="${_ctx[listheight]:-0}"
	local -a _form_args=()
	local _i=0
	local _y=1
	while (( _i < ${#_labels[@]} )); do
		_form_args+=("${_labels[$_i]}" "$_y" 1 "${_inits[$_i]:-}" 20 40)
		(( _i++ ))
		(( _y++ ))
	done
	dialog --form "" "$_tui_h" "$_tui_w" "$_lh" "${_form_args[@]}" "${_tui_args[@]}" 2>&1 1>/dev/tty
}

tui::dialog::mixedform() {
	local -n _ctx="$1"
	local -n _labels="$2"
	local -n _types="$3"
	local -n _inits="$4"
	local -n _statuses="$5"
	[[ "$_tui_backend" == "dialog" ]] || return 1
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 15 60
	local _lh="${_ctx[listheight]:-0}"
	local -a _form_args=()
	local _i=0
	local _y=1
	while (( _i < ${#_labels[@]} )); do
		_form_args+=("${_labels[$_i]}" "$_y" 1 "${_inits[$_i]:-}" 20 40 "${_statuses[$_i]:-on}")
		(( _i++ ))
		(( _y++ ))
	done
	dialog --mixedform "" "$_tui_h" "$_tui_w" "$_lh" "${_form_args[@]}" "${_tui_args[@]}" 2>&1 1>/dev/tty
}

tui::dialog::editbox() {
	local -n _ctx="$1"; shift
	local _file="$1"
	[[ "$_tui_backend" == "dialog" ]] || return 1
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 20 70
	dialog --editbox "$_file" "$_tui_h" "$_tui_w" "${_tui_args[@]}" 2>&1 1>/dev/tty
}

tui::dialog::treeview() {
	local -n _ctx="$1"
	local -n _items="$2"
	[[ "$_tui_backend" == "dialog" ]] || return 1
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 20 60
	local _lh="${_ctx[listheight]:-10}"
	dialog --treeview "" "$_tui_h" "$_tui_w" "$_lh" "${_items[@]}" "${_tui_args[@]}" 2>&1 1>/dev/tty
}

tui::dialog::buildlist() {
	local -n _ctx="$1"
	local -n _items="$2"
	[[ "$_tui_backend" == "dialog" ]] || return 1
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 15 60
	local _lh="${_ctx[listheight]:-8}"
	dialog --buildlist "" "$_tui_h" "$_tui_w" "$_lh" "${_items[@]}" "${_tui_args[@]}" 2>&1 1>/dev/tty
}

tui::dialog::rangebox() {
	local -n _ctx="$1"; shift
	local _min="$1" _max="$2" _init="$3"
	[[ "$_tui_backend" == "dialog" ]] || return 1
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 8 50
	dialog --rangebox "" "$_tui_h" "$_tui_w" "$_min" "$_max" "$_init" "${_tui_args[@]}" 2>&1 1>/dev/tty
}

tui::dialog::mixedgauge() {
	local -n _ctx="$1"; shift
	local _text="$1" _pct="$2"; shift 2
	local -n _tasks="$1"
	[[ "$_tui_backend" == "dialog" ]] || return 1
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 10 60
	dialog --mixedgauge "$_text" "$_tui_h" "$_tui_w" "$_pct" "${_tasks[@]}" "${_tui_args[@]}" 2>/dev/null
}

tui::dialog::tailbox() {
	local -n _ctx="$1"; shift
	local _file="$1"
	[[ "$_tui_backend" == "dialog" ]] || return 1
	_tui::_build_args _ctx
	_tui::_get_dims _ctx 20 70
	dialog --tailbox "$_file" "$_tui_h" "$_tui_w" "${_tui_args[@]}" 2>/dev/null
}

# --- STORAGE ---
# Uses | as separator between key=value pairs
# Format: key1=val1|key2=val2|key3=val3

tui::storage::set() {
	local -n _store_ref="$1"
	local _key="$2" _val="$3"
	local _store="${_store_ref[storage]:-}"
	# Remove existing key if present
	if [[ -n "$_store" ]]; then
		_store=$(echo "$_store" | tr '|' '\n' | grep -v "^${_key}=" | tr '\n' '|' | sed 's/|$//')
	fi
	# Append new key=value
	if [[ -n "$_store" ]]; then
		_store_ref[storage]="${_store}|${_key}=${_val}"
	else
		_store_ref[storage]="${_key}=${_val}"
	fi
}

tui::storage::get() {
	local -n _store_ref="$1"
	local _key="$2"
	echo "${_store_ref[storage]}" | tr '|' '\n' | awk -F= -v k="$_key" '$1==k{sub(/^[^=]*=/,""); print}'
}

tui::storage::unset() {
	local -n _store_ref="$1"
	local _key="$2"
	_store_ref[storage]=$(echo "${_store_ref[storage]}" | tr '|' '\n' | grep -v "^${_key}=" | tr '\n' '|' | sed 's/|$//')
}

tui::storage::keys() {
	local -n _store_ref="$1"
	echo "${_store_ref[storage]}" | tr '|' '\n' | awk -F= '{print $1}' | grep -v '^$'
}

tui::storage::dump() {
	local -n _store_ref="$1"
	echo "${_store_ref[storage]}" | tr '|' '\n' | grep -v '^$'
}

# --- UTILITY ---

tui::clear() {
	clear
}

tui::set_size() {
	export LINES="$1" COLUMNS="$2"
}
