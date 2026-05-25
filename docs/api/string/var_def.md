# `string::var_def`

**Signature:** `string::var_def(varname)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Print a variable's definition in re-eval'able declare form.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `varname` | variable | Yes | |

## Source

```bash
string::var_def() {
	[[ -v "$1" ]] || return 1
	echo "${!1@A}"
}
```

