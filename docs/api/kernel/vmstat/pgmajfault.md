# `kernel::vmstat::pgmajfault`

**Signature:** `kernel::vmstat::pgmajfault(arg2)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |

## Source

```bash
kernel::vmstat::pgmajfault() {
	awk '/^pgmajfault/{print $2}' /proc/vmstat 2>/dev/null || echo "0"
}
```

