# `kernel::xnu::summary`

**Signature:** `kernel::xnu::summary()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- XNU: Summary ---


## Source

```bash
kernel::xnu::summary() {
	local _model _ncpu _memsize _osver _product _version _build
	_model=$(kernel::xnu::hw::model)
	_ncpu=$(kernel::xnu::hw::ncpu)
	_memsize=$(kernel::xnu::hw::memsize)
	_osver=$(kernel::xnu::kern::osversion)
	_product=$(kernel::xnu::swvers::product)
	_version=$(kernel::xnu::swvers::version)
	_build=$(kernel::xnu::swvers::build)
	printf 'model=%s ncpu=%s memsize=%s osver=%s product=%s version=%s build=%s\n' \
		"$_model" "$_ncpu" "$_memsize" "$_osver" "$_product" "$_version" "$_build"
}
```

