# `runtime::clocks::elapsed`

**Signature:** `runtime::clocks::elapsed($t0)`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Elapsed seconds since a saved monotonic tick.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `$t0` | string | Yes | |

## Source

```bash
runtime::clocks::elapsed() {
		local _start=${1:-}
		[[ -n "$_start" ]] || { echo "0"; return 1; }
		local _now="${BASH_MONOSECONDS:-0}"
		if runtime::has_command bc; then
				echo "$_now - $_start" | bc
		else
				awk -v now="$_now" -v start="$_start" 'BEGIN { printf "%.6f", now - start }'
		fi
}
```

