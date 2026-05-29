# shellcheck shell=bash
# shellcheck disable=SC2154
# ext/json/kv.sh — Stateful JSON container context (read + write)
# Requires: runtime string json
#
# KV state lives in the caller's _ctx:
#   kv_root, kv_path, kv_cstart, kv_cend, kv_ctype
#
# All functions take _ctx as first param.  No module-level globals.
# Char access inlined to avoid bash nameref/printf -v scoping issues.

declare -f 'json::get' &>/dev/null || {
	echo "${BASH_SOURCE[0]}: json.sh not found — source it first" >&2
	return 1
}
# --- end guard ---

_json::_kv_require() {
	local -n _cr="$1"
	[[ -n "${_cr[kv_root]:-}" ]] && return 0
	echo "json::kv: no context — call json::kv first" >&2
	return 1
}

_json::_kv_enter() {
	local -n _cr="$1"
	local _root="${_cr[kv_root]}" _path="${_cr[kv_path]:-}"
	local -A _pc
	_json::_ctx_init _pc "$_root"

	if [[ -n "$_path" ]]; then
		local _norm_path _segments _segment _i
		_norm_path="$(_json::_normalise_path "$_path")"
		string::split::fast _segments '.' "$_norm_path"
		for (( _i=0; _i<${#_segments[@]}; _i++ )); do
			_segment="${_segments[$_i]}"
			_json::_skip_ws _pc
			local _char _p="${_pc[pos]}"
			if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
			case "$_char" in
				'{') _json::_find_key _pc "$_segment" || {
					echo "json::kv: key '$_segment' not found" >&2; return 1; } ;;
				'[') string::is_integer "$_segment" || {
					echo "json::kv: index must be integer" >&2; return 1; }
					_json::_find_index _pc "$_segment" || {
						echo "json::kv: index out of bounds" >&2; return 1; } ;;
				*) echo "json::kv: cannot navigate into scalar" >&2; return 1 ;;
			esac
		done
	fi

	_json::_skip_ws _pc
	_cr[kv_cstart]="${_pc[pos]}"
	_cr[kv_ctype]="object"
	local _char _p="${_pc[pos]}"
	if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
	[[ "$_char" == '[' ]] && _cr[kv_ctype]="array"

	local _opener
	_p="${_pc[pos]}"
	if (( _pc[use_array] )); then _opener="${_pc[chars,$_p]}"; else _opener="${_pc[buf]:$_p:1}"; fi
	[[ "$_opener" == '{' || "$_opener" == '[' ]] || return 1

	_json::_ctx_maybe_index _pc
	local _d=0 _closer="${_JSON_CLOSER[$_opener]}" _c
	((_pc[pos]++))
	while (( _pc[pos] < _pc[len] )); do
		_p="${_pc[pos]}"
		if (( _pc[use_array] )); then _c="${_pc[chars,$_p]}"; else _c="${_pc[buf]:$_p:1}"; fi
		case "$_c" in
			"$_opener") ((_d++)) ;;
			"$_closer")
				(( _d == 0 )) && { _cr[kv_cend]="${_pc[pos]}"; return 0; }
				((_d--)) ;;
			'"') _json::_skip_string _pc; continue ;;
		esac
		((_pc[pos]++))
	done
	return 1
}

