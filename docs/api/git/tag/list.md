# `git::tag::list`

**Signature:** `git::tag::list()`

**Module:** [`git`](../../git.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- TAG ---


## Source

```bash
git::tag::list() {
		git::is_repo || return 1
		git tag 2>/dev/null
}
```

