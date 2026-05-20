# `git::log`

_No description available._

## Source

```bash
git::log() {
    local count="${1:-10}"
    git::is_repo || return 1
    git log --oneline -"${count}" 2>/dev/null
}
```

## Module

[`git`](../git.md)
