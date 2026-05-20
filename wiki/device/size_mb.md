# `device::size_mb`

Returns the size of a block device in MB

## Source

```bash
device::size_mb() {
    local bytes
    bytes=$(device::size_bytes "$1")
    [[ "$bytes" == "unknown" ]] && echo "unknown" && return
    echo $(( bytes / 1024 / 1024 ))
}
```

## Module

[`device`](../device.md)
