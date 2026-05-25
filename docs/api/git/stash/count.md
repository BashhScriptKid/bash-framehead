# `git::stash::count`

**Signature:** `git::stash::count()`

**Module:** [`git`](../../git.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::stash::count() {
		git rev-list --count refs/stash 2>/dev/null || echo 0
}
```

