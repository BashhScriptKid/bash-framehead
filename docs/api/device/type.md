# `device::type`

**Signature:** `device::type(arg1)`

**Module:** [`device`](../device.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

--- CLASSIFICATION ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::type() {
		local dev="$1"
		local base="${dev##*/}"

		# Virtual/pseudo devices first
		device::is_virtual "$dev" && echo "virtual"   && return
		device::is_loop "$dev"    && echo "loop"      && return
		device::is_ram "$dev"     && echo "ram"       && return

		# TTY / PTY
		[[ "$dev" == /dev/tty*  ]] && echo "tty" && return
		[[ "$dev" == /dev/pts/* ]] && echo "pty" && return

		# NVMe
		[[ "$base" =~ ^nvme[0-9]+n[0-9]+p[0-9]+$ ]] && echo "partition" && return
		[[ "$base" =~ ^nvme[0-9]+n[0-9]+$        ]] && echo "nvme"      && return

		# SD/SAS/SATA partitions vs disks
		[[ "$base" =~ ^sd[a-z]+[0-9]+$  ]] && echo "partition" && return
		[[ "$base" =~ ^sd[a-z]+$        ]] && echo "disk"      && return

		# MMC / eMMC
		[[ "$base" =~ ^mmcblk[0-9]+p[0-9]+$ ]] && echo "partition" && return
		[[ "$base" =~ ^mmcblk[0-9]+$        ]] && echo "disk"      && return

		# IDE (legacy)
		[[ "$base" =~ ^hd[a-z]+[0-9]+$ ]] && echo "partition" && return
		[[ "$base" =~ ^hd[a-z]+$       ]] && echo "disk"      && return

		# Optical
		[[ "$base" =~ ^sr[0-9]+$  ]] && echo "optical" && return
		[[ "$base" =~ ^cd[a-z]+$  ]] && echo "optical" && return

		# USB block devices (often shows as sdX — covered above, but flag specific paths)
		[[ "$dev" == /dev/bus/usb/* ]] && echo "usb" && return

		# Generic character vs block fallback
		device::is_device::block "$dev" && echo "block" && return
		device::is_device::char  "$dev" && echo "char"  && return

		echo "unknown"
}
```

