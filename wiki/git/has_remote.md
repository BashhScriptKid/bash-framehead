# `git::has_remote`

_No description available._

## Source

```bash
git::has_remote() {
    git::is_repo || return 1
    [[ -n "$(git remote 2>/dev/null)" ]]
}
```

## Module

[`git`](../git.md)
