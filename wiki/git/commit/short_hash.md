# `git::commit::short_hash`

_No description available._

## Source

```bash
git::commit::short_hash() {
    local ref="${1:-HEAD}"
    git rev-parse --short "${ref}" 2>/dev/null || echo "unknown"
}
```

## Module

[`git`](../git.md)
