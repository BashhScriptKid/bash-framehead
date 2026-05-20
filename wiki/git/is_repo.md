# `git::is_repo`

_No description available._

## Source

```bash
git::is_repo() {
    git rev-parse --git-dir >/dev/null 2>&1
}
```

## Module

[`git`](../git.md)
