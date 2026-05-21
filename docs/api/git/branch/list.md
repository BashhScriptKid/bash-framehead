# `git::branch::list`

**Signature:** `git::branch::list()`

**Module:** [`git`](../../git.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::branch::list() {
    git::is_repo || return 1
    git branch 2>/dev/null | sed 's/^[* ] //'
}
```

