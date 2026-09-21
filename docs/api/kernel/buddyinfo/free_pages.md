# `kernel::buddyinfo::free_pages`

**Signature:** `kernel::buddyinfo::free_pages()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- BUDDYINFO ---


## Source

```bash
kernel::buddyinfo::free_pages() {
	local _total=0 _line _val
	while IFS= read -r _line; do
		for _val in $_line; do
			[[ "$_val" =~ ^[0-9]+$ ]] && _total=$((_total + _val))
		done
	done < /proc/buddyinfo 2>/dev/null
	echo "$_total"
}
```

