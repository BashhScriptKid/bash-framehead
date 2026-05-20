# `git::is_stashed`

_No description available._

## Source

```bash
git::is_stashed() {
    git rev-parse --verify refs/stash >/dev/null 2>&1
}
```

## Module

[`git`](../git.md)
