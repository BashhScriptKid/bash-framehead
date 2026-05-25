# `runtime::bench::capture`

**Signature:** `runtime::bench::capture(result_var, sleep, 1)`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Time a command, store elapsed in a nameref, preserve exit code.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `sleep` | string | Yes | |
| `1` | string | Yes | |

## Source

```bash
runtime::bench::capture() {
		local -n _bench_result="$1"; shift
		local _t0; _t0=$(runtime::clocks::mono) || return 1
		"$@"
		local _ret=$?
		printf -v _bench_result '%s' "$(runtime::clocks::elapsed "$_t0")"
		return $_ret
}
```

