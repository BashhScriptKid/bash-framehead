# `hardware::cpu::core_count::logical`

**Signature:** `hardware::cpu::core_count::logical(arg2)`

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
hardware::cpu::core_count::logical() {
    case "$(runtime::os)" in
    linux|wsl|cygwin|mingw)
        case "$(uname -m)" in
            "sparc"*)
                lscpu 2>/dev/null | awk -F': *' '/^CPU\(s\)/ {print $2}'
                ;;
            *)
                grep -c '^processor' /proc/cpuinfo
                ;;
        esac
        ;;
    darwin)
        sysctl -n hw.logicalcpu
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

