# `git::unstaged::count`

_No description available._

## Source

```bash
git::unstaged::count() {
    git::is_repo || { echo 0; return; }
    git diff --numstat 2>/dev/null | wc -l | xargs
}
```

## Module

[`git`](../git.md)
