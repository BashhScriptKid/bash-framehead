# `device::read::gpu::freq`

**Signature:** `device::read::gpu::freq(arg2)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |

## Source

```bash
device::read::gpu::freq() {
		local _card="${1:-card0}"
		local _freq
		_freq=$(cat "/sys/class/drm/${_card}/device/pp_dpm_sclk" 2>/dev/null | grep '\*' | awk '{print $2}') || \
		_freq=$(cat "/sys/class/drm/${_card}/gt_cur_freq_mhz" 2>/dev/null) || \
		{ echo "unknown"; return 1; }
		echo "$_freq"
}
```

