# `device::read::io_stat`

**Signature:** `device::read::io_stat(arg1, arg5)`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg5` | string | Yes | |

## Source

```bash
device::read::io_stat() {
		local _dev="$1" _base="${1##*/}"
		local _stat
		_stat=$(cat "/sys/block/${_base}/stat" 2>/dev/null) || { echo "unknown"; return 1; }
		local _reads _writes _ios
		_reads=$(awk '{print $1}' <<< "$_stat")
		_writes=$(awk '{print $5}' <<< "$_stat")
		_ios=$(awk '{print $9}' <<< "$_stat")
		printf 'reads=%s writes=%s ios=%s\n' "$_reads" "$_writes" "$_ios"
}
```

