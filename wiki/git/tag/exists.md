# `git::tag::exists`

_No description available._

## Source

```bash
git::tag::exists() {
    local tag="$1"
    git::is_repo || return 1
    git show-ref --verify --quiet "refs/tags/${tag}" 2>/dev/null
}
```

## Module

[`git`](../git.md)
