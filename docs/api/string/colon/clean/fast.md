# `string::colon::clean::fast`

**Signature:** `string::colon::clean::fast(var_ref)`

**Module:** [`string`](../../../string.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Clean a colon-separated variable in-place via nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `var_ref` | variable | Yes | |

## Source

```bash
string::colon::clean::fast() {
	local -n _string_colon_clean_result="$1"
	local -a _arr _out _seen

	IFS=: read -ra _arr <<< "$_string_colon_clean_result"

	local _e _s
	for _e in "${_arr[@]}"; do
		[[ -z $_e ]] && continue
		[[ ${_e:0:1} != '/' ]] && continue
		[[ -d $_e ]] || continue

		for _s in "${_seen[@]}"; do
			[[ $_s == "$_e" ]] && continue 2
		done
		_seen+=("$_e")

		_out+=("$_e")
	done

	local IFS=:
	_string_colon_clean_result="${_out[*]}"
}
```

