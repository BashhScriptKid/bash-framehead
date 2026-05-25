# `runtime::coproc::read`

**Signature:** `runtime::coproc::read(<name>)`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Read one line from a coproc's stdout (blocks until data available).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |

## Source

```bash
runtime::coproc::read() {
		local name=$1 line
		local -n _cr_fd="${name}[0]"
		IFS= read -r -t 5 line <&${_cr_fd} || true
		echo "$line"
}
```

