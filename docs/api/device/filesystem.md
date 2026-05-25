# `device::filesystem`

**Signature:** `device::filesystem(arg1, arg2)`

**Module:** [`device`](../device.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Returns the filesystem on a block device (if mounted or detectable)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
device::filesystem() {
		local dev="$1"
		case "$(runtime::os)" in
		linux|wsl)
				if runtime::has_command blkid; then
						blkid -o value -s TYPE "$dev" 2>/dev/null || echo "unknown"
				else
						echo "unknown"
				fi
				;;
		darwin)
				diskutil info "$dev" 2>/dev/null \
						| awk -F': +' '/Type \(Bundle\)/ { print $2 }' || echo "unknown"
				;;
		*)
				echo "unknown"
				;;
		esac
}
```

