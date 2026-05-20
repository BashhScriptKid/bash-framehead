# `git::is_dirty`

_No description available._

## Source

```bash
git::is_dirty() {
    git::is_repo || return 1
    ! git diff --quiet 2>/dev/null
}
```

## Module

[`git`](../git.md)
