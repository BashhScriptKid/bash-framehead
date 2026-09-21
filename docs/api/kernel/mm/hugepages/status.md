# `kernel::mm::hugepages::status`

**Signature:** `kernel::mm::hugepages::status()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::mm::hugepages::status() {
	local _dir _size _free _total
	for _dir in /sys/kernel/mm/hugepages/hugepages-*kB; do
		[[ -d "$_dir" ]] || continue
		_size=${_dir##*-}
		_size=${_size%kB}
		_total=$(cat "$_dir/nr_hugepages" 2>/dev/null) || continue
		_free=$(cat "$_dir/free_hugepages" 2>/dev/null) || _free=0
		printf '%skB: free=%s total=%s\n' "$_size" "$_free" "$_total"
	done
}
```

