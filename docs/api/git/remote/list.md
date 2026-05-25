# `git::remote::list`

**Signature:** `git::remote::list()`

**Module:** [`git`](../../git.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::remote::list() {
		git::is_repo || return 1
		git remote 2>/dev/null
}
```

