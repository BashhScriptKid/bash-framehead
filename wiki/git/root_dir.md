# `git::root_dir`

_No description available._

## Source

```bash
git::root_dir() {
    git rev-parse --show-toplevel 2>/dev/null || echo "unknown"
}
```

## Module

[`git`](../git.md)
