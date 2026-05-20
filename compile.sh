#!/usr/bin/env bash
# compile.sh — bash-framehead build tool
#
# Orchestrates the full pipeline: [optimize] -> [minify] -> [obfuscate]
# Accepts a single .sh file or a src/ directory (with optional manifest.txt).
#
# Usage:
#   ./compile.sh [options] input.sh [output.sh]
#   ./compile.sh [options] src/     [output.sh]
#
# Flags:
#   --no-optimize           skip optimizer
#   --no-minify             skip minifier
#   --obfuscate[=PASSES]    enable obfuscation (off by default)
#                           passes: all, private_functions, functions,
#                                   local_variables, variables, strings
#
#   --optimize: "FLAGS"     flags forwarded to optimizer (word-split at runtime)
#   --minify: "FLAGS"       flags forwarded to minifier
#   --obfuscate: "FLAGS"    flags forwarded to obfuscator
#
#   --check                 run full pipeline, validate only, don't write
#   --verbose               propagate to all stages
#   --quiet                 propagate to all stages
#   --target=bash4|bash5    minimum bash version target (informs optimizer)
#   --shebang=PATH          override shebang in output
#   --stamp                 inject build timestamp comment at top of output
#
# Directory mode (src/):
#   Merges all .sh files then runs the pipeline as a single unit.
#   If manifest.txt exists in the dir: use listed order (# comments, blank lines ok).
#   Otherwise: alphabetical with a warning.
#   Files in manifest not found: warn and skip.
#   Files in dir not in manifest: warn and exclude.
#
# Requires: bash 4.3+
# Optional: base32 (obfuscate strings pass), bc (--optimize: --fold-bc)
# ==============================================================================

# ==============================================================================
# EMBEDDED TOOLS
# Each tool is sourced inline — BASH_SOURCE guards prevent their CLIs from
# running, exposing only their library functions: optimize(), minify(), obfuscate()
# ==============================================================================

# shellcheck source=optimize.sh
_COMPILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

