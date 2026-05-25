# `git::staged::count`

**Signature:** `git::staged::count()`

**Module:** [`git`](../../git.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::staged::count() {
		git::is_repo || { echo 0; return; }
		git diff --cached --numstat 2>/dev/null | wc -l | xargs
}
```

