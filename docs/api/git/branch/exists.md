# `git::branch::exists`

**Signature:** `git::branch::exists()`

**Module:** [`git`](../../git.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::branch::exists() {
		local branch="$1"
		git::is_repo || return 1
		git show-ref --verify --quiet "refs/heads/${branch}" 2>/dev/null
}
```

