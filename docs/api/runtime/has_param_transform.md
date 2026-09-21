# `runtime::has_param_transform`

**Signature:** `runtime::has_param_transform()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Predicate: reads bit 0 of the cached register directly (no nested call,


## Source

```bash
runtime::has_param_transform() {
	(( _RUNTIME_FEATURES_READY )) || _runtime::features_scan
	(( _RUNTIME_FEATURES & 1 ))
}
```

