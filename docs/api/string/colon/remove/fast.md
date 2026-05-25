# `string::colon::remove::fast`

**Signature:** `string::colon::remove::fast(var_ref, dir)`

**Module:** [`string`](../../../string.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Remove every instance of a directory from a colon-separated variable in-place

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `var_ref` | variable | Yes | |
| `dir` | string | Yes | |

## Source

```bash
string::colon::remove::fast() {
	local -n _string_colon_remove_result="$1"
	local _dir="$2"

	if [[ -z $_dir || $_dir == *:* ]]; then
		echo "string::colon::remove::fast: invalid argument: '$_dir'" >&2
		return 1
	fi

	local -a _arr _out
	IFS=: read -ra _arr <<< "$_string_colon_remove_result"

	local _e
	for _e in "${_arr[@]}"; do
		[[ $_e == "$_dir" ]] && continue
		_out+=("$_e")
	done

	local IFS=:
	_string_colon_remove_result="${_out[*]}"
}
```

