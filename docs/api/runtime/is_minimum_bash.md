# `runtime::is_minimum_bash`

**Signature:** `runtime::is_minimum_bash()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Default to 3, assuming that's what's at least needed for this framework (not final)


## Source

```bash
runtime::is_minimum_bash() {
	((BASH_VERSINFO[0] >= ${1:-3}))
}
```