_json::_kv_scan_entries() {
	local -n _cr="$1"
	local -A _pc
	_json::_ctx_init _pc "${_cr[kv_root]}"
	_pc[pos]="$((_cr[kv_cstart] + 1))"
	_json_entries=()
	local _opener="${_cr[kv_root]:${_cr[kv_cstart]}:1}" _char _p

	if [[ "$_opener" == '{' ]]; then
		_json::_skip_ws _pc
		_p="${_pc[pos]}"
		if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
		[[ "$_char" == '}' ]] && return
		while (( _pc[pos] < _pc[len] )); do
			local _ks="${_pc[pos]}"
			_json::_skip_string _pc
			local _ke=$((_pc[pos] - 1))
			_json::_skip_ws _pc; ((_pc[pos]++))
			local _vs="${_pc[pos]}"
			_json::_skip_value _pc
			local _ve=$((_pc[pos] - 1))
			_json_entries+=("$_ks $_ke $_vs $_ve")
			_json::_skip_ws _pc
			_p="${_pc[pos]}"
			if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
			[[ "$_char" == ',' ]] && { ((_pc[pos]++)); _json::_skip_ws _pc; }
			_p="${_pc[pos]}"
			if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
			[[ "$_char" == '}' ]] && break
		done
	else
		_json::_skip_ws _pc
		_p="${_pc[pos]}"
		if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
		[[ "$_char" == ']' ]] && return
		local _ai=0
		while (( _pc[pos] < _pc[len] )); do
			local _vs="${_pc[pos]}"
			_json::_skip_value _pc
			local _ve=$((_pc[pos] - 1))
			_json_entries+=("$_ai $_ai $_vs $_ve")
			((_ai++)); _json::_skip_ws _pc
			_p="${_pc[pos]}"
			if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
			[[ "$_char" == ',' ]] && { ((_pc[pos]++)); _json::_skip_ws _pc; }
			_p="${_pc[pos]}"
			if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
			[[ "$_char" == ']' ]] && break
		done
	fi
}

_json::_kv_rebuild() {
	local -n _cr="$1"
	local _new="$2"
	local _pre="${_cr[kv_root]:0:${_cr[kv_cstart]}}"
	local _post="${_cr[kv_root]:$(( ${_cr[kv_cend]} + 1 ))}"
	_cr[kv_root]="$_pre$_new$_post"
	_cr[kv_cend]=$(( ${_cr[kv_cstart]} + ${#_new} - 1 ))
}

# --- Public API ---

json::kv() {
	local -n _cr="$1"
	_cr[kv_root]="$2"
	_cr[kv_path]="${3:-}"
	_cr[kv_cstart]=0; _cr[kv_cend]=0; _cr[kv_ctype]=""
	_json::_kv_enter "$1" || { _cr[kv_root]=""; return 1; }
	[[ "${_cr[kv_ctype]}" == "object" || "${_cr[kv_ctype]}" == "array" ]] && return 0
	echo "json::kv: path does not point to a container" >&2
	_cr[kv_root]=""; return 1
}

json::kv::keys() {
	local -n _cr="$1"; local _char _p
	_json::_kv_require "$1" || return 1
	_json::_kv_enter "$1" || return 1
	local -A _pc
	_json::_ctx_init _pc "${_cr[kv_root]}"
	_pc[pos]="${_cr[kv_cstart]}"
	_p="${_pc[pos]}"
	if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
	local _opener="$_char"

	if [[ "$_opener" == '{' ]]; then
		((_pc[pos]++))
		_json::_skip_ws _pc
		_p="${_pc[pos]}"
		if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
		[[ "$_char" == '}' ]] && return 0
		while (( _pc[pos] < _pc[len] )); do
			local _kn; _json::_read_string _pc _kn; printf '%s\n' "$_kn"
			_json::_skip_ws _pc; ((_pc[pos]++)); _json::_skip_value _pc
			_json::_skip_ws _pc
			_p="${_pc[pos]}"
			if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
			[[ "$_char" == ',' ]] && { ((_pc[pos]++)); _json::_skip_ws _pc; }
			_p="${_pc[pos]}"
			if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
			[[ "$_char" == '}' ]] && break
		done
	else
		local _ai=0
		((_pc[pos]++))
		_json::_skip_ws _pc
		_p="${_pc[pos]}"
		if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
		[[ "$_char" == ']' ]] && return 0
		while (( _pc[pos] < _pc[len] )); do
			printf '%d\n' "$_ai"; ((_ai++)); _json::_skip_value _pc
			_json::_skip_ws _pc
			_p="${_pc[pos]}"
			if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
			[[ "$_char" == ',' ]] && { ((_pc[pos]++)); _json::_skip_ws _pc; }
			_p="${_pc[pos]}"
			if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
			[[ "$_char" == ']' ]] && break
		done
	fi
}

json::kv::keys::exists() {
	local -n _cr="$1"; local _char _p
	_json::_kv_require "$1" || return 1
	[[ "${_cr[kv_ctype]}" != "object" ]] && {
		echo "json::kv::keys::exists: not an object" >&2; return 1; }
	_json::_kv_enter "$1" || return 1
	local -A _pc
	_json::_ctx_init _pc "${_cr[kv_root]}"
	_pc[pos]="${_cr[kv_cstart]}"
	_json::_find_key _pc "$2"
}

json::kv::value::get() {
	local -n _cr="$1"; local _char _p
	_json::_kv_require "$1" || return 1
	_json::_kv_enter "$1" || return 1
	local -A _pc
	_json::_ctx_init _pc "${_cr[kv_root]}"
	_pc[pos]="${_cr[kv_cstart]}"
	if [[ "${_cr[kv_ctype]}" == "object" ]]; then
		_json::_find_key _pc "$2" || { echo "json::kv::value::get: key '$2' not found" >&2; return 1; }
	else
		string::is_integer "$2" || { echo "json::kv::value::get: index must be integer" >&2; return 1; }
		_json::_find_index _pc "$2" || { echo "json::kv::value::get: index out of bounds" >&2; return 1; }
	fi
	_json::_read_value _pc
}

json::kv::value::type() {
	local -n _cr="$1"; local _char _p
	_json::_kv_require "$1" || return 1
	_json::_kv_enter "$1" || return 1
	local -A _pc
	_json::_ctx_init _pc "${_cr[kv_root]}"
	_pc[pos]="${_cr[kv_cstart]}"
	if [[ "${_cr[kv_ctype]}" == "object" ]]; then
		_json::_find_key _pc "$2" || { echo "json::kv::value::type: key '$2' not found" >&2; return 1; }
	else
		string::is_integer "$2" || { echo "json::kv::value::type: index must be integer" >&2; return 1; }
		_json::_find_index _pc "$2" || { echo "json::kv::value::type: index out of bounds" >&2; return 1; }
	fi
	_json::_skip_ws _pc
	_p="${_pc[pos]}"
	if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
	case "$_char" in
		'{') echo "object" ;; '[') echo "array" ;; '"') echo "string" ;;
		[0-9\-]) echo "number" ;; t|f) echo "boolean" ;; n) echo "null" ;;
	esac
}

