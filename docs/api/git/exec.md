# `git::exec`

**Signature:** `git::exec()`

**Module:** [`git`](../git.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

SAFE PASSTHROUGH


## Source

```bash
git::exec() {
		git::is_repo || {
				echo "git::exec: not inside a git repository" >&2
				return 1
		}
		git "$@"
}
```

