# `git::is_behind`

**Signature:** `git::is_behind()`

**Module:** [`git`](../git.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::is_behind() {
		git::is_repo || return 1
		[[ "$(git::behind_count)" -gt 0 ]]
}
```

