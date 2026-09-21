# `kernel::irq::busiest`

**Signature:** `kernel::irq::busiest(arg1, arg2, arg3)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

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
kernel::irq::busiest() {
	local _count="${1:-10}" _irq _dir _action _total _all
	_all=""
	for _dir in /sys/kernel/irq/[0-9]*/; do
		[[ -d "$_dir" ]] || continue
		_irq=${_dir%/}
		_irq=${_irq##*/}
		_action=$(cat "$_dir/actions" 2>/dev/null) || continue
		_total=$(cat "$_dir/per_cpu_count" 2>/dev/null) || _total=0
		# Sum all per_cpu_count values
		_total=0
		local _val
		_val=$(cat "$_dir/per_cpu_count" 2>/dev/null) || _val="0"
		_total=0
		local _n
		for _n in $_val; do
			_total=$((_total + _n))
		done
		_all="${_all}${_total} ${_irq} ${_action}\n"
	done
	printf "$_all" | sort -rn | head -"$_count" | \
		awk '{printf "%-6s %-20s %s\n", $2, $3, $1}'
}
```

