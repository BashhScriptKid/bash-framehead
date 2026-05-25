# `runtime::coproc::pid`

**Signature:** `runtime::coproc::pid(<name>)`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Echo the PID of a named coproc.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |

## Source

```bash
runtime::coproc::pid() {
		local -n _cp_var="${1}_PID"
		echo "${_cp_var:-}"
}
```

