# shellcheck shell=bash
# shellcheck disable=SC2154
# ext/json.sh — Pure Bash JSON parser (stateless)
# Requires: runtime string
#
# All parser state lives in an associative array _ctx, passed by the caller.
# Char access is inlined at every call site — no helper abstraction that
# fights bash's nameref/scoping rules.  Explicit, self-contained, zero
# hidden state.

# --- Guard ---

declare -f 'runtime::bash_version' &>/dev/null || {
	echo "${BASH_SOURCE[0]}: runtime not found — source bash-framehead.sh first" >&2
	return 1
}

_guard_core_deps=(string::is_integer string::split::fast)
_guard_ext_deps=()

for _guard_dep in "${_guard_core_deps[@]}"; do
	declare -f "$_guard_dep" &>/dev/null || {
		echo "${BASH_SOURCE[0]}: missing core function '$_guard_dep'" >&2
		return 1
	}
done

for _guard_dep in "${_guard_ext_deps[@]}"; do
	command -v "$_guard_dep" &>/dev/null || {
		echo "${BASH_SOURCE[0]}: missing external tool '$_guard_dep'" >&2
		return 1
	}
done

unset _guard_core_deps _guard_ext_deps _guard_dep
# --- end guard ---

declare -A _JSON_CLOSER=(["{"]="}" ["["]="]")

_json::_decode_unicode() {
	local _hex_digits="$1" _codepoint _utf8_fmt
	[[ "$_hex_digits" =~ ^[0-9a-fA-F]{4}$ ]] || { printf '\\u%s' "$_hex_digits"; return; }
	_codepoint=$(( 16#$_hex_digits ))
	if (( _codepoint < 0x80 )); then
		printf -v _utf8_fmt "\\x%02x" "$_codepoint"
	elif (( _codepoint < 0x800 )); then
		printf -v _utf8_fmt "\\x%02x\\x%02x" \
			"$(( 0xC0 | (_codepoint >> 6) ))" \
			"$(( 0x80 | (_codepoint & 0x3F) ))"
	else
		printf -v _utf8_fmt "\\x%02x\\x%02x\\x%02x" \
			"$(( 0xE0 | (_codepoint >> 12) ))" \
			"$(( 0x80 | ((_codepoint >> 6) & 0x3F) ))" \
			"$(( 0x80 | (_codepoint & 0x3F) ))"
	fi
	printf "$_utf8_fmt"
}

# --- Context init + indexing ---

_json::_ctx_init() {
	local -n _cr="$1"
	_cr[buf]="$2"
	_cr[pos]=0
	_cr[len]="${#2}"
	_cr[use_array]=0
}

_json::_ctx_index() {
	local -n _cr="$1"
	(( _cr[use_array] )) && return 0
	local _buf="${_cr[buf]}" _len="${_cr[len]}" _byte
	(( _len == 0 )) && { _cr[use_array]=1; return 0; }
	local _i=0
	while IFS= read -r -N 1 _byte; do
		_cr[chars,$_i]="$_byte"
		((_i++))
	done <<< "$_buf"
	unset '_cr[chars,'"$_i"']'
	_cr[use_array]=1
}

_json::_quick_scan() {
	local -n _cr="$1"
	local _opener="$2" _closer="${_JSON_CLOSER[$2]}"
	local _scan=$(( _cr[pos] + 1 )) _depth=1 _scan_char _buf="${_cr[buf]}" _len="${_cr[len]}"
	while (( _scan < _len && _scan < _cr[pos] + 64 && _depth > 0 )); do
		_scan_char="${_buf:_scan:1}"
		case "$_scan_char" in
			"$_opener") ((_depth++)) ;;
			"$_closer") ((_depth--)) ;;
			'"')
				((_scan++))
				while (( _scan < _len )); do
					_scan_char="${_buf:_scan:1}"; ((_scan++))
					[[ "$_scan_char" == '\' ]] && { ((_scan++)); continue; }
					[[ "$_scan_char" == '"' ]] && break
				done
				continue ;;
		esac
		((_scan++))
	done
	(( _depth == 0 ))
}

_json::_ctx_maybe_index() {
	local -n _cr="$1"
	(( _cr[use_array] )) && return 0
	_cr[use_array]=0
	local _opener="${_cr[buf]:${_cr[pos]}:1}"
	_json::_quick_scan "$1" "$_opener" && return 0
	_json::_ctx_index "$1"
}

# --- Core primitives (char access inlined) ---

_json::_scan_number() {
	local -n _cr="$1"; local _char _p
	while (( _cr[pos] < _cr[len] )); do
		_p="${_cr[pos]}"
		if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
		[[ "$_char" == [-+0-9.eE] ]] || break
		((_cr[pos]++))
	done
}

_json::_skip_ws() {
	local -n _cr="$1"; local _char _p
	while (( _cr[pos] < _cr[len] )); do
		_p="${_cr[pos]}"
		if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
		[[ "$_char" == [[:space:]] ]] || return 0
		((_cr[pos]++))
	done
}

_json::_skip_string() {
	local -n _cr="$1"; local _char _p
	((_cr[pos]++))
	while (( _cr[pos] < _cr[len] )); do
		_p="${_cr[pos]}"
		if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
		((_cr[pos]++))
		if [[ "$_char" == '\' ]]; then ((_cr[pos]++))
		elif [[ "$_char" == '"' ]]; then return 0; fi
	done
	return 2
}

_json::_read_string() {
	local -n _cr="$1" _out="$2"
	_out=""
	local _char _hex_digits _p _i _r
	((_cr[pos]++))
	while (( _cr[pos] < _cr[len] )); do
		_p="${_cr[pos]}"
		if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
		((_cr[pos]++))
		case "$_char" in
			'"') return 0 ;;
			'\')
				_p="${_cr[pos]}"
				if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
				((_cr[pos]++))
				case "$_char" in
					'"'|'\'|'/') _out+="$_char" ;;
					'b') _out+=$'\b' ;;
					'f') _out+=$'\f' ;;
					'n') _out+=$'\n' ;;
					'r') _out+=$'\r' ;;
					't') _out+=$'\t' ;;
					'u')
						_p="${_cr[pos]}"
						if (( _cr[use_array] )); then
							_hex_digits="${_cr[chars,$_p]}${_cr[chars,$((_p+1))]}${_cr[chars,$((_p+2))]}${_cr[chars,$((_p+3))]}"
						else
							_hex_digits="${_cr[buf]:$_p:4}"
						fi
						((_cr[pos] += 4))
						_out+="$(_json::_decode_unicode "$_hex_digits")" ;;
					*) _out+="\\$_char" ;;
				esac ;;
			*) _out+="$_char" ;;
		esac
	done
	return 2
}

