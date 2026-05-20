# `git::behind_count`

_No description available._

## Source

```bash
git::behind_count() {
    git::is_repo || { echo 0; return; }
    local branch
    branch=$(git::branch::current)
    git rev-list --count "HEAD..origin/${branch}" 2>/dev/null || echo 0
}
```

## Module

[`git`](../git.md)
