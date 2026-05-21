# `git::has_remote`

**Signature:** `git::has_remote()`

**Module:** [`git`](../git.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::has_remote() {
    git::is_repo || return 1
    [[ -n "$(git remote 2>/dev/null)" ]]
}
```

