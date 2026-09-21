# `device::read::input::info`

**Signature:** `device::read::input::info(arg1, arg2)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
device::read::input::info() {
		local _pattern="$1"
		if [[ -f /proc/bus/input/devices ]]; then
				awk -v pat="$_pattern" -F= '
				/^N:/{name=$2; buf=$0}
				/^H:/{handlers=$2; buf=buf"\n"$0}
				/^B: EV/{ev=$2; buf=buf"\n"$0}
				/^B: KEY/{key=$2; buf=buf"\n"$0}
				/^B: ABS/{abs=$2; buf=buf"\n"$0}
				/^B: REL/{rel=$2; buf=buf"\n"$0}
				/^S:/{sysfs=$2; buf=buf"\n"$0}
				/^$/{if(name ~ pat || handlers ~ pat)print buf"\n"; buf=""}
				' /proc/bus/input/devices
		else
				echo "unknown"
		fi
}
```

