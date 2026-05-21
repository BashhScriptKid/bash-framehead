# `device::list::char`

**Signature:** `device::list::char()`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

List all character devices


## Source

```bash
device::list::char() {
    find /dev -maxdepth 1 -type c 2>/dev/null | sort
}
```

