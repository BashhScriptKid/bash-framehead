# `kernel::irq::info`

**Signature:** `kernel::irq::info(arg1)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::irq::info() {
	local _irq="$1" _dir="/sys/kernel/irq/$_irq"
	[[ -d "$_dir" ]] || { echo "unknown"; return 1; }
	local _action _chip _hwirq _type _count _name
	_action=$(cat "$_dir/actions" 2>/dev/null) || _action="?"
	_chip=$(cat "$_dir/chip_name" 2>/dev/null) || _chip="?"
	_hwirq=$(cat "$_dir/hwirq" 2>/dev/null) || _hwirq="?"
	_type=$(cat "$_dir/type" 2>/dev/null) || _type="?"
	_count=$(cat "$_dir/per_cpu_count" 2>/dev/null) || _count="?"
	_name=$(cat "$_dir/name" 2>/dev/null) || _name=""
	printf 'irq=%s action=%s chip=%s hwirq=%s type=%s count=%s\n' \
		"$_irq" "$_action" "$_chip" "$_hwirq" "$_type" "$_count"
	[[ -n "$_name" ]] && printf 'name=%s\n' "$_name"
}
```

