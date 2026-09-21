# `kernel::meminfo::summary`

**Signature:** `kernel::meminfo::summary()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::meminfo::summary() {
	local _total _avail _used _free _buffers _cached _swap_t _swap_f _slab
	_total=$(kernel::meminfo::total)
	_free=$(kernel::meminfo::free)
	_buffers=$(kernel::meminfo::buffers)
	_cached=$(kernel::meminfo::cached)
	_slab=$(kernel::meminfo::slab)
	_swap_t=$(kernel::meminfo::swap_total)
	_swap_f=$(kernel::meminfo::swap_free)
	printf 'total=%sMB free=%sMB buffers=%sMB cached=%sMB slab=%sMB swap_total=%sMB swap_free=%sMB\n' \
		"${_total:-?}" "${_free:-?}" "${_buffers:-?}" "${_cached:-?}" "${_slab:-?}" "${_swap_t:-?}" "${_swap_f:-?}"
}
```

