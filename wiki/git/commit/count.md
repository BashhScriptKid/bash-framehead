# `git::commit::count`

_No description available._

## Source

```bash
git::commit::count() {
    git::is_repo || { echo 0; return; }
    git rev-list --count HEAD 2>/dev/null || echo 0
}
```

## Module

[`git`](../git.md)
