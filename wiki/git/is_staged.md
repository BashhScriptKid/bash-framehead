# `git::is_staged`

_No description available._

## Source

```bash
git::is_staged() {
    git::is_repo || return 1
    ! git diff --cached --quiet 2>/dev/null
}
```

## Module

[`git`](../git.md)
