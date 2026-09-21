# `kernel::slab::cache_info`

**Signature:** `kernel::slab::cache_info(arg1)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::slab::cache_info() {
	local _cache="$1" _dir="/sys/kernel/slab/$_cache"
	[[ -d "$_dir" ]] || { echo "unknown"; return 1; }
	local _objects _size _slabs _ctor
	_objects=$(cat "$_dir/objects" 2>/dev/null) || _objects="?"
	_size=$(cat "$_dir/object_size" 2>/dev/null) || _size="?"
	_slabs=$(cat "$_dir/slabs" 2>/dev/null) || _slabs="?"
	_ctor=$(cat "$_dir/ctor" 2>/dev/null) || _ctor=""
	printf 'objects=%s object_size=%s slabs=%s' "$_objects" "$_size" "$_slabs"
	[[ -n "$_ctor" && "$_ctor" != "0" && "$_ctor" != "" ]] && printf ' ctor=%s' "$_ctor"
	echo
}
```

