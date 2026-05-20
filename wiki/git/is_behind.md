# `git::is_behind`

_No description available._

## Source

```bash
git::is_behind() {
    git::is_repo || return 1
    [[ "$(git::behind_count)" -gt 0 ]]
}
```

## Module

[`git`](../git.md)
