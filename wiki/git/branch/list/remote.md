# `git::branch::list::remote`

_No description available._

## Source

```bash
git::branch::list::remote() {
    git::is_repo || return 1
    git branch -r 2>/dev/null | sed 's/^[* ] //' | grep -v '\->'
}
```

## Module

[`git`](../git.md)
