# `git::is_repo`

**Signature:** `git::is_repo()`

**Module:** [`git`](../git.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

!/usr/bin/env bash


## Source

```bash
git::is_repo() {
		git rev-parse --git-dir >/dev/null 2>&1
}
```