_json::_validate_number() {
	local _number_text="$1"
	[[ "$_number_text" =~ ^-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]] && return 0
	echo "json: invalid number '$_number_text'" >&2
	return 1
}

_json::_skip_value() {
	local -n _cr="$1"; local _char _p
	_json::_skip_ws "$1"
	_p="${_cr[pos]}"
	if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
	case "$_char" in
		'{'|'[')
			if ! _json::_quick_scan "$1" "$_char"; then
				_json::_grep_skip_container "$1"
				return
			fi
			_json::_ctx_maybe_index "$1"
			local -a _stack=("${_JSON_CLOSER[$_char]}")
			((_cr[pos]++))
			while (( ${#_stack[@]} > 0 && _cr[pos] < _cr[len] )); do
				_p="${_cr[pos]}"
				if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
				case "$_char" in
					'{'|'[') _stack+=("${_JSON_CLOSER[$_char]}"); ((_cr[pos]++)) ;;
					'}'|']')
						[[ "$_char" == "${_stack[-1]}" ]] && unset '_stack[-1]'
						((_cr[pos]++)) ;;
					'"') _json::_skip_string "$1" ;;
					[tfn])
						_p="${_cr[pos]}"
						local _span
						if (( _cr[use_array] )); then
							_span="${_cr[chars,$_p]}${_cr[chars,$((_p+1))]}${_cr[chars,$((_p+2))]}${_cr[chars,$((_p+3))]}"
						else
							_span="${_cr[buf]:$_p:4}"
						fi
						case "$_span" in
							fals) ((_cr[pos] += 5)) ;;
							true|null) ((_cr[pos] += 4)) ;;
						esac ;;
					[-0-9]) _json::_scan_number "$1" ;;
					*)
						while (( _cr[pos] < _cr[len] )); do
							_p="${_cr[pos]}"
							if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
							[[ "$_char" == [[:space:]] || "$_char" == ',' || "$_char" == ':' ]] || break
							((_cr[pos]++))
						done ;;
				esac
			done ;;
		'"') _json::_skip_string "$1" ;;
		[tfn])
			_p="${_cr[pos]}"
			local _span
			if (( _cr[use_array] )); then
				_span="${_cr[chars,$_p]}${_cr[chars,$((_p+1))]}${_cr[chars,$((_p+2))]}${_cr[chars,$((_p+3))]}"
			else
				_span="${_cr[buf]:$_p:4}"
			fi
			case "$_span" in
				fals) ((_cr[pos] += 5)) ;;
				true|null) ((_cr[pos] += 4)) ;;
			esac ;;
		[-0-9]) _json::_scan_number "$1" ;;
	esac
}

