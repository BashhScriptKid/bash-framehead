# `git::commit::author::email`

_No description available._

## Source

```bash
git::commit::author::email() {
    local ref="${1:-HEAD}"
    git log -1 --format="%ae" "${ref}" 2>/dev/null || echo "unknown"
}
```

## Module

[`git`](../git.md)
