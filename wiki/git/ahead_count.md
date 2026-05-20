# `git::ahead_count`

_No description available._

## Source

```bash
git::ahead_count() {
    git::is_repo || { echo 0; return; }
    local branch
    branch=$(git::branch::current)
    git rev-list --count "origin/${branch}..HEAD" 2>/dev/null || echo 0
}
```

## Module

[`git`](../git.md)