_json::_find_key() {
	local -n _cr="$1"; local _char _p
	local _target="$2" _cur_key
	((_cr[pos]++))
	_json::_skip_ws "$1"
	_p="${_cr[pos]}"
	if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
	[[ "$_char" == '}' ]] && { ((_cr[pos]++)); return 1; }
	while (( _cr[pos] < _cr[len] )); do
		_json::_read_string "$1" _cur_key
		_json::_skip_ws "$1"
		((_cr[pos]++))
		[[ "$_cur_key" == "$_target" ]] && return 0
		_json::_skip_value "$1"
		_json::_skip_ws "$1"
		local _had_comma=0
		_p="${_cr[pos]}"
		if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
		if [[ "$_char" == ',' ]]; then
			((_cr[pos]++)); _had_comma=1
			_json::_skip_ws "$1"
			_p="${_cr[pos]}"
			if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
			[[ "$_char" == '}' ]] && { echo "json::get: trailing comma in object" >&2; return 1; }
		fi
		(( ! _had_comma )) && _json::_skip_ws "$1"
		_p="${_cr[pos]}"
		if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
		[[ "$_char" == '}' ]] && { ((_cr[pos]++)); return 1; }
	done
	return 1
}

_json::_find_index() {
	local -n _cr="$1"; local _char _p
	local _target="$2" _index=0
	((_cr[pos]++))
	_json::_skip_ws "$1"
	_p="${_cr[pos]}"
	if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
	[[ "$_char" == ']' ]] && { ((_cr[pos]++)); return 1; }
	while (( _cr[pos] < _cr[len] )); do
		_json::_skip_ws "$1"
		(( _index == _target )) && return 0
		_json::_skip_value "$1"
		((_index++))
		_json::_skip_ws "$1"
		local _had_comma=0
		_p="${_cr[pos]}"
		if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
		if [[ "$_char" == ',' ]]; then
			((_cr[pos]++)); _had_comma=1
			_json::_skip_ws "$1"
			_p="${_cr[pos]}"
			if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
			[[ "$_char" == ']' ]] && { echo "json::get: trailing comma in array" >&2; return 1; }
		fi
		(( ! _had_comma )) && _json::_skip_ws "$1"
		_p="${_cr[pos]}"
		if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
		[[ "$_char" == ']' ]] && { ((_cr[pos]++)); return 1; }
	done
	return 1
}

