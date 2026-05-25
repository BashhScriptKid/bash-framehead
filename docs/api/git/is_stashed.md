# `git::is_stashed`

**Signature:** `git::is_stashed()`

**Module:** [`git`](../git.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::is_stashed() {
		git rev-parse --verify refs/stash >/dev/null 2>&1
}
```

