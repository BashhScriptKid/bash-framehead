# `git::tag::list`

_No description available._

## Source

```bash
git::tag::list() {
    git::is_repo || return 1
    git tag 2>/dev/null
}
```

## Module

[`git`](../git.md)
