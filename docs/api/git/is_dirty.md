# `git::is_dirty`

**Signature:** `git::is_dirty()`

**Module:** [`git`](../git.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::is_dirty() {
		git::is_repo || return 1
		! git diff --quiet 2>/dev/null
}
```

