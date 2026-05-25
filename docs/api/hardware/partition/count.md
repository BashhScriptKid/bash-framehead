# `hardware::partition::count`

**Signature:** `hardware::partition::count()`

**Module:** [`hardware`](../../hardware.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
hardware::partition::count() {
		case "$(runtime::os)" in
		linux|wsl)
				lsblk -no NAME 2>/dev/null | grep -cv '^loop' | xargs
				;;
		darwin)
				diskutil list 2>/dev/null | grep -c '^\s*[0-9]'
				;;
		*)
				echo "unknown"
				;;
		esac
}
```

