# `kernel::irq::list`

**Signature:** `kernel::irq::list()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- IRQ ---


## Source

```bash
kernel::irq::list() {
	local _irq _dir _action _chip _type _count
	for _dir in /sys/kernel/irq/[0-9]*/; do
		[[ -d "$_dir" ]] || continue
		_irq=${_dir%/}
		_irq=${_irq##*/}
		_action=$(cat "$_dir/actions" 2>/dev/null) || continue
		_chip=$(cat "$_dir/chip_name" 2>/dev/null) || _chip="?"
		_type=$(cat "$_dir/type" 2>/dev/null) || __type="?"
		_count=$(cat "$_dir/per_cpu_count" 2>/dev/null) || __count="?"
		printf '%-6s %-20s %-20s %-10s %s\n' "$_irq" "$_action" "$_chip" "$_type" "$_count"
	done
}
```

