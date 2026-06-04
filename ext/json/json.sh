# shellcheck shell=bash
# shellcheck disable=SC2154
# ext/json.sh — Pure Bash JSON parser (stateless)
# Requires: runtime string
#
# All parser state lives in an associative array _ctx, passed by the caller.
# Char access is inlined at every call site.
# Auto-detects GNU grep for C-speed large-container scanning.
# Force pure bash: NOGREP=1 or _ctx[no_grep]=1.

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

# --- Grep detection ---
# Auto-detect GNU grep with -b flag.  Override: NOGREP=1 or _ctx[no_grep]=1.

_json_has_grep=0
if [[ "${NOGREP:-0}" != "1" ]]; then
	if command -v grep &>/dev/null; then
		# Verify grep -b works (GNU grep); macOS BSD grep lacks -b
		if echo '{}' | grep -ob '[{}]' &>/dev/null 2>&1; then
			_json_has_grep=1
		fi
	fi
fi

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
	local _use_grep=$_json_has_grep
	(( ${_cr[no_grep]:-0} )) && _use_grep=0
	if (( _use_grep )); then
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
	else
		local _opener="$2" _depth=0 _in_string=0 _count=0
		local _buf="${_cr[buf]}" _pos="${_cr[pos]}" _len="${_cr[len]}" _i="$((_pos+1))" _ch
		while (( _i < _len )); do
			_ch="${_buf:_i:1}"
			if (( _in_string )); then
				if [[ "$_ch" == '"' ]]; then _in_string=0
				elif [[ "$_ch" == '\' ]]; then ((_i++))
				fi
				((_i++)); continue
			fi
			case "$_ch" in
				'"') _in_string=1 ;;
				'{'|'[') ((_depth++)) ;;
				'}'|']')
					(( _depth == 0 )) && {
						[[ "$_opener" == '[' ]] && echo "$((_count+1))" || echo "$_count"
						return 0
					}
					((_depth--)) ;;
				',') (( ! _depth && _opener == '[' )) && ((_count++)) ;;
				':') (( ! _depth && _opener == '{' )) && ((_count++)) ;;
			esac
			((_i++))
		done
		echo "$_count"
	fi
}

_json::_grep_skip_container() {
	local -n _cr="$1"
	local _use_grep=$_json_has_grep
	(( ${_cr[no_grep]:-0} )) && _use_grep=0
	if (( _use_grep )); then
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
	else
		local _opener="${_cr[buf]:${_cr[pos]}:1}" _closer="${_JSON_CLOSER[${_cr[buf]:${_cr[pos]}:1}]}"
		local _depth=1 _in_string=0
		local _buf="${_cr[buf]}" _len="${_cr[len]}" _i=$((_cr[pos]+1)) _ch
		while (( _i < _len )); do
			_ch="${_buf:_i:1}"
			if (( _in_string )); then
				if [[ "$_ch" == '"' ]]; then _in_string=0
				elif [[ "$_ch" == '\' ]]; then ((_i++))
				fi
				((_i++)); continue
			fi
			case "$_ch" in
				'"') _in_string=1 ;;
				"$_opener") ((_depth++)) ;;
				"$_closer")
					((_depth--))
					(( _depth == 0 )) && { _cr[pos]=$((_i+1)); return 0; }
					;;
			esac
			((_i++))
		done
		return 1
	fi
}

