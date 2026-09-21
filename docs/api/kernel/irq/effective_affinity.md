# `kernel::irq::effective_affinity`

**Signature:** `kernel::irq::effective_affinity(arg1)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::irq::effective_affinity() {
	local _irq="$1"
	cat "/proc/irq/$_irq/effective_affinity_list" 2>/dev/null || echo "unknown"
}
```

