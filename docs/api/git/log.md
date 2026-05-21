# `git::log`

**Signature:** `git::log()`

**Module:** [`git`](../git.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::log() {
    local count="${1:-10}"
    git::is_repo || return 1
    git log --oneline -"${count}" 2>/dev/null
}
```

