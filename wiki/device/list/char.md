# `device::list::char`

List all character devices

## Source

```bash
device::list::char() {
    find /dev -maxdepth 1 -type c 2>/dev/null | sort
}
```

## Module

[`device`](../device.md)
