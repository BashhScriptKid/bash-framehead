# `kernel::vmstat::pswpout`

**Signature:** `kernel::vmstat::pswpout(arg2)`

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
kernel::vmstat::pswpout() {
	awk '/^pswpout/{print $2}' /proc/vmstat 2>/dev/null || echo "0"
}
```