_json::_read_raw_span() {
	local -n _cr="$1"; local _char _p
	_json::_skip_ws "$1"
	_cr[raw_start]="${_cr[pos]}"
	_p="${_cr[pos]}"
	if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
	case "$_char" in '{'|'[') _json::_ctx_maybe_index "$1" ;; esac
	_p="${_cr[pos]}"
	if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
	case "$_char" in
		'{'|'[')
			local -a _stack=("${_JSON_CLOSER[$_char]}")
			((_cr[pos]++))
			while (( ${#_stack[@]} > 0 && _cr[pos] < _cr[len] )); do
				_p="${_cr[pos]}"
				if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
				case "$_char" in
					'{'|'[') _stack+=("${_JSON_CLOSER[$_char]}"); ((_cr[pos]++)) ;;
					'}'|']')
						[[ "$_char" == "${_stack[-1]}" ]] && unset '_stack[-1]'
						((_cr[pos]++)) ;;
					'"') _json::_skip_string "$1" ;;
					[tfn])
						_p="${_cr[pos]}"
						local _span
						if (( _cr[use_array] )); then
							_span="${_cr[chars,$_p]}${_cr[chars,$((_p+1))]}${_cr[chars,$((_p+2))]}${_cr[chars,$((_p+3))]}"
						else
							_span="${_cr[buf]:$_p:4}"
						fi
						case "$_span" in
							fals) ((_cr[pos] += 5)) ;;
							true|null) ((_cr[pos] += 4)) ;;
						esac ;;
					[-0-9])
						local _ns="${_cr[pos]}"
						_json::_scan_number "$1"
						_json::_validate_number "${_cr[buf]:_ns:$((_cr[pos] - _ns))}" || return 1 ;;
					*)
						while (( _cr[pos] < _cr[len] )); do
							_p="${_cr[pos]}"
							if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
							[[ "$_char" == [[:space:]] || "$_char" == ',' || "$_char" == ':' ]] || break
							((_cr[pos]++))
						done ;;
				esac
			done
			_cr[raw_end]=$(( _cr[pos] - 1 )) ;;
		'"') _json::_skip_string "$1" ;;
		[tfn])
			_p="${_cr[pos]}"
			local _span
			if (( _cr[use_array] )); then
				_span="${_cr[chars,$_p]}${_cr[chars,$((_p+1))]}${_cr[chars,$((_p+2))]}${_cr[chars,$((_p+3))]}"
			else
				_span="${_cr[buf]:$_p:4}"
			fi
			case "$_span" in
				fals) ((_cr[pos] += 5)) ;;
				true|null) ((_cr[pos] += 4)) ;;
			esac ;;
		[-0-9])
			local _ns="${_cr[pos]}"
			_json::_scan_number "$1"
			_json::_validate_number "${_cr[buf]:_ns:$((_cr[pos] - _ns))}" || return 1 ;;
	esac
	_cr[raw_end]=$(( _cr[pos] - 1 ))
}

_json::_read_value() {
	local -n _cr="$1"; local _char _p
	_json::_skip_ws "$1"
	_p="${_cr[pos]}"
	if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
	case "$_char" in
		'"')
			local _decoded
			_json::_read_string "$1" _decoded
			printf '%s' "$_decoded" ;;
		*)
			_json::_read_raw_span "$1" || return 1
			printf '%s' "${_cr[buf]:${_cr[raw_start]}:$(( _cr[raw_end] - _cr[raw_start] + 1 ))}" ;;
	esac
}

_json::_normalise_path() {
	local _path="$1"
	_path="${_path//\[/.}"
	_path="${_path//\]/}"
	_path="${_path#.}"
	printf '%s' "$_path"
}

_json::_check_trailing_comma() {
	local -n _cr="$1"; local _char _p
	local _saved="${_cr[pos]}"
	_json::_skip_ws "$1"
	_p="${_cr[pos]}"
	if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
	if [[ "$_char" == ',' ]]; then
		((_cr[pos]++))
		_json::_skip_ws "$1"
		_p="${_cr[pos]}"
		if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
		[[ "$_char" == "}" || "$_char" == "]" ]] && { echo "json::get: trailing comma" >&2; return 1; }
	fi
	_cr[pos]="$_saved"
	return 0
}

