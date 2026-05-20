# `device::list::loop`

List all loop devices

## Source

```bash
device::list::loop() {
    find /dev -maxdepth 1 -name 'loop*' -type b 2>/dev/null | sort
}
```

## Module

[`device`](../device.md)