_json::_grep_keys() {
	local -n _cr="$1"
	local _use_grep=$_json_has_grep
	(( ${_cr[no_grep]:-0} )) && _use_grep=0
	local _opener="${_cr[buf]:${_cr[pos]}:1}"
	if (( _use_grep )); then
		local _depth=1 _in_string=0 _first=1
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
	else
		local _depth=1 _in_string=0
		local _buf="${_cr[buf]}" _len="${_cr[len]}" _i _ch
		if [[ "$_opener" == '[' ]]; then
			local _idx=0
			_i=$((_cr[pos]+1))
			while (( _i < _len )); do
				_ch="${_buf:_i:1}"
				if (( _in_string )); then
					if [[ "$_ch" == '"' ]]; then _in_string=0
					elif [[ "$_ch" == '\' ]]; then ((_i++))
					fi
					((_i++)); continue
				fi
				case "$_ch" in
					'"') _in_string=1 ;;
					'{'|'[') ((_depth++)) ;;
					'}'|']')
						((_depth--))
						(( _depth == 0 )) && { printf '%d\n' "$_idx"; _cr[pos]=$((_i+1)); return 0; } ;;
					',')
						if (( _depth == 1 )); then
							printf '%d\n' "$_idx"
							((_idx++))
						fi ;;
				esac
				((_i++))
			done
			return 0
		fi
		local _key_start=0 _abs _raw _ke
		_i=$((_cr[pos]+1))
		while (( _i < _len )); do
			_ch="${_buf:_i:1}"
			if (( _in_string )); then
				if [[ "$_ch" == '"' ]]; then
					_in_string=0
					if (( _depth == 1 && _key_start > 0 )); then
						_abs=$_i
						_raw="${_buf:_key_start:$((_abs-_key_start))}"
						_ke=$((_abs+1))
						while (( _ke < _len )) && [[ "${_buf:_ke:1}" == [[:space:]] ]]; do ((_ke++)); done
						if (( _ke < _len )) && [[ "${_buf:_ke:1}" == ':' ]]; then
							printf '%s\n' "$_raw"
						fi
						_key_start=0
					fi
				elif [[ "$_ch" == '\' ]]; then ((_i++))
				fi
				((_i++)); continue
			fi
			case "$_ch" in
				'"')
					_in_string=1
					if (( _depth == 1 )); then
						_key_start=$((_i+1))
					fi ;;
				'{'|'[') ((_depth++)) ;;
				'}'|']')
					((_depth--))
					(( _depth == 0 )) && { _cr[pos]=$((_i+1)); return 0; } ;;
			esac
			((_i++))
		done
	fi
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
#
# In dev mode (sourcing json.sh directly), sub-modules are siblings in
# ext/json/. In compiled mode (ext/json/json.sh inlined into a single
# output file), BASH_SOURCE[0] points to the compiled file, so the
# sub-module paths resolve to the project root and don't exist. The
# compile step inlines the sub-module content directly after this block,
# so by the time the loader runs, the inlined functions are not yet
# defined — but they will be momentarily. The file-exists check below
# makes the source a no-op in compiled mode while preserving dev-mode
# behavior.

_json_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$_json_dir/kv.sh" ]] && ! declare -f 'json::kv' &>/dev/null; then
	source "$_json_dir/kv.sh"
fi
unset _json_dir

# ==============================================================================
# SQLITE STORE SUB-NAMESPACE — JSON document store backed by SQLite
# ==============================================================================
#
# Each document is stored as a JSON string in a SQLite table. The table
# is auto-created on first open. Useful for "structured but
# schemaless" persistence — documents can have any shape, queries
# can use json_extract to navigate nested fields.
#
# Capability checks follow the math.sh::has_bc pattern: helpers return
# truthy/falsy, and each public function checks at call time and bails
# with a clear error if the underlying sqlite3 (or json1/fts5 build) is
# missing. This means the functions are always defined — no load-time
# guard — and behave consistently in dev and compiled mode.

# Quote an identifier (table name, column name) for safe interpolation.
_json_sqlitestore::_quote_ident() {
	local _val="$1"
	printf '"%s"' "${_val//\"/\"\"}"
}

# Escape a string value for use inside a single-quoted SQL literal.
_json_sqlitestore::_escape_string() {
	local _val="$1"
	printf '%s' "$_val" | sed "s/'/''/g"
}

# Internal: ensure the store table exists for the given (db, table) pair.
_json_sqlitestore::_ensure_table() {
	local _db="$1" _table="$2"
	local _qtable
	_qtable=$(_json_sqlitestore::_quote_ident "$_table")
	sqlite3 -noheader -batch "$_db" \
		"CREATE TABLE IF NOT EXISTS $_qtable (
			id TEXT PRIMARY KEY,
			data TEXT NOT NULL,
			created_at TEXT DEFAULT (datetime('now')),
			updated_at TEXT DEFAULT (datetime('now'))
		);" 2>/dev/null
}

# Check if the sqlite3 CLI is available.
json::sqlitestore::has_sqlite3() { runtime::has_command sqlite3; }

# Check if the sqlite3 build has the JSON1 extension compiled in.
json::sqlitestore::has_json1() {
	json::sqlitestore::has_sqlite3 || return 1
	sqlite3 :memory: "SELECT sqlite_compileoption_used('ENABLE_JSON1');" 2>/dev/null | grep -qx 1
}

# Check if the sqlite3 build has FTS5 compiled in.
json::sqlitestore::has_fts5() {
	json::sqlitestore::has_sqlite3 || return 1
	sqlite3 :memory: "SELECT sqlite_compileoption_used('ENABLE_FTS5');" 2>/dev/null | grep -qx 1
}

