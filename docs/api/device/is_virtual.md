# `device::is_virtual`

**Signature:** `device::is_virtual(arg1)`

**Module:** [`device`](../device.md) — [Guide](../guide/index.md)

**Return:** exit code

## Description

Check if device is a virtual/pseudo device

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::is_virtual() {
		case "$1" in
				/dev/null | /dev/zero | /dev/full | /dev/random | \
				/dev/urandom | /dev/stdin | /dev/stdout | /dev/stderr | \
				/dev/fd/* | /dev/ptmx | /dev/tty*)
						return 0 ;;
				*)
						return 1 ;;
		esac
}
```

