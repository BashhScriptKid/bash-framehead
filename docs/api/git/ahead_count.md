# `git::ahead_count`

**Signature:** `git::ahead_count()`

**Module:** [`git`](../git.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::ahead_count() {
		git::is_repo || { echo 0; return; }
		local branch
		branch=$(git::branch::current)
		git rev-list --count "origin/${branch}..HEAD" 2>/dev/null || echo 0
}
```

