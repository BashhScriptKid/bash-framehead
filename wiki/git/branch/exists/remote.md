# `git::branch::exists::remote`

_No description available._

## Source

```bash
git::branch::exists::remote() {
    local branch="$1"
    git::is_repo || return 1
    git show-ref --verify --quiet "refs/remotes/origin/${branch}" 2>/dev/null
}
```

## Module

[`git`](../git.md)
