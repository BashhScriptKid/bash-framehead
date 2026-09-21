# `kernel::bsd::summary`

**Signature:** `kernel::bsd::summary()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- BSD: Summary ---


## Source

```bash
kernel::bsd::summary() {
	local _model _ncpu _physmem _maxproc _maxfiles _swap
	_model=$(kernel::bsd::hw::model)
	_ncpu=$(kernel::bsd::hw::ncpu)
	_physmem=$(kernel::bsd::hw::physmem)
	_maxproc=$(kernel::bsd::kern::maxproc::get)
	_maxfiles=$(kernel::bsd::kern::maxfiles::get)
	_swap=$(kernel::bsd::vm::swapusage)
	printf 'model=%s ncpu=%s physmem=%s maxproc=%s maxfiles=%s swap=%s\n' \
		"$_model" "$_ncpu" "$_physmem" "$_maxproc" "$_maxfiles" "$_swap"
}
```

