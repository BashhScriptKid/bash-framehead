# `hardware::ram::freeSpaceMB`

**Signature:** `hardware::ram::freeSpaceMB(arg2, arg3)`

**Module:** [`hardware`](../../hardware.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |
| `arg3` | string | Yes | |

## Source

```bash
hardware::ram::freeSpaceMB() {
		case "$(runtime::os)" in
		linux|wsl|cygwin|mingw)
				awk '/MemAvailable/ { printf "%d\n", $2/1024 }' /proc/meminfo
				;;
		darwin)
				local hw_pagesize pages_free
				hw_pagesize="$(sysctl -n hw.pagesize)"
				pages_free="$(vm_stat | awk '/Pages free/ { gsub(/\./, "", $3); print $3 }')"
				echo $(( pages_free * hw_pagesize / 1024 / 1024 ))
				;;
		freebsd|dragonfly|openbsd|netbsd)
				local total used
				total=$(hardware::ram::totalSpaceMB)
				used=$(hardware::ram::usedSpaceMB)
				echo $(( total - used ))
				;;
		*)
				echo "unknown"
				;;
		esac
}
```

