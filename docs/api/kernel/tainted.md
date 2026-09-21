# `kernel::tainted`

**Signature:** `kernel::tainted()`

**Module:** [`kernel`](../kernel.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::tainted() {
	local _val
	_val=$(cat /proc/sys/kernel/tainted 2>/dev/null) || { echo "unknown"; return 1; }
	if [[ "$_val" == "0" ]]; then
		echo "clean"
		return
	fi
	local _flags="" _tmp="$_val"
	(( _tmp & 1 )) && _flags="${_flags}G(proprietary) "
	(( _tmp & 2 )) && _flags="${_flags}F(out-of-tree) "
	(( _tmp & 4 )) && _flags="${_flags}S(unsigned) "
	(( _tmp & 8 ))&&  _flags="${_flags}X(soft-dirty) "
	(( _tmp & 16 )) && _flags="${_flags}D(died) "
	(( _tmp & 32 )) && _flags="${_flags}W(warned) "
	(( _tmp & 64 )) && _flags="${_flags}C(staging) "
	(( _tmp & 128 )) && _flags="${_flags}A(aged) "
	(( _tmp & 256 )) && _flags="${_flags}O(override) "
	(( _tmp & 512 )) && _flags="${_flags}E(signed) "
	printf '%s (%s)' "$_val" "${_flags% }"
}
```

