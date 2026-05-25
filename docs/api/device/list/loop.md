# `device::list::loop`

**Signature:** `device::list::loop()`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

List all loop devices


## Source

```bash
device::list::loop() {
		find /dev -maxdepth 1 -name 'loop*' -type b 2>/dev/null | sort
}
```

