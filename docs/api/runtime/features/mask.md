# `runtime::features::mask`

**Signature:** `runtime::features::mask()`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
runtime::features::mask() {
	(( _RUNTIME_FEATURES_READY )) || _runtime::features_scan
	printf '0x%x\n' "$_RUNTIME_FEATURES"
}
```

