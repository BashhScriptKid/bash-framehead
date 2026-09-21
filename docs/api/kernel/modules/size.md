# `kernel::modules::size`

**Signature:** `kernel::modules::size(arg2)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- MODULES (EXTENDED) ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |

## Source

```bash
kernel::modules::size() {
	awk '{sum += $2} END{print sum}' /proc/modules 2>/dev/null || echo "0"
}
```

