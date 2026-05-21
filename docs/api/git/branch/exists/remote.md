# `git::branch::exists::remote`

**Signature:** `git::branch::exists::remote(arg1)`

**Module:** [`git`](../../../git.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
git::branch::exists::remote() {
    local branch="$1"
    git::is_repo || return 1
    git show-ref --verify --quiet "refs/remotes/origin/${branch}" 2>/dev/null
}
```

