# `hardware::cpu::core_count::physical`

**Signature:** `hardware::cpu::core_count::physical(arg2)`

**Module:** [`hardware`](../../../hardware.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |

## Source

```bash
hardware::cpu::core_count::physical() {
		case "$(runtime::os)" in
		linux|wsl|cygwin|mingw)
				case "$(uname -m)" in
						"sparc"*)
								lscpu 2>/dev/null | awk -F': *' '
										/^Core\(s\) per socket/ { cores=$2 }
										/^Socket\(s\)/          { sockets=$2 }
										END { print cores * sockets }'
								;;
						*)
								awk '/^core id/&&!a[$0]++{++i} END {print i}' /proc/cpuinfo
								;;
				esac
				;;
		darwin)
				sysctl -n hw.physicalcpu
				;;
		freebsd|openbsd|netbsd)
				sysctl -n hw.ncpu 2>/dev/null || echo "unknown"
				;;
		*)
				echo "unknown"
				;;
		esac
}
```

