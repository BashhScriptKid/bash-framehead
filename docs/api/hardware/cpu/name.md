# `hardware::cpu::name`

**Signature:** `hardware::cpu::name(arg1, arg2, arg4)`

**Module:** [`hardware`](../../hardware.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |
| `arg4` | string | Yes | |

## Source

```bash
hardware::cpu::name() {
    case "$(runtime::os)" in
    linux|wsl|cygwin|mingw)
        local cpu
        case "$(uname -m)" in
            "frv"|"hppa"|"m68k"|"openrisc"|"or"*|"powerpc"|"ppc"*|"sparc"*)
                cpu="$(awk -F':' '/^cpu\t|^CPU/ {printf $2; exit}' /proc/cpuinfo)"
                ;;
            "s390"*)
                cpu="$(awk -F'=' '/machine/ {print $4; exit}' /proc/cpuinfo)"
                ;;
            "ia64"|"m32r")
                cpu="$(awk -F':' '/model/ {print $2; exit}' /proc/cpuinfo)"
                [[ -z "$cpu" ]] && cpu="$(awk -F':' '/family/ {printf $2; exit}' /proc/cpuinfo)"
                ;;
            *)
                cpu="$(awk -F'\\s*: | @' \
                    '/model name|Hardware|Processor|^cpu model|chip type|^cpu type/ {
                        cpu=$2; if ($1 == "Hardware") exit } END { print cpu }' /proc/cpuinfo)"
                ;;
        esac
        cpu="${cpu//(TM)}"; cpu="${cpu//(tm)}"
        cpu="${cpu//(R)}";  cpu="${cpu//(r)}"
        cpu="${cpu//CPU}";  cpu="${cpu//Processor}"
        cpu="${cpu//Dual-Core}"; cpu="${cpu//Quad-Core}"
        cpu="${cpu//Six-Core}";  cpu="${cpu//Eight-Core}"
        cpu="${cpu//[1-9][0-9]-Core}"; cpu="${cpu//[0-9]-Core}"
        cpu="${cpu//Core2/Core 2}"
        echo "${cpu}" | xargs
        ;;
    darwin)
        sysctl -n machdep.cpu.brand_string
        ;;
    freebsd|openbsd|netbsd)
        sysctl -n hw.model 2>/dev/null | sed 's/[0-9]\..*//' | sed 's/ @.*//' | xargs
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

