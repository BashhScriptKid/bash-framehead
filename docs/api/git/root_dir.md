# `git::root_dir`

**Signature:** `git::root_dir()`

**Module:** [`git`](../git.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::root_dir() {
		git rev-parse --show-toplevel 2>/dev/null || echo "unknown"
}
```

