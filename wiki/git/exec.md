# `git::exec`

_No description available._

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

## Module

[`git`](../git.md)