_compile_load_tools() {
    local missing=()
    for tool in optimize.sh minify.sh obfuscate.sh; do
        local tool_path="${_COMPILE_DIR}/${tool}"
        if [[ ! -f "$tool_path" ]]; then
            missing+=("$tool")
            continue
        fi
        # Source with a fake BASH_SOURCE[0] so the CLI guard doesn't fire
        # We do this by temporarily making the script think it's being sourced
        # shellcheck disable=SC1090
        source "$tool_path"
    done
    if (( ${#missing[@]} > 0 )); then
        echo "compile.sh: missing tools: ${missing[*]}" >&2
        echo "compile.sh: expected alongside compile.sh at: ${_COMPILE_DIR}" >&2
        return 1
    fi
}

# ==============================================================================
# LOGGING
# ==============================================================================

_minify_log_mode=""

_compile_log() {
    [[ "$_minify_log_mode" == quiet ]] && return 0
    echo "compile.sh: $*" >&2
}

_compile_warn() {
    echo "compile.sh: warning: $*" >&2
}

_compile_verbose() {
    [[ "$_minify_log_mode" == verbose ]] || return 0
    echo "compile.sh: [verbose] $*" >&2
}

# ==============================================================================
# MANIFEST / DIRECTORY MERGE
# ==============================================================================

# _read_manifest dir — print ordered list of .sh file paths from manifest.txt
# Falls back to sorted glob if no manifest, emits warnings.
_read_manifest() {
    local dir="$1"
    local manifest="${dir}/manifest.txt"
    local -a files=()

    if [[ -f "$manifest" ]]; then
        _compile_verbose "Using manifest: ${manifest}"
        local line
        while IFS= read -r line; do
            # Strip comments and blank lines
            line="${line%%#*}"
            line="${line// /}"
            [[ -z "$line" ]] && continue

            local fpath="${dir}/${line}"
            if [[ ! -f "$fpath" ]]; then
                _compile_warn "manifest lists '${line}' but file not found — skipping"
                continue
            fi
            files+=("$fpath")
        done < "$manifest"

        # Warn about .sh files in dir not listed in manifest
        local disk_file
        while IFS= read -r disk_file; do
            local fname="${disk_file##*/}"
            local listed=false
            local f
            for f in "${files[@]}"; do
                [[ "${f##*/}" == "$fname" ]] && { listed=true; break; }
            done
            $listed || _compile_warn "'${fname}' is in dir but not in manifest.txt — excluding"
        done < <(find "$dir" -maxdepth 1 -name "*.sh" | sort)
    else
        _compile_warn "no manifest.txt found in '${dir}' — merging in alphabetical order"
        while IFS= read -r f; do files+=("$f"); done \
            < <(find "$dir" -maxdepth 1 -name "*.sh" | sort)
    fi

    if (( ${#files[@]} == 0 )); then
        echo "compile.sh: no .sh files found in '${dir}'" >&2
        return 1
    fi

    printf '%s\n' "${files[@]}"
}

# _merge_dir dir seen_nameref — merge all files from dir into a single string
# Tracks sourced paths to avoid duplicating files already inlined via source calls
_merge_dir() {
    local dir="$1"
    local -n _md_seen="$2"

    local -a ordered_files=()
    while IFS= read -r f; do ordered_files+=("$f"); done \
        < <(_read_manifest "$dir") || return 1

    local merged="" shebang_seen=false
    local f
    for f in "${ordered_files[@]}"; do
        local abs_f
        abs_f="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"

        # Skip if already inlined via a source call
        if [[ -n "${_md_seen[$abs_f]+x}" ]]; then
            _compile_verbose "Skipping already-sourced: ${abs_f}"
            continue
        fi
        _md_seen["$abs_f"]=1

        local fcontent
        fcontent=$(cat "$f")

        # Strip shebang from all but first file
        if ! $shebang_seen && [[ "$fcontent" =~ ^#! ]]; then
            shebang_seen=true
        elif [[ "$fcontent" =~ ^#! ]]; then
            fcontent="${fcontent#*$'\n'}"
        fi

        merged+="# --- ${f##*/} ---"$'\n'
        merged+="$fcontent"$'\n'
    done

    printf '%s' "$merged"
}

# ==============================================================================
# SHEBANG HANDLING
# ==============================================================================

_extract_shebang() {
    local content="$1"
    if [[ "$content" =~ ^(#![^\n]*) ]]; then
        printf '%s' "${BASH_REMATCH[1]}"
    fi
}

_strip_shebang() {
    local content="$1"
    if [[ "$content" =~ ^#! ]]; then
        printf '%s' "${content#*$'\n'}"
    else
        printf '%s' "$content"
    fi
}

_apply_shebang() {
    local content="$1"
    local shebang="$2"
    printf '%s\n%s' "$shebang" "$(_strip_shebang "$content")"
}

# ==============================================================================
# PIPELINE
# ==============================================================================

# _run_pipeline content input_path opts_nameref
# opts keys: do_optimize do_minify do_obfuscate obfuscate_passes
#            optimize_flags minify_flags obfuscate_flags
#            check shebang_override stamp target
_run_pipeline() {
    local content="$1"
    local input_path="$2"
    local -n _rp_opts="$3"

    local do_optimize="${_rp_opts[do_optimize]:-1}"
    local do_minify="${_rp_opts[do_minify]:-1}"
    local do_obfuscate="${_rp_opts[do_obfuscate]:-0}"
    local obfuscate_passes="${_rp_opts[obfuscate_passes]:-private_functions,local_variables}"
    local optimize_flags="${_rp_opts[optimize_flags]:-}"
    local minify_flags="${_rp_opts[minify_flags]:-}"
    local obfuscate_extra="${_rp_opts[obfuscate_flags]:-}"
    local check="${_rp_opts[check]:-0}"
    local shebang_override="${_rp_opts[shebang_override]:-}"
    local stamp="${_rp_opts[stamp]:-0}"
    local target="${_rp_opts[target]:-}"
    local verbose_flag=""
    local quiet_flag=""
    [[ "$_minify_log_mode" == verbose ]] && verbose_flag="--verbose"
    [[ "$_minify_log_mode" == quiet ]]   && quiet_flag="--quiet"

    # Preserve shebang
    local original_shebang
    original_shebang=$(_extract_shebang "$content")

    # Stage 1: optimize
    if (( do_optimize )); then
        _compile_verbose "Stage 1: optimize"
        local -A opt_opts=(
            [fold_constants]=1 [dce]=1 [positional_inline]=1
            [array_inline]=1   [if_collapse]=1
            [framehead_specific]=0 [inline_functions]=0
            [fold_bc]=0        [dce_aggressive]=0
            [source_inline]=0  [ignore_annotations]=0
            [dce_roots]=""
        )
        # Apply --target
        [[ "$target" == bash4 ]] && opt_opts[legacy_compat]=1
        # Intentional word splitting on optimize_flags
        # shellcheck disable=SC2086
        if [[ -n "$optimize_flags" ]]; then
            # Parse forwarded flags into opt_opts
            local _of
            for _of in $optimize_flags; do
                case "$_of" in
                    --framehead-specific)   opt_opts[framehead_specific]=1 ;;
                    --source-inline)        opt_opts[source_inline]=1 ;;
                    --inline-functions)     opt_opts[inline_functions]=1 ;;
                    --fold-bc)              opt_opts[fold_bc]=1 ;;
                    --dce-aggressive)       opt_opts[dce_aggressive]=1 ;;
                    --all)
                        opt_opts[framehead_specific]=1
                        opt_opts[source_inline]=1
                        opt_opts[inline_functions]=1
                        opt_opts[fold_bc]=1
                        opt_opts[dce_aggressive]=1 ;;
                    --no-fold-constants)    opt_opts[fold_constants]=0 ;;
                    --no-dce)               opt_opts[dce]=0 ;;
                    --no-positional-inline) opt_opts[positional_inline]=0 ;;
                    --no-array-inline)      opt_opts[array_inline]=0 ;;
                    --no-if-collapse)       opt_opts[if_collapse]=0 ;;
                    --ignore-annotates)     opt_opts[ignore_annotations]=1 ;;
                    --ignore=*|--ignore-all=*)
                        local _fn="${_of#*=}"
                        local _p; IFS=',' read -ra _ps <<< "$_fn"
                        for _p in "${_ps[@]}"; do _cli_add_ignore "$_p" all; done ;;
                    --entry=*)
                        opt_opts[dce_roots]+="${opt_opts[dce_roots]:+,}${_of#--entry=}" ;;
                    *) _compile_warn "unknown optimize flag: ${_of}" ;;
                esac
            done
        fi
        content=$(optimize "$content" opt_opts "$input_path")
    fi

    # Stage 2: minify
    if (( do_minify )); then
        _compile_verbose "Stage 2: minify"
        # minify() takes content on stdin via the internal API
        # minify() takes content as $1; extra flags go via the tokeniser path
        # shellcheck disable=SC2086
        content=$(minify "$content" $minify_flags)
    fi

    # Stage 3: obfuscate
    if (( do_obfuscate )); then
        _compile_verbose "Stage 3: obfuscate"
        local -A ob_passes=(
            [private_functions]=0 [functions]=0
            [local_variables]=0   [variables]=0
            [strings]=0
        )
        local _p
        IFS=',' read -ra _ps <<< "$obfuscate_passes"
        for _p in "${_ps[@]}"; do
            case "$_p" in
                all)
                    for k in "${!ob_passes[@]}"; do ob_passes[$k]=1; done ;;
                private_functions|functions|local_variables|variables|strings)
                    ob_passes[$_p]=1 ;;
                *) _compile_warn "unknown obfuscate pass: ${_p}" ;;
            esac
        done
        content=$(obfuscate "$content" ob_passes)
    fi

    # Restore/override shebang
    local final_shebang="${shebang_override:-$original_shebang}"
    if [[ -n "$final_shebang" ]]; then
        content=$(_apply_shebang "$content" "$final_shebang")
    fi

    # Stamp
    if (( stamp )); then
        local ts
        ts=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
        content="# compiled: ${ts}"$'\n'"$content"
    fi

    printf '%s' "$content"
}

