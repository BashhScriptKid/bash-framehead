# `git::branch::list::remote`

**Signature:** `git::branch::list::remote()`

**Module:** [`git`](../../../git.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::branch::list::remote() {
		git::is_repo || return 1
		git branch -r 2>/dev/null | sed 's/^[* ] //' | grep -v '\->'
}
```