json::kv::list() {
	local -n _cr="$1"; local _char _p
	local _fmt="${2:-}"
	_json::_kv_require "$1" || return 1
	_json::_kv_enter "$1" || return 1
	local -A _pc
	_json::_ctx_init _pc "${_cr[kv_root]}"
	_pc[pos]="$(( ${_cr[kv_cstart]} + 1 ))"
	local _opener="${_cr[kv_root]:${_cr[kv_cstart]}:1}"

	if [[ "$_fmt" == "json" ]]; then
		printf '%s\n' "${_cr[kv_root]:${_cr[kv_cstart]}:$(( ${_cr[kv_cend]} - ${_cr[kv_cstart]} + 1 ))}"
		return
	fi

	if [[ "$_fmt" == "csv" ]]; then
		local _first=1
		if [[ "$_opener" == '{' ]]; then
			_json::_skip_ws _pc
			_p="${_pc[pos]}"
			if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
			[[ "$_char" == '}' ]] && { echo; return; }
			while (( _pc[pos] < _pc[len] )); do
				_json::_skip_string _pc; _json::_skip_ws _pc; ((_pc[pos]++))
				_json::_read_raw_span _pc
				((_first)) && _first=0 || printf ','
				printf '%s' "${_cr[kv_root]:${_pc[raw_start]}:$(( ${_pc[raw_end]} - ${_pc[raw_start]} + 1 ))}"
				_pc[pos]=$(( ${_pc[raw_end]} + 1 ))
				_json::_skip_ws _pc
				_p="${_pc[pos]}"
				if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
				[[ "$_char" == ',' ]] && { ((_pc[pos]++)); _json::_skip_ws _pc; }
				_p="${_pc[pos]}"
				if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
				[[ "$_char" == '}' ]] && break
			done
		else
			_json::_skip_ws _pc
			_p="${_pc[pos]}"
			if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
			[[ "$_char" == ']' ]] && { echo; return; }
			while (( _pc[pos] < _pc[len] )); do
				_json::_read_raw_span _pc
				((_first)) && _first=0 || printf ','
				printf '%s' "${_cr[kv_root]:${_pc[raw_start]}:$(( ${_pc[raw_end]} - ${_pc[raw_start]} + 1 ))}"
				_pc[pos]=$(( ${_pc[raw_end]} + 1 ))
				_json::_skip_ws _pc
				_p="${_pc[pos]}"
				if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
				[[ "$_char" == ',' ]] && { ((_pc[pos]++)); _json::_skip_ws _pc; }
				_p="${_pc[pos]}"
				if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
				[[ "$_char" == ']' ]] && break
			done
		fi
		echo; return
	fi

	if [[ "$_opener" == '{' ]]; then
		_json::_skip_ws _pc
		_p="${_pc[pos]}"
		if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
		[[ "$_char" == '}' ]] && return
		while (( _pc[pos] < _pc[len] )); do
			local _kn; _json::_read_string _pc _kn
			_json::_skip_ws _pc; ((_pc[pos]++))
			printf '%s\t' "$_kn"; _json::_read_value _pc; echo
			_json::_skip_ws _pc
			_p="${_pc[pos]}"
			if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
			[[ "$_char" == ',' ]] && { ((_pc[pos]++)); _json::_skip_ws _pc; }
			_p="${_pc[pos]}"
			if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
			[[ "$_char" == '}' ]] && break
		done
	else
		local _ai=0
		_json::_skip_ws _pc
		_p="${_pc[pos]}"
		if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
		[[ "$_char" == ']' ]] && return
		while (( _pc[pos] < _pc[len] )); do
			printf '%d\t' "$_ai"; ((_ai++)); _json::_read_value _pc; echo
			_json::_skip_ws _pc
			_p="${_pc[pos]}"
			if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
			[[ "$_char" == ',' ]] && { ((_pc[pos]++)); _json::_skip_ws _pc; }
			_p="${_pc[pos]}"
			if (( _pc[use_array] )); then _char="${_pc[chars,$_p]}"; else _char="${_pc[buf]:$_p:1}"; fi
			[[ "$_char" == ']' ]] && break
		done
	fi
}

