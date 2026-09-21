# `kernel::irq::by_device`

**Signature:** `kernel::irq::by_device(arg1)`

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
kernel::irq::by_device() {
	local _pattern="$1" _irq _dir _action
	for _dir in /sys/kernel/irq/[0-9]*/; do
		[[ -d "$_dir" ]] || continue
		_irq=${_dir%/}
		_irq=${_irq##*/}
		_action=$(cat "$_dir/actions" 2>/dev/null) || continue
		[[ "$_action" == *"$_pattern"* ]] && kernel::irq::info "$_irq"
	done
}
```

