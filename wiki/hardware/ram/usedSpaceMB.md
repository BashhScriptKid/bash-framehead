# `hardware::ram::usedSpaceMB`

_No description available._

## Source

```bash
hardware::ram::usedSpaceMB() {
    case "$(runtime::os)" in
    linux|wsl|cygwin|mingw)
        # MemUsed = MemTotal + Shmem - MemFree - Buffers - Cached - SReclaimable
        # Uses MemAvailable when present (Linux 3.14+) for better accuracy
        awk '
            /MemTotal/     { total=$2 }
            /Shmem/        { shmem=$2 }
            /MemFree/      { free=$2 }
            /Buffers/      { buffers=$2 }
            /^Cached/      { cached=$2 }
            /SReclaimable/ { sreclaimable=$2 }
            /MemAvailable/ { avail=$2 }
            END {
                if (avail) {
                    printf "%d\n", (total - avail) / 1024
                } else {
                    printf "%d\n", (total + shmem - free - buffers - cached - sreclaimable) / 1024
                }
            }' /proc/meminfo
        ;;
    darwin)
        local hw_pagesize pages_app pages_wired pages_compressed
        hw_pagesize="$(sysctl -n hw.pagesize)"
        pages_app=$(( $(sysctl -n vm.page_pageable_internal_count) - $(sysctl -n vm.page_purgeable_count) ))
        pages_wired="$(vm_stat | awk '/ wired/ { gsub(/\./, "", $4); print $4 }')"
        pages_compressed="$(vm_stat | awk '/ occupied/ { gsub(/\./, "", $5); print $5 }')"
        pages_compressed="${pages_compressed:-0}"
        echo "$(( (pages_app + pages_wired + pages_compressed) * hw_pagesize / 1024 / 1024 ))"
        ;;
    freebsd|dragonfly)
        local hw_pagesize mem_inactive mem_unused mem_cache mem_free mem_total
        hw_pagesize="$(sysctl -n hw.pagesize)"
        mem_inactive=$(( $(sysctl -n vm.stats.vm.v_inactive_count) * hw_pagesize ))
        mem_unused=$(( $(sysctl -n vm.stats.vm.v_free_count) * hw_pagesize ))
        mem_cache=$(( $(sysctl -n vm.stats.vm.v_cache_count) * hw_pagesize ))
        mem_free=$(( (mem_inactive + mem_unused + mem_cache) / 1024 / 1024 ))
        mem_total=$(hardware::ram::totalSpaceMB)
        echo $(( mem_total - mem_free ))
        ;;
    openbsd)
        vmstat | awk 'END { printf $3 }' | tr -d 'M'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

## Module

[`hardware`](../hardware.md)
