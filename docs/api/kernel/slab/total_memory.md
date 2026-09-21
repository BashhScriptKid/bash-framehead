# `kernel::slab::total_memory`

**Signature:** `kernel::slab::total_memory()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::slab::total_memory() {
	local _dir _objects _size _total=0
	for _dir in /sys/kernel/slab/*/; do
		[[ -f "$_dir/object_size" && -f "$_dir/objects" ]] || continue
		_objects=$(cat "$_dir/objects" 2>/dev/null) || continue
		_size=$(cat "$_dir/object_size" 2>/dev/null) || continue
		_total=$((_total + _objects * _size))
	done
	echo "$((_total / 1024))"
}
```

