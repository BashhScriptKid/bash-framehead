# `git::branch::current`

_No description available._

## Source

```bash
git::branch::current() {
    git::is_repo || return 1
    local branch
    # --show-current is cleaner but requires git 2.22+
    # fall back to the sed approach for older versions
    branch="$(git symbolic-ref --short HEAD 2>/dev/null)" \
        || branch="$(git branch 2>/dev/null | sed -n 's/^\* //p')"
    [[ -n "$branch" ]] && echo "$branch" || echo "unknown"
}
```

## Module

[`git`](../git.md)
