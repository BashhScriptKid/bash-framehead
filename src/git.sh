#!/usr/bin/env bash
# git.sh — bash-frameheader git lib
# Requires: runtime.sh (runtime::has_command)

# ==============================================================================
# REPO STATE
# ==============================================================================

git::is_repo() {
		git rev-parse --git-dir >/dev/null 2>&1
}

git::root_dir() {
		git rev-parse --show-toplevel 2>/dev/null || echo "unknown"
}

git::is_dirty() {
		git::is_repo || return 1
		! git diff --quiet 2>/dev/null
}

git::is_staged() {
		git::is_repo || return 1
		! git diff --cached --quiet 2>/dev/null
}

git::is_stashed() {
		git rev-parse --verify refs/stash >/dev/null 2>&1
}

git::stash::count() {
		git rev-list --count refs/stash 2>/dev/null || echo 0
}

git::staged::count() {
		git::is_repo || { echo 0; return; }
		git diff --cached --numstat 2>/dev/null | wc -l | xargs
}

git::unstaged::count() {
		git::is_repo || { echo 0; return; }
		git diff --numstat 2>/dev/null | wc -l | xargs
}

git::untracked::count() {
		git::is_repo || { echo 0; return; }
		git ls-files --others --exclude-standard 2>/dev/null | wc -l | xargs
}

# ==============================================================================
# BRANCH
# ==============================================================================

git::branch::current() {
		git::is_repo || return 1
		local branch
		# --show-current is cleaner but requires git 2.22+
		# fall back to the sed approach for older versions
		branch="$(git symbolic-ref --short HEAD 2>/dev/null)" \
				|| branch="$(git branch 2>/dev/null | sed -n 's/^\* //p')"
		[[ -n "$branch" ]] && echo "$branch" || echo "unknown"
}

git::branch::list() {
		git::is_repo || return 1
		git branch 2>/dev/null | sed 's/^[* ] //'
}

git::branch::list::remote() {
		git::is_repo || return 1
		git branch -r 2>/dev/null | sed 's/^[* ] //' | grep -v '\->'
}

git::branch::list::all() {
		git::is_repo || return 1
		git branch -a 2>/dev/null | sed 's/^[* ] //' | grep -v '\->'
}

git::branch::exists() {
		local branch="$1"
		git::is_repo || return 1
		git show-ref --verify --quiet "refs/heads/${branch}" 2>/dev/null
}

git::branch::exists::remote() {
		local branch="$1"
		git::is_repo || return 1
		git show-ref --verify --quiet "refs/remotes/origin/${branch}" 2>/dev/null
}

# ==============================================================================
# COMMIT
# ==============================================================================

git::commit::hash() {
		local ref="${1:-HEAD}"
		git rev-parse "${ref}" 2>/dev/null || echo "unknown"
}

git::commit::short_hash() {
		local ref="${1:-HEAD}"
		git rev-parse --short "${ref}" 2>/dev/null || echo "unknown"
}

git::commit::message() {
		local ref="${1:-HEAD}"
		git log -1 --format="%s" "${ref}" 2>/dev/null || echo "unknown"
}

git::commit::author() {
		local ref="${1:-HEAD}"
		git log -1 --format="%an" "${ref}" 2>/dev/null || echo "unknown"
}

git::commit::author::email() {
		local ref="${1:-HEAD}"
		git log -1 --format="%ae" "${ref}" 2>/dev/null || echo "unknown"
}

git::commit::date() {
		local ref="${1:-HEAD}"
		git log -1 --format="%ci" "${ref}" 2>/dev/null || echo "unknown"
}

git::commit::date::relative() {
		local ref="${1:-HEAD}"
		git log -1 --format="%cr" "${ref}" 2>/dev/null || echo "unknown"
}

git::commit::count() {
		git::is_repo || { echo 0; return; }
		git rev-list --count HEAD 2>/dev/null || echo 0
}

git::log() {
		local count="${1:-10}"
		git::is_repo || return 1
		git log --oneline -"${count}" 2>/dev/null
}

# ==============================================================================
# REMOTE
# ==============================================================================

git::has_remote() {
		git::is_repo || return 1
		[[ -n "$(git remote 2>/dev/null)" ]]
}

git::remote::list() {
		git::is_repo || return 1
		git remote 2>/dev/null
}

git::remote::url() {
		local remote="${1:-origin}"
		git remote get-url "${remote}" 2>/dev/null || echo "unknown"
}

git::is_ahead() {
		git::is_repo || return 1
		[[ "$(git::ahead_count)" -gt 0 ]]
}

git::is_behind() {
		git::is_repo || return 1
		[[ "$(git::behind_count)" -gt 0 ]]
}

git::ahead_count() {
		git::is_repo || { echo 0; return; }
		local branch
		branch=$(git::branch::current)
		git rev-list --count "origin/${branch}..HEAD" 2>/dev/null || echo 0
}

git::behind_count() {
		git::is_repo || { echo 0; return; }
		local branch
		branch=$(git::branch::current)
		git rev-list --count "HEAD..origin/${branch}" 2>/dev/null || echo 0
}

# ==============================================================================
# TAG
# ==============================================================================

git::tag::list() {
		git::is_repo || return 1
		git tag 2>/dev/null
}

git::tag::latest() {
		git::is_repo || { echo "unknown" && return; }
		git describe --tags --abbrev=0 2>/dev/null || echo "unknown"
}

git::tag::exists() {
		local tag="$1"
		git::is_repo || return 1
		git show-ref --verify --quiet "refs/tags/${tag}" 2>/dev/null
}

# ==============================================================================
# SAFE PASSTHROUGH
# Checks git::is_repo before running any git command
# ==============================================================================

git::exec() {
		git::is_repo || {
				echo "git::exec: not inside a git repository" >&2
				return 1
		}
		git "$@"
}
