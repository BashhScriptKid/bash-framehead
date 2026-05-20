# `device::is_mounted`

Check if a block device is mounted

## Source

```bash
device::is_mounted() {
    grep -q "^$1 " /proc/mounts 2>/dev/null \
        || grep -q " $1 " /proc/mounts 2>/dev/null
}
```

## Module

[`device`](../device.md)
