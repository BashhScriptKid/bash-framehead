# `runtime::coproc::send`

**Signature:** `runtime::coproc::send(<name>, <data>)`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Send data to a coproc's stdin.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |
| `<data>` | string | Yes | |

## Source

```bash
runtime::coproc::send() {
		local name=$1 data=$2
		local -n _cs_fd="${name}[1]"
		printf '%s\n' "$data" >&${_cs_fd}
}
```