# Open a SQLite database for use as a JSON document store. Creates the
# store table for <table> if it doesn't exist. No HANDLE — pass <db>
# and <table> to subsequent calls.
#
# Usage: json::sqlitestore::open <path> <table>
json::sqlitestore::open() {
	local _db="$1" _table="$2"
	if ! json::sqlitestore::has_sqlite3; then
		echo "json::sqlitestore::open: requires sqlite3" >&2
		return 1
	fi
	[[ -n "$_db" ]] || {
		echo "json::sqlitestore::open: path required" >&2
		return 1
	}
	[[ -n "$_table" ]] || {
		echo "json::sqlitestore::open: table required" >&2
		return 1
	}
	# Create the database file if it doesn't exist
	[[ -f "$_db" ]] || sqlite3 -noheader -batch "$_db" "" 2>/dev/null
	_json_sqlitestore::_ensure_table "$_db" "$_table"
}

# Store or replace a JSON document. <json> must be a valid JSON string.
# Usage: json::sqlitestore::put <path> <table> <key> <json>
json::sqlitestore::put() {
	local _db="$1" _table="$2" _key="$3" _json="$4"
	if ! json::sqlitestore::has_sqlite3; then
		echo "json::sqlitestore::put: requires sqlite3" >&2
		return 1
	fi
	[[ -n "$_key" ]] || {
		echo "json::sqlitestore::put: key required" >&2
		return 1
	}
	[[ -n "$_json" ]] || {
		echo "json::sqlitestore::put: json required" >&2
		return 1
	}
	_json_sqlitestore::_ensure_table "$_db" "$_table"
	local _qtable _ekey _ejson
	_qtable=$(_json_sqlitestore::_quote_ident "$_table")
	_ekey=$(_json_sqlitestore::_escape_string "$_key")
	_ejson=$(_json_sqlitestore::_escape_string "$_json")
	sqlite3 -noheader -batch "$_db" \
		"INSERT OR REPLACE INTO $_qtable (id, data, updated_at)
		 VALUES ('$_ekey', '$_ejson', datetime('now'));"
}

# Retrieve a JSON document by key. Prints the JSON string to stdout.
# Returns 1 (no output) if the key doesn't exist.
# Usage: json::sqlitestore::get <path> <table> <key>
json::sqlitestore::get() {
	local _db="$1" _table="$2" _key="$3"
	if ! json::sqlitestore::has_sqlite3; then
		echo "json::sqlitestore::get: requires sqlite3" >&2
		return 1
	fi
	local _qtable _ekey
	_qtable=$(_json_sqlitestore::_quote_ident "$_table")
	_ekey=$(_json_sqlitestore::_escape_string "$_key")
	sqlite3 -noheader -batch -list "$_db" \
		"SELECT data FROM $_qtable WHERE id = '$_ekey';"
}

# Delete a document by key. Returns 0 if removed, 1 if not found.
# Usage: json::sqlitestore::delete <path> <table> <key>
json::sqlitestore::delete() {
	local _db="$1" _table="$2" _key="$3"
	if ! json::sqlitestore::has_sqlite3; then
		echo "json::sqlitestore::delete: requires sqlite3" >&2
		return 1
	fi
	local _qtable _ekey
	_qtable=$(_json_sqlitestore::_quote_ident "$_table")
	_ekey=$(_json_sqlitestore::_escape_string "$_key")
	sqlite3 -noheader -batch "$_db" \
		"DELETE FROM $_qtable WHERE id = '$_ekey';"
}

# List all keys in the store. One per line.
# Usage: json::sqlitestore::list <path> <table>
json::sqlitestore::list() {
	local _db="$1" _table="$2"
	if ! json::sqlitestore::has_sqlite3; then
		echo "json::sqlitestore::list: requires sqlite3" >&2
		return 1
	fi
	local _qtable
	_qtable=$(_json_sqlitestore::_quote_ident "$_table")
	sqlite3 -noheader -batch -list "$_db" \
		"SELECT id FROM $_qtable ORDER BY id;"
}

# Count documents in the store.
# Usage: json::sqlitestore::count <path> <table>
json::sqlitestore::count() {
	local _db="$1" _table="$2"
	if ! json::sqlitestore::has_sqlite3; then
		echo "json::sqlitestore::count: requires sqlite3" >&2
		return 1
	fi
	local _qtable
	_qtable=$(_json_sqlitestore::_quote_ident "$_table")
	sqlite3 -noheader -batch -list "$_db" \
		"SELECT count(*) FROM $_qtable;"
}

