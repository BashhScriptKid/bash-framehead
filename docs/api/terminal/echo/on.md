# `terminal::echo::on`

**Signature:** `terminal::echo::on()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Re-enable terminal echo


## Source

```bash
terminal::echo::on() {
		stty echo 2>/dev/null
}
```

