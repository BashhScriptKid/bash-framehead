# `device::read::alsa::card_info`

**Signature:** `device::read::alsa::card_info(arg1, arg2)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
device::read::alsa::card_info() {
		local _card="$1"
		local _dir="/proc/asound/card${_card}"
		[[ -d "$_dir" ]] || { echo "unknown"; return 1; }
		local _stream _pcm
		for _stream in "$_dir"/pcm*p; do
				[[ -d "$_stream" ]] || continue
				_pcm=$(cat "$_stream/info" 2>/dev/null | grep -E '^card|^id|^name' | awk -F: '{gsub(/^[[:space:]]+/,"",$2); printf "%s=%s ", $1, $2}')
				[[ -n "$_pcm" ]] && echo "$_pcm"
		done
}
```