_json::_navigate() {
	local -n _cr="$1"; local _char _p
	local _path="$2" _last_idx
	[[ -z "$_path" ]] && return 0
	_path="$(_json::_normalise_path "$_path")"
	local _segments
	string::split::fast _segments '.' "$_path"
	_last_idx=$((${#_segments[@]} - 1))
	local _i _segment
	for (( _i=0; _i<${#_segments[@]}; _i++ )); do
		_segment="${_segments[$_i]}"
		_json::_skip_ws "$1"
		_p="${_cr[pos]}"
		if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
		case "$_char" in
			'{')
				_json::_find_key "$1" "$_segment" || {
					echo "json: key '$_segment' not found" >&2; return 1; }
				(( _i == _last_idx )) && return 0 ;;
			'[')
				string::is_integer "$_segment" || {
					echo "json: array index must be integer" >&2; return 1; }
				_json::_find_index "$1" "$_segment" || {
					echo "json: index $_segment out of bounds" >&2; return 1; }
				(( _i == _last_idx )) && return 0 ;;
			*) echo "json: cannot navigate into scalar at '$_segment'" >&2; return 1 ;;
		esac
	done
	echo "json: path exhausted before reaching a value" >&2
	return 1
}

# --- grep-accelerated helpers ---

_json::_grep_len() {
	local -n _cr="$1"
	local _opener="$2" _depth=0 _in_string=0 _count=0 _first=1 _bo _bc _gl
	local _buf="${_cr[buf]}" _pos="${_cr[pos]}"
	while IFS= read -r _gl; do
		_bo="${_gl%%:*}"; _bc="${_gl#*:}"
		(( _first )) && _first=0 && continue
		(( _in_string )) && { [[ "$_bc" == '"' ]] && _in_string=0; continue; }
		case "$_bc" in
			'"') _in_string=1 ;;
			'{'|'[') ((_depth++)) ;;
			'}'|']')
				(( _depth == 0 )) && { [[ "$_opener" == '[' ]] && echo "$((_count+1))" || echo "$_count"; return 0; }
				((_depth--)) ;;
			',') (( ! _depth && _opener == '[' )) && ((_count++)) ;;
			':') (( ! _depth && _opener == '{' )) && ((_count++)) ;;
		esac
	done < <(printf '%s' "${_buf:_pos}" | grep -ob '[][{}",:]')
}

_json::_grep_skip_container() {
	local -n _cr="$1"
	local _opener="${_cr[buf]:${_cr[pos]}:1}" _depth=1 _in_string=0 _first=1 _bo _bc _gl
	while IFS= read -r _gl; do
		_bo="${_gl%%:*}"; _bc="${_gl#*:}"
		(( _first )) && _first=0 && continue
		(( _in_string )) && { [[ "$_bc" == '"' ]] && _in_string=0; continue; }
		case "$_bc" in
			'"') _in_string=1 ;;
			'{'|'[') ((_depth++)) ;;
			'}'|']')
				((_depth--))
				(( _depth == 0 )) && { _cr[pos]=$((_cr[pos]+_bo+1)); return 0; }
				;;
		esac
	done < <(printf '%s' "${_cr[buf]:${_cr[pos]}}" | grep -ob '[][{}",:]')
	return 1
}

_json::_grep_keys() {
	local -n _cr="$1"
	local _opener="${_cr[buf]:${_cr[pos]}:1}" _depth=1 _in_string=0 _first=1
	local _ks=0 _abs _raw _ke _bo _bc _gl _buf="${_cr[buf]}" _len="${_cr[len]}"
	if [[ "$_opener" == '[' ]]; then
		local _idx=0
		while IFS= read -r _gl; do
			_bo="${_gl%%:*}"; _bc="${_gl#*:}"
			(( _first )) && _first=0 && continue
			(( _in_string )) && { [[ "$_bc" == '"' ]] && _in_string=0; continue; }
			case "$_bc" in
				'"') _in_string=1 ;;
				'{'|'[') ((_depth++)) ;;
				'}'|']')
					((_depth--))
					(( _depth == 0 )) && { printf '%d\n' "$_idx"; _cr[pos]=$((_cr[pos]+_bo+1)); return 0; } ;;
				',') (( _depth == 1 )) && { printf '%d\n' "$_idx"; ((_idx++)); } ;;
			esac
		done < <(printf '%s' "${_buf:${_cr[pos]}}" | grep -ob '[][{}",:]')
		return 0
	fi
	while IFS= read -r _gl; do
		_bo="${_gl%%:*}"; _bc="${_gl#*:}"
		(( _first )) && _first=0 && continue
		if (( _in_string )); then
			if [[ "$_bc" == '"' ]]; then
				_in_string=0
				if (( _depth == 1 && _ks > 0 )); then
					_abs=$((_cr[pos]+_bo)); _raw="${_buf:_ks:$((_abs-_ks))}"
					_ke=$((_abs+1))
					while (( _ke < _len )) && [[ "${_buf:_ke:1}" == [[:space:]] ]]; do ((_ke++)); done
					(( _ke < _len )) && [[ "${_buf:_ke:1}" == ':' ]] && printf '%s\n' "$_raw"
					_ks=0
				fi
			fi
			continue
		fi
		case "$_bc" in
			'"') _in_string=1; (( _depth == 1 )) && _ks=$((_cr[pos]+_bo+1)) ;;
			'{'|'[') ((_depth++)) ;;
			'}'|']')
				((_depth--))
				(( _depth == 0 )) && { _cr[pos]=$((_cr[pos]+_bo+1)); return 0; } ;;
		esac
	done < <(printf '%s' "${_buf:${_cr[pos]}}" | grep -ob '[][{}",:]')
}

