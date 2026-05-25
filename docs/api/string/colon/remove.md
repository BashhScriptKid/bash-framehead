# `string::colon::remove`

**Signature:** `string::colon::remove(value, dir)`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Remove every instance of a directory from a colon-separated value

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `value` | string | Yes | |
| `dir` | string | Yes | |

## Source

```bash
string::colon::remove() {
	local _value="$1" _dir="$2"

	if [[ -z $_dir || $_dir == *:* ]]; then
		echo "string::colon::remove: invalid argument: '$_dir'" >&2
		return 1
	fi

	local -a _arr _out
	IFS=: read -ra _arr <<< "$_value"

	local _e
	for _e in "${_arr[@]}"; do
		[[ $_e == "$_dir" ]] && continue
		_out+=("$_e")
	done

	(IFS=:; echo "${_out[*]}")
}
```

