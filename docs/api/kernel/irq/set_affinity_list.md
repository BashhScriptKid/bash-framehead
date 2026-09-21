# `kernel::irq::set_affinity_list`

**Signature:** `kernel::irq::set_affinity_list(arg1, arg2)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
kernel::irq::set_affinity_list() {
	local _irq="$1" _list="$2"
	runtime::is_root || { echo "kernel::irq::set_affinity_list: requires root" >&2; return 1; }
	echo "$_list" > "/proc/irq/$_irq/smp_affinity_list"
}
```

