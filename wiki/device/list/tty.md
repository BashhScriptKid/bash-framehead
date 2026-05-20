# `device::list::tty`

List all TTY devices

## Source

```bash
device::list::tty() {
    find /dev -maxdepth 1 -name 'tty*' -type c 2>/dev/null | sort
}
```

## Module

[`device`](../device.md)
