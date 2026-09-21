# `kernel::vmstat::thp_fault_alloc`

**Signature:** `kernel::vmstat::thp_fault_alloc(arg2)`

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
kernel::vmstat::thp_fault_alloc() {
	awk '/^thp_fault_alloc/{print $2}' /proc/vmstat 2>/dev/null || echo "0"
}
```

