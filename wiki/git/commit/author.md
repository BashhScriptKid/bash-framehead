# `git::commit::author`

_No description available._

## Source

```bash
git::commit::author() {
    local ref="${1:-HEAD}"
    git log -1 --format="%an" "${ref}" 2>/dev/null || echo "unknown"
}
```

## Module

[`git`](../git.md)
