# `device::input::find::id`

**Signature:** `device::input::find::id(arg1)`

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
device::input::find::id() {
		local _id="$1"
		local _link
		_link="/dev/input/by-id/${_id}"
		if [[ -L "$_link" ]]; then
				local _target
				_target=$(readlink "$_link") || { echo ""; return 1; }
				basename "$_target"
				return
		fi
		_link="/dev/input/by-path/${_id}"
		if [[ -L "$_link" ]]; then
				local _target
				_target=$(readlink "$_link") || { echo ""; return 1; }
				basename "$_target"
				return
		fi
		echo ""
		return 1
}
```

