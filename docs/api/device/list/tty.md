# `device::list::tty`

**Signature:** `device::list::tty()`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

List all TTY devices


## Source

```bash
device::list::tty() {
    find /dev -maxdepth 1 -name 'tty*' -type c 2>/dev/null | sort
}
```

