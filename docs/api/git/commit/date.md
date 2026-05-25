# `git::commit::date`

**Signature:** `git::commit::date()`

**Module:** [`git`](../../git.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::commit::date() {
		local ref="${1:-HEAD}"
		git log -1 --format="%ci" "${ref}" 2>/dev/null || echo "unknown"
}
```

