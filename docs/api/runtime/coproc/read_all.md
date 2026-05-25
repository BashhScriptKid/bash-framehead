# `runtime::coproc::read_all`

**Signature:** `runtime::coproc::read_all(<name>)`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Read all available output from a coproc (non-blocking).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |

## Source

```bash
runtime::coproc::read_all() {
		local name=$1 line
		local -n _cra_fd="${name}[0]"
		while IFS= read -r -t 0.1 line <&${_cra_fd} 2>/dev/null; do
				echo "$line"
		done
}
```

