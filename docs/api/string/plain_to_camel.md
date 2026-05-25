# `string::plain_to_camel`

**Signature:** `string::plain_to_camel()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

plain → camelCase


## Source

```bash
string::plain_to_camel() {
	local input; _string::read_input input "$@"
	local result="" first=true
	for word in $input; do
		if $first; then
			result+="${word,,}"
			first=false
		else result+="${word^}"; fi
	done
	echo "$result"
}
```

