# `string::var_attrs`

**Signature:** `string::var_attrs(varname)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Print attribute flags of a variable: r=readonly, a=array, A=assoc,

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `varname` | variable | Yes | |

## Source

```bash
string::var_attrs() {
	[[ -v "$1" ]] || { echo "unset"; return 1; }
	echo "${!1@a}"
}
```