# --- Public API ---

json::get() {
	local -n _cr="$1"
	local LC_ALL=C
	_json::_ctx_init "$1" "$2"
	local _json_path="$3"
	if [[ -z "$_json_path" ]]; then
		_json::_read_value "$1" || return 1
		_json::_check_trailing_comma "$1" || return 1
		return
	fi
	_json::_navigate "$1" "$_json_path" || return 1
	_json::_read_value "$1" || return 1
	_json::_check_trailing_comma "$1" || return 1
}

json::get_file() {
	local _file="$2" _path="$3" _json_content
	_json_content="$(<"$_file")" || { echo "json::get_file: cannot read '$_file'" >&2; return 1; }
	json::get "$1" "$_json_content" "$_path"
}

json::keys() {
	local -n _cr="$1"; local _char _p
	local LC_ALL=C
	_json::_ctx_init "$1" "$2"
	local _path="${3:-}"
	[[ -n "$_path" ]] && { _json::_navigate "$1" "$_path" || return 1; }
	_json::_skip_ws "$1"
	_p="${_cr[pos]}"
	if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
	local _opener="$_char"
	if _json::_quick_scan "$1" "$_opener"; then
		case "$_opener" in
			'{')
				((_cr[pos]++)); _json::_skip_ws "$1"
				_p="${_cr[pos]}"
				if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
				[[ "$_char" == '}' ]] && { ((_cr[pos]++)); return 0; }
				while true; do
					local _kn; _json::_read_string "$1" _kn; printf '%s\n' "$_kn"
					_json::_skip_ws "$1"; ((_cr[pos]++)); _json::_skip_value "$1"
					_json::_skip_ws "$1"
					_p="${_cr[pos]}"
					if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
					[[ "$_char" == ',' ]] && { ((_cr[pos]++)); _json::_skip_ws "$1"; }
					_p="${_cr[pos]}"
					if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
					[[ "$_char" == '}' ]] && { ((_cr[pos]++)); break; }
				done ;;
			'[')
				local _ai=0; ((_cr[pos]++)); _json::_skip_ws "$1"
				_p="${_cr[pos]}"
				if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
				[[ "$_char" == ']' ]] && { ((_cr[pos]++)); return 0; }
				while true; do
					printf '%d\n' "$_ai"; ((_ai++)); _json::_skip_value "$1"
					_json::_skip_ws "$1"
					_p="${_cr[pos]}"
					if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
					[[ "$_char" == ',' ]] && { ((_cr[pos]++)); _json::_skip_ws "$1"; }
					_p="${_cr[pos]}"
					if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
					[[ "$_char" == ']' ]] && { ((_cr[pos]++)); break; }
				done ;;
		esac
	else
		case "$_opener" in
			'{'|'[') _json::_grep_keys "$1" ;;
			*) echo "json::keys: not a container" >&2; return 1 ;;
		esac
	fi
}

