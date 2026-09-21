# `device::read::serial::info`

**Signature:** `device::read::serial::info(arg1)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::read::serial::info() {
		local _port="$1"
		local _dir="/sys/class/tty/${_port}"
		[[ -d "$_dir" ]] || { echo "unknown"; return 1; }
		local _driver _type
		_driver=$(readlink "$_dir/device/driver" 2>/dev/null | xargs basename 2>/dev/null) || _driver="unknown"
		if [[ -e "/dev/${_port}" ]]; then
				if [[ -c "/dev/${_port}" ]]; then
						_type="char"
				else
						_type="unknown"
				fi
		else
				_type="missing"
		fi
		printf 'port=%s driver=%s type=%s\n' "$_port" "$_driver" "$_type"
}
```

