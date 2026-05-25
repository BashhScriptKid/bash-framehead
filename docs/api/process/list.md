# `process::list`

**Signature:** `process::list()`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

List all running processes (PID and name)


## Source

```bash
process::list() {
		ps -eo pid,comm --no-headers 2>/dev/null || \
				ps -eo pid,comm 2>/dev/null | tail -n +2
}
```

