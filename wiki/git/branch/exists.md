# `git::branch::exists`

_No description available._

## Source

```bash
git::branch::exists() {
    local branch="$1"
    git::is_repo || return 1
    git show-ref --verify --quiet "refs/heads/${branch}" 2>/dev/null
}
```

## Module

[`git`](../git.md)
