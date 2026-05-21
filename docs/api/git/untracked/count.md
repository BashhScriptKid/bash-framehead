# `git::untracked::count`

**Signature:** `git::untracked::count()`

**Module:** [`git`](../../git.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
git::untracked::count() {
    git::is_repo || { echo 0; return; }
    git ls-files --others --exclude-standard 2>/dev/null | wc -l | xargs
}
```

