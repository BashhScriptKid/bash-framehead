# `git::commit::count`

**Signature:** `git::commit::count()`

**Module:** [`git`](../../git.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::commit::count() {
    git::is_repo || { echo 0; return; }
    git rev-list --count HEAD 2>/dev/null || echo 0
}
```

