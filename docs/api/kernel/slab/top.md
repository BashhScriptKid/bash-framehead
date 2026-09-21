# `kernel::slab::top`

**Signature:** `kernel::slab::top(arg1, arg2, arg3, arg4)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- SLAB ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |
| `arg3` | string | Yes | |
| `arg4` | string | Yes | |

## Source

```bash
kernel::slab::top() {
	local _count="${1:-10}" _dir _name _objects _size
	for _dir in /sys/kernel/slab/*/; do
		[[ -f "$_dir/object_size" && -f "$_dir/objects" ]] || continue
		_objects=$(cat "$_dir/objects" 2>/dev/null) || continue
		_size=$(cat "$_dir/object_size" 2>/dev/null) || continue
		_name=${_dir%/}
		_name=${_name##*/}
		echo "$((_objects * _size)) $_name $_objects $_size"
	done | sort -rn | head -"$_count" | \
		awk '{printf "%-30s objects=%-10s size=%-8s total=%s\n", $2, $3, $4, $1}'
}
```

