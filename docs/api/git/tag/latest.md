# `git::tag::latest`

**Signature:** `git::tag::latest()`

**Module:** [`git`](../../git.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::tag::latest() {
		git::is_repo || { echo "unknown" && return; }
		git describe --tags --abbrev=0 2>/dev/null || echo "unknown"
}
```

