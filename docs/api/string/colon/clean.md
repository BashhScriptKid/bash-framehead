# `string::colon::clean`

**Signature:** `string::colon::clean(value)`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Clean a colon-separated value:

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `value` | string | Yes | |

## Source

```bash
string::colon::clean() {
	local _value="$1"
	local -a _arr _out _seen

	IFS=: read -ra _arr <<< "$_value"

	local _e _s
	for _e in "${_arr[@]}"; do
		# Skip empty entries
		[[ -z $_e ]] && continue

		# Skip relative paths
		[[ ${_e:0:1} != '/' ]] && continue

		# Skip if directory does not exist
		[[ -d $_e ]] || continue

		# Skip duplicates
		for _s in "${_seen[@]}"; do
			[[ $_s == "$_e" ]] && continue 2
		done
		_seen+=("$_e")

		_out+=("$_e")
	done

	(IFS=:; echo "${_out[*]}")
}
```

