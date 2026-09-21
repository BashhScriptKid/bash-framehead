# `kernel::irq::spurious`

**Signature:** `kernel::irq::spurious(arg1, arg2, arg3)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |
| `arg3` | string | Yes | |

## Source

```bash
kernel::irq::spurious() {
	local _irq="$1"
	awk '/^count/{printf "count=%s ", $2} /^unhandled/{printf "unhandled=%s ", $2} /^last_unhandled/{printf "last=%s %s", $2, $3}' \
		"/proc/irq/$_irq/spurious" 2>/dev/null || echo "unknown"
}
```