# ==============================================================================
# CLI
# ==============================================================================

_compile_cli() {
    local input="" output=""
    local -A opts=(
        [do_optimize]=1     [do_minify]=1       [do_obfuscate]=0
        [obfuscate_passes]="private_functions,local_variables"
        [optimize_flags]="" [minify_flags]=""   [obfuscate_flags]=""
        [check]=0           [shebang_override]="" [stamp]=0
        [target]=""
    )

    while (( $# )); do
        case "$1" in
            --no-optimize)      opts[do_optimize]=0 ;;
            --no-minify)        opts[do_minify]=0 ;;
            --obfuscate)        opts[do_obfuscate]=1 ;;
            --obfuscate=*)      opts[do_obfuscate]=1; opts[obfuscate_passes]="${1#--obfuscate=}" ;;
            --optimize:)        shift; opts[optimize_flags]="$1" ;;
            --minify:)          shift; opts[minify_flags]="$1" ;;
            --obfuscate:)       shift; opts[obfuscate_flags]="$1" ;;
            --check)            opts[check]=1 ;;
            --verbose)          _minify_log_mode=verbose ;;
            --quiet)            _minify_log_mode=quiet ;;
            --target=*)         opts[target]="${1#--target=}" ;;
            --shebang=*)        opts[shebang_override]="${1#--shebang=}" ;;
            --stamp)            opts[stamp]=1 ;;
            --)                 shift; break ;;
            -*)                 echo "compile.sh: unknown option: $1" >&2; return 1 ;;
            *)
                if [[ -z "$input" ]];       then input="$1"
                elif [[ -z "$output" ]];    then output="$1"
                else echo "compile.sh: unexpected argument: $1" >&2; return 1
                fi ;;
        esac
        shift
    done

    if [[ -z "$input" ]]; then
        cat >&2 << 'USAGE'
