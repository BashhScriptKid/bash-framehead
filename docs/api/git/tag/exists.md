# `git::tag::exists`

**Signature:** `git::tag::exists()`

**Module:** [`git`](../../git.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::tag::exists() {
		local tag="$1"
		git::is_repo || return 1
		git show-ref --verify --quiet "refs/tags/${tag}" 2>/dev/null
}
```

