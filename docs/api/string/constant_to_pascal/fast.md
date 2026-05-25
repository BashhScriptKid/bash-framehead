# `string::constant_to_pascal::fast`

**Signature:** `string::constant_to_pascal::fast(result_var, arg1)`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `arg1` | string | Yes | |

## Source

```bash
string::constant_to_pascal::fast() {
	local -n _string_constant_to_pascal_result="$1"
	local result="" words="${2,,}"
	words="${words//_/ }"
	for word in $words; do result+="${word^}"; done
	_string_constant_to_pascal_result="$result"
}
```