Usage: compile.sh [options] input.sh [output.sh]
       compile.sh [options] src/     [output.sh]

Pipeline (all on by default except obfuscation):
  --no-optimize           skip optimizer
  --no-minify             skip minifier
  --obfuscate[=PASSES]    enable obfuscation
                          passes: all, private_functions, functions,
                                  local_variables, variables, strings
                          default: private_functions,local_variables

Flag forwarding (word-split at runtime):
  --optimize: "FLAGS"     e.g. "--framehead-specific --source-inline"
  --minify: "FLAGS"       e.g. "--no-mangle-private"
  --obfuscate: "FLAGS"    e.g. "--skip-minifier"

Build options:
  --check                 validate pipeline output only, don't write
  --target=bash4|bash5    minimum bash version (informs optimizer)
  --shebang=PATH          override shebang line in output
  --stamp                 inject build timestamp comment at top

General:
  --verbose               propagate to all stages
  --quiet                 suppress all progress output

Directory mode (src/):
  Merges all .sh files then runs the pipeline as a single unit.
  Respects manifest.txt in the directory for merge order.
  manifest.txt format: one filename per line, # comments ok.
USAGE
        return 1
    fi

    # Validate input
    if [[ ! -e "$input" ]]; then
        echo "compile.sh: input not found: ${input}" >&2
        return 1
    fi

    local content="" input_path=""

    if [[ -f "$input" ]]; then
        # Single file mode
        if [[ "$input" != *.sh ]]; then
            echo "compile.sh: input must be a .sh file, got: ${input}" >&2
            return 1
        fi
        input_path="$(cd "$(dirname "$input")" && pwd)/$(basename "$input")"
        content=$(cat "$input_path")
        _compile_log "Compiling ${input}..."

    elif [[ -d "$input" ]]; then
        # Directory mode
        input_path="$(cd "$input" && pwd)"
        _compile_log "Merging ${input}/..."
        local -A seen_paths=()
        content=$(_merge_dir "$input_path" seen_paths) || return 1
        _compile_log "Merged $(echo "$content" | wc -l) lines from $(find "$input_path" -maxdepth 1 -name "*.sh" | wc -l) files"

    else
        echo "compile.sh: input must be a .sh file or directory, got: ${input}" >&2
        return 1
    fi

    local input_bytes=${#content}

    # Load tools
    _compile_load_tools || return 1

    # Run pipeline
    local result
    result=$(_run_pipeline "$content" "$input_path" opts)

    # Syntax check
    if ! bash -n <<< "$result" 2>/dev/null; then
        echo "compile.sh: output failed syntax check" >&2
        bash -n <<< "$result" 2>&1 | head -5 >&2
        if [[ -n "$output" ]]; then
            printf '%s\n' "$result" > "${output}.broken"
            echo "compile.sh: broken output written to ${output}.broken" >&2
        fi
        return 1
    fi

    local output_bytes=${#result}
    local reduction=$(( (input_bytes - output_bytes) * 100 / (input_bytes > 0 ? input_bytes : 1) ))

    if (( opts[check] )); then
        echo "compile.sh: syntax OK (${output_bytes} bytes, ${reduction}% reduction)" >&2
        return 0
    fi

    if [[ -z "$output" ]]; then
        printf '%s\n' "$result"
    else
        printf '%s\n' "$result" > "$output"
        chmod +x "$output"
        [[ "$_minify_log_mode" != quiet ]] && \
            echo "compile.sh: ${input} -> ${output} (${input_bytes} -> ${output_bytes} bytes, ${reduction}% reduction)" >&2
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _compile_cli "$@"
fi
