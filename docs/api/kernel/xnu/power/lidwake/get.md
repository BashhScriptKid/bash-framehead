# `kernel::xnu::power::lidwake::get`

**Signature:** `kernel::xnu::power::lidwake::get(arg2)`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |

## Source

```bash
kernel::xnu::power::lidwake::get() {
	local _val
	_val=$(pmset -g 2>/dev/null | awk '/ LidWake/{print $2}')
	echo "${_val:-unknown}"
}
```

