# `hardware::partition::info`

**Signature:** `hardware::partition::info([mountpoint])`

**Module:** [`hardware`](../../hardware.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Returns human-readable disk info for a mount point (default: /)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `mountpoint` | path | No | |

## Source

```bash
hardware::partition::info() {
    local mount="${1:-/}"
    runtime::has_command df || { echo "unknown"; return 1; }

    local -a flags
    read -ra flags <<< "$(_hardware::df_flags)"

    local -a disks
    IFS=$'\n' read -d "" -ra disks <<< "$(df "${flags[@]}" "$mount" 2>/dev/null)"
    unset "disks[0]"

    [[ ${disks[*]} ]] || { echo "unknown"; return 1; }

    local -a disk_info
    IFS=" " read -ra disk_info <<< "${disks[0]}"
    local used="${disk_info[${#disk_info[@]} - 4]}"
    local total="${disk_info[${#disk_info[@]} - 5]}"
    local perc="${disk_info[${#disk_info[@]} - 2]/\%}"
    echo "${used} / ${total} (${perc}%)"
}
```

