# `runtime::bench`

**Signature:** `runtime::bench(sleep, 1)`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Time a command, print elapsed seconds, preserve exit code.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `sleep` | string | Yes | |
| `1` | string | Yes | |

## Source

```bash
runtime::bench() {
		local _t0; _t0=$(runtime::clocks::mono) || return 1
		"$@"
		local _ret=$?
		printf '%.6fs\n' "$(runtime::clocks::elapsed "$_t0")"
		return $_ret
}
```

