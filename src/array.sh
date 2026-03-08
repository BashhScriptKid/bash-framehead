#!/usr/bin/env bash
# array.sh — bash-frameheader array lib
# Requires: runtime.sh (runtime::is_minimum_bash)
#
# ==============================================================================
# USAGE PATTERNS
# ==============================================================================
#
# Bash arrays cannot be passed by value. This module supports two patterns:
#
# 1. TRADITIONAL (subshell capture) — works everywhere, slower:
#    result=($(array::push new "${arr[@]}"))
#    count=$(array::length "${arr[@]}")
#
# 2. FAST (nameref) — Bash 4.3+, no subshell, recommended:
#    array::push::fast result_arr new "${arr[@]}"
#    array::length::fast count "${arr[@]}"
#
# The ::fast variants use nameref to write results directly into variables
# without spawning subshells. This is significantly faster for large arrays.
#
# ==============================================================================
# BASH 5 FEATURES
# ==============================================================================
# Some functions use associative arrays only available in Bash 5+.
# These are guarded with runtime::is_minimum_bash 5 and will print an
# error and return 1 if called on an older version.

# ==============================================================================
# CONSTRUCTION
# ==============================================================================

# Build an array from a delimited string
# Usage: array::from_string delimiter string
# Example: array::from_string "," "a,b,c" → prints one element per line
array::from_string() {
    [[ $# -lt 2 ]] && { echo "Usage: array::from_string <delimiter> <string> [array_name]" >&2; return 1; }

    local delim="$1" s="$2"
    local array_name="$3"

    # Use awk to split properly
    local elements
    elements=$(echo "$s" | awk -v d="$delim" 'BEGIN {ORS="\n"} {
        gsub(d, "\n")
        print
    }')

    if [[ -n "$array_name" ]]; then
        # Populate named array using readarray
        readarray -t "$array_name" <<< "$elements"
    else
        # Output elements
        echo "$elements"
    fi
}

# Build an array from lines of stdin or a string (newline-delimited)
# Usage: array::from_lines "line1\nline2\nline3"
array::from_lines() {
    local IFS=$'\n'
    local -a parts=($1)
    printf '%s\n' "${parts[@]}"
}

# Build a range of integers
# Usage: array::range start end [step]
# Example: array::range 1 5 → 1 2 3 4 5
array::range() {
    local start="$1" end="$2" step="${3:-1}" i
    for (( i=start; i<=end; i+=step )); do
        echo "$i"
    done
}

# ==============================================================================
# INSPECTION
# ==============================================================================

# Number of elements
# Usage: array::length el1 el2 ...
array::length() {
    echo "$#"
}

# Fast variant using nameref
# Usage: array::length::fast result_var el1 el2 ...
array::length::fast() {
    local -n _array_length_result="$1"
    shift
    _array_length_result=$#
}

# Check if array is empty
# Usage: array::is_empty "$@"
array::is_empty() {
    [[ "$#" -eq 0 ]]
}

# Check if array contains a value
# Usage: array::contains needle el1 el2 ...
array::contains() {
    local needle="$1"; shift
    local el
    for el in "$@"; do
        [[ "$el" == "$needle" ]] && return 0
    done
    return 1
}

# Return index of first match (-1 if not found)
# Usage: array::index_of needle el1 el2 ...
array::index_of() {
    local needle="$1"; shift
    local i=0 el
    for el in "$@"; do
        [[ "$el" == "$needle" ]] && echo "$i" && return 0
        (( i++ ))
    done
    echo -1
    return 1
}

# Fast variant using nameref
# Usage: array::index_of::fast result_var needle el1 el2 ...
array::index_of::fast() {
    local -n _array_index_of_result="$1"
    local needle="$2"; shift 2
    local i=0 el
    for el in "$@"; do
        [[ "$el" == "$needle" ]] && { _array_index_of_result=$i; return 0; }
        (( i++ ))
    done
    _array_index_of_result=-1
    return 1
}

# Return first element
# Usage: array::first el1 el2 ...
array::first() {
    echo "$1"
}

# Fast variant using nameref
# Usage: array::first::fast result_var el1 el2 ...
array::first::fast() {
    local -n _array_first_result="$1"
    shift
    _array_first_result="$1"
}

# Return last element
# Usage: array::last el1 el2 ...
array::last() {
    eval echo "\${$#}"
}

# Fast variant using nameref
# Usage: array::last::fast result_var el1 el2 ...
array::last::fast() {
    local -n _array_last_result="$1"
    shift
    local -a _arr=("$@")
    _array_last_result="${_arr[-1]}"
}

# Return element at index
# Usage: array::get index el1 el2 ...
array::get() {
    local idx="$1"; shift
    local -a arr=("$@")
    echo "${arr[$idx]}"
}

# Fast variant using nameref
# Usage: array::get::fast result_var index el1 el2 ...
array::get::fast() {
    local -n _array_get_result="$1"
    local idx="$2"; shift 2
    local -a _arr=("$@")
    _array_get_result="${_arr[$idx]}"
}

# Count occurrences of a value
# Usage: array::count_of needle el1 el2 ...
array::count_of() {
    local needle="$1" count=0; shift
    for el in "$@"; do
        [[ "$el" == "$needle" ]] && (( count++ ))
    done
    echo "$count"
}

# Fast variant using nameref
# Usage: array::count_of::fast result_var needle el1 el2 ...
array::count_of::fast() {
    local -n _array_count_of_result="$1"
    local needle="$2"; shift 2
    local count=0
    for el in "$@"; do
        [[ "$el" == "$needle" ]] && (( count++ ))
    done
    _array_count_of_result=$count
}

# ==============================================================================
# TRANSFORMATION
# ==============================================================================

# Print each element on its own line (normalise for piping)
array::print() {
    printf '%s\n' "$@"
}

# Reverse order of elements
# Usage: array::reverse el1 el2 ...
array::reverse() {
    local -a arr=("$@")
    local i
    for (( i=${#arr[@]}-1; i>=0; i-- )); do
        echo "${arr[$i]}"
    done
}

# Fast variant using nameref
# Usage: array::reverse::fast result_arr el1 el2 ...
array::reverse::fast() {
    local -n _array_reverse_result="$1"
    shift
    local -a _arr=("$@")
    local i
    _array_reverse_result=()
    for (( i=${#_arr[@]}-1; i>=0; i-- )); do
        _array_reverse_result+=("${_arr[$i]}")
    done
}

# Flatten one level — splits each element by whitespace
# Usage: array::flatten el1 "el2a el2b" el3
array::flatten() {
    for el in "$@"; do
        for word in $el; do
            echo "$word"
        done
    done
}

# Slice a subarray
# Usage: array::slice start length el1 el2 ...
array::slice() {
    local start="$1" len="$2"; shift 2
    local -a arr=("$@")
    printf '%s\n' "${arr[@]:$start:$len}"
}

# Fast variant using nameref
# Usage: array::slice::fast result_arr start length el1 el2 ...
array::slice::fast() {
    local -n _array_slice_result="$1"
    local start="$2" len="$3"; shift 3
    local -a _arr=("$@")
    _array_slice_result=("${_arr[@]:$start:$len}")
}

# Append elements (print existing + new)
# Usage: array::push new_el el1 el2 ...
array::push() {
    local new="$1"; shift
    printf '%s\n' "$@" "$new"
}

# Fast variant using nameref
# Usage: array::push::fast result_arr new_el el1 el2 ...
array::push::fast() {
    local -n _array_push_result="$1"
    local new="$2"; shift 2
    _array_push_result=("$@" "$new")
}

# Remove last element
# Usage: array::pop el1 el2 ...
array::pop() {
    local -a arr=("$@")
    unset 'arr[-1]'
    printf '%s\n' "${arr[@]}"
}

# Fast variant using nameref
# Usage: array::pop::fast result_arr el1 el2 ...
array::pop::fast() {
    local -n _array_pop_result="$1"
    shift
    local -a _arr=("$@")
    unset '_arr[-1]'
    _array_pop_result=("${_arr[@]}")
}

# Prepend an element
# Usage: array::unshift new_el el1 el2 ...
array::unshift() {
    local new="$1"; shift
    printf '%s\n' "$new" "$@"
}

# Fast variant using nameref
# Usage: array::unshift::fast result_arr new_el el1 el2 ...
array::unshift::fast() {
    local -n _array_unshift_result="$1"
    local new="$2"; shift 2
    _array_unshift_result=("$new" "$@")
}

# Remove first element
# Usage: array::shift el1 el2 ...
array::shift() {
    shift
    printf '%s\n' "$@"
}

# Fast variant using nameref
# Usage: array::shift::fast result_arr el1 el2 ...
array::shift::fast() {
    local -n _array_shift_result="$1"
    shift 2
    _array_shift_result=("$@")
}

# Remove element at index
# Usage: array::remove_at index el1 el2 ...
array::remove_at() {
    local idx="$1" i=0; shift
    for el in "$@"; do
        [[ "$i" -ne "$idx" ]] && echo "$el"
        (( i++ ))
    done
}

# Fast variant using nameref
# Usage: array::remove_at::fast result_arr index el1 el2 ...
array::remove_at::fast() {
    local -n _array_remove_at_result="$1"
    local idx="$2"; shift 2
    local i=0
    _array_remove_at_result=()
    for el in "$@"; do
        [[ "$i" -ne "$idx" ]] && _array_remove_at_result+=("$el")
        (( i++ ))
    done
}

# Remove all occurrences of a value
# Usage: array::remove value el1 el2 ...
array::remove() {
    local target="$1"; shift
    for el in "$@"; do
        [[ "$el" != "$target" ]] && echo "$el"
    done
}

# Fast variant using nameref
# Usage: array::remove::fast result_arr value el1 el2 ...
array::remove::fast() {
    local -n _array_remove_result="$1"
    local target="$2"; shift 2
    _array_remove_result=()
    for el in "$@"; do
        [[ "$el" != "$target" ]] && _array_remove_result+=("$el")
    done
}

# Replace element at index with new value
# Usage: array::set index value el1 el2 ...
array::set() {
    local idx="$1" val="$2" i=0; shift 2
    for el in "$@"; do
        [[ "$i" -eq "$idx" ]] && echo "$val" || echo "$el"
        (( i++ ))
    done
}

# Fast variant using nameref
# Usage: array::set::fast result_arr index value el1 el2 ...
array::set::fast() {
    local -n _array_set_result="$1"
    local idx="$2" val="$3"; shift 3
    local i=0
    _array_set_result=()
    for el in "$@"; do
        [[ "$i" -eq "$idx" ]] && _array_set_result+=("$val") || _array_set_result+=("$el")
        (( i++ ))
    done
}

# Insert element at index
# Usage: array::insert_at index value el1 el2 ...
array::insert_at() {
    local idx="$1" val="$2" i=0; shift 2
    for el in "$@"; do
        [[ "$i" -eq "$idx" ]] && echo "$val"
        echo "$el"
        (( i++ ))
    done
    # If index is beyond end, append
    [[ "$i" -le "$idx" ]] && echo "$val"
}

# Fast variant using nameref
# Usage: array::insert_at::fast result_arr index value el1 el2 ...
array::insert_at::fast() {
    local -n _array_insert_at_result="$1"
    local idx="$2" val="$3"; shift 3
    local i=0
    _array_insert_at_result=()
    for el in "$@"; do
        [[ "$i" -eq "$idx" ]] && _array_insert_at_result+=("$val")
        _array_insert_at_result+=("$el")
        (( i++ ))
    done
    [[ "$i" -le "$idx" ]] && _array_insert_at_result+=("$val")
}

# ==============================================================================
# FILTERING
# ==============================================================================

# Filter elements matching a regex
# Usage: array::filter regex el1 el2 ...
array::filter() {
    local regex="$1"; shift
    for el in "$@"; do
        [[ "$el" =~ $regex ]] && echo "$el"
    done
}

# Fast variant using nameref
# Usage: array::filter::fast result_arr regex el1 el2 ...
array::filter::fast() {
    local -n _array_filter_result="$1"
    local regex="$2"; shift 2
    _array_filter_result=()
    for el in "$@"; do
        [[ "$el" =~ $regex ]] && _array_filter_result+=("$el")
    done
}

# Filter elements NOT matching a regex
# Usage: array::reject regex el1 el2 ...
array::reject() {
    local regex="$1"; shift
    for el in "$@"; do
        [[ ! "$el" =~ $regex ]] && echo "$el"
    done
}

# Fast variant using nameref
# Usage: array::reject::fast result_arr regex el1 el2 ...
array::reject::fast() {
    local -n _array_reject_result="$1"
    local regex="$2"; shift 2
    _array_reject_result=()
    for el in "$@"; do
        [[ ! "$el" =~ $regex ]] && _array_reject_result+=("$el")
    done
}

# Return only elements that are non-empty
# Usage: array::compact el1 el2 ...
array::compact() {
    for el in "$@"; do
        [[ -n "$el" ]] && echo "$el"
    done
}

# Fast variant using nameref
# Usage: array::compact::fast result_arr el1 el2 ...
array::compact::fast() {
    local -n _array_compact_result="$1"
    shift
    _array_compact_result=()
    for el in "$@"; do
        [[ -n "$el" ]] && _array_compact_result+=("$el")
    done
}

# ==============================================================================
# AGGREGATION
# ==============================================================================

# Join elements with a delimiter
# Usage: array::join delimiter el1 el2 ...
array::join() {
    local delim="$1" result="" first=true; shift
    for el in "$@"; do
        if $first; then result="$el"; first=false
        else result+="${delim}${el}"; fi
    done
    echo "$result"
}

# Fast variant using nameref
# Usage: array::join::fast result_var delimiter el1 el2 ...
array::join::fast() {
    local -n _array_join_result="$1"
    local delim="$2"; shift 2
    local result="" first=true
    for el in "$@"; do
        if $first; then result="$el"; first=false
        else result+="${delim}${el}"; fi
    done
    _array_join_result="$result"
}

# Sum all numeric elements
# Usage: array::sum el1 el2 ...
array::sum() {
    local total=0 el
    for el in "$@"; do
        total=$(( total + el ))
    done
    echo "$total"
}

# Fast variant using nameref
# Usage: array::sum::fast result_var el1 el2 ...
array::sum::fast() {
    local -n _array_sum_result="$1"
    shift
    local total=0
    for el in "$@"; do
        total=$(( total + el ))
    done
    _array_sum_result=$total
}

# Minimum value (numeric)
# Usage: array::min el1 el2 ...
array::min() {
    local min="$1" el; shift
    for el in "$@"; do
        (( el < min )) && min="$el"
    done
    echo "$min"
}

# Fast variant using nameref
# Usage: array::min::fast result_var el1 el2 ...
array::min::fast() {
    local -n _array_min_result="$1"
    shift
    local min="$1"
    for el in "$@"; do
        (( el < min )) && min="$el"
    done
    _array_min_result=$min
}

# Maximum value (numeric)
# Usage: array::max el1 el2 ...
array::max() {
    local max="$1" el; shift
    for el in "$@"; do
        (( el > max )) && max="$el"
    done
    echo "$max"
}

# Fast variant using nameref
# Usage: array::max::fast result_var el1 el2 ...
array::max::fast() {
    local -n _array_max_result="$1"
    shift
    local max="$1"
    for el in "$@"; do
        (( el > max )) && max="$el"
    done
    _array_max_result=$max
}

# ==============================================================================
# SET OPERATIONS
# ==============================================================================

# Intersection — elements present in both arrays
# Usage: array::intersect "el1 el2 el3" "el2 el3 el4"
# Pass each array as a single space-separated string
array::intersect() {
    local -a a=($1) b=($2)
    local el other
    for el in "${a[@]}"; do
        for other in "${b[@]}"; do
            [[ "$el" == "$other" ]] && echo "$el" && break
        done
    done
}

# Fast variant using nameref
# Usage: array::intersect::fast result_arr "el1 el2 el3" "el2 el3 el4"
array::intersect::fast() {
    local -n _array_intersect_result="$1"
    local -a a=($2) b=($3)
    _array_intersect_result=()
    for el in "${a[@]}"; do
        for other in "${b[@]}"; do
            [[ "$el" == "$other" ]] && { _array_intersect_result+=("$el"); break; }
        done
    done
}

# Difference — elements in first array not in second
# Usage: array::diff "el1 el2 el3" "el2 el3 el4"
array::diff() {
    local -a a=($1) b=($2)
    local el other found
    for el in "${a[@]}"; do
        found=false
        for other in "${b[@]}"; do
            [[ "$el" == "$other" ]] && found=true && break
        done
        $found || echo "$el"
    done
}

# Fast variant using nameref
# Usage: array::diff::fast result_arr "el1 el2 el3" "el2 el3 el4"
array::diff::fast() {
    local -n _array_diff_result="$1"
    local -a a=($2) b=($3)
    _array_diff_result=()
    for el in "${a[@]}"; do
        local found=false
        for other in "${b[@]}"; do
            [[ "$el" == "$other" ]] && found=true && break
        done
        $found || _array_diff_result+=("$el")
    done
}

# Union — all unique elements from both arrays
# Usage: array::union "el1 el2" "el2 el3"
array::union() {
    local -a a=($1) b=($2)
    array::unique "${a[@]}" "${b[@]}"
}

# Fast variant using nameref
# Usage: array::union::fast result_arr "el1 el2" "el2 el3"
array::union::fast() {
    local -n _array_union_result="$1"
    local -a a=($2) b=($3)
    if runtime::is_minimum_bash 5; then
        _array_union_result=()
        local -A _seen=()
        for el in "${a[@]}" "${b[@]}"; do
            if [[ -z "${_seen[$el]+x}" ]]; then
                _seen["$el"]=1
                _array_union_result+=("$el")
            fi
        done
    else
        echo "array::union::fast: requires Bash 5+" >&2
        return 1
    fi
}

# ==============================================================================
# SORTING
# ==============================================================================

# Sort elements alphabetically
# Usage: array::sort el1 el2 ...
array::sort() {
    printf '%s\n' "$@" | sort
}

# Sort elements in reverse
array::sort::reverse() {
    printf '%s\n' "$@" | sort -r
}

# Sort elements numerically
array::sort::numeric() {
    printf '%s\n' "$@" | sort -n
}

# Sort elements numerically in reverse
array::sort::numeric_reverse() {
    printf '%s\n' "$@" | sort -rn
}

# Check if two arrays are equal (same elements, same order)
# Usage: array::equals "el1 el2" "el1 el2"
array::equals() {
    local -a a=($1) b=($2)
    local i
    [[ "${#a[@]}" -ne "${#b[@]}" ]] && return 1
    for (( i=0; i<${#a[@]}; i++ )); do
        [[ "${a[$i]}" != "${b[$i]}" ]] && return 1
    done
    return 0
}

# Fast variant using nameref
# Usage: array::equals::fast result_var "el1 el2" "el1 el2"
array::equals::fast() {
    local -n _array_equals_result="$1"
    local -a a=($2) b=($3)
    local i
    [[ "${#a[@]}" -ne "${#b[@]}" ]] && { _array_equals_result=false; return 1; }
    for (( i=0; i<${#a[@]}; i++ )); do
        [[ "${a[$i]}" != "${b[$i]}" ]] && { _array_equals_result=false; return 1; }
    done
    _array_equals_result=true
    return 0
}

# Zip two arrays together — pairs elements by index
# Usage: array::zip "a1 a2 a3" "b1 b2 b3"
# Output: "a1 b1", "a2 b2", "a3 b3" (one pair per line)
array::zip() {
    local -a a=($1) b=($2)
    local len=$(( ${#a[@]} < ${#b[@]} ? ${#a[@]} : ${#b[@]} ))
    local i
    for (( i=0; i<len; i++ )); do
        echo "${a[$i]} ${b[$i]}"
    done
}

# Fast variant using nameref
# Usage: array::zip::fast result_arr "a1 a2 a3" "b1 b2 b3"
array::zip::fast() {
    local -n _array_zip_result="$1"
    local -a a=($2) b=($3)
    local len=$(( ${#a[@]} < ${#b[@]} ? ${#a[@]} : ${#b[@]} ))
    local i
    _array_zip_result=()
    for (( i=0; i<len; i++ )); do
        _array_zip_result+=("${a[$i]} ${b[$i]}")
    done
}

# Rotate array left by n positions
# Usage: array::rotate n el1 el2 ...
array::rotate() {
    local n="$1"; shift
    local -a arr=("$@")
    local len="${#arr[@]}"
    n=$(( n % len ))
    printf '%s\n' "${arr[@]:$n}" "${arr[@]:0:$n}"
}

# Fast variant using nameref
# Usage: array::rotate::fast result_arr n el1 el2 ...
array::rotate::fast() {
    local -n _array_rotate_result="$1"
    local n="$2"; shift 2
    local -a _arr=("$@")
    local len="${#_arr[@]}"
    n=$(( n % len ))
    _array_rotate_result=("${_arr[@]:$n}" "${_arr[@]:0:$n}")
}

# Chunk array into groups of n
# Usage: array::chunk size el1 el2 ...
# Output: each chunk on one line, space-separated
array::chunk() {
    local size="$1" i=0 chunk=""; shift
    for el in "$@"; do
        if [[ -n "$chunk" ]]; then chunk+=" $el"
        else chunk="$el"; fi
        (( i++ ))
        if (( i % size == 0 )); then
            echo "$chunk"
            chunk=""
        fi
    done
    [[ -n "$chunk" ]] && echo "$chunk"
}

# Fast variant using nameref
# Usage: array::chunk::fast result_arr size el1 el2 ...
array::chunk::fast() {
    local -n _array_chunk_result="$1"
    local size="$2" i=0 chunk=""; shift 2
    _array_chunk_result=()
    for el in "$@"; do
        if [[ -n "$chunk" ]]; then chunk+=" $el"
        else chunk="$el"; fi
        (( i++ ))
        if (( i % size == 0 )); then
            _array_chunk_result+=("$chunk")
            chunk=""
        fi
    done
    [[ -n "$chunk" ]] && _array_chunk_result+=("$chunk")
}

# ==============================================================================
# BASH 5+ FEATURES
# ==============================================================================

# Remove duplicate elements (preserves first occurrence order)
# Usage: array::unique el1 el2 ...
array::unique() {
    local -A seen=()
    for el in "$@"; do
        if [[ -z "${seen[$el]+x}" ]]; then
            seen["$el"]=1
            echo "$el"
        fi
    done
}

# Fast variant using nameref (Bash 5+)
# Usage: array::unique::fast result_arr el1 el2 ...
array::unique::fast() {
    local -n _array_unique_result="$1"
    shift
    local -A _seen=()
    _array_unique_result=()
    for el in "$@"; do
        if [[ -z "${_seen[$el]+x}" ]]; then
            _seen["$el"]=1
            _array_unique_result+=("$el")
        fi
    done
}