json::kv::count() {
	local -n _cr="$1"
	_json::_kv_require "$1" || return 1
	_json::_kv_enter "$1" || return 1
	local _root="${_cr[kv_root]}" _path="${_cr[kv_path]:-}"
	local -A _pc
	_json::_ctx_init _pc "$_root"
	[[ -n "$_path" ]] && { _json::_navigate _pc "$_path" || return 1; }
	json::len _pc "$_root" ""
}

json::kv::at() {
	local -n _cr="$1"
	_json::_kv_require "$1" || return 1
	local _rel="$2"
	local _old_path="${_cr[kv_path]:-}"
	[[ -n "$_old_path" ]] && _cr[kv_path]="${_old_path}.${_rel}" || _cr[kv_path]="$_rel"
	_json::_kv_enter "$1" || { _cr[kv_path]="${_cr[kv_path]%.*}"; return 1; }
	[[ "${_cr[kv_ctype]}" == "object" || "${_cr[kv_ctype]}" == "array" ]] && return 0
	_cr[kv_path]="${_cr[kv_path]%.*}"
	echo "json::kv::at: '$_rel' does not point to a container" >&2
	return 1
}

json::kv::parent() {
	local -n _cr="$1"
	_json::_kv_require "$1" || return 1
	local _path="${_cr[kv_path]:-}"
	[[ -z "$_path" ]] && { echo "json::kv::parent: already at root" >&2; return 1; }
	_cr[kv_path]="${_path%.*}"
	[[ "${_cr[kv_path]}" != *.* ]] && _cr[kv_path]=""
	_json::_kv_enter "$1" || return 1
}

json::kv::root() {
	local -n _cr="$1"
	_json::_kv_require "$1" || return 1
	_cr[kv_path]=""
	_json::_kv_enter "$1" || return 1
}

