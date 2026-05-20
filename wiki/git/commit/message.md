# `git::commit::message`

_No description available._

## Source

```bash
git::commit::message() {
    local ref="${1:-HEAD}"
    git log -1 --format="%s" "${ref}" 2>/dev/null || echo "unknown"
}
```

## Module

[`git`](../git.md)
