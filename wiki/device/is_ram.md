# `device::is_ram`

Check if device is a RAM disk

## Source

```bash
device::is_ram() {
    [[ "$1" == /dev/ram* || "$1" == /dev/zram* ]]
}
```

## Module

[`device`](../device.md)
