# `process::uptime`

**Signature:** `process::uptime(arg1, arg2)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Get process uptime in seconds

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
process::uptime() {
		local pid="$1"
		if [[ -f "/proc/$pid/stat" ]]; then
				local clk_tck start_ticks uptime_secs
				clk_tck=$(getconf CLK_TCK 2>/dev/null || echo 100)
				start_ticks=$(awk '{print $22}' "/proc/$pid/stat")
				uptime_secs=$(awk '{print $1}' /proc/uptime)
				echo "$(( ${uptime_secs%.*} - start_ticks / clk_tck ))"
		fi
}
```

