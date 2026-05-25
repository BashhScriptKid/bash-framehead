# `runtime::timestamp`

**Signature:** `runtime::timestamp()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

ISO-8601 timestamp with microseconds.


## Source

```bash
runtime::timestamp() {
		local _ts; _ts=$(runtime::clocks::wall) || return 1
		local _sec="${_ts%.*}" _us="${_ts#*.}"
		printf "%(%Y-%m-%dT%H:%M:%S)T.%s" "$_sec" "$_us"
}
```

