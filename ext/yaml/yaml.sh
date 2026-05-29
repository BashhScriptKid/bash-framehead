# shellcheck shell=bash
# shellcheck disable=SC2154
# ext/yaml/yaml.sh — Pure Bash YAML parser
# Requires: runtime string
#
# Parses YAML into a native AST stored in caller-owned context arrays.
# Query the tree with yaml::get, yaml::keys, yaml::type.
# Convert to JSON with yaml::to_json (requires ext/json).
#
# AST storage (flat associative arrays):
#   _TYPE[id]  — "scalar" | "sequence" | "mapping"
#   _VAL[id]   — scalar value
#   _KEY[id]   — key name in parent mapping
#   _CHILDREN[id] — "1 2 3" (space-separated child IDs)
#   _PARENT[id]   — parent node ID

# --- Guard ---

declare -f 'runtime::bash_version' &>/dev/null || {
	echo "${BASH_SOURCE[0]}: runtime not found — source bash-framehead.sh first" >&2
	return 1
}

_guard_core_deps=()
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

# --- AST context API ---

_yaml_next_id=1
_yaml_last_id=0

_yaml::_ctx_init() {
	local -n _c="$1"
	_c[_root]=0
	_yaml_next_id=1
}

_yaml::_new_node() {
	local -n _c="$1"
	local _type="$2"
	_yaml_last_id=$_yaml_next_id
	((_yaml_next_id++))
	_c["T${_yaml_last_id}"]="$_type"
	_c["C${_yaml_last_id}"]=""
	_c["P${_yaml_last_id}"]=""
	_c["K${_yaml_last_id}"]=""
	_c["V${_yaml_last_id}"]=""
}

_yaml::_add_child() {
	local -n _c="$1"
	local _parent="$2" _child="$3"
	local _existing="${_c["C${_parent}"]}"
	if [[ -n "$_existing" ]]; then
		_c["C${_parent}"]="${_existing} ${_child}"
	else
		_c["C${_parent}"]="$_child"
	fi
	_c["P${_child}"]="$_parent"
}

_yaml::_children() {
	local -n _c="$1"
	echo "${_c["C${_node}"]}"
}

# --- Scalar utilities ---

_yaml::_json_escape() {
	local _s="$1" _out="" _i=0 _ch
	while (( _i < ${#_s} )); do
		_ch="${_s:_i:1}"
		case "$_ch" in
			'"')  _out+='\"' ;;
			'\')  _out+='\\' ;;
			$'\n') _out+='\n' ;;
			$'\r') _out+='\r' ;;
			$'\t') _out+='\t' ;;
			*)    _out+="$_ch" ;;
		esac
		((_i++))
	done
	echo "$_out"
}

_yaml::_unquote() {
	local _s="$1"
	if [[ "$_s" =~ ^\".*\"$ && ${#_s} -ge 2 ]]; then
		_s="${_s:1:-1}"
		_s="$(_yaml::_parse_escapes "$_s")"
	elif [[ "$_s" =~ ^\'.*\'$ && ${#_s} -ge 2 ]]; then
		_s="${_s:1:-1}"
	fi
	echo "$_s"
}

_yaml::_parse_escapes() {
	local _s="$1" _out="" _i=0 _ch
	while (( _i < ${#_s} )); do
		_ch="${_s:_i:1}"
		if [[ "$_ch" == '\' ]] && (( _i + 1 < ${#_s} )); then
			case "${_s:$((_i+1)):1}" in
				n)  _out+=$'\n'; ((_i+=2)); continue ;;
				r)  _out+=$'\r'; ((_i+=2)); continue ;;
				t)  _out+=$'\t'; ((_i+=2)); continue ;;
				'\') _out+='\'; ((_i+=2)); continue ;;
				'"') _out+='"'; ((_i+=2)); continue ;;
				/)  _out+='/'; ((_i+=2)); continue ;;
				b)  _out+=$'\b'; ((_i+=2)); continue ;;
				f)  _out+=$'\f'; ((_i+=2)); continue ;;
				*)  _out+="$_ch"; ((_i++)); continue ;;
			esac
		fi
		_out+="$_ch"
		((_i++))
	done
	echo "$_out"
}

_yaml::_strip_tag() {
	local _s="$1"
	while [[ "$_s" =~ ^[[:space:]]*!(!?[^[:space:]]+[[:space:]]+)+ ]]; do
		_s="${_s#* }"; _s="${_s# }"
	done
	echo "$_s"
}

_yaml::_classify_scalar() {
	local _v="$1"
	case "$_v" in
		'~'|'null'|'Null'|'NULL') echo "null"; return ;;
	esac
	case "$_v" in
		'true'|'True'|'TRUE'|'yes'|'Yes'|'YES'|'on'|'On'|'ON')
			echo "true"; return ;;
		'false'|'False'|'FALSE'|'no'|'No'|'NO'|'off'|'Off'|'OFF')
			echo "false"; return ;;
	esac
	[[ "$_v" =~ ^-?[0-9]+$ ]] && { echo "$_v"; return; }
	[[ "$_v" =~ ^-?[0-9]+\.[0-9]+([eE][+-]?[0-9]+)?$ ]] && { echo "$_v"; return; }
	echo "\"$(_yaml::_json_escape "$_v")\""
}

