# `git::commit::hash`

_No description available._

## Source

```bash
git::commit::hash() {
    local ref="${1:-HEAD}"
    git rev-parse "${ref}" 2>/dev/null || echo "unknown"
}
```

## Module

[`git`](../git.md)
