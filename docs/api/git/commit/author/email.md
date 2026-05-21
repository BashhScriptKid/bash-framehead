# `git::commit::author::email`

**Signature:** `git::commit::author::email()`

**Module:** [`git`](../../../git.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::commit::author::email() {
    local ref="${1:-HEAD}"
    git log -1 --format="%ae" "${ref}" 2>/dev/null || echo "unknown"
}
```