json::kv::value::set() {
	local -n _cr="$1"
	local _key="$2" _val="$3"
	_json::_kv_require "$1" || return 1
	_json::_kv_enter "$1" || return 1
	_json::_kv_scan_entries "$1"
	local _opener="${_cr[kv_root]:${_cr[kv_cstart]}:1}"
	local _closer="${_JSON_CLOSER[$_opener]}"
	local _new="$_opener" _first=1 _found=0 _e _ks _ke _vs _ve
	if [[ "$_opener" == '{' ]]; then
		for _e in "${_json_entries[@]}"; do
			read -r _ks _ke _vs _ve <<< "$_e"
			local _ek="${_cr[kv_root]:_ks:$((_ke - _ks + 1))}"
			(( _first )) && _first=0 || _new+=","
			if [[ "${_ek:1:-1}" == "$_key" ]]; then
				_new+="\"$_key\":$_val"; _found=1
			else
				_new+="${_cr[kv_root]:_ks:$((_ke - _ks + 1))}:${_cr[kv_root]:_vs:$((_ve - _vs + 1))}"
			fi
		done
		(( ! _found )) && { (( ${#_json_entries[@]} > 0 )) && _new+=","; _new+="\"$_key\":$_val"; }
	else
		for _e in "${_json_entries[@]}"; do
			read -r _ks _ke _vs _ve <<< "$_e"
			(( _first )) && _first=0 || _new+=","
			_new+="${_cr[kv_root]:_vs:$((_ve - _vs + 1))}"
		done
	fi
	_new+="$_closer"
	_json::_kv_rebuild "$1" "$_new"
}

json::kv::keys::remove() {
	local -n _cr="$1"
	_json::_kv_require "$1" || return 1
	[[ "${_cr[kv_ctype]}" != "object" ]] && {
		echo "json::kv::keys::remove: not an object" >&2; return 1; }
	_json::_kv_enter "$1" || return 1
	_json::_kv_scan_entries "$1"
	local _new="{" _first=1 _found=0 _e _ks _ke _vs _ve
	for _e in "${_json_entries[@]}"; do
		read -r _ks _ke _vs _ve <<< "$_e"
		local _ek="${_cr[kv_root]:_ks:$((_ke - _ks + 1))}"
		if [[ "${_ek:1:-1}" == "$2" ]]; then _found=1; continue; fi
		(( _first )) && _first=0 || _new+=","
		_new+="${_cr[kv_root]:_ks:$((_ke - _ks + 1))}:${_cr[kv_root]:_vs:$((_ve - _vs + 1))}"
	done
	_new+="}"
	(( _found )) || { echo "json::kv::keys::remove: key '$2' not found" >&2; return 1; }
	_json::_kv_rebuild "$1" "$_new"
}

json::kv::keys::rename() {
	local -n _cr="$1"
	_json::_kv_require "$1" || return 1
	[[ "${_cr[kv_ctype]}" != "object" ]] && {
		echo "json::kv::keys::rename: not an object" >&2; return 1; }
	_json::_kv_enter "$1" || return 1
	_json::_kv_scan_entries "$1"
	local _new="{" _first=1 _found=0 _e _ks _ke _vs _ve
	for _e in "${_json_entries[@]}"; do
		read -r _ks _ke _vs _ve <<< "$_e"
		local _ek="${_cr[kv_root]:_ks:$((_ke - _ks + 1))}"
		(( _first )) && _first=0 || _new+=","
		if [[ "${_ek:1:-1}" == "$2" ]]; then
			_new+="\"$3\":${_cr[kv_root]:_vs:$((_ve - _vs + 1))}"; _found=1
		else
			_new+="${_cr[kv_root]:_ks:$((_ke - _ks + 1))}:${_cr[kv_root]:_vs:$((_ve - _vs + 1))}"
		fi
	done
	_new+="}"
	(( _found )) || { echo "json::kv::keys::rename: key '$2' not found" >&2; return 1; }
	_json::_kv_rebuild "$1" "$_new"
}
