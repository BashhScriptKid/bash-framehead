# `git::commit::date`

_No description available._

## Source

```bash
git::commit::date() {
    local ref="${1:-HEAD}"
    git log -1 --format="%ci" "${ref}" 2>/dev/null || echo "unknown"
}
```

## Module

[`git`](../git.md)
