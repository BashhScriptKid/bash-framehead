# `device::mount_point`

**Signature:** `device::mount_point(arg1, arg2)`

**Module:** [`device`](../device.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Returns the mount point of a block device (empty if not mounted)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
device::mount_point() {
		local dev="$1"
		case "$(runtime::os)" in
		linux|wsl)
				grep "^$dev " /proc/mounts 2>/dev/null | awk '{print $2}' | head -1
				;;
		darwin)
				diskutil info "$dev" 2>/dev/null \
						| awk -F': +' '/Mount Point/ { print $2 }'
				;;
		*)
				echo ""
				;;
		esac
}
```

