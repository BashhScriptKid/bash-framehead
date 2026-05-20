# `hardware::cpu::frequencyMHz`

_No description available._

## Source

```bash
hardware::cpu::frequencyMHz() {
    case "$(runtime::os)" in
    linux|wsl|cygwin|mingw)
        local speed_dir="/sys/devices/system/cpu/cpu0/cpufreq"
        # /sys/ only exists on Linux/WSL — cygwin/mingw fall through to /proc/cpuinfo
        if [[ -d "$speed_dir" ]]; then
            local speed
            speed="$(cat "${speed_dir}/scaling_cur_freq" 2>/dev/null)" ||
            speed="$(cat "${speed_dir}/bios_limit" 2>/dev/null)" ||
            speed="$(cat "${speed_dir}/scaling_max_freq" 2>/dev/null)" ||
            speed="$(cat "${speed_dir}/cpuinfo_max_freq" 2>/dev/null)"
            echo "$((speed / 1000))"
        else
            case "$(uname -m)" in
                "sparc"*)
                    echo "$(( $(cat /sys/devices/system/cpu/cpu0/clock_tick 2>/dev/null) / 1000000 ))"
                    ;;
                *)
                    awk -F': |\\.' '/cpu MHz|^clock/ {printf $2; exit}' /proc/cpuinfo \
                        | sed 's/MHz//' | xargs
                    ;;
            esac
        fi
        ;;
    darwin)
        sysctl -n hw.cpufrequency 2>/dev/null \
            | awk '{ printf "%d\n", $1/1000000 }' || echo "unknown"
        ;;
    freebsd|openbsd|netbsd)
        sysctl -n hw.cpuspeed 2>/dev/null \
            || sysctl -n hw.clockrate 2>/dev/null \
            || echo "unknown"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

## Module

[`hardware`](../hardware.md)
