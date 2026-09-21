# `kernel::meminfo::buffers`

**Signature:** `kernel::meminfo::buffers(arg2)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- MEMINFO (EXTENDED) ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |

## Source

```bash
kernel::meminfo::buffers() {
	awk '/^Buffers:/{printf "%.0f", $2/1024}' /proc/meminfo 2>/dev/null || echo "unknown"
}
```

