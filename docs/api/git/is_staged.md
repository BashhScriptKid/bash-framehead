# `git::is_staged`

**Signature:** `git::is_staged()`

**Module:** [`git`](../git.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::is_staged() {
    git::is_repo || return 1
    ! git diff --cached --quiet 2>/dev/null
}
```