_yaml::_quote_closed() {
	local _s="$1" _sq=0 _dq=0 _i=0 _ch
	while (( _i < ${#_s} )); do
		_ch="${_s:_i:1}"
		if [[ "$_ch" == '\' ]] && (( _i + 1 < ${#_s} )); then ((_i+=2)); continue; fi
		[[ "$_ch" == "'" ]] && (( _sq ^= 1 ))
		[[ "$_ch" == '"' ]] && (( _dq ^= 1 ))
		((_i++))
	done
	(( _sq == 0 && _dq == 0 ))
}

_yaml::_count_indent() {
	local _n=0 _c
	while (( _n < ${#1} )); do
		_c="${1:_n:1}"
		[[ "$_c" == ' ' || "$_c" == $'\t' ]] || break
		((_n++))
	done
	echo "$_n"
}

_yaml::_strip_comment() {
	local _s="$1" _out="" _i=0 _ch _in_sq=0 _in_dq=0
	while (( _i < ${#_s} )); do
		_ch="${_s:_i:1}"
		if (( _in_sq )); then
			[[ "$_ch" == "'" ]] && _in_sq=0; _out+="$_ch"
		elif (( _in_dq )); then
			[[ "$_ch" == '"' ]] && _in_dq=0; _out+="$_ch"
		elif [[ "$_ch" == "'" ]]; then
			_in_sq=1; _out+="$_ch"
		elif [[ "$_ch" == '"' ]]; then
			_in_dq=1; _out+="$_ch"
		elif [[ "$_ch" == '#' ]] && { [[ -z "$_out" ]] || [[ "${_out: -1}" =~ [[:space:]] ]]; }; then
			break
		else
			_out+="$_ch"
		fi
		((_i++))
	done
	echo "${_out%"${_out##*[![:space:]]}"}"
}

# --- Flow container parser ---
# Sets _yaml_flow_id to the created node ID (avoids $() subshell issue).

_yaml::_parse_flow() {
	local -n _c="$1"
	local _expr="$2" _parent="$3"
	_expr="${_expr#"${_expr%%[![:space:]]*}"}"
	_expr="${_expr%"${_expr##*[![:space:]]}"}"

	_yaml_flow_id=0

	if [[ "$_expr" =~ ^\{.*\}$ ]]; then
		_yaml::_new_node "$1" mapping
		_yaml_flow_id="$_yaml_last_id"
		_c["P${_yaml_flow_id}"]="$_parent"
		local _inner="${_expr:1:-1}"
		_inner="${_inner#"${_inner%%[![:space:]]*}"}"
		_inner="${_inner%"${_inner##*[![:space:]]}"}"
		[[ -z "$_inner" ]] && return

		local _depth=0 _in_sq=0 _in_dq=0 _i=0 _ch _start=0 _len="${#_inner}"
		while (( _i <= _len )); do
			_ch="${_inner:_i:1}"
			if (( _in_sq )); then [[ "$_ch" == "'" ]] && _in_sq=0
			elif (( _in_dq )); then [[ "$_ch" == '\' ]] && { ((_i+=2)); continue; }; [[ "$_ch" == '"' ]] && _in_dq=0
			elif [[ "$_ch" == "'" ]]; then _in_sq=1
			elif [[ "$_ch" == '"' ]]; then _in_dq=1
			elif [[ "$_ch" == '{' || "$_ch" == '[' ]]; then ((_depth++))
			elif [[ "$_ch" == '}' || "$_ch" == ']' ]]; then ((_depth--))
			elif [[ "$_ch" == ',' && _depth -eq 0 ]] || (( _i == _len )); then
				local _pair="${_inner:_start:$((_i - _start))}"
				_pair="${_pair#"${_pair%%[![:space:]]*}"}"
				_pair="${_pair%"${_pair##*[![:space:]]}"}"
				if [[ -n "$_pair" && "$_pair" =~ : ]]; then
					local _k="${_pair%%:*}" _v="${_pair#*:}"
					_k="${_k%"${_k##*[![:space:]]}"}"
					_k="$(_yaml::_unquote "$_k")"
					_v="${_v#"${_v%%[![:space:]]*}"}"
					local _val_id
					if [[ "$_v" =~ ^[\{\[] ]]; then
						local _outer_id="$_yaml_flow_id"
						_yaml::_parse_flow "$1" "$_v" "$_yaml_flow_id"
						_val_id="$_yaml_flow_id"
						_yaml_flow_id="$_outer_id"
					else
						_yaml::_new_node "$1" scalar
						_val_id="$_yaml_last_id"
						_v="$(_yaml::_unquote "$_v")"
						_c["V${_val_id}"]="$_v"
					fi
					_c["K${_val_id}"]="$_k"
					_yaml::_add_child "$1" "$_yaml_flow_id" "$_val_id"
				fi
				_start=$((_i + 1))
			fi
			((_i++))
		done
		return
	fi

	if [[ "$_expr" =~ ^\[.*\]$ ]]; then
		_yaml::_new_node "$1" sequence
		_yaml_flow_id="$_yaml_last_id"
		_c["P${_yaml_flow_id}"]="$_parent"
		local _inner="${_expr:1:-1}"
		_inner="${_inner#"${_inner%%[![:space:]]*}"}"
		_inner="${_inner%"${_inner##*[![:space:]]}"}"
		[[ -z "$_inner" ]] && return

		local _depth=0 _in_sq=0 _in_dq=0 _i=0 _ch _start=0 _len="${#_inner}"
		while (( _i <= _len )); do
			_ch="${_inner:_i:1}"
			if (( _in_sq )); then [[ "$_ch" == "'" ]] && _in_sq=0
			elif (( _in_dq )); then [[ "$_ch" == '\' ]] && { ((_i+=2)); continue; }; [[ "$_ch" == '"' ]] && _in_dq=0
			elif [[ "$_ch" == "'" ]]; then _in_sq=1
			elif [[ "$_ch" == '"' ]]; then _in_dq=1
			elif [[ "$_ch" == '{' || "$_ch" == '[' ]]; then ((_depth++))
			elif [[ "$_ch" == '}' || "$_ch" == ']' ]]; then ((_depth--))
			elif [[ "$_ch" == ',' && _depth -eq 0 ]] || (( _i == _len )); then
				local _item="${_inner:_start:$((_i - _start))}"
				_item="${_item#"${_item%%[![:space:]]*}"}"
				_item="${_item%"${_item##*[![:space:]]}"}"
				if [[ -n "$_item" ]]; then
					local _item_id
					if [[ "$_item" =~ ^[\{\[] ]]; then
						local _outer_id="$_yaml_flow_id"
						_yaml::_parse_flow "$1" "$_item" "$_yaml_flow_id"
						_item_id="$_yaml_flow_id"
						_yaml_flow_id="$_outer_id"
					else
						_yaml::_new_node "$1" scalar
						_item_id="$_yaml_last_id"
						_item="$(_yaml::_unquote "$_item")"
						_c["V${_item_id}"]="$_item"
					fi
					_yaml::_add_child "$1" "$_yaml_flow_id" "$_item_id"
				fi
				_start=$((_i + 1))
			fi
			((_i++))
		done
		return
	fi
}

# --- Main parser ---

yaml::parse() {
	local -n _c="$1"
	local _yaml="${2:-$(cat)}"
	_yaml::_ctx_init "$1"

	# Stack: "node_id:indent:type" (M=map, A=sequence)
	local -a _stack=()
	local _dp=0

	# Pending key state
	local _pending_key_id=0 _pending_key_indent=0

	# Block scalar state
	local _in_block=0 _block_node=0 _block_type="" _block_chomp="" _block_indent=0
	local _block_content_indent=0 _block_lines=()

	# Multi-line quoted string state
	local _in_multiline=0 _multiline_buf=""

	# Create root
	_yaml::_new_node "$1" mapping
	local _root_id="$_yaml_last_id"
	_c[_root]="$_root_id"
	_stack=("${_root_id}:0:M")
	_dp=1

	while IFS= read -r _line; do
		# Multi-line quoted string accumulation
		if (( _in_multiline )); then
			_multiline_buf+=$'\n'"$_line"
			if _yaml::_quote_closed "$_multiline_buf"; then
				_line="$_multiline_buf"
				_in_multiline=0
			else
				continue
			fi
		fi

		_line="${_line%$'\r'}"

		if ! _yaml::_quote_closed "$_line"; then
			_multiline_buf="$_line"
			_in_multiline=1
			continue
		fi

		# Block scalar accumulation
		if (( _in_block )); then
			local _bline_indent
			_bline_indent="$(_yaml::_count_indent "$_line")"
			if (( ${#_block_lines[@]} == 0 )); then
				_block_content_indent=$_bline_indent
			fi
			if (( _bline_indent >= _block_content_indent )) && ! [[ "$_line" =~ ^[[:space:]]*$ ]]; then
				_block_lines+=("${_line:$_block_content_indent}")
				continue
			fi
			if [[ "$_line" =~ ^[[:space:]]*$ ]] && (( ${#_block_lines[@]} > 0 )); then
				_block_lines+=("")
				continue
			fi
			_yaml::_flush_block "$1" "$_block_node" "$_block_type" "$_block_chomp"
			_in_block=0
		fi

		[[ "$_line" =~ ^[[:space:]]*$ ]] && continue
		[[ "$_line" =~ ^[[:space:]]*# ]] && continue
		[[ "$_line" =~ ^[[:space:]]*---[[:space:]]*$ ]] && continue
		[[ "$_line" =~ ^[[:space:]]*\.\.\.[[:space:]]*$ ]] && continue

		local _indent
		_indent="$(_yaml::_count_indent "$_line")"
		local _stripped="${_line:$_indent}"
		_stripped="$(_yaml::_strip_comment "$_stripped")"
		[[ -z "$_stripped" ]] && continue
		_stripped="$(_yaml::_strip_tag "$_stripped")"
		if [[ "$_stripped" =~ \&([a-zA-Z0-9_]+) ]]; then
			local _aname="${BASH_REMATCH[1]}"
			_stripped="${_stripped//\&${_aname} /}"
			_stripped="${_stripped//\&${_aname}/}"
			_stripped="${_stripped#"${_stripped%%[![:space:]]*}"}"
		fi
		[[ -z "$_stripped" ]] && continue

		# --- Pop containers whose indent is strictly less ---
		while (( _dp > 1 )); do
			local _top="${_stack[$((_dp-1))]}"
			local _t_id="${_top%%:*}"
			local _rest="${_top#*:}"
			local _t_indent="${_rest%%:*}"
			if (( _indent >= _t_indent )); then break; fi
			if (( _pending_key_id > 0 )); then
				_yaml::_new_node "$1" scalar
				local _nid="$_yaml_last_id"
				_c["V${_nid}"]="null"
				_c["K${_nid}"]="${_c["K${_pending_key_id}"]}"
				_yaml::_add_child "$1" "$_t_id" "$_nid"
				_pending_key_id=0
			fi
			unset '_stack[-1]'
			((_dp--))
		done

		# Resolve pending key
		if (( _pending_key_id > 0 )); then
			local _ptop="${_stack[$((_dp-1))]}"
			local _p_id="${_ptop%%:*}"
			local _prest="${_ptop#*:}"
			local _p_indent="${_prest%%:*}"
			if (( _indent <= _p_indent )); then
				_c["V${_pending_key_id}"]="null"
				_yaml::_add_child "$1" "$_p_id" "$_pending_key_id"
				_pending_key_id=0
			fi
		fi

		# --- Flow container ---
		if [[ "$_stripped" =~ ^[\{\[] ]] && { [[ "$_stripped" =~ [\}]$ ]] || [[ "$_stripped" =~ [\]]$ ]]; }; then
			local _ptop="${_stack[$((_dp-1))]}"
			local _p_id="${_ptop%%:*}"
			_yaml::_parse_flow "$1" "$_stripped" "$_p_id"
			local _flow_id="$_yaml_flow_id"
			if (( _pending_key_id > 0 )); then
				_c["K${_flow_id}"]="${_c["K${_pending_key_id}"]}"
				_yaml::_add_child "$1" "$_p_id" "$_flow_id"
				_pending_key_id=0
			elif [[ -z "${_c["C${_p_id}"]}" ]] && (( _indent == 0 )); then
				# Root is empty — make the flow container the root
				_c[_root]="$_flow_id"
				local _ft="${_c[T${_flow_id}]}"
				_stack=("${_flow_id}:0:$([[ "$_ft" == "mapping" ]] && echo "M" || echo "A")")
				_dp=1
			else
				_yaml::_add_child "$1" "$_p_id" "$_flow_id"
			fi
			continue
		fi

		# --- Sequence item: - value ---
		if [[ "$_stripped" == '-' ]] || [[ "$_stripped" =~ ^-\  ]]; then
			local _item="${_stripped#-}"
			[[ -n "$_item" ]] && _item="${_item#"${_item%%[![:space:]]*}"}"

			local _ptop="${_stack[$((_dp-1))]}"
			local _p_id="${_ptop%%:*}"
			local _prest="${_ptop#*:}"
			local _p_indent="${_prest%%:*}"
			local _p_type="${_prest#*:}"

			if (( _pending_key_id > 0 )); then
				_yaml::_new_node "$1" sequence
				local _seq_id="$_yaml_last_id"
				_c["K${_seq_id}"]="${_c["K${_pending_key_id}"]}"
				_yaml::_add_child "$1" "$_p_id" "$_seq_id"
				_pending_key_id=0
				_stack+=("${_seq_id}:${_indent}:A")
				((_dp++))
			elif (( _dp == 0 )) || (( _indent > _p_indent )) || [[ "$_p_type" != "A" ]]; then
				_yaml::_new_node "$1" sequence
				local _new_seq="$_yaml_last_id"
				_yaml::_add_child "$1" "$_p_id" "$_new_seq"
				_stack+=("${_new_seq}:${_indent}:A")
				((_dp++))
			fi

			local _top="${_stack[$((_dp-1))]}"
			local _t_id="${_top%%:*}"

			# Block scalar: - | or - >
			if [[ "$_item" =~ ^[\|\>] ]]; then
				_yaml::_new_node "$1" scalar
				local _scalar_id="$_yaml_last_id"
				_c["K${_scalar_id}"]=""
				_yaml::_add_child "$1" "$_t_id" "$_scalar_id"
				_block_node="$_scalar_id"
				_block_type="${_item:0:1}"
				_block_chomp="${_item:1}"
				_block_indent="$_indent"
				_block_lines=()
				_block_content_indent=0
				_in_block=1
				continue
			fi

			if [[ -z "$_item" ]]; then
				_yaml::_new_node "$1" mapping
				local _new_map="$_yaml_last_id"
				_yaml::_add_child "$1" "$_t_id" "$_new_map"
				_stack+=("${_new_map}:${_indent}:M")
				((_dp++))
			elif [[ "$_item" =~ ^[\{\[] ]]; then
				local _flow_id
				_yaml::_parse_flow "$1" "$_item" "$_t_id"
					_flow_id="$_yaml_flow_id"
				_yaml::_add_child "$1" "$_t_id" "$_flow_id"
			elif [[ "$_item" =~ :[[:space:]] ]] || [[ "$_item" =~ :$ ]]; then
				local _k="${_item%%:*}" _v="${_item#*:}"
				_k="${_k%"${_k##*[![:space:]]}"}"
				_k="$(_yaml::_unquote "$_k")"
				_v="${_v#"${_v%%[![:space:]]*}"}"

				_yaml::_new_node "$1" mapping
				local _new_map="$_yaml_last_id"
				_yaml::_add_child "$1" "$_t_id" "$_new_map"
				_stack+=("${_new_map}:${_indent}:M")
				((_dp++))

				if [[ -z "$_v" ]]; then
					_yaml::_new_node "$1" scalar
					local _key_id="$_yaml_last_id"
					_c["K${_key_id}"]="$_k"
					_c["V${_key_id}"]=""
					_yaml::_add_child "$1" "$_new_map" "$_key_id"
					_pending_key_id="$_key_id"
					_pending_key_indent="$_indent"
				elif [[ "$_v" =~ ^[\|\>] ]]; then
					_yaml::_new_node "$1" scalar
					local _key_id="$_yaml_last_id"
					_c["K${_key_id}"]="$_k"
					_c["V${_key_id}"]=""
					_yaml::_add_child "$1" "$_new_map" "$_key_id"
					_yaml::_new_node "$1" scalar
					local _scalar_id="$_yaml_last_id"
					_c["K${_scalar_id}"]=""
					_yaml::_add_child "$1" "$_key_id" "$_scalar_id"
					_block_node="$_scalar_id"
					_block_type="${_v:0:1}"
					_block_chomp="${_v:1}"
					_block_indent="$_indent"
					_block_lines=()
					_block_content_indent=0
					_in_block=1
					_pending_key_id=0
				else
					local _val_id
					if [[ "$_v" =~ ^[\{\[] ]]; then
						_yaml::_parse_flow "$1" "$_v" "$_new_map"
						_val_id="$_yaml_flow_id"
					else
						_yaml::_new_node "$1" scalar
						_val_id="$_yaml_last_id"
						_v="$(_yaml::_unquote "$_v")"
						_c["V${_val_id}"]="$_v"
					fi
					_c["K${_val_id}"]="$_k"
					_yaml::_add_child "$1" "$_new_map" "$_val_id"
				fi
			else
				_yaml::_new_node "$1" scalar
				local _val_id="$_yaml_last_id"
				_item="$(_yaml::_unquote "$_item")"
				_c["V${_val_id}"]="$_item"
				_yaml::_add_child "$1" "$_t_id" "$_val_id"
			fi
			continue
		fi

		# --- Map entry: key: value ---
		# If pending key + deeper indent → handle as nested value
		if (( _pending_key_id > 0 )); then
			local _ptop="${_stack[$((_dp-1))]}"
			local _p_id="${_ptop%%:*}"
			local _prest="${_ptop#*:}"
			local _p_indent="${_prest%%:*}"
			if (( _indent > _pending_key_indent )); then
				if [[ "$_stripped" =~ :[[:space:]] ]] || [[ "$_stripped" =~ :$ ]]; then
					# Line is a map entry → create nested map
					_yaml::_new_node "$1" mapping
					local _new_map="$_yaml_last_id"
					_c["K${_new_map}"]="${_c["K${_pending_key_id}"]}"
					_yaml::_add_child "$1" "$_p_id" "$_new_map"
					_stack+=("${_new_map}:${_indent}:M")
					((_dp++))
					_pending_key_id=0
					# Fall through to process this line as entry in the new map
				else
					# Plain scalar → value for the pending key
					local _val_id
					_yaml::_new_node "$1" scalar
					_val_id="$_yaml_last_id"
					_stripped="$(_yaml::_unquote "$_stripped")"
					_c["V${_val_id}"]="$_stripped"
					_c["K${_val_id}"]="${_c["K${_pending_key_id}"]}"
					_yaml::_add_child "$1" "$_p_id" "$_val_id"
					_pending_key_id=0
					continue
				fi
			fi
		fi

		if [[ "$_stripped" =~ :[[:space:]] ]] || [[ "$_stripped" =~ :$ ]]; then
			local _k="${_stripped%%:*}" _v="${_stripped#*:}"
			_k="${_k%"${_k##*[![:space:]]}"}"
			_k="$(_yaml::_unquote "$_k")"
			_v="${_v#"${_v%%[![:space:]]*}"}"

			local _ptop="${_stack[$((_dp-1))]}"
			local _p_id="${_ptop%%:*}"

			# Resolve previous pending key
			if (( _pending_key_id > 0 )); then
				_yaml::_new_node "$1" scalar
				local _nid="$_yaml_last_id"
				_c["V${_nid}"]="null"
				_c["K${_nid}"]="${_c["K${_pending_key_id}"]}"
				_yaml::_add_child "$1" "$_p_id" "$_nid"
				_pending_key_id=0
			fi

			# Block scalar
			if [[ "$_v" =~ ^[\|\>] ]]; then
				_yaml::_new_node "$1" scalar
				local _key_id="$_yaml_last_id"
				_c["K${_key_id}"]="$_k"
				_c["V${_key_id}"]=""
				_yaml::_add_child "$1" "$_p_id" "$_key_id"
				_yaml::_new_node "$1" scalar
				local _scalar_id="$_yaml_last_id"
				_c["K${_scalar_id}"]=""
				_yaml::_add_child "$1" "$_key_id" "$_scalar_id"
				_block_node="$_scalar_id"
				_block_type="${_v:0:1}"
				_block_chomp="${_v:1}"
				_block_indent="$_indent"
				_block_lines=()
				_block_content_indent=0
				_in_block=1
				_pending_key_id=0
				continue
			fi

			if [[ -z "$_v" ]]; then
				_yaml::_new_node "$1" scalar
				local _key_id="$_yaml_last_id"
				_c["K${_key_id}"]="$_k"
				_c["V${_key_id}"]=""
				# Don't add as child yet — wait for value resolution
				_pending_key_id="$_key_id"
				_pending_key_indent="$_indent"
			else
				local _val_id
				if [[ "$_v" =~ ^[\{\[] ]]; then
					_yaml::_parse_flow "$1" "$_v" "$_p_id"
					_val_id="$_yaml_flow_id"
				else
					_yaml::_new_node "$1" scalar
					_val_id="$_yaml_last_id"
					_v="$(_yaml::_unquote "$_v")"
					_c["V${_val_id}"]="$_v"
				fi
				_c["K${_val_id}"]="$_k"
				_yaml::_add_child "$1" "$_p_id" "$_val_id"
				_pending_key_id=0
			fi
			continue
		fi

		# --- Plain scalar continuation (pending key value) ---
		if (( _pending_key_id > 0 )); then
			local _ptop="${_stack[$((_dp-1))]}"
			local _p_id="${_ptop%%:*}"
			local _prest="${_ptop#*:}"
			local _p_indent="${_prest%%:*}"
			if (( _indent > _p_indent )); then
				_yaml::_new_node "$1" scalar
				local _val_id="$_yaml_last_id"
				_stripped="$(_yaml::_unquote "$_stripped")"
				_c["V${_val_id}"]="$_stripped"
				_c["K${_val_id}"]="${_c["K${_pending_key_id}"]}"
				_yaml::_add_child "$1" "$_p_id" "$_val_id"
				_pending_key_id=0
				continue
			fi
		fi

	done <<< "$_yaml"

	# Flush pending block scalar
	if (( _in_block )); then
		_yaml::_flush_block "$1" "$_block_node" "$_block_type" "$_block_chomp"
	fi

	# Resolve trailing pending key
	if (( _pending_key_id > 0 )); then
		local _ptop="${_stack[$((_dp-1))]}"
		local _p_id="${_ptop%%:*}"
		_yaml::_new_node "$1" scalar
		local _nid="$_yaml_last_id"
		_c["V${_nid}"]="null"
		_c["K${_nid}"]="${_c["K${_pending_key_id}"]}"
		_yaml::_add_child "$1" "$_p_id" "$_nid"
	fi
}

_yaml::_flush_block() {
	local -n _c="$1"
	local _node="$2" _type="$3" _chomp="$4"
	local _joined=""
	if [[ "$_type" == '|' ]]; then
		printf -v _joined '%s\n' "${_block_lines[@]}"
		_joined="${_joined%$'\n'}"
	else
		local _b
		for _b in "${_block_lines[@]}"; do
			[[ -z "${_b##*[![:space:]]*}" ]] && _joined+="$_b " || _joined+=$'\n'
		done
		_joined="${_joined% }"
	fi
	case "$_chomp" in
		*-) _joined="${_joined%"${_joined##*[!$'\n']}"}" ;;
		*+) ;;
		*)  _joined="${_joined%$'\n'}" ;;
	esac
	_c["V${_node}"]="$_joined"
}

# --- Query API ---

_yaml::_resolve() {
	local -n _c="$1"
	local _path="$2" _node="${_c[_root]}"
	[[ -z "$_path" ]] && { echo "$_node"; return; }

	local _segments _segment
	string::split::fast _segments '.' "$_path"
	local _i
	for (( _i=0; _i<${#_segments[@]}; _i++ )); do
		_segment="${_segments[$_i]}"
		local _type="${_c["T${_node}"]}"
		case "$_type" in
			mapping)
				local _found=0 _children _child
				_children="${_c["C${_node}"]}"
				for _child in $_children; do
					if [[ "${_c["K${_child}"]}" == "$_segment" ]]; then
						_node="$_child"
						_found=1
						break
					fi
				done
				(( _found )) || { echo "yaml: key '$_segment' not found" >&2; return 1; }
				;;
			sequence)
				if ! [[ "$_segment" =~ ^[0-9]+$ ]]; then
					echo "yaml: index must be integer" >&2; return 1
				fi
				local _children _child _idx=0
				_children="${_c["C${_node}"]}"
				for _child in $_children; do
					if (( _idx == _segment )); then
						_node="$_child"
						break 2
					fi
					((_idx++))
				done
				echo "yaml: index $_segment out of bounds" >&2; return 1
				;;
			*)
				echo "yaml: cannot navigate into scalar" >&2; return 1
				;;
		esac
	done
	echo "$_node"
}

# Usage: yaml::get <ctx> <yaml> <path>
yaml::get() {
	local -n _c="$1"
	yaml::parse "$1" "$2" || return 1
	local _node
	_node="$(_yaml::_resolve "$1" "$3")" || return 1
	local _type="${_c["T${_node}"]}"
	case "$_type" in
		scalar) echo "${_c["V${_node}"]}" ;;
		*)
			local _json
			_json="$(_yaml::_to_json "$1" "$_node")"
			echo "$_json"
			;;
	esac
}

# Usage: yaml::keys <ctx> <yaml> [path]
yaml::keys() {
	local -n _c="$1"
	yaml::parse "$1" "$2" || return 1
	local _node
	if [[ -n "${3:-}" ]]; then
		_node="$(_yaml::_resolve "$1" "$3")" || return 1
	else
		_node="${_c[_root]}"
	fi
	local _type="${_c["T${_node}"]}"
	case "$_type" in
		mapping)
			local _children _child
			_children="${_c["C${_node}"]}"
			for _child in $_children; do
				echo "${_c["K${_child}"]}"
			done
			;;
		sequence)
			local _children _child _idx=0
			_children="${_c["C${_node}"]}"
			for _child in $_children; do
				echo "$_idx"
				((_idx++))
			done
			;;
		*) echo "yaml: not a container" >&2; return 1 ;;
	esac
}

# Usage: yaml::type <ctx> <yaml> <path>
yaml::type() {
	local -n _c="$1"
	yaml::parse "$1" "$2" || return 1
	local _node
	_node="$(_yaml::_resolve "$1" "$3")" || return 1
	local _type="${_c["T${_node}"]}"
	case "$_type" in
		scalar)
			local _v="${_c["V${_node}"]}"
			case "$_v" in
				'true'|'false') echo "boolean" ;;
				'null') echo "null" ;;
				*)
					if [[ "$_v" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]]; then
						echo "number"
					else
						echo "string"
					fi
					;;
			esac
			;;
		*) echo "$_type" ;;
	esac
}

# Usage: yaml::len <ctx> <yaml> [path]
yaml::len() {
	local -n _c="$1"
	yaml::parse "$1" "$2" || return 1
	local _node
	if [[ -n "${3:-}" ]]; then
		_node="$(_yaml::_resolve "$1" "$3")" || return 1
	else
		_node="${_c[_root]}"
	fi
	local _type="${_c["T${_node}"]}"
	case "$_type" in
		mapping|sequence)
			local _count=0 _children _child
			_children="${_c["C${_node}"]}"
			for _child in $_children; do ((_count++)); done
			echo "$_count"
			;;
		*) echo "yaml: not a container" >&2; return 1 ;;
	esac
}

# --- AST to JSON converter ---

_yaml::_to_json() {
	local -n _c="$1"
	local _node="$2"
	local _type="${_c["T${_node}"]}"

	case "$_type" in
		scalar)
			local _v="${_c["V${_node}"]}"
			_yaml::_classify_scalar "$_v"
			;;
		mapping)
			local _children _child _first=1 _k
			_children="${_c["C${_node}"]}"
			echo -n "{"
			for _child in $_children; do
				(( _first )) || echo -n ","
				_first=0
				_k="${_c["K${_child}"]}"
				echo -n "\"$(_yaml::_json_escape "$_k")\":$(_yaml::_to_json "$1" "$_child")"
			done
			echo -n "}"
			;;
		sequence)
			local _children _child _first=1
			_children="${_c["C${_node}"]}"
			echo -n "["
			for _child in $_children; do
				(( _first )) || echo -n ","
				_first=0
				echo -n "$(_yaml::_to_json "$1" "$_child")"
			done
			echo -n "]"
			;;
	esac
}

# Usage: yaml::to_json <yaml>
yaml::to_json() {
	local -A _yaml_ctx
	yaml::parse _yaml_ctx "$1" || return 1
	_yaml::_to_json _yaml_ctx "${_yaml_ctx[_root]}"
}

# --- Validator ---

yaml::validate() {
	local -A _yaml_ctx
	yaml::parse _yaml_ctx "$1" 2>/dev/null && return 0
	return 1
}

# --- File reader ---

yaml::get_file() {
	local _yaml
	_yaml="$(< "$1")" || { echo "yaml::get_file: cannot read '$1'" >&2; return 1; }
	declare -A _yaml_file_ctx
	yaml::get _yaml_file_ctx "$_yaml" "$2"
}
