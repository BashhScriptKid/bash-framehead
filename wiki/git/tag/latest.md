# `git::tag::latest`

_No description available._

## Source

```bash
git::tag::latest() {
    git::is_repo || { echo "unknown" && return; }
    git describe --tags --abbrev=0 2>/dev/null || echo "unknown"
}
```

## Module

[`git`](../git.md)
