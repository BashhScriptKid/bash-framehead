# `git::branch::list::all`

**Signature:** `git::branch::list::all()`

**Module:** [`git`](../../../git.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::branch::list::all() {
		git::is_repo || return 1
		git branch -a 2>/dev/null | sed 's/^[* ] //' | grep -v '\->'
}
```

