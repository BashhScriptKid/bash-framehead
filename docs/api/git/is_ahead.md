# `git::is_ahead`

**Signature:** `git::is_ahead()`

**Module:** [`git`](../git.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::is_ahead() {
		git::is_repo || return 1
		[[ "$(git::ahead_count)" -gt 0 ]]
}
```

