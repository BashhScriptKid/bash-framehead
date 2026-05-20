# `git::commit::date::relative`

_No description available._

## Source

```bash
git::commit::date::relative() {
    local ref="${1:-HEAD}"
    git log -1 --format="%cr" "${ref}" 2>/dev/null || echo "unknown"
}
```

## Module

[`git`](../git.md)
