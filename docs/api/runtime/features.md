# `runtime::features`

**Signature:** `runtime::features()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Feature introspection as plain API functions (no CLI-style flags). The


## Source

```bash
runtime::features() {
	(( _RUNTIME_FEATURES_READY )) || _runtime::features_scan
	local -a _names=(param_transform case_modify nameref assoc_array assoc_dump assoc_kv epoch_realtime bash_monoseconds globsort unset_array_all wait_n_p mapfile_delim)
	local _id _state
	printf 'bash %s\n' "${BASH_VERSION:-unknown}"
	for ((_id = 0; _id < ${#_names[@]}; _id++)); do
		(( _RUNTIME_FEATURES & (1 << _id) )) && _state=yes || _state=no
		printf '%2d  %-18s %s\n' "$_id" "${_names[_id]}" "$_state"
	done
}
```

