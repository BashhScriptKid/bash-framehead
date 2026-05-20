# `git`

Git repository introspection — repo state, branches, commits, remotes, tags, and safe passthrough command execution. **35 functions.** No `::fast` variants.

---

## Repo State

| Function | Description |
|----------|-------------|
| `git::is_repo` | Check if current directory is inside a git repository |
| `git::root_dir` | Return the repository root directory path |
| `git::is_dirty` | Check if there are unstaged changes |
| `git::is_staged` | Check if there are staged changes |
| `git::is_stashed` | Check if there are stashed changes |
| `git::stash::count` | Return number of stashes |
| `git::staged::count` | Return number of staged files |
| `git::unstaged::count` | Return number of unstaged files |
| `git::untracked::count` | Return number of untracked files |

```bash
if ! git::is_repo; then
    echo "Not in a git repository"
    exit 1
fi

if git::is_dirty; then
    echo "Warning: ${unstaged} unstaged and ${untracked} untracked files"
fi
```

## Branches

| Function | Description |
|----------|-------------|
| `git::branch::current` | Return current branch name (falls back from `--show-current` to `symbolic-ref` to sed parsing) |
| `git::branch::list` | List all local branches |
| `git::branch::list::remote` | List all remote branches |
| `git::branch::list::all` | List all branches (local + remote) |
| `git::branch::exists` | Check if a local branch exists |
| `git::branch::exists::remote` | Check if a remote branch exists on origin |

```bash
git::branch::current              # → main
git::branch::exists "feature/x" && echo "Branch exists"
```

## Commits

| Function | Description |
|----------|-------------|
| `git::commit::hash` | Full commit hash (default: `HEAD`) |
| `git::commit::short_hash` | Short commit hash |
| `git::commit::message` | Commit message subject |
| `git::commit::author` | Author name |
| `git::commit::author::email` | Author email |
| `git::commit::date` | Commit date (ISO format) |
| `git::commit::date::relative` | Commit date relative (e.g., "2 hours ago") |
| `git::commit::count` | Total commit count on current branch |
| `git::log` | Show formatted commit log (default: 10 entries) |

```bash
git::commit::hash              # → a1b2c3d4e5f6...
git::commit::short_hash        # → a1b2c3d
git::commit::message           # → "Fix login bug"
git::commit::author            # → "Jane Doe"
git::log 5                     # Last 5 commits, one-line format
```

## Remotes

| Function | Description |
|----------|-------------|
| `git::has_remote` | Check if the repo has any remotes |
| `git::remote::list` | List all remote names |
| `git::remote::url` | Get URL for a remote (default: `origin`) |
| `git::is_ahead` | Check if local branch is ahead of remote |
| `git::is_behind` | Check if local branch is behind remote |
| `git::ahead_count` | Number of commits ahead of `origin/<branch>` |
| `git::behind_count` | Number of commits behind `origin/<branch>` |

```bash
git::remote::url               # → https://github.com/user/repo.git
if git::is_ahead; then
    echo "Unpushed commits: $(git::ahead_count)"
fi
```

## Tags

| Function | Description |
|----------|-------------|
| `git::tag::list` | List all tags |
| `git::tag::latest` | Return the latest tag name |
| `git::tag::exists` | Check if a tag exists |

```bash
git::tag::latest                # → v1.2.3
git::tag::exists "v1.0.0" && echo "Tag exists"
```

## Safe Passthrough

| Function | Description |
|----------|-------------|
| `git::exec` | Run a git command — checks `git::is_repo` first and returns an error if not in a repository |

```bash
# Safer than raw `git` — guards against running outside a repo
git::exec status --short
git::exec log --oneline -5
```

## Dependencies

- **Requires**: `runtime`
- **External tools**: `git` (required for all functions)
