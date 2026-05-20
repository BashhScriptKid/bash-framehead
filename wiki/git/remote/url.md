# `git::remote::url`

_No description available._

## Source

```bash
git::remote::url() {
    local remote="${1:-origin}"
    git remote get-url "${remote}" 2>/dev/null || echo "unknown"
}
```

## Module

[`git`](../git.md)