json::type() {
	local -n _cr="$1"; local _char _p
	local LC_ALL=C
	_json::_ctx_init "$1" "$2"
	local _path="${3:-}"
	[[ -n "$_path" ]] && { _json::_navigate "$1" "$_path" || return 1; }
	_json::_skip_ws "$1"
	_p="${_cr[pos]}"
	if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
	case "$_char" in
		'{') echo "object" ;; '[') echo "array" ;; '"') echo "string" ;;
		[0-9\-]) echo "number" ;; t|f) echo "boolean" ;; n) echo "null" ;;
		*) echo "json::type: unknown type" >&2; return 1 ;;
	esac
}

json::len() {
	local -n _cr="$1"; local _char _p
	local LC_ALL=C
	_json::_ctx_init "$1" "$2"
	local _path="${3:-}"
	[[ -n "$_path" ]] && { _json::_navigate "$1" "$_path" || return 1; }
	_json::_skip_ws "$1"
	_p="${_cr[pos]}"
	if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
	local _opener="$_char"
	if _json::_quick_scan "$1" "$_opener"; then
		local _count=0
		case "$_opener" in
			'{')
				((_cr[pos]++)); _json::_skip_ws "$1"
				_p="${_cr[pos]}"
				if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
				[[ "$_char" == '}' ]] && { ((_cr[pos]++)); echo 0; return 0; }
				while true; do
					_json::_skip_string "$1"; _json::_skip_ws "$1"; ((_cr[pos]++))
					_json::_skip_value "$1"; ((_count++)); _json::_skip_ws "$1"
					_p="${_cr[pos]}"
					if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
					[[ "$_char" == ',' ]] && { ((_cr[pos]++)); _json::_skip_ws "$1"; }
					_p="${_cr[pos]}"
					if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
					[[ "$_char" == '}' ]] && { ((_cr[pos]++)); break; }
				done; echo "$_count" ;;
			'[')
				((_cr[pos]++)); _json::_skip_ws "$1"
				_p="${_cr[pos]}"
				if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
				[[ "$_char" == ']' ]] && { ((_cr[pos]++)); echo 0; return 0; }
				while true; do
					_json::_skip_value "$1"; ((_count++)); _json::_skip_ws "$1"
					_p="${_cr[pos]}"
					if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
					[[ "$_char" == ',' ]] && { ((_cr[pos]++)); _json::_skip_ws "$1"; }
					_p="${_cr[pos]}"
					if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
					[[ "$_char" == ']' ]] && { ((_cr[pos]++)); break; }
				done; echo "$_count" ;;
		esac
	else
		case "$_opener" in
			'{'|'[') _json::_grep_len "$1" "$_opener" ;;
			*) echo "json::len: not a container" >&2; return 1 ;;
		esac
	fi
}

json::validate() {
	local -n _cr="$1"; local _char _p
	local LC_ALL=C
	_json::_ctx_init "$1" "$2"
	local _span
	_json::_skip_ws "$1"
	(( _cr[pos] >= _cr[len] )) && { echo "json::validate: empty input" >&2; return 1; }
	_p="${_cr[pos]}"
	if (( _cr[use_array] )); then _char="${_cr[chars,$_p]}"; else _char="${_cr[buf]:$_p:1}"; fi
	case "$_char" in
		'{'|'[') _json::_skip_value "$1" ;;
		'"') _json::_skip_string "$1" ;;
		[0-9\-]) _json::_read_raw_span "$1" || return 1 ;;
		t|f|n)
			if (( _cr[use_array] )); then
				_span="${_cr[chars,$_p]}${_cr[chars,$((_p+1))]}${_cr[chars,$((_p+2))]}${_cr[chars,$((_p+3))]}"
			else
				_span="${_cr[buf]:$_p:4}"
			fi
			case "$_span" in true|fals|null) ;; *) echo "json::validate: unexpected literal" >&2; return 1 ;; esac
			_cr[pos]=$((_cr[pos]+4)); [[ "$_char" == 'f' ]] && ((_cr[pos]++)) ;;
		*) echo "json::validate: unexpected character '$_char'" >&2; return 1 ;;
	esac
	_json::_skip_ws "$1"
	(( _cr[pos] < _cr[len] )) && { echo "json::validate: trailing content" >&2; return 1; }
	return 0
}

# --- Load sub-modules ---

_json_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -f 'json::kv' &>/dev/null || source "$_json_dir/kv.sh"
unset _json_dir
