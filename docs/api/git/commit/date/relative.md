# `git::commit::date::relative`

**Signature:** `git::commit::date::relative()`

**Module:** [`git`](../../../git.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::commit::date::relative() {
    local ref="${1:-HEAD}"
    git log -1 --format="%cr" "${ref}" 2>/dev/null || echo "unknown"
}
```

