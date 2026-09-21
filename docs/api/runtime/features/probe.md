# `runtime::features::probe`

**Signature:** `runtime::features::probe()`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
runtime::features::probe() {
	local -a _names=(param_transform case_modify nameref assoc_array assoc_dump assoc_kv epoch_realtime bash_monoseconds globsort unset_array_all wait_n_p mapfile_delim)
	local _id _state
	for ((_id = 0; _id < ${#_names[@]}; _id++)); do
		_runtime::feature_probe "${_names[_id]}" && _state=yes || _state=no
		printf '%2d  %-18s %s\n' "$_id" "${_names[_id]}" "$_state"
	done
}
```

