# `git::untracked::count`

_No description available._

## Source

```bash
git::untracked::count() {
    git::is_repo || { echo 0; return; }
    git ls-files --others --exclude-standard 2>/dev/null | wc -l | xargs
}
```

## Module

[`git`](../git.md)