# Query documents by JSON path. <path> is a json_extract path (e.g.
# '$.name', '$.tags[0]'). <value> is the value to match (string compare).
# Prints matching documents' full JSON, one per line.
# Usage: json::sqlitestore::query <path> <table> <json_path> <value>
json::sqlitestore::query() {
	local _db="$1" _table="$2" _jpath="$3" _value="$4"
	if ! json::sqlitestore::has_json1; then
		echo "json::sqlitestore::query: requires json1 (not available in this sqlite3 build)" >&2
		return 1
	fi
	[[ -n "$_jpath" ]] || {
		echo "json::sqlitestore::query: json path required" >&2
		return 1
	}
	local _qtable _ejpath _evalue
	_qtable=$(_json_sqlitestore::_quote_ident "$_table")
	_ejpath=$(_json_sqlitestore::_escape_string "$_jpath")
	_evalue=$(_json_sqlitestore::_escape_string "$_value")
	sqlite3 -noheader -batch -list "$_db" \
		"SELECT data FROM $_qtable
		 WHERE json_extract(data, '$_ejpath') = '$_evalue';"
}

# Full-text search across JSON documents. Requires FTS5.
# Creates a contentless FTS5 index on first call, keeps it in sync on
# put/delete. <query> uses FTS5 syntax (e.g. 'hello world', 'hello*').
#
# Note: this is a simple "rebuild on every call" implementation. For
# large stores, consider a trigger-based FTS index instead.
# Usage: json::sqlitestore::search <path> <table> <query>
json::sqlitestore::search() {
	local _db="$1" _table="$2" _query="$3"
	if ! json::sqlitestore::has_fts5; then
		echo "json::sqlitestore::search: FTS5 not available in this sqlite3 build" >&2
		return 1
	fi
	[[ -n "$_query" ]] || {
		echo "json::sqlitestore::search: query required" >&2
		return 1
	}
	local _qtable _ftstable _equery
	_qtable=$(_json_sqlitestore::_quote_ident "$_table")
	_ftstable="${_qtable}_fts"
	_equery=$(_json_sqlitestore::_escape_string "$_query")
	# Create FTS5 contentless table if missing
	sqlite3 -noheader -batch "$_db" \
		"CREATE VIRTUAL TABLE IF NOT EXISTS $_ftstable USING fts5(data, content='$_table', content_rowid='rowid');" 2>/dev/null
	# Rebuild index from main table (simple but safe)
	sqlite3 -noheader -batch "$_db" \
		"INSERT INTO $_ftstable($_ftstable) VALUES('rebuild');" 2>/dev/null
	# Search
	sqlite3 -noheader -batch -list "$_db" \
		"SELECT $_qtable.data
		 FROM $_ftstable
		 JOIN $_qtable ON $_qtable.rowid = $_ftstable.rowid
		 WHERE $_ftstable MATCH '$_equery'
		 ORDER BY rank;"
}

# Import a JSON array from a file. Each element becomes a document
# with index-based key ("0", "1", "2", ...).
# Usage: json::sqlitestore::import <path> <table> <file>
json::sqlitestore::import() {
	local _db="$1" _table="$2" _file="$3"
	if ! json::sqlitestore::has_json1; then
		echo "json::sqlitestore::import: requires json1 (not available in this sqlite3 build)" >&2
		return 1
	fi
	[[ -r "$_file" ]] || {
		echo "json::sqlitestore::import: cannot read '$_file'" >&2
		return 1
	}
	_json_sqlitestore::_ensure_table "$_db" "$_table"
	local _qtable
	_qtable=$(_json_sqlitestore::_quote_ident "$_table")
	# Use sqlite3's json1 + readfile to ingest a JSON array.
	# Each element is inserted with its array index as the key.
	sqlite3 -noheader -batch "$_db" <<EOF
DELETE FROM $_qtable;
INSERT INTO $_qtable (id, data)
SELECT
	CAST(json_each.key AS TEXT),
	json_each.value
FROM json_each(readfile('$_file'));
EOF
}

# Export all documents as a JSON array. Prints to stdout.
# Usage: json::sqlitestore::export <path> <table>
json::sqlitestore::export() {
	local _db="$1" _table="$2"
	if ! json::sqlitestore::has_json1; then
		echo "json::sqlitestore::export: requires json1 (not available in this sqlite3 build)" >&2
		return 1
	fi
	local _qtable
	_qtable=$(_json_sqlitestore::_quote_ident "$_table")
	sqlite3 -noheader -batch -list "$_db" \
		"SELECT '[' || group_concat(data, ',') || ']'
		 FROM (SELECT data FROM $_qtable ORDER BY id);"
}
