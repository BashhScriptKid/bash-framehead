# `git::commit::hash`

**Signature:** `git::commit::hash()`

**Module:** [`git`](../../git.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::commit::hash() {
    local ref="${1:-HEAD}"
    git rev-parse "${ref}" 2>/dev/null || echo "unknown"
}
```

