# `git::remote::url`

**Signature:** `git::remote::url()`

**Module:** [`git`](../../git.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::remote::url() {
		local remote="${1:-origin}"
		git remote get-url "${remote}" 2>/dev/null || echo "unknown"
}
```

