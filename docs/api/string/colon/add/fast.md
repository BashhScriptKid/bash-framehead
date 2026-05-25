# `string::colon::add::fast`

**Signature:** `string::colon::add::fast(var_ref, dir, [after|before])`

**Module:** [`string`](../../../string.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Add a directory to a colon-separated variable in-place via nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `var_ref` | variable | Yes | |
| `dir` | string | Yes | |
| `after|before` | string | No | |

## Source

```bash
string::colon::add::fast() {
	local -n _string_colon_add_result="$1"
	local _dir="$2" _pos="${3:-after}"

	if [[ -z $_dir || $_dir == *:* ]]; then
		echo "string::colon::add::fast: invalid argument: '$_dir'" >&2
		return 1
	fi

	local -a _arr
	IFS=: read -ra _arr <<< "$_string_colon_add_result"

	local _e
	for _e in "${_arr[@]}"; do
		[[ $_e == "$_dir" ]] && return 0
	done

	case "$_pos" in
		after) _arr+=("$_dir");;
		*) local -a _tmp=("$_dir"); _tmp+=("${_arr[@]}"); _arr=("${_tmp[@]}");;
	esac

	local IFS=:
	_string_colon_add_result="${_arr[*]}"
}
```

