# `kernel::vmstat::get`

**Signature:** `kernel::vmstat::get(arg1, arg2)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- VMSTAT ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
kernel::vmstat::get() {
	local _key="$1"
	awk -v k="$_key" '$1==k{print $2}' /proc/vmstat 2>/dev/null || echo "unknown"
}
```

