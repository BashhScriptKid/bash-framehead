# `device::null_ok`

Check if /dev/null is functional (sanity check)

## Source

```bash
device::null_ok() {
    echo "" > /dev/null 2>&1
}
```

## Module

[`device`](../device.md)
