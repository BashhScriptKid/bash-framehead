# `git::stash::count`

_No description available._

## Source

```bash
git::stash::count() {
    git rev-list --count refs/stash 2>/dev/null || echo 0
}
```

## Module

[`git`](../git.md)
