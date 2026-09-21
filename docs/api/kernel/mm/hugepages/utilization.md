# `kernel::mm::hugepages::utilization`

**Signature:** `kernel::mm::hugepages::utilization()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::mm::hugepages::utilization() {
	local _dir _total _free _utilized=0 _total_all=0
	for _dir in /sys/kernel/mm/hugepages/hugepages-*kB; do
		[[ -d "$_dir" ]] || continue
		_total=$(cat "$_dir/nr_hugepages" 2>/dev/null) || continue
		_free=$(cat "$_dir/free_hugepages" 2>/dev/null) || _free=0
		_total_all=$((_total_all + _total))
		_utilized=$((_utilized + _total - _free))
	done
	(( _total_all > 0 )) && echo $((_utilized * 100 / _total_all)) || echo "0"
}
```

