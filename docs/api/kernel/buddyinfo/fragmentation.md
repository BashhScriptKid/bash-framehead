# `kernel::buddyinfo::fragmentation`

**Signature:** `kernel::buddyinfo::fragmentation()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::buddyinfo::fragmentation() {
	local _zone _order _count _total _frag
	while read -r _zone _rest; do
		_zone=${_zone##*:}
		_zone=${_zone# }
		set -- $_rest
		_total=0
		for _order in "${!_rest[@]}"; do
			_count=${_rest[$_order]}
			_total=$((_total + _count))
		done
		if (( _total > 0 )); then
			printf '%s: total=%s\n' "$_zone" "$_total"
			_order=0
			for _count in "${_rest[@]}"; do
				_frag=$(( _count * 100 / _total ))
				printf '  order %s: %s (%s%%)\n' "$_order" "$_count" "$_frag"
				_order=$((_order + 1))
			done
		fi
	done < /proc/buddyinfo 2>/dev/null
}
```

