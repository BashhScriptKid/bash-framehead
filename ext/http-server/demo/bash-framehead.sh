#!/usr/bin/env bash

##==============================================================================
## bash::framehead — a runtime stdlib for Bash
## A comprehensive (and frankly ridiculous) set of helpers for when you're
## committed to doing it in Bash anyway
##==============================================================================
## Version: 0.1-dev+240526.57
## Author: BashhScriptKid <contact@bashh.slmail.me>
## Copyright (C) 2025 BashhScriptKid
## SPDX-License-Identifier: AGPL-3.0-or-later
##
##   This program is free software: you can redistribute it and/or modify
##   it under the terms of the GNU Affero General Public License as published
##   by the Free Software Foundation, either version 3 of the License, or
##   (at your option) any later version.
##
##   This program is distributed in the hope that it will be useful,
##   but WITHOUT ANY WARRANTY; without even the implied warranty of
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##   GNU Affero General Public License for more details.
##
##   You should have received a copy of the GNU Affero General Public License
##   along with this program.  If not, see <https://www.gnu.org/licenses/>.
##
##==============================================================================

# array.sh — bash-frameheader array lib
# Requires: runtime.sh (runtime::is_minimum_bash)
# shellcheck disable=SC2206
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
    local start="$1" end="$2" step="${3:-1}"
    local i
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
    local i=0
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
    local i=0
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
    local total=0
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
    local min="$1"; shift
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
    local max="$1"; shift
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
    for el in "${a[@]}"; do
        local found=false
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
    [[ "${#a[@]}" -ne "${#b[@]}" ]] && return 1
    local i
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
    [[ "${#a[@]}" -ne "${#b[@]}" ]] && { _array_equals_result=false; return 1; }
    local i
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
    local size="$1" i=0; shift
    local chunk=""
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
    local size="$2"; shift 2
    local i=0 chunk=""
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

# binary.sh — bash::framehead binary data primitives
#
# Integer-to-binary packing via pure Bash printf %b. Adapted from Dave Eddy's
# bash-bmp (github.com/bahamas10/bash-bmp, MIT license).
#
# EXAMPLE:
#   source bash-framehead.sh
#   binary::u32le 0x12345678 | xxd -p    # 78563412
#   binary::u32be 0x12345678 | xxd -p    # 12345678
#   binary::u16le 256 | od -An -tx1       # 00 01

# ==============================================================================
# INTERNAL
# ==============================================================================

# Emit an integer as raw bytes to stdout.
# Usage: _binary::pack <width> <value> <endian>
#   width  — number of bytes (2, 4, or 8)
#   value  — integer to pack
#   endian — "le" (little-endian, LSB first) or "be" (big-endian, MSB first)
_binary::pack() {
    local width=$1 value=$2 endian=$3
    local octets=() i

    for ((i = 0; i < width; i++)); do
        octets+=($(( (value >> (8 * i)) & 0xFF )))
    done

    if [[ $endian == be ]]; then
        local tmp=() idx
        for ((idx = width - 1; idx >= 0; idx--)); do
            tmp+=("${octets[idx]}")
        done
        octets=("${tmp[@]}")
    fi

    local fmt
    printf -v fmt '\\x%02x' "${octets[@]}"
    printf '%b' "$fmt"
}

# ==============================================================================
# LITTLE-ENDIAN (LSB first)
# ==============================================================================

# Emit a 16-bit unsigned integer in little-endian byte order.
# Usage: binary::u16le <value>
binary::u16le() { _binary::pack 2 "$1" le; }

# Emit a 32-bit unsigned integer in little-endian byte order.
# Usage: binary::u32le <value>
binary::u32le() { _binary::pack 4 "$1" le; }

# Emit a 64-bit unsigned integer in little-endian byte order.
# Usage: binary::u64le <value>
binary::u64le() { _binary::pack 8 "$1" le; }

# ==============================================================================
# BIG-ENDIAN (MSB first)
# ==============================================================================

# Emit a 16-bit unsigned integer in big-endian byte order.
# Usage: binary::u16be <value>
binary::u16be() { _binary::pack 2 "$1" be; }

# Emit a 32-bit unsigned integer in big-endian byte order.
# Usage: binary::u32be <value>
binary::u32be() { _binary::pack 4 "$1" be; }

# Emit a 64-bit unsigned integer in big-endian byte order.
# Usage: binary::u64be <value>
binary::u64be() { _binary::pack 8 "$1" be; }

# ==============================================================================
# STRING-TO-BINARY
# ==============================================================================

# Internal: emit unsigned integer as minimal-width little-endian bytes.
# Usage: _binary::from_uint <value>
_binary::from_uint() {
    local val=$1
    if (( val == 0 )); then
        printf '\x00'
        return
    fi
    local octets=()
    while (( val > 0 )); do
        octets+=($(( val & 0xFF )))
        (( val >>= 8 ))
    done
    local fmt
    printf -v fmt '\\x%02x' "${octets[@]}"
    printf '%b' "$fmt"
}

# Emit raw bytes from a hex string (each pair of hex chars = 1 byte).
# Odd-length input is zero-padded on the left.
# Usage: binary::from_hex <hex>
binary::from_hex() {
    local hex=$1
    (( ${#hex} % 2 != 0 )) && hex="0$hex"
    local i
    for ((i = 0; i < ${#hex}; i += 2)); do
        printf -v _fh_byte '\\x%s' "${hex:i:2}"
        printf '%b' "$_fh_byte"
    done
    unset _fh_byte
}

# Emit raw bytes from an octal number string (minimal-width unsigned LE).
# Usage: binary::from_oct <octal>
binary::from_oct() {
    local val=$((8#$1))
    _binary::from_uint "$val"
}

# Emit raw bytes from an unsigned decimal integer (minimal-width LE).
# Usage: binary::from_uint <n>
binary::from_uint() {
    _binary::from_uint "$1"
}

# Emit raw bytes from a signed decimal integer (minimal-width two's complement LE).
# Usage: binary::from_int <n>
#   -1   → ff
#   -128 → 80
#   -129 → 7fff
#   127  → 7f
#   128  → 8000
binary::from_int() {
    local val=$1
    if (( val == 0 )); then
        printf '\x00'
        return
    fi

    local octets=() neg=0
    if (( val < 0 )); then
        neg=1
        (( val = -val ))
    fi

    # Encode absolute value as minimal unsigned bytes
    while (( val > 0 )); do
        octets+=($(( val & 0xFF )))
        (( val >>= 8 ))
    done

    if (( neg )); then
        # Two's complement: flip bits and add 1
        local carry=1 i
        for ((i = 0; i < ${#octets[@]}; i++)); do
            (( octets[i] = (~octets[i] & 0xFF) + carry ))
            (( carry = octets[i] >> 8 ? 1 : 0 ))
            (( octets[i] &= 0xFF ))
        done
        if (( carry )); then
            octets+=(1)
        fi
        # Ensure sign bit is set in the high byte
        if (( (octets[-1] & 0x80) == 0 )); then
            octets+=(0xFF)
        fi
    else
        # Positive: ensure sign bit is clear in the high byte
        if (( (octets[-1] & 0x80) != 0 )); then
            octets+=(0)
        fi
    fi

    local fmt
    printf -v fmt '\\x%02x' "${octets[@]}"
    printf '%b' "$fmt"
}
# colour.sh — bash-frameheader colour lib
# Requires: runtime.sh (runtime::has_command)
#
# THREE COLOUR DEPTHS:
#   4-bit  — 16 colours (black, red, green, yellow, blue, magenta, cyan, white + bright variants)
#   8-bit  — 256 colours (16 named + 216 RGB cube + 24 greyscale)
#   24-bit — 16 million colours (true colour, R,G,B 0-255 each)
#
# COLOUR NAMES (4-bit and 8-bit):
#   black, red, green, yellow, blue, magenta, cyan, white
#   Prefix with "bright" for bright variants: "bright red", "brightred"
#
# 8-BIT RGB CUBE: rgb0,0,0 to rgb5,5,5 (or bare R,G,B without prefix)
# 8-BIT GREYSCALE: grey0 to grey23 (or gray0 to gray23)
#
# 24-BIT RGB: R,G,B where each is 0-255

# ==============================================================================
# CAPABILITY DETECTION
# ==============================================================================

# Check if the terminal supports any colour
colour::supports() {
    [[ -t 1 ]] || return 1
    local count
    count=$(colour::depth)
    (( count >= 8 ))
}

# Return the number of colours the terminal supports
colour::depth() {
    tput colors 2>/dev/null || echo "0"
}

# Check if terminal supports 256 colours
colour::supports_256() {
    (( $(colour::depth) >= 256 ))
}

# Check if terminal supports true colour (24-bit)
# Checks $COLORTERM env var — set by most modern terminals
colour::supports_truecolor() {
    [[ "$COLORTERM" == "truecolor" || "$COLORTERM" == "24bit" ]]
}

# ==============================================================================
# INDEX LOOKUP
# Internal helpers — returns the numeric colour index for use in escape codes
# ==============================================================================

# Get 4-bit ANSI colour code index
# Usage: colour::index::4bit colour_name [fg|bg]
# Returns: ANSI code number (30-37, 40-47, 90-97, 100-107)
colour::index::4bit() {
    local key="${1,,}" fg_bg="${2:-fg}"

    # Handle bright prefix — "bright red" or "brightred"
    local is_bright=0
    if [[ "$key" == bright* ]]; then
        is_bright=1
        key="${key#bright}"
        key="${key# }"  # strip optional space
    fi

    local val
    case "$key" in
        black)   val=30 ;;
        red)     val=31 ;;
        green)   val=32 ;;
        yellow)  val=33 ;;
        blue)    val=34 ;;
        magenta) val=35 ;;
        cyan)    val=36 ;;
        white)   val=37 ;;
        *)       return 1 ;;
    esac

    (( is_bright )) && val=$(( val + 60 ))
    [[ "$fg_bg" == "bg" ]] && val=$(( val + 10 ))

    echo "$val"
}

# Get 8-bit colour index (0-255)
# Usage: colour::index::8bit colour_name
# Accepts: named colours, "bright name", "rgbR,G,B", "greyN"/"grayN"
colour::index::8bit() {
    local key="${1,,}"

    # Handle bright prefix
    local is_bright=0
    if [[ "$key" == bright* ]]; then
        is_bright=1
        key="${key#bright}"
        key="${key# }"
    fi

    # Named colours (0-7, or 8-15 if bright)
    local val=-1
    case "$key" in
        black)   val=0 ;;
        red)     val=1 ;;
        green)   val=2 ;;
        yellow)  val=3 ;;
        blue)    val=4 ;;
        magenta) val=5 ;;
        cyan)    val=6 ;;
        white)   val=7 ;;
    esac

    if (( val >= 0 )); then
        (( is_bright )) && val=$(( val + 8 ))
        echo "$val"
        return 0
    fi

    # RGB cube (16-231): rgb0,0,0 to rgb5,5,5 or bare R,G,B
    if [[ "$key" =~ ^(rgb)?([0-5]),([0-5]),([0-5])$ ]]; then
        local r="${BASH_REMATCH[2]}" g="${BASH_REMATCH[3]}" b="${BASH_REMATCH[4]}"
        (( is_bright )) && echo "colour::index::8bit: bright ignored for RGB" >&2
        echo $(( 16 + r * 36 + g * 6 + b ))
        return 0
    fi

    # Greyscale (232-255): grey0-grey23 or gray0-gray23
    if [[ "$key" =~ ^(gr[ae]y)?([0-9]+)$ ]]; then
        local n="${BASH_REMATCH[2]}"
        # Warn on bare numbers — ambiguous intent
        [[ "$key" =~ ^[0-9]+$ ]] && \
            echo "colour::index::8bit: bare number interpreted as greyscale index" >&2
        (( n >= 0 && n <= 23 )) || { echo "colour::index::8bit: greyscale index must be 0-23" >&2; return 1; }
        echo $(( 232 + n ))
        return 0
    fi

    echo "colour::index::8bit: unrecognised colour '${1}'" >&2
    return 1
}

# ==============================================================================
# ESCAPE CODE GENERATION
# ==============================================================================

# Generate a raw ANSI escape sequence
# Usage: colour::esc bit fg_bg colour [colour...]
#   bit    — 4, 8, or 24
#   fg_bg  — fg or bg
#   colour — colour name/value (see header for formats)
colour::esc() {
    local bit="${1:-}" fg_bg="${2:-fg}"; shift 2
    [[ -n "$bit" ]] || return 1

    case "$bit" in
    4)
        local index
        index=$(colour::index::4bit "$*" "$fg_bg") || return 1
        printf '\033[%sm' "$index"
        ;;
    8)
        local index
        index=$(colour::index::8bit "$*") || return 1
        if [[ "$fg_bg" == "bg" ]]; then
            printf '\033[48;5;%sm' "$index"
        else
            printf '\033[38;5;%sm' "$index"
        fi
        ;;
    24)
        local r g b
        if [[ "$1" =~ ^(rgb)?([0-9]+),([0-9]+),([0-9]+)$ ]]; then
            r="${BASH_REMATCH[2]}"
            g="${BASH_REMATCH[3]}"
            b="${BASH_REMATCH[4]}"
        else
            echo "colour::esc: 24-bit expects R,G,B format" >&2
            return 1
        fi
        # Clamp to 0-255
        (( r = r > 255 ? 255 : r ))
        (( g = g > 255 ? 255 : g ))
        (( b = b > 255 ? 255 : b ))
        if [[ "$fg_bg" == "bg" ]]; then
            printf '\033[48;2;%s;%s;%sm' "$r" "$g" "$b"
        else
            printf '\033[38;2;%s;%s;%sm' "$r" "$g" "$b"
        fi
        ;;
    *)
        echo "colour::esc: bit depth must be 4, 8, or 24" >&2
        return 1
        ;;
    esac
}

# ==============================================================================
# ATTRIBUTES
# Text styling — not colour-depth dependent
# ==============================================================================

colour::reset()     { printf '\033[0m';  }
colour::bold()      { printf '\033[1m';  }
colour::dim()       { printf '\033[2m';  }
colour::italic()    { printf '\033[3m';  }
colour::underline() { printf '\033[4m';  }
colour::blink()     { printf '\033[5m';  }
colour::reverse()   { printf '\033[7m';  }
colour::hidden()    { printf '\033[8m';  }
colour::strike()    { printf '\033[9m';  }

# Reset individual attributes
colour::reset::bold()      { printf '\033[22m'; }
colour::reset::dim()       { printf '\033[22m'; }
colour::reset::italic()    { printf '\033[23m'; }
colour::reset::underline() { printf '\033[24m'; }
colour::reset::blink()     { printf '\033[25m'; }
colour::reset::reverse()   { printf '\033[27m'; }
colour::reset::hidden()    { printf '\033[28m'; }
colour::reset::strike()    { printf '\033[29m'; }
colour::reset::fg()        { printf '\033[39m'; }
colour::reset::bg()        { printf '\033[49m'; }

# ==============================================================================
# CONVENIENCE — 4-BIT NAMED SHORTCUTS
# colour::fg::red, colour::bg::bright_blue etc.
# ==============================================================================

# Foreground
colour::fg::black()          { printf '\033[30m'; }
colour::fg::red()            { printf '\033[31m'; }
colour::fg::green()          { printf '\033[32m'; }
colour::fg::yellow()         { printf '\033[33m'; }
colour::fg::blue()           { printf '\033[34m'; }
colour::fg::magenta()        { printf '\033[35m'; }
colour::fg::cyan()           { printf '\033[36m'; }
colour::fg::white()          { printf '\033[37m'; }
colour::fg::bright_black()   { printf '\033[90m'; }
colour::fg::bright_red()     { printf '\033[91m'; }
colour::fg::bright_green()   { printf '\033[92m'; }
colour::fg::bright_yellow()  { printf '\033[93m'; }
colour::fg::bright_blue()    { printf '\033[94m'; }
colour::fg::bright_magenta() { printf '\033[95m'; }
colour::fg::bright_cyan()    { printf '\033[96m'; }
colour::fg::bright_white()   { printf '\033[97m'; }

# Background
colour::bg::black()          { printf '\033[40m';  }
colour::bg::red()            { printf '\033[41m';  }
colour::bg::green()          { printf '\033[42m';  }
colour::bg::yellow()         { printf '\033[43m';  }
colour::bg::blue()           { printf '\033[44m';  }
colour::bg::magenta()        { printf '\033[45m';  }
colour::bg::cyan()           { printf '\033[46m';  }
colour::bg::white()          { printf '\033[47m';  }
colour::bg::bright_black()   { printf '\033[100m'; }
colour::bg::bright_red()     { printf '\033[101m'; }
colour::bg::bright_green()   { printf '\033[102m'; }
colour::bg::bright_yellow()  { printf '\033[103m'; }
colour::bg::bright_blue()    { printf '\033[104m'; }
colour::bg::bright_magenta() { printf '\033[105m'; }
colour::bg::bright_cyan()    { printf '\033[106m'; }
colour::bg::bright_white()   { printf '\033[107m'; }

# ==============================================================================
# HIGHER-LEVEL HELPERS
# ==============================================================================

# Print text wrapped in colour, auto-reset after
# Usage: colour::print bit fg_bg colour text
#        echo "text" | colour::print bit fg_bg colour
colour::print() {
  local bit="$1" fg_bg="$2" col="$3" text
  if [[ $# -ge 4 ]]; then text="$4"; else text=$(cat); fi
  colour::esc "$bit" "$fg_bg" "$col"
  printf '%s' "$text"
  colour::reset
}

# Print text in colour followed by newline
colour::println() {
  colour::print "$@"
  printf '\n'
}

# Wrap text in escape codes and return as string (no direct print)
# Usage: colour::wrap bit fg_bg colour text
#        echo "text" | colour::wrap bit fg_bg colour
colour::wrap() {
  local bit="$1" fg_bg="$2" col="$3" text
  if [[ $# -ge 4 ]]; then text="$4"; else text=$(cat); fi
  printf '%s%s%s' "$(colour::esc "$bit" "$fg_bg" "$col")" "$text" "$(colour::reset)"
}

# Strip all ANSI escape codes from a string
# Usage: colour::strip text
#        echo "text" | colour::strip
colour::strip() {
  local input
  if [[ $# -ge 1 ]]; then input="$1"; else input=$(cat); fi
  printf '%s\n' "$input" | sed 's/\x1b\[[0-9;]*[mGKHF]//g'
}

# Return the visible length of a string (excluding escape codes)
# Useful for padding/alignment with coloured strings
colour::visible_length() {
  local input
  if [[ $# -ge 1 ]]; then input="$1"; else input=$(cat); fi
  local stripped
  stripped=$(colour::strip "$input")
  echo "${#stripped}"
}

# Check if a string contains any ANSI escape codes
colour::has_colour() {
  local input
  if [[ $# -ge 1 ]]; then input="$1"; else input=$(cat); fi
  [[ "$input" =~ $'\033'\[ ]]
}

# Gracefully degrade — return escape code only if terminal supports the depth
# Usage: colour::safe_esc bit fg_bg colour
# Returns empty string (no-op) if terminal doesn't support the requested depth
colour::safe_esc() {
    local bit="$1"
    case "$bit" in
    4)  colour::supports     || return 0 ;;
    8)  colour::supports_256 || return 0 ;;
    24) colour::supports_truecolor || return 0 ;;
    esac
    colour::esc "$@"
}
# device.sh — bash-frameheader device lib
# Requires: runtime.sh (runtime::os, runtime::has_command)

# ==============================================================================
# INSPECTION
# ==============================================================================

# Check if path is a character device
device::is_device() {
    [[ -c "$1" ]]
}

# Check if path is a block device
device::is_block() {
    [[ -b "$1" ]]
}

# Check if device is writable
device::is_writeable() {
    [[ -w "$1" ]]
}

# Check if device is readable
device::is_readable() {
    [[ -r "$1" ]]
}

# Check if device exists (block or character)
device::exists() {
    [[ -b "$1" || -c "$1" ]]
}

# Check if device has open file handles via lsof
device::has_processes() {
    runtime::has_command lsof || return 1
    lsof -t "$1" >/dev/null 2>&1
}

# Check if device is occupied via /proc (no lsof needed)
device::is_occupied() {
    find /proc/[0-9]*/fd -lname "*${1#/dev/}" 2>/dev/null | head -1 | grep -q .
}

# Check if a block device is mounted
device::is_mounted() {
    grep -q "^$1 " /proc/mounts 2>/dev/null \
        || grep -q " $1 " /proc/mounts 2>/dev/null
}

# Check if device is a loop device
device::is_loop() {
    [[ "$1" == /dev/loop* ]]
}

# Check if device is a RAM disk
device::is_ram() {
    [[ "$1" == /dev/ram* || "$1" == /dev/zram* ]]
}

# Check if device is a virtual/pseudo device
device::is_virtual() {
    case "$1" in
        /dev/null | /dev/zero | /dev/full | /dev/random | \
        /dev/urandom | /dev/stdin | /dev/stdout | /dev/stderr | \
        /dev/fd/* | /dev/ptmx | /dev/tty*)
            return 0 ;;
        *)
            return 1 ;;
    esac
}

# ==============================================================================
# CLASSIFICATION
# ==============================================================================

# Returns the type of a device as a string
# Possible returns: block, char, loop, ram, disk, partition, nvme,
#                   virtual, tty, pty, usb, optical, unknown
device::type() {
    local dev="$1"
    local base="${dev##*/}"

    # Virtual/pseudo devices first
    device::is_virtual "$dev" && echo "virtual"   && return
    device::is_loop "$dev"    && echo "loop"      && return
    device::is_ram "$dev"     && echo "ram"       && return

    # TTY / PTY
    [[ "$dev" == /dev/tty*  ]] && echo "tty" && return
    [[ "$dev" == /dev/pts/* ]] && echo "pty" && return

    # NVMe
    [[ "$base" =~ ^nvme[0-9]+n[0-9]+p[0-9]+$ ]] && echo "partition" && return
    [[ "$base" =~ ^nvme[0-9]+n[0-9]+$        ]] && echo "nvme"      && return

    # SD/SAS/SATA partitions vs disks
    [[ "$base" =~ ^sd[a-z]+[0-9]+$  ]] && echo "partition" && return
    [[ "$base" =~ ^sd[a-z]+$        ]] && echo "disk"      && return

    # MMC / eMMC
    [[ "$base" =~ ^mmcblk[0-9]+p[0-9]+$ ]] && echo "partition" && return
    [[ "$base" =~ ^mmcblk[0-9]+$        ]] && echo "disk"      && return

    # IDE (legacy)
    [[ "$base" =~ ^hd[a-z]+[0-9]+$ ]] && echo "partition" && return
    [[ "$base" =~ ^hd[a-z]+$       ]] && echo "disk"      && return

    # Optical
    [[ "$base" =~ ^sr[0-9]+$  ]] && echo "optical" && return
    [[ "$base" =~ ^cd[a-z]+$  ]] && echo "optical" && return

    # USB block devices (often shows as sdX — covered above, but flag specific paths)
    [[ "$dev" == /dev/bus/usb/* ]] && echo "usb" && return

    # Generic character vs block fallback
    device::is_block "$dev"  && echo "block" && return
    device::is_device "$dev" && echo "char"  && return

    echo "unknown"
}

# Returns the major:minor device number
device::number() {
    local dev="$1"
    if runtime::has_command stat; then
        case "$(runtime::os)" in
        linux|wsl|cygwin|mingw)
            stat -c '%t:%T' "$dev" 2>/dev/null | \
                awk -F: '{ printf "%d:%d\n", strtonum("0x"$1), strtonum("0x"$2) }'
            ;;
        darwin)
            stat -f '%Hr:%Lr' "$dev" 2>/dev/null
            ;;
        *)
            echo "unknown"
            ;;
        esac
    else
        echo "unknown"
    fi
}

# Returns the filesystem on a block device (if mounted or detectable)
# Requires: blkid (Linux) or diskutil (macOS)
device::filesystem() {
    local dev="$1"
    case "$(runtime::os)" in
    linux|wsl)
        if runtime::has_command blkid; then
            blkid -o value -s TYPE "$dev" 2>/dev/null || echo "unknown"
        else
            echo "unknown"
        fi
        ;;
    darwin)
        diskutil info "$dev" 2>/dev/null \
            | awk -F': +' '/Type \(Bundle\)/ { print $2 }' || echo "unknown"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

# Returns the size of a block device in bytes
device::size_bytes() {
    local dev="$1"
    case "$(runtime::os)" in
    linux|wsl)
        if [[ -r "/sys/block/${dev##*/}/size" ]]; then
            # /sys/block reports 512-byte sectors
            echo $(( $(cat "/sys/block/${dev##*/}/size") * 512 ))
        elif runtime::has_command blockdev; then
            blockdev --getsize64 "$dev" 2>/dev/null || echo "unknown"
        else
            echo "unknown"
        fi
        ;;
    darwin)
        diskutil info "$dev" 2>/dev/null \
            | awk -F': +' '/Disk Size/ { match($2, /[0-9]+/, a); print a[0] }' \
            || echo "unknown"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

# Returns the size of a block device in MB
device::size_mb() {
    local bytes
    bytes=$(device::size_bytes "$1")
    [[ "$bytes" == "unknown" ]] && echo "unknown" && return
    echo $(( bytes / 1024 / 1024 ))
}

# Returns the mount point of a block device (empty if not mounted)
device::mount_point() {
    local dev="$1"
    case "$(runtime::os)" in
    linux|wsl)
        grep "^$dev " /proc/mounts 2>/dev/null | awk '{print $2}' | head -1
        ;;
    darwin)
        diskutil info "$dev" 2>/dev/null \
            | awk -F': +' '/Mount Point/ { print $2 }'
        ;;
    *)
        echo ""
        ;;
    esac
}

# ==============================================================================
# LISTING
# ==============================================================================

# List all block devices
device::list::block() {
    case "$(runtime::os)" in
    linux|wsl)
        lsblk -dno NAME 2>/dev/null | sed 's/^/\/dev\//' | grep -v loop
        ;;
    darwin)
        diskutil list 2>/dev/null | awk '/^\/dev\// { print $1 }'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

# List all character devices
device::list::char() {
    find /dev -maxdepth 1 -type c 2>/dev/null | sort
}

# List all TTY devices
device::list::tty() {
    find /dev -maxdepth 1 -name 'tty*' -type c 2>/dev/null | sort
}

# List all loop devices
device::list::loop() {
    find /dev -maxdepth 1 -name 'loop*' -type b 2>/dev/null | sort
}

# List mounted devices with their mount points
device::list::mounted() {
    case "$(runtime::os)" in
    linux|wsl)
        grep '^/dev/' /proc/mounts 2>/dev/null | awk '{print $1, $2}'
        ;;
    darwin)
        mount 2>/dev/null | awk '/^\/dev\// { print $1, $3 }'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

# ==============================================================================
# SPECIAL DEVICES
# ==============================================================================

# Write n bytes of zeros to a device or file (wraps /dev/zero)
# Usage: device::zero target [bytes]
# WARNING: Destructive — use with care
device::zero() {
    local target="$1" bytes="${2:-16}"
    if [[ -n "$bytes" ]]; then
        dd if=/dev/zero of="$target" bs=1 count="$bytes" 2>/dev/null
    else
        dd if=/dev/zero of="$target" 2>/dev/null
    fi
}

# Read n random bytes from /dev/urandom
# Usage: device::random [bytes]
device::random() {
    local bytes="${1:-16}"
    dd if=/dev/urandom bs=1 count="$bytes" 2>/dev/null | od -An -tx1 | tr -d ' \n'
    echo
}

# Check if /dev/null is functional (sanity check)
device::null_ok() {
    echo "" > /dev/null 2>&1
}
# fs.sh — bash-frameheader filesystem lib
# Requires: runtime.sh (runtime::has_command)

# ==============================================================================
# PATH MANIPULATION
# Pure string operations — no filesystem access required
# ==============================================================================

# Join path components
# Usage: fs::path::join part1 part2 ...
fs::path::join() {
    local result="$1"; shift
    for part in "$@"; do
        part="${part#/}"   # strip leading slash from each part
        result="${result%/}/$part"
    done
    echo "$result"
}

# Get filename from path (like basename)
fs::path::basename() {
    echo "${1##*/}"
}

# Get directory from path (like dirname)
fs::path::dirname() {
    local p="${1%/*}"
    [[ "$p" == "$1" ]] && echo "." || echo "$p"
}

# Get file extension (without dot)
# Usage: fs::path::extension file.tar.gz → gz
fs::path::extension() {
    local base="${1##*/}"
    [[ "$base" == *.* ]] && echo "${base##*.}" || echo ""
}

# Get all extensions for multi-part extensions
# Usage: fs::path::extensions file.tar.gz → tar.gz
fs::path::extensions() {
    local base="${1##*/}"
    [[ "$base" == *.* ]] && echo "${base#*.}" || echo ""
}

# Strip extension from filename
fs::path::stem() {
    local base="${1##*/}"
    [[ "$base" == *.* ]] && echo "${base%.*}" || echo "$base"
}

# Get absolute path (resolves . and .. without requiring the path to exist)
fs::path::absolute() {
    local p="$1"
    if [[ "$p" != /* ]]; then
        p="$(pwd)/$p"
    fi
    # Resolve . and .. manually
    local -a parts=() result=()
    IFS='/' read -ra parts <<< "$p"
    for part in "${parts[@]}"; do
        case "$part" in
            ""|.) ;;
            ..)   [[ ${#result[@]} -gt 0 ]] && unset 'result[-1]' ;;
            *)    result+=("$part") ;;
        esac
    done
    echo "/${result[*]// //}"
}

# Get path relative to a base
# Usage: fs::path::relative /a/b/c /a → b/c
fs::path::relative() {
    local target="$1" base="$2"
    # Strip common prefix
    while [[ "$target" == "$base"* && "$base" != "/" ]]; do
        target="${target#"$base"}"
        target="${target#/}"
        break
    done
    echo "$target"
}

# Check if a path is absolute
fs::path::is_absolute() {
    [[ "$1" == /* ]]
}

# Check if a path is relative
fs::path::is_relative() {
    [[ "$1" != /* ]]
}

# ==============================================================================
# FILE / DIR CHECKS
# ==============================================================================

fs::exists()        { [[ -e "$1" ]]; }
fs::is_file()       { [[ -f "$1" ]]; }
fs::is_dir()        { [[ -d "$1" ]]; }
fs::is_symlink()    { [[ -L "$1" ]]; }
fs::is_readable()   { [[ -r "$1" ]]; }
fs::is_writable()   { [[ -w "$1" ]]; }
fs::is_executable() { [[ -x "$1" ]]; }
fs::is_empty()      { [[ -f "$1" && ! -s "$1" ]] || [[ -d "$1" && -z "$(ls -A "$1" 2>/dev/null)" ]]; }

# Check if two paths resolve to the same file (inode comparison)
fs::is_same() {
    [[ "$(stat -c '%d:%i' "$1" 2>/dev/null)" == "$(stat -c '%d:%i' "$2" 2>/dev/null)" ]]
}

# ==============================================================================
# FILE INFO
# ==============================================================================

# File size in bytes
fs::size() {
    stat -c '%s' "$1" 2>/dev/null || wc -c < "$1" 2>/dev/null
}

# Human-readable file size
fs::size::human() {
    local size
    size=$(fs::size "$1")
    if runtime::has_command numfmt; then
        numfmt --to=iec-i --suffix=B "$size"
    else
        awk -v s="$size" 'BEGIN {
            split("B KiB MiB GiB TiB", u)
            i=1; while(s>=1024 && i<5){s/=1024; i++}
            printf "%.1f%s\n", s, u[i]
        }'
    fi
}

# Last modified time (unix timestamp)
fs::modified() {
    stat -c '%Y' "$1" 2>/dev/null
}

# Last modified time (human readable)
fs::modified::human() {
    stat -c '%y' "$1" 2>/dev/null
}

# Creation time (unix timestamp) — not available on all filesystems
fs::created() {
    stat -c '%W' "$1" 2>/dev/null
}

# Octal permissions
fs::permissions() {
    stat -c '%a' "$1" 2>/dev/null
}

# Symbolic permissions (e.g. -rwxr-xr-x)
fs::permissions::symbolic() {
    stat -c '%A' "$1" 2>/dev/null
}

# Owner username
fs::owner() {
    stat -c '%U' "$1" 2>/dev/null
}

# Owner group
fs::owner::group() {
    stat -c '%G' "$1" 2>/dev/null
}

# Inode number
fs::inode() {
    stat -c '%i' "$1" 2>/dev/null
}

# MIME type
fs::mime_type() {
    if runtime::has_command file; then
        file --mime-type -b "$1" 2>/dev/null
    else
        echo "unknown"
    fi
}

# Number of hard links
fs::link_count() {
    stat -c '%h' "$1" 2>/dev/null
}

# Symlink target
fs::symlink::target() {
    readlink "$1" 2>/dev/null
}

# Resolved symlink target (follows chain)
fs::symlink::resolve() {
    readlink -f "$1" 2>/dev/null
}

# ==============================================================================
# OPERATIONS
# ==============================================================================

# Copy file or directory
# Usage: fs::copy src dst
fs::copy() {
    cp -r "$1" "$2"
}

# Move/rename
fs::move() {
    mv "$1" "$2"
}

# Delete file or directory
fs::delete() {
    rm -rf "$1"
}

# Create directory (including parents)
fs::mkdir() {
    mkdir -p "$1"
}

# Touch a file (create or update timestamp)
fs::touch() {
    touch "$1"
}

# Create a symlink
# Usage: fs::symlink target link_name
fs::symlink() {
    ln -s "$1" "$2"
}

# Create a hard link
fs::hardlink() {
    ln "$1" "$2"
}

# Rename just the filename, keeping directory
# Usage: fs::rename old_path new_name
fs::rename() {
    local dir
    dir="$(fs::path::dirname "$1")"
    mv "$1" "$dir/$2"
}

# Safely delete to a trash dir instead of permanent delete
# Usage: fs::trash path
fs::trash() {
    local trash_dir="${HOME}/.local/share/Trash/files"
    mkdir -p "$trash_dir"
    mv "$1" "$trash_dir/$(fs::path::basename "$1").$(date +%s)"
}

# ==============================================================================
# TEMP FILES
# ==============================================================================

# Create a temporary file, print its path
# Usage: tmpfile=$(fs::temp::file [prefix])
fs::temp::file() {
    local prefix="${1:-fsbshf}"
    mktemp "/tmp/${prefix}.XXXXXX"
}

# Create a temporary directory, print its path
# Usage: tmpdir=$(fs::temp::dir [prefix])
fs::temp::dir() {
    local prefix="${1:-fsbshf}"
    mktemp -d "/tmp/${prefix}.XXXXXX"
}

# Create a temp file and register cleanup on EXIT
# Usage: fs::temp::file::auto [prefix]
fs::temp::file::auto() {
    local tmp
    tmp=$(fs::temp::file "$1")
    # shellcheck disable=SC2064
    trap "rm -f '$tmp'" EXIT
    echo "$tmp"
}

# Create a temp dir and register cleanup on EXIT
fs::temp::dir::auto() {
    local tmp
    tmp=$(fs::temp::dir "$1")
    # shellcheck disable=SC2064
    trap "rm -rf '$tmp'" EXIT
    echo "$tmp"
}

# ==============================================================================
# READING / WRITING
# ==============================================================================

# Read entire file contents
fs::read() {
    cat "$1"
}

# Write content to file (overwrites)
# Usage: fs::write path content
fs::write() {
    printf '%s' "$2" > "$1"
}

# Write with newline
fs::writeln() {
    printf '%s\n' "$2" > "$1"
}

# Append content to file
fs::append() {
    printf '%s' "$2" >> "$1"
}

# Append with newline
fs::appendln() {
    printf '%s\n' "$2" >> "$1"
}

# Read a specific line number (1-indexed)
# Usage: fs::line path line_number
fs::line() {
    sed -n "${2}p" "$1"
}

# Read a range of lines
# Usage: fs::lines path start end
fs::lines() {
    sed -n "${2},${3}p" "$1"
}

# Count lines in a file
fs::line_count() {
    wc -l < "$1"
}

# Count words in a file
fs::word_count() {
    wc -w < "$1"
}

# Count characters in a file
fs::char_count() {
    wc -c < "$1"
}

# Check if file contains a string
# Usage: fs::contains path string
fs::contains() {
    grep -qF "$2" "$1" 2>/dev/null
}

# Check if file matches a regex
fs::matches() {
    grep -qE "$2" "$1" 2>/dev/null
}

# Replace string in file (in-place)
# Usage: fs::replace path old new
fs::replace() {
    sed -i "s|${2}|${3}|g" "$1"
}

# Prepend content to file
fs::prepend() {
    local tmp
    tmp=$(fs::temp::file)
    printf '%s\n' "$2" | cat - "$1" > "$tmp"
    mv "$tmp" "$1"
}

# ==============================================================================
# DIRECTORY OPERATIONS
# ==============================================================================

# List directory contents (one per line)
fs::ls() {
    ls -1 "${1:-.}"
}

# List with hidden files
fs::ls::all() {
    ls -1A "${1:-.}"
}

# List only files
fs::ls::files() {
    # shellcheck disable=SC2010
    find "${1:-.}" -maxdepth 1 -type f -printf '%f\n' 2>/dev/null || \
    ls -1p "${1:-.}" | grep -v '/$'
}

# List only directories
fs::ls::dirs() {
    # shellcheck disable=SC2010
    find "${1:-.}" -maxdepth 1 -type d -not -path "${1:-.}" -printf '%f\n' 2>/dev/null || \
    ls -1p "${1:-.}" | grep '/$' | tr -d '/'
}

# Recursive find by name pattern
# Usage: fs::find path pattern
fs::find() {
    find "${1:-.}" -name "$2" 2>/dev/null
}

# Recursive find by type (f=file, d=dir, l=symlink)
fs::find::type() {
    find "${1:-.}" -type "$2" 2>/dev/null
}

# Find files modified within n minutes
fs::find::recent() {
    find "${1:-.}" -type f -mmin "-${2:-60}" 2>/dev/null
}

# Find files larger than n bytes
fs::find::larger_than() {
    find "${1:-.}" -type f -size "+${2}c" 2>/dev/null
}

# Find files smaller than n bytes
fs::find::smaller_than() {
    find "${1:-.}" -type f -size "-${2}c" 2>/dev/null
}

# Get total size of directory
fs::dir::size() {
    du -sb "${1:-.}" 2>/dev/null | awk '{print $1}'
}

# Get total size of directory, human readable
fs::dir::size::human() {
    du -sh "${1:-.}" 2>/dev/null | awk '{print $1}'
}

# Count items in directory
fs::dir::count() {
    find "${1:-.}" -maxdepth 1 -not -path "${1:-.}" 2>/dev/null | wc -l
}

# Check if directory is empty
fs::dir::is_empty() {
    [[ -z "$(ls -A "${1:-.}" 2>/dev/null)" ]]
}

# ==============================================================================
# WATCHING
# ==============================================================================

# Watch a file for changes, run callback on change
# Usage: fs::watch path callback [interval_seconds]
# Callback receives the path as $1
fs::watch() {
    local path="$1" callback="$2" interval="${3:-1}"
    local last_modified
    last_modified=$(fs::modified "$path")

    while true; do
        sleep "$interval"
        local current
        current=$(fs::modified "$path")
        if [[ "$current" != "$last_modified" ]]; then
            last_modified="$current"
            "$callback" "$path"
        fi
    done
}

# Watch with a timeout (seconds)
# Usage: fs::watch::timeout path callback timeout [interval]
fs::watch::timeout() {
    local path="$1" callback="$2" timeout="$3" interval="${4:-1}"
    local elapsed=0
    local last_modified
    last_modified=$(fs::modified "$path")

    while (( elapsed < timeout )); do
        local current
        current=$(fs::modified "$path")
        if [[ "$current" != "$last_modified" ]]; then
            last_modified="$current"
            "$callback" "$path"
        fi
        (( elapsed += interval ))
        (( elapsed < timeout )) || break
        sleep "$interval"
    done
}

# ==============================================================================
# CHECKSUMS
# ==============================================================================

fs::checksum::md5() {
    if runtime::has_command md5sum; then
        md5sum "$1" | awk '{print $1}'
    elif runtime::has_command md5; then
        md5 -q "$1"
    fi
}

fs::checksum::sha1() {
    if runtime::has_command sha1sum; then
        sha1sum "$1" | awk '{print $1}'
    elif runtime::has_command shasum; then
        shasum -a 1 "$1" | awk '{print $1}'
    fi
}

fs::checksum::sha256() {
    if runtime::has_command sha256sum; then
        sha256sum "$1" | awk '{print $1}'
    elif runtime::has_command shasum; then
        shasum -a 256 "$1" | awk '{print $1}'
    fi
}

# Check if two files are identical (by content)
fs::is_identical() {
    local sum1 sum2
    sum1=$(fs::checksum::sha256 "$1")
    sum2=$(fs::checksum::sha256 "$2")
    [[ "$sum1" == "$sum2" ]]
}
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
# hardware.sh — bash-frameheader hardware lib
# Requires: runtime.sh (runtime::os, runtime::has_command)

# ==============================================================================
# CPU
# ==============================================================================

hardware::cpu::name() {
    case "$(runtime::os)" in
    linux|wsl|cygwin|mingw)
        local cpu
        case "$(uname -m)" in
            "frv"|"hppa"|"m68k"|"openrisc"|"or"*|"powerpc"|"ppc"*|"sparc"*)
                cpu="$(awk -F':' '/^cpu\t|^CPU/ {printf $2; exit}' /proc/cpuinfo)"
                ;;
            "s390"*)
                cpu="$(awk -F'=' '/machine/ {print $4; exit}' /proc/cpuinfo)"
                ;;
            "ia64"|"m32r")
                cpu="$(awk -F':' '/model/ {print $2; exit}' /proc/cpuinfo)"
                [[ -z "$cpu" ]] && cpu="$(awk -F':' '/family/ {printf $2; exit}' /proc/cpuinfo)"
                ;;
            *)
                cpu="$(awk -F'\\s*: | @' \
                    '/model name|Hardware|Processor|^cpu model|chip type|^cpu type/ {
                        cpu=$2; if ($1 == "Hardware") exit } END { print cpu }' /proc/cpuinfo)"
                ;;
        esac
        cpu="${cpu//(TM)}"; cpu="${cpu//(tm)}"
        cpu="${cpu//(R)}";  cpu="${cpu//(r)}"
        cpu="${cpu//CPU}";  cpu="${cpu//Processor}"
        cpu="${cpu//Dual-Core}"; cpu="${cpu//Quad-Core}"
        cpu="${cpu//Six-Core}";  cpu="${cpu//Eight-Core}"
        cpu="${cpu//[1-9][0-9]-Core}"; cpu="${cpu//[0-9]-Core}"
        cpu="${cpu//Core2/Core 2}"
        echo "${cpu}" | xargs
        ;;
    darwin)
        sysctl -n machdep.cpu.brand_string
        ;;
    freebsd|openbsd|netbsd)
        sysctl -n hw.model 2>/dev/null | sed 's/[0-9]\..*//' | sed 's/ @.*//' | xargs
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

hardware::cpu::core_count::physical() {
    case "$(runtime::os)" in
    linux|wsl|cygwin|mingw)
        case "$(uname -m)" in
            "sparc"*)
                lscpu 2>/dev/null | awk -F': *' '
                    /^Core\(s\) per socket/ { cores=$2 }
                    /^Socket\(s\)/          { sockets=$2 }
                    END { print cores * sockets }'
                ;;
            *)
                awk '/^core id/&&!a[$0]++{++i} END {print i}' /proc/cpuinfo
                ;;
        esac
        ;;
    darwin)
        sysctl -n hw.physicalcpu
        ;;
    freebsd|openbsd|netbsd)
        sysctl -n hw.ncpu 2>/dev/null || echo "unknown"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

hardware::cpu::core_count::logical() {
    case "$(runtime::os)" in
    linux|wsl|cygwin|mingw)
        case "$(uname -m)" in
            "sparc"*)
                lscpu 2>/dev/null | awk -F': *' '/^CPU\(s\)/ {print $2}'
                ;;
            *)
                grep -c '^processor' /proc/cpuinfo
                ;;
        esac
        ;;
    darwin)
        sysctl -n hw.logicalcpu
        ;;
    freebsd|openbsd|netbsd)
        sysctl -n hw.ncpu 2>/dev/null || echo "unknown"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

hardware::cpu::core_count::total() {
    hardware::cpu::core_count::logical
}

hardware::cpu::thread_count() {
    hardware::cpu::core_count::logical
}

hardware::cpu::frequencyMHz() {
    case "$(runtime::os)" in
    linux|wsl|cygwin|mingw)
        local speed_dir="/sys/devices/system/cpu/cpu0/cpufreq"
        # /sys/ only exists on Linux/WSL — cygwin/mingw fall through to /proc/cpuinfo
        if [[ -d "$speed_dir" ]]; then
            local speed
            speed="$(cat "${speed_dir}/scaling_cur_freq" 2>/dev/null)" ||
            speed="$(cat "${speed_dir}/bios_limit" 2>/dev/null)" ||
            speed="$(cat "${speed_dir}/scaling_max_freq" 2>/dev/null)" ||
            speed="$(cat "${speed_dir}/cpuinfo_max_freq" 2>/dev/null)"
            echo "$((speed / 1000))"
        else
            case "$(uname -m)" in
                "sparc"*)
                    echo "$(( $(cat /sys/devices/system/cpu/cpu0/clock_tick 2>/dev/null) / 1000000 ))"
                    ;;
                *)
                    awk -F': |\\.' '/cpu MHz|^clock/ {printf $2; exit}' /proc/cpuinfo \
                        | sed 's/MHz//' | xargs
                    ;;
            esac
        fi
        ;;
    darwin)
        sysctl -n hw.cpufrequency 2>/dev/null \
            | awk '{ printf "%d\n", $1/1000000 }' || echo "unknown"
        ;;
    freebsd|openbsd|netbsd)
        sysctl -n hw.cpuspeed 2>/dev/null \
            || sysctl -n hw.clockrate 2>/dev/null \
            || echo "unknown"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

hardware::cpu::temp() {
    case "$(runtime::os)" in
    linux|wsl)
        local temp_dir
        for dir in /sys/class/hwmon/*; do
            [[ -f "${dir}/name" ]] || continue
            if [[ "$(< "${dir}/name")" =~ (cpu_thermal|coretemp|fam15h_power|k10temp) ]]; then
                local inputs=("${dir}"/temp*_input)
                temp_dir="${inputs[0]}"
                break
            fi
        done
        if [[ -f "$temp_dir" ]]; then
            awk '{ printf "%.1f\n", $1/1000 }' "$temp_dir"
        else
            echo "unknown"
        fi
        ;;
    darwin)
        # No native CLI — would need osx-cpu-temp or similar
        echo "unknown"
        ;;
    freebsd|dragonfly)
        sysctl -n dev.cpu.0.temperature 2>/dev/null | tr -d 'C' || echo "unknown"
        ;;
    openbsd|netbsd)
        sysctl hw.sensors 2>/dev/null | \
            awk -F'=|degC' '/(ksmn|adt|lm|cpu)0.temp0/ {printf("%.1f\n", $2); exit}' \
            || echo "unknown"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

# ==============================================================================
# GPU
# ==============================================================================

hardware::gpu() {
    case "$(runtime::os)" in
        linux|wsl|cygwin|mingw)
            if runtime::has_command nvidia-smi; then
                nvidia-smi -q 2>/dev/null | awk -F': ' '/Product Name/ { print $2; exit }' | xargs
            elif runtime::has_command lspci; then
                lspci -mm 2>/dev/null | awk -F'"' \
                    '/VGA|3D|Display/ { print $6 }' | head -1 | xargs
            elif runtime::has_command glxinfo; then
                glxinfo 2>/dev/null | awk -F': ' \
                    '/OpenGL renderer string/ { print $2 }' | head -1 | xargs
            else
                echo "unknown"
            fi
            ;;
    darwin)
        system_profiler SPDisplaysDataType 2>/dev/null \
            | awk -F': ' '/Chipset Model/ { printf $2", " }' \
            | sed 's/, $//' | xargs
        ;;
    freebsd|dragonfly)
        pciconf -lv 2>/dev/null \
            | grep -A4 'VGA' \
            | awk -F'=' '/device/ { gsub(/"/, "", $2); print $2 }' \
            | head -1 | xargs
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

hardware::gpu::vramMB() {
    case "$(runtime::os)" in
    linux|wsl|cygwin|mingw)
        if runtime::has_command nvidia-smi; then
            nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1
        elif runtime::has_command lspci; then
            lspci -v 2>/dev/null \
                | grep -A12 'VGA' \
                | grep 'prefetchable' \
                | grep -oE '[0-9]+M' | head -1 | tr -d 'M'
        else
            echo "unknown"
        fi
        ;;
    darwin)
        system_profiler SPDisplaysDataType 2>/dev/null \
            | awk '/VRAM/ { gsub(/[^0-9]/,"",$NF); print $NF }' | head -1 \
            || echo "unknown"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

# ==============================================================================
# RAM
# ==============================================================================

hardware::ram::totalSpaceMB() {
    case "$(runtime::os)" in
    linux|wsl|cygwin|mingw)
        awk '/MemTotal/ { printf "%d\n", $2/1024 }' /proc/meminfo
        ;;
    darwin)
        sysctl -n hw.memsize | awk '{ printf "%d\n", $1/1024/1024 }'
        ;;
    freebsd|dragonfly)
        sysctl -n hw.physmem 2>/dev/null | awk '{ printf "%d\n", $1/1024/1024 }'
        ;;
    netbsd)
        sysctl -n hw.physmem64 2>/dev/null | awk '{ printf "%d\n", $1/1024/1024 }'
        ;;
    openbsd)
        sysctl -n hw.physmem 2>/dev/null | awk '{ printf "%d\n", $1/1024/1024 }'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

hardware::ram::usedSpaceMB() {
    case "$(runtime::os)" in
    linux|wsl|cygwin|mingw)
        # MemUsed = MemTotal + Shmem - MemFree - Buffers - Cached - SReclaimable
        # Uses MemAvailable when present (Linux 3.14+) for better accuracy
        awk '
            /MemTotal/     { total=$2 }
            /Shmem/        { shmem=$2 }
            /MemFree/      { free=$2 }
            /Buffers/      { buffers=$2 }
            /^Cached/      { cached=$2 }
            /SReclaimable/ { sreclaimable=$2 }
            /MemAvailable/ { avail=$2 }
            END {
                if (avail) {
                    printf "%d\n", (total - avail) / 1024
                } else {
                    printf "%d\n", (total + shmem - free - buffers - cached - sreclaimable) / 1024
                }
            }' /proc/meminfo
        ;;
    darwin)
        local hw_pagesize pages_app pages_wired pages_compressed
        hw_pagesize="$(sysctl -n hw.pagesize)"
        pages_app=$(( $(sysctl -n vm.page_pageable_internal_count) - $(sysctl -n vm.page_purgeable_count) ))
        pages_wired="$(vm_stat | awk '/ wired/ { gsub(/\./, "", $4); print $4 }')"
        pages_compressed="$(vm_stat | awk '/ occupied/ { gsub(/\./, "", $5); print $5 }')"
        pages_compressed="${pages_compressed:-0}"
        echo "$(( (pages_app + pages_wired + pages_compressed) * hw_pagesize / 1024 / 1024 ))"
        ;;
    freebsd|dragonfly)
        local hw_pagesize mem_inactive mem_unused mem_cache mem_free mem_total
        hw_pagesize="$(sysctl -n hw.pagesize)"
        mem_inactive=$(( $(sysctl -n vm.stats.vm.v_inactive_count) * hw_pagesize ))
        mem_unused=$(( $(sysctl -n vm.stats.vm.v_free_count) * hw_pagesize ))
        mem_cache=$(( $(sysctl -n vm.stats.vm.v_cache_count) * hw_pagesize ))
        mem_free=$(( (mem_inactive + mem_unused + mem_cache) / 1024 / 1024 ))
        mem_total=$(hardware::ram::totalSpaceMB)
        echo $(( mem_total - mem_free ))
        ;;
    openbsd)
        vmstat | awk 'END { printf $3 }' | tr -d 'M'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

hardware::ram::freeSpaceMB() {
    case "$(runtime::os)" in
    linux|wsl|cygwin|mingw)
        awk '/MemAvailable/ { printf "%d\n", $2/1024 }' /proc/meminfo
        ;;
    darwin)
        local hw_pagesize pages_free
        hw_pagesize="$(sysctl -n hw.pagesize)"
        pages_free="$(vm_stat | awk '/Pages free/ { gsub(/\./, "", $3); print $3 }')"
        echo $(( pages_free * hw_pagesize / 1024 / 1024 ))
        ;;
    freebsd|dragonfly|openbsd|netbsd)
        local total used
        total=$(hardware::ram::totalSpaceMB)
        used=$(hardware::ram::usedSpaceMB)
        echo $(( total - used ))
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

hardware::ram::percentage() {
    local used total
    used=$(hardware::ram::usedSpaceMB)
    total=$(hardware::ram::totalSpaceMB)
    [[ "$used" == "unknown" || "$total" == "unknown" ]] && echo "unknown" && return
    awk "BEGIN { printf \"%.1f\n\", ($used / $total) * 100 }"
}

# ==============================================================================
# DISK
# ==============================================================================

hardware::disk::devices() {
    case "$(runtime::os)" in
    linux|wsl)
        lsblk -dno NAME 2>/dev/null | grep -v '^loop' | tr '\n' ' ' | xargs
        ;;
    darwin)
        diskutil list 2>/dev/null | awk '/^\/dev\/disk/ { print $1 }' | tr '\n' ' ' | xargs
        ;;
    freebsd|dragonfly|openbsd|netbsd)
        sysctl -n kern.disks 2>/dev/null | tr ' ' '\n' | grep -v '^$' | tr '\n' ' ' | xargs
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

hardware::disk::count::total() {
    case "$(runtime::os)" in
    linux|wsl)
        lsblk -dno NAME 2>/dev/null | grep -cv '^loop' | xargs
        ;;
    darwin)
        diskutil list 2>/dev/null | grep -c '^/dev/disk'
        ;;
    *)
        hardware::disk::devices | wc -w | xargs
        ;;
    esac
}

hardware::disk::count::physical() {
    case "$(runtime::os)" in
    linux|wsl)
        lsblk -dno NAME,TYPE 2>/dev/null | awk '/disk/ && !/loop/' | wc -l | xargs
        ;;
    darwin)
        diskutil list physical 2>/dev/null | grep -c '^/dev/disk'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

hardware::disk::count::virtual() {
    case "$(runtime::os)" in
    linux|wsl)
        lsblk -dno NAME,TYPE 2>/dev/null | grep -c 'loop\|ram'
        ;;
    darwin)
        diskutil list 2>/dev/null | grep -c 'virtual'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

hardware::disk::name() {
    case "$(runtime::os)" in
    linux|wsl)
        lsblk -dno MODEL 2>/dev/null | grep -v '^$' | head -1 | xargs
        ;;
    darwin)
        diskutil info disk0 2>/dev/null \
            | awk -F': +' '/Device \/ Media Name/ { print $2 }' | xargs
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

# ==============================================================================
# PARTITIONS
# df flags vary per OS/version — detect them like neofetch does
# ==============================================================================

_hardware::df_flags() {
    local df_version
    df_version=$(df --version 2>&1)
    case "$df_version" in
        *IMitv*)   echo "-P -g" ;;  # AIX
        *befhikm*) echo "-P -k" ;;  # IRIX
        *hiklnP*)  echo "-h"    ;;  # OpenBSD
        *)         echo "-P -h" ;;  # Linux, macOS, Cygwin, MinGW, etc.
    esac
}

hardware::partition::count() {
    case "$(runtime::os)" in
    linux|wsl)
        lsblk -no NAME 2>/dev/null | grep -cv '^loop' | xargs
        ;;
    darwin)
        diskutil list 2>/dev/null | grep -c '^\s*[0-9]'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

# Returns human-readable disk info for a mount point (default: /)
# Usage: hardware::partition::info [mountpoint]
hardware::partition::info() {
    local mount="${1:-/}"
    runtime::has_command df || { echo "unknown"; return 1; }

    local -a flags
    read -ra flags <<< "$(_hardware::df_flags)"

    local -a disks
    IFS=$'\n' read -d "" -ra disks <<< "$(df "${flags[@]}" "$mount" 2>/dev/null)"
    unset "disks[0]"

    [[ ${disks[*]} ]] || { echo "unknown"; return 1; }

    local -a disk_info
    IFS=" " read -ra disk_info <<< "${disks[0]}"
    local used="${disk_info[${#disk_info[@]} - 4]}"
    local total="${disk_info[${#disk_info[@]} - 5]}"
    local perc="${disk_info[${#disk_info[@]} - 2]/\%}"
    echo "${used} / ${total} (${perc}%)"
}

hardware::partition::totalSpaceMB() {
    local device="${1:-/}"
    df -BM "$device" 2>/dev/null | awk 'NR==2 { gsub(/M/,"",$2); print $2 }'
}

hardware::partition::usedSpaceMB() {
    local device="${1:-/}"
    df -BM "$device" 2>/dev/null | awk 'NR==2 { gsub(/M/,"",$3); print $3 }'
}

hardware::partition::freeSpaceMB() {
    local device="${1:-/}"
    df -BM "$device" 2>/dev/null | awk 'NR==2 { gsub(/M/,"",$4); print $4 }'
}

hardware::partition::usagePercent() {
    local device="${1:-/}"
    df "$device" 2>/dev/null | awk 'NR==2 { gsub(/%/,"",$5); print $5 }'
}

# ==============================================================================
# SWAP
# ==============================================================================

hardware::swap::totalSpaceMB() {
    case "$(runtime::os)" in
    linux|wsl|cygwin|mingw)
        awk '/SwapTotal/ { printf "%d\n", $2/1024 }' /proc/meminfo
        ;;
    darwin)
        sysctl -n vm.swapusage 2>/dev/null | awk '{ gsub(/M/,"",$3); print $3 }'
        ;;
    freebsd|dragonfly)
        swapinfo -k 2>/dev/null | awk 'NR>1 { total+=$2 } END { printf "%d\n", total/1024 }'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

hardware::swap::usedSpaceMB() {
    case "$(runtime::os)" in
    linux|wsl|cygwin|mingw)
        awk '/SwapTotal/ { total=$2 } /SwapFree/ { free=$2 }
             END { printf "%d\n", (total-free)/1024 }' /proc/meminfo
        ;;
    darwin)
        sysctl -n vm.swapusage 2>/dev/null | awk '{ gsub(/M/,"",$6); print $6 }'
        ;;
    freebsd|dragonfly)
        swapinfo -k 2>/dev/null | awk 'NR>1 { used+=$3 } END { printf "%d\n", used/1024 }'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

hardware::swap::freeSpaceMB() {
    case "$(runtime::os)" in
    linux|wsl|cygwin|mingw)
        awk '/SwapFree/ { printf "%d\n", $2/1024 }' /proc/meminfo
        ;;
    darwin)
        sysctl -n vm.swapusage 2>/dev/null | awk '{ gsub(/M/,"",$9); print $9 }'
        ;;
    freebsd|dragonfly)
        local total used
        total=$(hardware::swap::totalSpaceMB)
        used=$(hardware::swap::usedSpaceMB)
        echo $(( total - used ))
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

# ==============================================================================
# BATTERY
# Uses dynamic discovery of BAT*, axp288_fuel_gauge, CMB* (tablets/embedded)
# ==============================================================================

_hardware::battery::find_bat() {
    # neofetch covers BAT*, axp288_fuel_gauge, and CMB* (embedded/tablet devices)
    for bat in "/sys/class/power_supply/"{BAT,axp288_fuel_gauge,CMB}*; do
        [[ -f "${bat}/capacity" ]] && echo "$bat" && return
    done
}

hardware::battery::present() {
    case "$(runtime::os)" in
    linux|wsl)
        [[ -n "$(_hardware::battery::find_bat)" ]]
        ;;
    darwin)
        system_profiler SPPowerDataType 2>/dev/null | grep -q 'Battery'
        ;;
    freebsd|dragonfly)
        sysctl -n hw.acpi.battery.life 2>/dev/null | grep -qv '^$'
        ;;
    cygwin|mingw)
        wmic Path Win32_Battery get EstimatedChargeRemaining 2>/dev/null \
            | grep -qv '^EstimatedChargeRemaining'
        ;;
    *)
        return 1
        ;;
    esac
}

hardware::battery::percentage() {
    case "$(runtime::os)" in
    linux|wsl)
        local bat
        bat=$(_hardware::battery::find_bat)
        [[ -z "$bat" ]] && echo "unknown" && return
        cat "${bat}/capacity" 2>/dev/null || echo "unknown"
        ;;
    darwin)
        pmset -g batt 2>/dev/null | grep -oE '[0-9]+%' | tr -d '%' | head -1 || echo "unknown"
        ;;
    freebsd|dragonfly)
        acpiconf -i 0 2>/dev/null \
            | awk -F ':\t' '/Remaining capacity/ {print $2}' \
            | tr -d '%' || echo "unknown"
        ;;
    netbsd)
        envstat 2>/dev/null | awk '/charge:/ {print $2}' | cut -d. -f1 || echo "unknown"
        ;;
    openbsd)
        local full now
        full="$(sysctl -n hw.sensors.acpibat0.watthour0 hw.sensors.acpibat0.amphour0 2>/dev/null)"
        full="${full%% *}"
        now="$(sysctl -n hw.sensors.acpibat0.watthour3 hw.sensors.acpibat0.amphour3 2>/dev/null)"
        now="${now%% *}"
        [[ -z "$full" || -z "$now" ]] && echo "unknown" && return
        echo "$(( 100 * ${now/\.} / ${full/\.} ))"
        ;;
    cygwin|mingw)
        local val
        val="$(wmic Path Win32_Battery get EstimatedChargeRemaining 2>/dev/null \
            | grep -v 'EstimatedChargeRemaining' | tr -d '[:space:]')"
        [[ -n "$val" ]] && echo "$val" || echo "unknown"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

hardware::battery::is_charging() {
    case "$(runtime::os)" in
    linux|wsl)
        local bat
        bat=$(_hardware::battery::find_bat)
        [[ -z "$bat" ]] && return 1
        [[ "$(cat "${bat}/status" 2>/dev/null)" == "Charging" ]]
        ;;
    darwin)
        pmset -g batt 2>/dev/null | grep -q 'AC Power'
        ;;
    freebsd|dragonfly)
        sysctl -n hw.acpi.acline 2>/dev/null | grep -q '^1$'
        ;;
    openbsd)
        local state
        state="$(sysctl -n hw.sensors.acpibat0.raw0 2>/dev/null)"
        state="${state##? (battery }"
        state="${state%)*}"
        [[ "$state" == "charging" ]]
        ;;
    cygwin|mingw)
        local state
        state="$(wmic /NameSpace:'\\root\WMI' Path BatteryStatus get Charging 2>/dev/null)"
        [[ "$state" == *TRUE* ]]
        ;;
    *)
        return 1
        ;;
    esac
}

hardware::battery::status() {
    case "$(runtime::os)" in
    linux|wsl)
        local bat
        bat=$(_hardware::battery::find_bat)
        [[ -z "$bat" ]] && echo "unknown" && return
        cat "${bat}/status" 2>/dev/null || echo "unknown"
        ;;
    darwin)
        local state
        state="$(pmset -g batt 2>/dev/null | awk '/;/ {print $4}')"
        [[ "$state" == "charging;" ]] && echo "Charging" || echo "Discharging"
        ;;
    freebsd|dragonfly)
        local acline state
        acline=$(sysctl -n hw.acpi.acline 2>/dev/null)
        state=$(sysctl -n hw.acpi.battery.state 2>/dev/null)
        if [[ "$acline" == "1" && "$state" == "0" ]]; then echo "Full"
        elif [[ "$acline" == "1" ]]; then echo "Charging"
        else echo "Discharging"
        fi
        ;;
    openbsd)
        local state
        state="$(sysctl -n hw.sensors.acpibat0.raw0 2>/dev/null)"
        state="${state##? (battery }"
        state="${state%)*}"
        echo "${state^}"  # capitalise first letter
        ;;
    cygwin|mingw)
        hardware::battery::is_charging && echo "Charging" || echo "Discharging"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

hardware::battery::time_remaining() {
    case "$(runtime::os)" in
    linux|wsl)
        local bat
        bat=$(_hardware::battery::find_bat)
        [[ -z "$bat" ]] && echo "unknown" && return
        if runtime::has_command upower; then
            upower -i "$(upower -e 2>/dev/null | grep battery | head -1)" 2>/dev/null \
                | awk '/time to empty/ { print $4, $5 }' || echo "unknown"
        else
            cat "${bat}/time_to_empty_now" 2>/dev/null || echo "unknown"
        fi
        ;;
    darwin)
        pmset -g batt 2>/dev/null | grep -oE '[0-9]+:[0-9]+ remaining' | head -1 || echo "unknown"
        ;;
    freebsd|dragonfly)
        sysctl -n hw.acpi.battery.time 2>/dev/null || echo "unknown"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

hardware::battery::capacity() {
    case "$(runtime::os)" in
    linux|wsl)
        local bat
        bat=$(_hardware::battery::find_bat)
        [[ -z "$bat" ]] && echo "unknown" && return
        cat "${bat}/charge_full_design" 2>/dev/null \
            || cat "${bat}/energy_full_design" 2>/dev/null \
            || echo "unknown"
        ;;
    darwin)
        system_profiler SPPowerDataType 2>/dev/null \
            | awk -F': ' '/Full Charge Capacity/ { print $2 }' || echo "unknown"
        ;;
    freebsd|dragonfly)
        sysctl -n hw.acpi.battery.capacity 2>/dev/null || echo "unknown"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

hardware::battery::health() {
    case "$(runtime::os)" in
    linux|wsl)
        local bat full design
        bat=$(_hardware::battery::find_bat)
        [[ -z "$bat" ]] && echo "unknown" && return
        full=$(cat "${bat}/charge_full" 2>/dev/null || cat "${bat}/energy_full" 2>/dev/null)
        design=$(cat "${bat}/charge_full_design" 2>/dev/null || cat "${bat}/energy_full_design" 2>/dev/null)
        [[ -z "$full" || -z "$design" ]] && echo "unknown" && return
        awk "BEGIN { printf \"%.1f\n\", ($full / $design) * 100 }"
        ;;
    darwin)
        system_profiler SPPowerDataType 2>/dev/null \
            | awk -F': ' '/Condition/ { print $2 }' || echo "unknown"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
# hash.sh — bash-frameheader hashing lib
# Hashing of strings and data. For file checksums see fs::checksum::*.
#
# CRYPTOGRAPHIC NOTE: md5 and sha1 are included for completeness and
# non-security uses (checksums, caching keys, deduplication). Do not
# use them for password hashing or security-sensitive applications.
# Use sha256 or sha512 for anything security-adjacent.

# ==============================================================================
# INTERNAL HELPERS
# ==============================================================================

# Feed a string to a hash command portably
# Usage: _hash::pipe string command [args...]
#        echo "string" | _hash::pipe "" command [args...]
_hash::pipe() {
  local s="$1"; shift
  if [[ -z "$s" && ! -t 0 ]]; then
    cat | "$@"
  else
    printf '%s' "$s" | "$@"
  fi
}

# Internal: read primary input from arg or stdin
_hash::read_input() {
  local -n _hash_read_result="$1"
  if [[ $# -ge 2 ]]; then
    _hash_read_result="$2"
  elif [[ ! -t 0 ]]; then
    _hash_read_result=$(cat)
  else
    _hash_read_result=""
  fi
}

# ==============================================================================
# CRYPTOGRAPHIC
# ==============================================================================

# MD5 hash of a string
# Usage: hash::md5 string
hash::md5() {
  local input; _hash::read_input input "$@"
    if runtime::has_command md5sum; then
        _hash::pipe "$input" md5sum | awk '{print $1}'
    elif runtime::has_command md5; then
        _hash::pipe "$input" md5 -q 2>/dev/null || \
        _hash::pipe "$input" md5 | awk '{print $NF}'
    else
        echo "hash::md5: requires md5sum or md5" >&2
        return 1
    fi
}

# SHA1 hash of a string
hash::sha1() {
  local input; _hash::read_input input "$@"
    if runtime::has_command sha1sum; then
        _hash::pipe "$input" sha1sum | awk '{print $1}'
    elif runtime::has_command shasum; then
        _hash::pipe "$input" shasum -a 1 | awk '{print $1}'
    elif runtime::has_command openssl; then
        _hash::pipe "$input" openssl dgst -sha1 | awk '{print $NF}'
    else
        echo "hash::sha1: requires sha1sum, shasum, or openssl" >&2
        return 1
    fi
}

# SHA256 hash of a string
hash::sha256() {
  local input; _hash::read_input input "$@"
    if runtime::has_command sha256sum; then
        _hash::pipe "$input" sha256sum | awk '{print $1}'
    elif runtime::has_command shasum; then
        _hash::pipe "$input" shasum -a 256 | awk '{print $1}'
    elif runtime::has_command openssl; then
        _hash::pipe "$input" openssl dgst -sha256 | awk '{print $NF}'
    else
        echo "hash::sha256: requires sha256sum, shasum, or openssl" >&2
        return 1
    fi
}

# SHA512 hash of a string
hash::sha512() {
  local input; _hash::read_input input "$@"
    if runtime::has_command sha512sum; then
        _hash::pipe "$input" sha512sum | awk '{print $1}'
    elif runtime::has_command shasum; then
        _hash::pipe "$input" shasum -a 512 | awk '{print $1}'
    elif runtime::has_command openssl; then
        _hash::pipe "$input" openssl dgst -sha512 | awk '{print $NF}'
    else
        echo "hash::sha512: requires sha512sum, shasum, or openssl" >&2
        return 1
    fi
}

# SHA3-256 hash of a string
hash::sha3_256() {
  local input; _hash::read_input input "$@"
    if runtime::has_command openssl; then
        _hash::pipe "$input" openssl dgst -sha3-256 2>/dev/null | awk '{print $NF}'
    else
        echo "hash::sha3_256: requires openssl with sha3 support" >&2
        return 1
    fi
}

# BLAKE2b hash of a string
hash::blake2b() {
  local input; _hash::read_input input "$@"
    if runtime::has_command b2sum; then
        _hash::pipe "$input" b2sum | awk '{print $1}'
    elif runtime::has_command openssl; then
        _hash::pipe "$input" openssl dgst -blake2b512 2>/dev/null | awk '{print $NF}'
    else
        echo "hash::blake2b: requires b2sum or openssl" >&2
        return 1
    fi
}

# ==============================================================================
# HMAC
# ==============================================================================

# HMAC-SHA256
# Usage: hash::hmac::sha256 key message
hash::hmac::sha256() {
    local key="$1" msg="$2"
    if runtime::has_command openssl; then
        printf '%s' "$msg" | \
            openssl dgst -sha256 -hmac "$key" 2>/dev/null | awk '{print $NF}'
    else
        echo "hash::hmac::sha256: requires openssl" >&2
        return 1
    fi
}

# HMAC-SHA512
# Usage: hash::hmac::sha512 key message
hash::hmac::sha512() {
    local key="$1" msg="$2"
    if runtime::has_command openssl; then
        printf '%s' "$msg" | \
            openssl dgst -sha512 -hmac "$key" 2>/dev/null | awk '{print $NF}'
    else
        echo "hash::hmac::sha512: requires openssl" >&2
        return 1
    fi
}

# HMAC-MD5
# Usage: hash::hmac::md5 key message
hash::hmac::md5() {
    local key="$1" msg="$2"
    if runtime::has_command openssl; then
        printf '%s' "$msg" | \
            openssl dgst -md5 -hmac "$key" 2>/dev/null | awk '{print $NF}'
    else
        echo "hash::hmac::md5: requires openssl" >&2
        return 1
    fi
}

# ==============================================================================
# NON-CRYPTOGRAPHIC — pure bash implementations
# Fast, portable, suitable for hash tables, caching keys, bloom filters.
# NOT suitable for security use.
# ==============================================================================

# DJB2 — Daniel J. Bernstein's hash, classic and fast
# Returns unsigned 32-bit integer
# Usage: hash::djb2 string
hash::djb2() {
  local input; _hash::read_input input "$@"
    local s="$input" hash=5381 i char
    for (( i=0; i<${#s}; i++ )); do
        char=$(printf '%d' "'${s:$i:1}")
        hash=$(( ((hash << 5) + hash + char) & 0xFFFFFFFF ))
    done
    echo "$hash"
}

# DJB2a (xor variant) — slightly better distribution than djb2
hash::djb2a() {
  local input; _hash::read_input input "$@"
    local s="$input" hash=5381 i char
    for (( i=0; i<${#s}; i++ )); do
        char=$(printf '%d' "'${s:$i:1}")
        hash=$(( ((hash << 5) + hash ^ char) & 0xFFFFFFFF ))
    done
    echo "$hash"
}

# SDBM hash — used in the SDBM database library
# Often outperforms DJB2 for database keys
hash::sdbm() {
  local input; _hash::read_input input "$@"
    local s="$input" hash=0 i char
    for (( i=0; i<${#s}; i++ )); do
        char=$(printf '%d' "'${s:$i:1}")
        hash=$(( (char + (hash << 6) + (hash << 16) - hash) & 0xFFFFFFFF ))
    done
    echo "$hash"
}

# FNV-1a 32-bit — Fowler-Noll-Vo, excellent avalanche, widely used
# Period: 2^32
hash::fnv1a32() {
  local input; _hash::read_input input "$@"
    local s="$input" hash=2166136261 i char
    for (( i=0; i<${#s}; i++ )); do
        char=$(printf '%d' "'${s:$i:1}")
        hash=$(( (hash ^ char) * 16777619 & 0xFFFFFFFF ))
    done
    echo "$hash"
}

# FNV-1a 64-bit — larger state, better for longer strings
# Note: bash uses signed 64-bit integers; result may be negative for large hashes
hash::fnv1a64() {
  local input; _hash::read_input input "$@"
    local s="$input"
    local hash_lo=2166136261 hash_hi=0
    local fnv_prime_lo=16777619 i char

    for (( i=0; i<${#s}; i++ )); do
        char=$(printf '%d' "'${s:$i:1}")
        # XOR low 32 bits with byte
        hash_lo=$(( (hash_lo ^ char) & 0xFFFFFFFF ))
        # Multiply: (hi:lo) * prime — simplified since prime fits in 32 bits
        local new_lo=$(( (hash_lo * fnv_prime_lo) & 0xFFFFFFFF ))
        local carry=$(( hash_lo * fnv_prime_lo >> 32 ))
        hash_hi=$(( (hash_hi * fnv_prime_lo + carry) & 0xFFFFFFFF ))
        hash_lo=$new_lo
    done

    printf '%08x%08x\n' "$hash_hi" "$hash_lo"
}

# Adler-32 — fast checksum used in zlib/PNG
# Not a hash in the traditional sense but useful for data integrity
hash::adler32() {
  local input; _hash::read_input input "$@"
    local s="$input"
    local a=1 b=0 i char MOD=65521

    for (( i=0; i<${#s}; i++ )); do
        char=$(printf '%d' "'${s:$i:1}")
        a=$(( (a + char) % MOD ))
        b=$(( (b + a) % MOD ))
    done

    echo $(( (b << 16) | a ))
}

# CRC32 — delegates to system tools, pure bash fallback is too slow for real use
# Usage: hash::crc32 string
hash::crc32() {
  local input; _hash::read_input input "$@"
    local s="$input"
    if runtime::has_command crc32; then
        printf '%s' "$s" | crc32 /dev/stdin 2>/dev/null
    elif runtime::has_command python3; then
        python3 -c "import binascii,sys; print('%08x' % (binascii.crc32(sys.argv[1].encode()) & 0xffffffff))" "$s"
    elif runtime::has_command cksum; then
        # cksum uses CRC but with a different algorithm — close but not standard CRC32
        printf '%s' "$s" | cksum | awk '{print $1}'
    else
        echo "hash::crc32: requires crc32, python3, or cksum" >&2
        return 1
    fi
}

# MurmurHash2 — pure bash, good distribution, faster than cryptographic hashes
# Austin Appleby, 2008
hash::murmur2() {
  local input; _hash::read_input input "$@"
    local s="$input" seed="${2:-0}"
    local len="${#s}"
    local m=2246822519 r=13
    local h=$(( seed ^ len ))
    local i=0 k

    while (( i + 4 <= len )); do
        local c0; c0=$(printf '%d' "'${s:$i:1}")
        local c1; c1=$(printf '%d' "'${s:$((i+1)):1}")
        local c2; c2=$(printf '%d' "'${s:$((i+2)):1}")
        local c3; c3=$(printf '%d' "'${s:$((i+3)):1}")
        k=$(( c0 | (c1 << 8) | (c2 << 16) | (c3 << 24) ))
        k=$(( (k * m) & 0xFFFFFFFF ))
        k=$(( k ^ (k >> r) ))
        k=$(( (k * m) & 0xFFFFFFFF ))
        h=$(( (h * m) & 0xFFFFFFFF ))
        h=$(( (h ^ k) & 0xFFFFFFFF ))
        (( i += 4 ))
    done

    # Handle remaining bytes
    local remaining=$(( len - i ))
    case "$remaining" in
    3) h=$(( h ^ ($(printf '%d' "'${s:$((i+2)):1}") << 16) )) ;&
    2) h=$(( h ^ ($(printf '%d' "'${s:$((i+1)):1}") << 8)  )) ;&
    1) h=$(( h ^ $(printf '%d' "'${s:$i:1}") ))
       h=$(( (h * m) & 0xFFFFFFFF ))
       ;;
    esac

    h=$(( h ^ (h >> 13) ))
    h=$(( (h * m) & 0xFFFFFFFF ))
    h=$(( h ^ (h >> 15) ))

    echo "$h"
}

# ==============================================================================
# UTILITY
# ==============================================================================

# Verify a string against a known hash
# Usage: hash::verify string expected_hash algorithm
# Example: hash::verify "hello" "2cf24dba..." sha256
hash::verify() {
    local s="$1" expected="$2" algo="${3:-sha256}"
    local actual
    actual=$(hash::"$algo" "$s" 2>/dev/null) || return 1
    [[ "$actual" == "$expected" ]]
}

# Consistent hashing — map a value to a bucket (0 to n-1)
# Useful for load balancing, sharding, cache partitioning
# Usage: hash::slot n_buckets value
hash::slot() {
    local n="$1" value="$2"
    local h
    h=$(hash::fnv1a32 "$value")
    echo $(( h % n ))
}

# Generate a short hash — first n chars of sha256
# Usage: hash::short string [length]
hash::short() {
  local input; _hash::read_input input "$@"
    local s="$input" len="${2:-8}"
    local full
    full=$(hash::sha256 "$s") || return 1
    echo "${full:0:$len}"
}

# Hash multiple values into one — useful for cache keys from multiple inputs
# Usage: hash::combine val1 val2 val3 ...
hash::combine() {
    local combined
    combined=$(printf '%s\0' "$@" | hash::sha256 /dev/stdin 2>/dev/null) || \
    combined=$(printf '%s:' "$@" | hash::sha256)
    echo "$combined"
}

# Check if two strings have the same hash (constant-time safe via hash comparison)
# Usage: hash::equal string1 string2 [algorithm]
hash::equal() {
    local h1 h2 algo="${3:-sha256}"
    h1=$(hash::"$algo" "$1" 2>/dev/null) || return 1
    h2=$(hash::"$algo" "$2" 2>/dev/null) || return 1
    [[ "$h1" == "$h2" ]]
}

# Generate a hash-based UUID v5 (name-based, SHA1)
# Usage: hash::uuid5 namespace name
# Namespace can be a UUID or a well-known string
hash::uuid5() {
    # uuidgen doesn't support v5 on all platforms — fall back to sha1-based manual construction
    local raw
    raw=$(hash::sha1 "${1}:${2}")
    printf '%s-%s-%s-%s-%s\n' \
        "${raw:0:8}" "${raw:8:4}" "5${raw:13:3}" \
        "$(printf '%x' $(( (16#${raw:16:2} & 0x3f) | 0x80 )))${raw:18:2}" \
        "${raw:20:12}"
}

# log.sh — bash::framehead logging module
#
# Provides levelled logging with configurable format, output routing,
# and colour support. All behaviour is controlled via environment variables
# so scripts can configure logging without touching function calls.
#
# CONFIGURATION:
#   LOG_FMT          Format string using %token% placeholders
#                    Default: "%datetime% [%severity%] %message%"
#   LOG_FILE         Path to log file. Empty = no file output.
#   LOG_TO_STDOUT    Bitmask controlling which levels go to stdout vs stderr.
#                    Levels not in the mask go to stderr instead.
#                    Use Bash base notation: 2#0011 = debug + info to stdout
#                    bit 0 = debug, bit 1 = info, bit 2 = warn, bit 3 = error
#                    Default: 2#0011 (warn + error → stderr)
#   LOG_COLOUR       1 = enable colour output, 0 = disable. Default: auto-detect.
#
# FORMAT TOKENS:
#   %timestamp%      Unix timestamp (seconds)
#   %datetime%       Human readable: 2025-02-27 14:32:11
#   %severity%       Uppercase: DEBUG, INFO, WARN, ERROR
#   %severity_lower% Lowercase: debug, info, warn, error
#   %message%        The log message
#   %script%         Calling script name ($0)
#   %pid%            Current process ID
#   %line%           Line number of the log call in the calling script
#   %func%           Function name that made the log call
#
# EXAMPLE:
#   LOG_FMT="%datetime% [%severity%] (%func%:%line%) %message%"
#   LOG_FILE="/var/log/myscript.log"
#   LOG_TO_STDOUT=2#1100  # warn + error to stdout, debug + info to stderr
#
#   log::info  "Starting up"
#   log::warn  "Config not found, using defaults"
#   log::error "Failed to connect" 1   # logs then exits 1

# ==============================================================================
# CONSTANTS
# ==============================================================================

readonly LOG_DEBUG=0
readonly LOG_INFO=1
readonly LOG_WARN=2
readonly LOG_ERROR=3

# ANSI colour codes — defined locally, no colour module dependency
readonly _LOG_COLOUR_CYAN='\033[0;36m'
readonly _LOG_COLOUR_GREEN='\033[0;32m'
readonly _LOG_COLOUR_YELLOW='\033[0;33m'
readonly _LOG_COLOUR_RED='\033[0;31m'
readonly _LOG_COLOUR_RESET='\033[0m'

# ==============================================================================
# DEFAULTS
# ==============================================================================

# Initialise config vars if not already set by the caller
log::init() {
    LOG_FMT="${LOG_FMT:-%datetime% [%severity%] %message%}"
    LOG_FILE="${LOG_FILE:-}"
    LOG_TO_STDOUT="${LOG_TO_STDOUT:-2#0011}"
    if [[ -z "${LOG_COLOUR+x}" ]]; then
        # Auto-detect: enable if terminal supports colour
        if [[ -t 1 && "${TERM:-}" != "dumb" && ( -n "${COLORTERM:-}" || "${TERM:-}" == *color* || "${TERM:-}" == *256* ) ]]; then
            LOG_COLOUR=1
        else
            LOG_COLOUR=0
        fi
    fi
}

# ==============================================================================
# INTERNAL
# ==============================================================================

# Strip ANSI escape codes from a string
# Usage: _log::strip_colour string
_log::strip_colour() {
    # shellcheck disable=SC2001
    sed 's/\x1b\[[0-9;]*m//g' <<< "$1"
}

# Format a log line using LOG_FMT token substitution
# Usage: _log::format severity message caller_line caller_func
_log::format() {
    local severity="$1" msg="$2" caller_line="$3" caller_func="$4"
    local fmt="${LOG_FMT}"

    fmt="${fmt//%timestamp%/$(date +%s)}"
    fmt="${fmt//%datetime%/$(date '+%Y-%m-%d %H:%M:%S')}"
    fmt="${fmt//%severity%/$severity}"
    fmt="${fmt//%severity_lower%/${severity,,}}"
    fmt="${fmt//%message%/$msg}"
    fmt="${fmt//%script%/$0}"
    fmt="${fmt//%pid%/$$}"
    fmt="${fmt//%line%/$caller_line}"
    fmt="${fmt//%func%/$caller_func}"

    echo "$fmt"
}

# Apply ANSI colour to a line based on severity
# Usage: _log::colourise severity line
_log::colourise() {
    local severity="$1" line="$2"
    (( LOG_COLOUR )) || { echo "$line"; return; }
    local colour
    case "$severity" in
        DEBUG) colour="$_LOG_COLOUR_CYAN"   ;;
        INFO)  colour="$_LOG_COLOUR_GREEN"  ;;
        WARN)  colour="$_LOG_COLOUR_YELLOW" ;;
        ERROR) colour="$_LOG_COLOUR_RED"    ;;
        *)     echo "$line"; return         ;;
    esac
    printf '%b%s%b\n' "$colour" "$line" "$_LOG_COLOUR_RESET"
}

# Core emit function — format, route, and output a log line
# Usage: _log::emit severity level_bit message caller_line caller_func
_log::emit() {
    local severity="$1" bit="$2" msg="$3" caller_line="$4" caller_func="$5"

    # Ensure defaults are set
    [[ -z "${LOG_FMT+x}" ]] && log::init

    local line
    line=$(_log::format "$severity" "$msg" "$caller_line" "$caller_func")

    local should_stdout=$(( (LOG_TO_STDOUT >> bit) & 1 ))

    if (( should_stdout )); then
        _log::colourise "$severity" "$line" >&1
    else
        _log::colourise "$severity" "$line" >&2
    fi

    if [[ -n "$LOG_FILE" ]]; then
        _log::strip_colour "$line" >> "$LOG_FILE"
    fi
}

# ==============================================================================
# PUBLIC API
# ==============================================================================

# Log a debug message
# Useful for verbose tracing during development — typically suppressed in production
# Usage: log::debug message
# Example:
#   log::debug "processing file: $filename"
log::debug() {
    _log::emit "DEBUG" $LOG_DEBUG "$*" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
}

# Log an informational message
# Usage: log::info message
# Example:
#   log::info "server started on port $port"
log::info() {
    _log::emit "INFO" $LOG_INFO "$*" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
}

# Log a warning message
# Indicates something unexpected but recoverable
# Usage: log::warn message
# Example:
#   log::warn "config not found, using defaults"
log::warn() {
    _log::emit "WARN" $LOG_WARN "$*" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
}

# Log an error message, optionally exiting with a given code
# If a second argument is provided and is an integer, exits with that code after logging
# Usage: log::error message [exit_code]
# Example:
#   log::error "failed to connect to database"
#   log::error "permission denied" 126
log::error() {
    local msg="$1"
    local exit_code="${2:-}"
    _log::emit "ERROR" $LOG_ERROR "$msg" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
    if [[ -n "$exit_code" && "$exit_code" =~ ^-?[0-9]+$ ]]; then
        exit "$exit_code"
    fi
}

# Log an error and always exit, defaulting to exit code 1
# Shorthand for log::error with guaranteed exit
# Usage: log::fatal message [exit_code]
# Example:
#   log::fatal "cannot continue without config file"
#   log::fatal "unsupported OS" 2
log::fatal() {
    log::error "$1" "${2:-1}"
}
# math.sh — bash-frameheader math lib
# Requires: runtime.sh (runtime::has_command)
# shellcheck disable=SC2034,SC2178
#
# Pure bash integer arithmetic where possible.
# Floating point operations require bc — math::bc() checks availability.
# Scale (decimal places) defaults to 10 unless overridden via MATH_SCALE.
#
# ------------------------------------------------------------------------------
# NAMING CONVENTION — f suffix and ::singleton
# ------------------------------------------------------------------------------
# `f` suffix (e.g. clampf, addf):
#   Marks a float variant where the base function is integer-primary.
#   Absence of `f` on a float-native function (sqrt, lerp, sigmoid) signals
#   that the function is already float-only — no int version exists or makes sense.
#   If a function's domain is obviously integer (mod, gcd, factorial), no `f`
#   counterpart is added — the name already implies integer intent.
#   If a function's domain is ambiguous (clamp, abs, min, max), an `f` counterpart
#   exists (even as a redirect) so that absence of `f` elsewhere is unambiguous.
#
# `::singleton` suffix (e.g. math::sigmoid::singleton):
#   Marks a single-value escape hatch for functions that are array-primary by design.
#   Absence of ::singleton means the function naturally accepts scalar args.
#   Presence signals: "the array form is the intended call path; use this sparingly."
# ------------------------------------------------------------------------------

MATH_SCALE="${MATH_SCALE:-10}"

# ==============================================================================
# CONSTANTS
# 42 digits
# Some constants are truncated to 42 digits where available —
# enough for the observable universe with room for Douglas Adams,
# others are given with their commonly known precision.
# ==============================================================================

# Fundamental constants
readonly MATH_PI="3.141592653589793238462643383279502884197169"
readonly MATH_E="2.718281828459045235360287471352662497757237"
readonly MATH_PHI="1.618033988749894848204586834365638117720309"  # Golden ratio
readonly MATH_TAU="6.283185307179586476925286766559005768394338"  # 2π

# Square roots
readonly MATH_SQRT2="1.414213562373095048801688724209698078569671"
readonly MATH_SQRT3="1.732050807568877293527446341505872366942805"
readonly MATH_SQRT5="2.236067977499789696409173668731276235440618"
readonly MATH_SQRT10="3.162277660168379331998893544432718533719555"

# Logarithms
readonly MATH_LN2="0.693147180559945309417232121458176568075500"
readonly MATH_LN10="2.302585092994045684017991454684364207601101"
readonly MATH_LOG2E="1.442695040888963407359924681001892137426645"   # log_2 (e)
readonly MATH_LOG10E="0.434294481903251827651128918916605082294397"  # log_10(e)

# Euler-related
readonly MATH_EULER_MASCHERONI="0.577215664901532860606512090082402431042159" # γ
readonly MATH_CATALAN="0.915965594177219015054603514932384110774149"          # G
readonly MATH_APERY="1.202056903159594285399738161511449990764986"            # ζ(3)

# Trigonometric (in radians)
readonly MATH_DEG_TO_RAD="0.017453292519943295769236907684886127134428"  # π/180
readonly MATH_RAD_TO_DEG="57.29577951308232087679815481410517033240547"  # 180/π

# Special angles (in radians)
readonly MATH_PI_OVER_2="1.570796326794896619231321691639751442098584"  # π/2
readonly MATH_PI_OVER_3="1.047197551196597746154214461093167628065723"  # π/3
readonly MATH_PI_OVER_4="0.785398163397448309615660845819875721049292"  # π/4
readonly MATH_PI_OVER_6="0.523598775598298873077107230546583814032861"  # π/6

# Physics/astronomy constants (SI units)
readonly MATH_SPEED_OF_LIGHT="299792458"                                      # c   @ m/s    (exact)
readonly MATH_GRAVITATIONAL_CONSTANT="0.0000000000667430"                     # G   @ m³ kg⁻^-1 s^-2
readonly MATH_PLANCK_CONSTANT="0.000000000000000000000000000000000662607015"  # h   @ J·s    (exact)
readonly MATH_AVOGADRO_NUMBER="602214076000000000000000"                      # N_A @ mol^-1 (exact)
readonly MATH_BOLTZMANN_CONSTANT="0.00000000000000000000001380649"            # k_B @ J/K    (exact)
readonly MATH_ELEMENTARY_CHARGE="0.0000000000000000001602176634"              # e   @ C      (exact)

# Derived physics constants
readonly MATH_REDUCED_PLANCK_CONSTANT="0.00000000000000000000000000000000010545718"  # ħ = h/2π

# Engineering constants
readonly MATH_EARTH_GRAVITY="9.80665"                # g   @ m/s² (standard gravity)
readonly MATH_STANDARD_ATMOSPHERE="101325"           # atm @ Pa
readonly MATH_STEFAN_BOLTZMANN="0.00000005670374419" # σ   @ W·m⁻²·K⁻⁴

# Number theory
readonly MATH_KHINCHIN="2.685452001065306445309714835481795693820382"           # K₀
readonly MATH_GLAISHER_KINKELIN="1.282427129100622636875342568869791727767688"  # A
readonly MATH_MILLS="1.306377883863080690468614492602605712916784"              # θ
readonly MATH_PLASTIC="1.324717957244746025960908854478097340734404"            # ρ

# Geometry
readonly MATH_SILVER_RATIO="2.414213562373095048801688724209698078569671"  # 1+√2
readonly MATH_BRONZE_RATIO="3.302775637731994646559610633735247973125648"  # (3+√13)/2
readonly MATH_SUPER_GOLDEN_RATIO="1.465571231876768026656731225219939108025577"

# Limits and bounds
readonly MATH_FEIGENBAUM_ALPHA="2.502907875095892822283902873218215786381271"
readonly MATH_FEIGENBAUM_DELTA="4.669201609102990671853203820466201617258185"

# Probability/statistics
readonly MATH_GAUSS_CONSTANT="0.834626841674073186281429732799046808993993"  # G
readonly MATH_ERDOS_BORWEIN="1.606695152415291763783301523190924580480579"   # E

# Computer science
readonly MATH_SHANNON_ENTROPY_BASE2="1.442695040888963407359924681001892137426645"  # 1/ln(2)
readonly MATH_GOLDEN_ANGLE="2.399963229728653322231555506633613853124999"           # 2π/φ² radians

# Famous irrationals
readonly MATH_CHAITIN="0.0078749969978123844"                            # Ω (Chaitin's constant, approximate)
readonly MATH_TWIN_PRIME="0.660161815846869573927812110014555778432623"  # C₂

# Dimensionless physical constants
readonly MATH_FINE_STRUCTURE="0.0072973525693"  # α
readonly MATH_PROTON_ELECTRON_MASS_RATIO="1836.15267343"

# Mathematical bounds
readonly MATH_LOWER_GAMMA="-0.072815845483676724860586375874901319137736"  # γ₁
readonly MATH_UPPER_GAMMA="0.989055995327972555395395651500634707939184"   # γ₂

# ==============================================================================
# ALIASES - Practical alternative names
# ==============================================================================

# Common mathematical names
readonly MATH_GOLDEN_RATIO="$MATH_PHI"
readonly MATH_EULER_GAMMA="$MATH_EULER_MASCHERONI"
readonly MATH_TWICE_PI="$MATH_TAU"
readonly MATH_CATALANS_CONSTANT="$MATH_CATALAN"
readonly MATH_APERYS_CONSTANT="$MATH_APERY"
readonly MATH_CHAITINS_CONSTANT="$MATH_CHAITIN"
readonly MATH_TWIN_PRIME_CONSTANT="$MATH_TWIN_PRIME"

# Physics constants (standard symbol names)
readonly MATH_c="$MATH_SPEED_OF_LIGHT"
readonly MATH_G="$MATH_GRAVITATIONAL_CONSTANT"
readonly MATH_h="$MATH_PLANCK_CONSTANT"
readonly MATH_hbar="$MATH_REDUCED_PLANCK_CONSTANT"
readonly MATH_N_A="$MATH_AVOGADRO_NUMBER"
readonly MATH_k_B="$MATH_BOLTZMANN_CONSTANT"
readonly MATH_e="$MATH_ELEMENTARY_CHARGE"
readonly MATH_g="$MATH_EARTH_GRAVITY"
readonly MATH_atm="$MATH_STANDARD_ATMOSPHERE"
readonly MATH_sigma="$MATH_STEFAN_BOLTZMANN"
readonly MATH_alpha="$MATH_FINE_STRUCTURE"

# Conversion shortcuts
readonly MATH_DEG2RAD="$MATH_DEG_TO_RAD"
readonly MATH_RAD2DEG="$MATH_RAD_TO_DEG"


# ==============================================================================
# BC WRAPPER
# ==============================================================================

# Check if bc is available
math::has_bc() {
    runtime::has_command bc
}

math::bc() {
    local expr="$1" scale="${2:-$MATH_SCALE}"
    if ! math::has_bc; then
        echo "math::bc: requires bc (GNU coreutils)" >&2
        return 1
    fi
    echo "scale=${scale}; ${expr}" | bc -l | sed 's/^\./0./; s/^-\./-0./'
}


# Safe bc wrapper — checks availability, applies scale
# Usage: math::bc expression [scale]
# Example: math::bc "4 * a(1)" 42


# ==============================================================================
# FLOAT DETECTION HELPER
# Internal helper — not exported as part of the public math API
# ==============================================================================

_math::is_float() {
    [[ "$1" =~ ^-?[0-9]+(\.[0-9]+)?([Ee][+-]?[0-9]+)?$ ]] && [[ "$1" == *"."* || "$1" == *[Ee]* ]]
}

_math::is_int() {
    [[ "$1" =~ ^-?[0-9]+$ ]]
}

math::is_int() {
  local n
  if [[ $# -ge 1 ]]; then n="$1"; else n=$(cat); fi
    [[ "$n" =~ ^-?[0-9]+$ ]]
}

# ==============================================================================
# BASIC INTEGER ARITHMETIC
# Pure bash — no bc needed
# ==============================================================================

# Absolute value (integer)
# Usage: math::abs n
math::abs() {
  local n
  if [[ $# -ge 1 ]]; then n="$1"; else n=$(cat); fi
    _math::is_float "$n" && { echo "math::abs: float input — use math::absf" >&2; return 1; }
    echo $(( $n < 0 ? -$n : $n ))
}

# Absolute value (float) — Usage: math::absf n [scale]
math::absf() {
  local n scale
  if [[ $# -ge 1 ]]; then n="$1"; scale="${2:-$MATH_SCALE}"
  else n=$(cat); scale="${1:-$MATH_SCALE}"; fi
  math::bc "if ($n < 0) { -($n) } else { $n }" "$scale"
}

# Minimum of two values (integer)
math::min() {
    _math::is_float "$1" || _math::is_float "$2" && { echo "math::min: float input — use math::minf" >&2; return 1; }
    echo $(( $1 < $2 ? $1 : $2 ))
}

# Minimum of two values (float) — Usage: math::minf a b [scale]
math::minf() {
    local scale="${3:-$MATH_SCALE}"
    math::bc "if ($1 < $2) { $1 } else { $2 }" "$scale"
}

# Maximum of two values (integer)
math::max() {
    _math::is_float "$1" || _math::is_float "$2" && { echo "math::max: float input — use math::maxf" >&2; return 1; }
    echo $(( $1 > $2 ? $1 : $2 ))
}

# Maximum of two values (float) — Usage: math::maxf a b [scale]
math::maxf() {
    local scale="${3:-$MATH_SCALE}"
    math::bc "if ($1 > $2) { $1 } else { $2 }" "$scale"
}

# Clamp n between min and max inclusive
# Usage: math::clamp n min max
math::clamp() {
    local n="$1" lo="$2" hi="$3"
    _math::is_float "$n" || _math::is_float "$lo" || _math::is_float "$hi" && { echo "math::clamp: float input — use math::clampf" >&2; return 1; }
    echo $(( n < lo ? lo : (n > hi ? hi : n) ))
}

math::clampf() {
    local n="$1" lo="$2" hi="$3"
    local scale=${4:-$MATH_SCALE}
    local result
    result=$(math::bc "if ($n < $lo) $lo else if ($n > $hi) $hi else $n" "$scale")
    # Format with consistent decimal places (bc is being inconsistent for some reason)
    printf "%.${scale}f\n" "$result"
}

# Integer division (truncated toward zero)
# Usage: math::div dividend divisor
math::div() {
    _math::is_float "$1" || _math::is_float "$2" && { echo "math::div: float input — use math::bc for float division" >&2; return 1; }
    echo $(( $1 / $2 ))
}

# Modulo
math::mod() {
    _math::is_float "$1" || _math::is_float "$2" && { echo "math::mod: float input — use math::bc for float modulo" >&2; return 1; }
    echo $(( $1 % $2 ))
}

# Integer exponentiation
# Usage: math::pow base exponent
math::pow() {
    local base="$1" exp="$2" result=1
    _math::is_float "$base" || _math::is_float "$exp" && { echo "math::pow: float input — use math::powf" >&2; return 1; }
    while (( exp > 0 )); do
        (( exp % 2 == 1 )) && result=$(( result * base ))
        base=$(( base * base ))
        exp=$(( exp / 2 ))
    done
    echo "$result"
}

# Greatest common divisor (Euclidean algorithm)
# Usage: math::gcd a b
math::gcd() {
    _math::is_float "$1" || _math::is_float "$2" && { echo "math::gcd: float input — gcd is integer-only" >&2; return 1; }
    local a=$(( $1 < 0 ? -$1 : $1 ))
    local b=$(( $2 < 0 ? -$2 : $2 ))
    while (( b != 0 )); do
        local t=$b
        b=$(( a % b ))
        a=$t
    done
    echo "$a"
}

# Least common multiple
# Usage: math::lcm a b
math::lcm() {
    local a="$1" b="$2"
    _math::is_float "$a" || _math::is_float "$b" && { echo "math::lcm: float input — lcm is integer-only" >&2; return 1; }
    local gcd
    gcd=$(math::gcd "$a" "$b")
    echo $(( (a / gcd) * b ))
}

# Check if integer is even
math::is_even() {
  local n
  if [[ $# -ge 1 ]]; then n="$1"; else n=$(cat); fi
    _math::is_float "$n" && { echo "math::is_even: float input — is_even is integer-only" >&2; return 1; }
    (( $n % 2 == 0 ))
}

# Check if integer is odd
math::is_odd() {
  local n
  if [[ $# -ge 1 ]]; then n="$1"; else n=$(cat); fi
    _math::is_float "$n" && { echo "math::is_odd: float input — is_odd is integer-only" >&2; return 1; }
    (( $n % 2 != 0 ))
}

# Check if integer is prime
math::is_prime() {
  local n scale
  if [[ $# -ge 1 ]]; then n="$1"; scale="${2:-$MATH_SCALE}"
  else n=$(cat); scale="${1:-$MATH_SCALE}"; fi
    _math::is_float "$n" && { echo "math::is_prime: float input — is_prime is integer-only" >&2; return 1; }
    (( n < 2 )) && return 1
    (( n == 2 )) && return 0
    (( n % 2 == 0 )) && return 1
    local i=3
    while (( i * i <= n )); do
        (( n % i == 0 )) && return 1
        (( i += 2 ))
    done
    return 0
}

# Factorial (integer)
# Usage: math::factorial n
math::factorial() {
  local n
  if [[ $# -ge 1 ]]; then n="$1"; else n=$(cat); fi
    local result=1
    _math::is_float "$n" && { echo "math::factorial: float input — factorial is integer-only" >&2; return 1; }
    (( n < 0 )) && { echo "math::factorial: negative input" >&2; return 1; }
    local i
    for (( i=2; i<=n; i++ )); do result=$(( result * i )); done
    echo "$result"
}

# Fibonacci (nth term, 0-indexed)
# Usage: math::fibonacci n
math::fibonacci() {
  local n
  if [[ $# -ge 1 ]]; then n="$1"; else n=$(cat); fi
    local a=0 b=1 i
    _math::is_float "$n" && { echo "math::fibonacci: float input — fibonacci is integer-only" >&2; return 1; }
    (( n == 0 )) && echo 0 && return
    for (( i=1; i<n; i++ )); do
        local t=$(( a + b ))
        a=$b
        b=$t
    done
    echo "$b"
}

# Integer square root (floor)
# Usage: math::isqrt n
math::int_sqrt() {
  local n
  if [[ $# -ge 1 ]]; then n="$1"; else n=$(cat); fi
    local x
    _math::is_float "$n" && { echo "math::int_sqrt: float input — use math::sqrt" >&2; return 1; }
    (( n < 0 )) && { echo "math::isqrt: negative input" >&2; return 1; }
    (( n == 0 )) && echo 0 && return
    x=$(( n / 2 + 1 ))
    local y=$(( (x + n / x) / 2 ))
    while (( y < x )); do
        x=$y
        y=$(( (x + n / x) / 2 ))
    done
    echo "$x"
}

# Sum of a sequence of integers
# Usage: math::sum n1 n2 n3 ...
math::sum() {
    local total=0
    for n in "$@"; do
        _math::is_float "$n" && { echo "math::sum: float input — use math::sumf" >&2; return 1; }
        (( total += n ))
    done
    echo "$total"
}

# Sum of a sequence of floats
# Usage: math::sumf scale n1 n2 n3 ...
math::sumf() {
    local scale=$1; shift
    local total="0"
    for n in "$@"; do total=$(math::bc "$total + $n" "$scale"); done
    echo "$total"
}

# Product of a sequence of integers
math::product() {
    local result=1
    for n in "$@"; do
        _math::is_float "$n" && { echo "math::product: float input — use math::productf" >&2; return 1; }
        (( result *= n ))
    done
    echo "$result"
}

# Product of a sequence of floats
# Usage: math::productf scale n1 n2 n3 ...
math::productf() {
    local scale=$1; shift
    local result="1"
    for n in "$@"; do result=$(math::bc "$result * $n" "$scale"); done
    echo "$result"
}

# ==============================================================================
# math::vec2 / math::vec3 — Vector operations
# Vectors are passed and returned as comma-separated strings: "x,y" or "x,y,z"
# Integer variants take components directly
# Float variants (f suffix) take scale as first argument
#
# Example:
#   a="1,2,3"
#   b="4,5,6"
#   math::vec3::dot "$a" "$b"                          # → 32
#   math::vec3::add "$a" "$b"                          # → 5,7,9
#   math::vec3::dot "$(math::vec3::add "$a" "$b")" "$b" # composable
#
#   # Destructure result
#   IFS=, read -r x y z <<< "$(math::vec3::add "$a" "$b")"
#
#   # Take just one component
#   IFS=, read -r x _ _ <<< "$(math::vec3::add "$a" "$b")"
# ==============================================================================

# Internal: split a comma-separated vec2 into positional vars
# Usage: _math::vec2::split "x,y" → sets _v_x1 _v_y1
_math::vec2::unpack2() {
    local -n _x="$1" _y="$2"
    IFS=, read -r _x _y <<< "$3"
}

# Internal: split two comma-separated vec2s into positional vars
_math::vec2::unpack4() {
    local -n _x1="$1" _y1="$2" _x2="$3" _y2="$4"
    IFS=, read -r _x1 _y1 <<< "$5"
    IFS=, read -r _x2 _y2 <<< "$6"
}

# Internal: split a comma-separated vec3 into positional vars
_math::vec3::unpack3() {
    local -n _x="$1" _y="$2" _z="$3"
    IFS=, read -r _x _y _z <<< "$4"
}

# Internal: split two comma-separated vec3s into positional vars
_math::vec3::unpack6() {
    local -n _x1="$1" _y1="$2" _z1="$3" _x2="$4" _y2="$5" _z2="$6"
    IFS=, read -r _x1 _y1 _z1 <<< "$7"
    IFS=, read -r _x2 _y2 _z2 <<< "$8"
}

# ==============================================================================
# math::vec2
# ==============================================================================

math::vec3::new() {
    local x="${1:-0}" y="${2:-0}"

    [[ "$x" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || x=0
    [[ "$y" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || y=0

    echo "${x},${y}"
}

math::vec3::new::fast() {
    [[ $# -lt 1 ]] && {
        echo "Usage: math::vec3::new::fast <var_name> [x] [y] [z]" >&2
        return 1
    }

    local -n vector=$1
    local x="${2:-0}" y="${3:-0}"

    [[ "$x" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || x=0
    [[ "$y" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || y=0

    vector="${x},${y}"
}

# Add two vec2 vectors
# Usage: math::vec2::add "x1,y1" "x2,y2"
# Returns: "x,y"
math::vec2::add() {
    local x1 y1 x2 y2
    _math::vec2::unpack4 x1 y1 x2 y2 "$1" "$2"
    echo "$(( x1 + x2 )),$(( y1 + y2 ))"
}

# Add two vec2 vectors with floating point precision
# Usage: math::vec2::addf scale "x1,y1" "x2,y2"
# Returns: "x,y"
math::vec2::addf() {
    local scale=$1 x1 y1 x2 y2
    _math::vec2::unpack4 x1 y1 x2 y2 "$2" "$3"
    echo "$(math::bc "$x1 + $x2" "$scale"),$(math::bc "$y1 + $y2" "$scale")"
}

# Subtract vec2 b from vec2 a
# Usage: math::vec2::sub "x1,y1" "x2,y2"
# Returns: "x,y"
math::vec2::sub() {
    local x1 y1 x2 y2
    _math::vec2::unpack4 x1 y1 x2 y2 "$1" "$2"
    echo "$(( x1 - x2 )),$(( y1 - y2 ))"
}

# Subtract vec2 b from vec2 a with floating point precision
# Usage: math::vec2::subf scale "x1,y1" "x2,y2"
# Returns: "x,y"
math::vec2::subf() {
    local scale=$1 x1 y1 x2 y2
    _math::vec2::unpack4 x1 y1 x2 y2 "$2" "$3"
    echo "$(math::bc "$x1 - $x2" "$scale"),$(math::bc "$y1 - $y2" "$scale")"
}

# Scale a vec2 by a scalar
# Usage: math::vec2::scale "x,y" scalar
# Returns: "x,y"
math::vec2::scale() {
    local x y
    _math::vec2::unpack2 x y "$1"
    echo "$(( x * $2 )),$(( y * $2 ))"
}

# Scale a vec2 by a scalar with floating point precision
# Usage: math::vec2::scalef scale "x,y" scalar
# Returns: "x,y"
math::vec2::scalef() {
    local scale=$1 x y
    _math::vec2::unpack2 x y "$2"
    echo "$(math::bc "$x * $3" "$scale"),$(math::bc "$y * $3" "$scale")"
}

# Dot product of two vec2 vectors
# Usage: math::vec2::dot "x1,y1" "x2,y2"
# Returns: scalar integer
math::vec2::dot() {
    local x1 y1 x2 y2
    _math::vec2::unpack4 x1 y1 x2 y2 "$1" "$2"
    echo "$(( x1 * x2 + y1 * y2 ))"
}

# Dot product of two vec2 vectors with floating point precision
# Usage: math::vec2::dotf scale "x1,y1" "x2,y2"
# Returns: scalar float
math::vec2::dotf() {
    local scale=$1 x1 y1 x2 y2
    _math::vec2::unpack4 x1 y1 x2 y2 "$2" "$3"
    math::bc "$x1 * $x2 + $y1 * $y2" "$scale"
}

# Magnitude (length) of a vec2 — requires bc
# Usage: math::vec2::magnitude "x,y"
# Returns: scalar float
math::vec2::magnitude() {
    local x y
    _math::vec2::unpack2 x y "$1"
    math::bc "sqrt($x * $x + $y * $y)"
}

# Magnitude with explicit scale
# Usage: math::vec2::magnitudef scale "x,y"
# Returns: scalar float
math::vec2::magnitudef() {
    local scale=$1 x y
    _math::vec2::unpack2 x y "$2"
    math::bc "sqrt($x * $x + $y * $y)" "$scale"
}

# Normalise a vec2 to unit length — requires bc
# Usage: math::vec2::normalise "x,y"
# Returns: "x,y"
math::vec2::normalise() {
    local x y mag
    _math::vec2::unpack2 x y "$1"
    mag=$(math::bc "sqrt($x * $x + $y * $y)")
    echo "$(math::bc "$x / $mag"),$(math::bc "$y / $mag")"
}

# Normalise a vec2 with explicit scale
# Usage: math::vec2::normalisef scale "x,y"
# Returns: "x,y"
math::vec2::normalisef() {
    local scale=$1 x y mag
    _math::vec2::unpack2 x y "$2"
    mag=$(math::bc "sqrt($x * $x + $y * $y)" "$scale")
    echo "$(math::bc "$x / $mag" "$scale"),$(math::bc "$y / $mag" "$scale")"
}

# Distance between two vec2 points — requires bc
# Usage: math::vec2::distance "x1,y1" "x2,y2"
# Returns: scalar float
math::vec2::distance() {
    local x1 y1 x2 y2
    _math::vec2::unpack4 x1 y1 x2 y2 "$1" "$2"
    math::bc "sqrt(($x1-$x2)*($x1-$x2) + ($y1-$y2)*($y1-$y2))"
}

# Distance between two vec2 points with explicit scale
# Usage: math::vec2::distancef scale "x1,y1" "x2,y2"
# Returns: scalar float
math::vec2::distancef() {
    local scale=$1 x1 y1 x2 y2
    _math::vec2::unpack4 x1 y1 x2 y2 "$2" "$3"
    math::bc "sqrt(($x1-$x2)*($x1-$x2) + ($y1-$y2)*($y1-$y2))" "$scale"
}

# Check if two vec2 vectors are equal
# Usage: math::vec2::eq "x1,y1" "x2,y2"
# Returns: 0 if equal, 1 otherwise
math::vec2::eq() {
    [[ "$1" == "$2" ]]
}

# ==============================================================================
# math::vec3
# ==============================================================================

math::vec3::new() {
    local x="${1:-0}" y="${2:-0}" z="${3:-0}"

    { _math::is_float "$x" || _math::is_int "$x"; } || x=0
    { _math::is_float "$y" || _math::is_int "$y"; } || y=0
    { _math::is_float "$z" || _math::is_int "$z"; } || z=0

    echo "${x},${y},${z}"
}

math::vec3::new::fast() {
    [[ $# -lt 1 ]] && {
        echo "Usage: math::vec3::new::fast <var_name> [x] [y] [z]" >&2
        return 1
    }

    local -n vector=$1
    local x="${2:-0}" y="${3:-0}" z="${4:-0}"

    { _math::is_float "$x" || _math::is_int "$x"; } || x=0
    { _math::is_float "$y" || _math::is_int "$y"; } || y=0
    { _math::is_float "$z" || _math::is_int "$z"; } || z=0

    vector="${x},${y},${z}"
}


# Add two vec3 vectors
# Usage: math::vec3::add "x1,y1,z1" "x2,y2,z2"
# Returns: "x,y,z"
math::vec3::add() {
    local x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$1" "$2"
    echo "$(( x1 + x2 )),$(( y1 + y2 )),$(( z1 + z2 ))"
}

# Add two vec3 vectors with floating point precision
# Usage: math::vec3::addf scale "x1,y1,z1" "x2,y2,z2"
# Returns: "x,y,z"
math::vec3::addf() {
    local scale=$1 x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$2" "$3"
    echo "$(math::bc "$x1 + $x2" "$scale"),$(math::bc "$y1 + $y2" "$scale"),$(math::bc "$z1 + $z2" "$scale")"
}

# Subtract vec3 b from vec3 a
# Usage: math::vec3::sub "x1,y1,z1" "x2,y2,z2"
# Returns: "x,y,z"
math::vec3::sub() {
    local x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$1" "$2"
    echo "$(( x1 - x2 )),$(( y1 - y2 )),$(( z1 - z2 ))"
}

# Subtract vec3 b from vec3 a with floating point precision
# Usage: math::vec3::subf scale "x1,y1,z1" "x2,y2,z2"
# Returns: "x,y,z"
math::vec3::subf() {
    local scale=$1 x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$2" "$3"
    echo "$(math::bc "$x1 - $x2" "$scale"),$(math::bc "$y1 - $y2" "$scale"),$(math::bc "$z1 - $z2" "$scale")"
}

# Scale a vec3 by a scalar
# Usage: math::vec3::scale "x,y,z" scalar
# Returns: "x,y,z"
math::vec3::scale() {
    local x y z
    _math::vec3::unpack3 x y z "$1"
    echo "$(( x * $2 )),$(( y * $2 )),$(( z * $2 ))"
}

# Scale a vec3 by a scalar with floating point precision
# Usage: math::vec3::scalef scale "x,y,z" scalar
# Returns: "x,y,z"
math::vec3::scalef() {
    local scale=$1 x y z
    _math::vec3::unpack3 x y z "$2"
    echo "$(math::bc "$x * $3" "$scale"),$(math::bc "$y * $3" "$scale"),$(math::bc "$z * $3" "$scale")"
}

# Dot product of two vec3 vectors
# Usage: math::vec3::dot "x1,y1,z1" "x2,y2,z2"
# Returns: scalar integer
math::vec3::dot() {
    local x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$1" "$2"
    echo "$(( x1 * x2 + y1 * y2 + z1 * z2 ))"
}

# Dot product of two vec3 vectors with floating point precision
# Usage: math::vec3::dotf scale "x1,y1,z1" "x2,y2,z2"
# Returns: scalar float
math::vec3::dotf() {
    local scale=$1 x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$2" "$3"
    math::bc "$x1 * $x2 + $y1 * $y2 + $z1 * $z2" "$scale"
}

# Cross product of two vec3 vectors
# Usage: math::vec3::cross "x1,y1,z1" "x2,y2,z2"
# Returns: "x,y,z"
math::vec3::cross() {
    local x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$1" "$2"
    echo "$(( y1*z2 - z1*y2 )),$(( z1*x2 - x1*z2 )),$(( x1*y2 - y1*x2 ))"
}

# Cross product of two vec3 vectors with floating point precision
# Usage: math::vec3::crossf scale "x1,y1,z1" "x2,y2,z2"
# Returns: "x,y,z"
math::vec3::crossf() {
    local scale=$1 x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$2" "$3"
    echo "$(math::bc "$y1*$z2 - $z1*$y2" "$scale"),$(math::bc "$z1*$x2 - $x1*$z2" "$scale"),$(math::bc "$x1*$y2 - $y1*$x2" "$scale")"
}

# Magnitude (length) of a vec3 — requires bc
# Usage: math::vec3::magnitude "x,y,z"
# Returns: scalar float
math::vec3::magnitude() {
    local x y z
    _math::vec3::unpack3 x y z "$1"
    math::bc "sqrt($x*$x + $y*$y + $z*$z)"
}

# Magnitude with explicit scale
# Usage: math::vec3::magnitudef scale "x,y,z"
# Returns: scalar float
math::vec3::magnitudef() {
    local scale=$1 x y z
    _math::vec3::unpack3 x y z "$2"
    math::bc "sqrt($x*$x + $y*$y + $z*$z)" "$scale"
}

# Normalise a vec3 to unit length — requires bc
# Usage: math::vec3::normalise "x,y,z"
# Returns: "x,y,z"
math::vec3::normalise() {
    local x y z mag
    _math::vec3::unpack3 x y z "$1"
    mag=$(math::bc "sqrt($x*$x + $y*$y + $z*$z)")
    echo "$(math::bc "$x / $mag"),$(math::bc "$y / $mag"),$(math::bc "$z / $mag")"
}

# Normalise a vec3 with explicit scale
# Usage: math::vec3::normalisef scale "x,y,z"
# Returns: "x,y,z"
math::vec3::normalisef() {
    local scale=$1 x y z mag
    _math::vec3::unpack3 x y z "$2"
    mag=$(math::bc "sqrt($x*$x + $y*$y + $z*$z)" "$scale")
    echo "$(math::bc "$x / $mag" "$scale"),$(math::bc "$y / $mag" "$scale"),$(math::bc "$z / $mag" "$scale")"
}

# Distance between two vec3 points — requires bc
# Usage: math::vec3::distance "x1,y1,z1" "x2,y2,z2"
# Returns: scalar float
math::vec3::distance() {
    local x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$1" "$2"
    math::bc "sqrt(($x1-$x2)*($x1-$x2) + ($y1-$y2)*($y1-$y2) + ($z1-$z2)*($z1-$z2))"
}

# Distance between two vec3 points with explicit scale
# Usage: math::vec3::distancef scale "x1,y1,z1" "x2,y2,z2"
# Returns: scalar float
math::vec3::distancef() {
    local scale=$1 x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$2" "$3"
    math::bc "sqrt(($x1-$x2)*($x1-$x2) + ($y1-$y2)*($y1-$y2) + ($z1-$z2)*($z1-$z2))" "$scale"
}

# Check if two vec3 vectors are equal
# Usage: math::vec3::eq "x1,y1,z1" "x2,y2,z2"
# Returns: 0 if equal, 1 otherwise
math::vec3::eq() {
    [[ "$1" == "$2" ]]
}

# ==============================================================================
# math::matrix — Matrix operations
#
# Dimensions are passed as "RxC" strings: "2x3" = 2 rows, 3 cols
# Elements are passed either as a named array (nameref) or flat args (spaghetti)
# The function auto-detects the calling pattern by checking if the first
# element arg looks like a number or an identifier.
#
# Two variants:
#   math::matrix::*        — echoes result as space-separated flat list
#   math::matrix::*::fast  — first arg is output array name, no subshell
#
# CALLING PATTERNS:
#
#   # Nameref style — pass array names
#   local -a a=(1 2 3 4) b=(5 6 7 8)
#   read -ra result <<< "$(math::matrix::mul "2x2" "2x2" a b)"
#
#   # Spaghetti style — pass elements directly
#   read -ra result <<< "$(math::matrix::mul "2x2" "2x2" 1 2 3 4 5 6 7 8)"
#
#   # Fast variant — output array written in place, no subshell
#   local -a result=()
#   math::matrix::mul::fast result "2x2" "2x2" a b
#   math::matrix::mul::fast result "2x2" "2x2" 1 2 3 4 5 6 7 8
#
# Warning: in nameref style, pass the array NAME not the expanded value.
#   Correct: math::matrix::mul "2x2" "2x2" a b
#   Wrong:   math::matrix::mul "2x2" "2x2" "${a[@]}" "${b[@]}"
# ==============================================================================

# ------------------------------------------------------------------------------
# Internal helpers — parsing and unpacking only, no bc calls
# ------------------------------------------------------------------------------

# Parse a dimension string into rows and cols
# Usage: _math::matrix::dim "2x3" rows_var cols_var
_math::matrix::dim() {
    local -n _rows="$2" _cols="$3"
    IFS='x' read -r _rows _cols <<< "$1"
}

# Unpack a single matrix from either nameref or spaghetti args into a target array
# Usage: _math::matrix::unpack target_var size [name_or_elements...]
# Returns: number of args consumed via _math_unpack_consumed
_math::matrix::unpack() {
    local -n _target="$1"
    local size="$2"; shift 2
    if [[ "$1" =~ ^-?[0-9] ]]; then
        _target=("${@:1:$size}")
        _math_unpack_consumed="$size"
    else
        local -n _src="$1"
        _target=("${_src[@]}")
        _math_unpack_consumed=1
    fi
}

# Unpack two matrices from either nameref or spaghetti args
# Usage: _math::matrix::unpack2 target_a target_b size_a size_b [args...]
_math::matrix::unpack2() {
    local -n _ta="$1" _tb="$2"
    local size_a="$3" size_b="$4"; shift 4
    if [[ "$1" =~ ^-?[0-9] ]]; then
        _ta=("${@:1:$size_a}")
        _tb=("${@:$(( size_a + 1 )):$size_b}")
    else
        local -n _sa="$1" _sb="$2"
        _ta=("${_sa[@]}")
        _tb=("${_sb[@]}")
    fi
}

# ==============================================================================
# math::matrix::new - Create a new matrix array
#
# Usage:
#   arr=($(math::matrix::new 3x4))          # Creates 3x4 matrix with zeros
#   arr=($(math::matrix::new 3x4 5))        # Creates 3x4 matrix with value 5
#
# Returns: Space-separated matrix elements
# ==============================================================================
math::matrix::new() {
    local dimensions="$1"
    local initial_value="${2:-0}"

    if [[ ! "$dimensions" =~ ^([0-9]+)x([0-9]+)$ ]]; then
        echo "Error: Invalid dimensions format. Use 'rowsxcols' (e.g., '3x4')" >&2
        return 1
    fi

    local rows="${BASH_REMATCH[1]}"
    local cols="${BASH_REMATCH[2]}"

    if [[ "$rows" -eq 0 ]] || [[ "$cols" -eq 0 ]]; then
        echo "Error: rows and cols must be greater than 0" >&2
        return 1
    fi

    # Just output the matrix elements
    for ((i=0; i<rows*cols; i++)); do
        echo "$initial_value"
    done
}

# ==============================================================================
# math::matrix::new::fast - Create a new matrix array using nameref (bash 4.3+)
#
# Usage:
#   math::matrix::new::fast <array_name> <rows>x<cols> [initial_value]
#
# Example:
#   math::matrix::new::fast my_matrix 3x4
#   math::matrix::new::fast my_matrix 3x4 5
# ==============================================================================
math::matrix::new::fast() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: math::matrix::new::fast <array_name> <rows>x<cols> [initial_value]" >&2
        return 1
    fi

    local -n arr_ref="$1"  # nameref to the array
    local dimensions="$2"
    local initial_value="${3:-0}"

    # Validate format and extract dimensions
    if [[ ! "$dimensions" =~ ^([0-9]+)x([0-9]+)$ ]]; then
        echo "Error: Invalid dimensions format. Use 'rowsxcols' (e.g., '3x4')" >&2
        return 1
    fi

    local rows="${BASH_REMATCH[1]}"
    local cols="${BASH_REMATCH[2]}"

    # Validate positive integers
    if [[ "$rows" -eq 0 ]] || [[ "$cols" -eq 0 ]]; then
        echo "Error: rows and cols must be greater than 0" >&2
        return 1
    fi

    # Clear and initialize the array
    arr_ref=()
    local total=$((rows * cols))

    # Populate with initial values
    for ((i=0; i<total; i++)); do
        arr_ref[$i]="$initial_value"
    done
}


# ==============================================================================
# math::matrix::add — Element-wise addition
# ==============================================================================

# Add two matrices element-wise
# Usage: math::matrix::add "RxC" a b
# Returns: flat space-separated element list
math::matrix::add() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:2}"
    local -a _result=()
    local i
    for (( i = 0; i < size; i++ )); do
        _result+=("$(( _a[$i] + _b[$i] ))")
    done
    echo "${_result[@]}"
}

# Add two matrices element-wise, writing result into output array
# Usage: math::matrix::add::fast result "RxC" a b
math::matrix::add::fast() {
    local -n _out="$1"; shift
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:2}"
    _out=()
    local i
    for (( i = 0; i < size; i++ )); do
        _out+=("$(( _a[$i] + _b[$i] ))")
    done
}

# Add two matrices element-wise with floating point precision
# Usage: math::matrix::addf scale "RxC" a b
# Returns: flat space-separated element list
math::matrix::addf() {
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:3}"
    local -a _result=()
    local i
    for (( i = 0; i < size; i++ )); do
        _result+=("$(math::bc "${_a[$i]} + ${_b[$i]}" "$scale")")
    done
    echo "${_result[@]}"
}

# Add two matrices element-wise with floating point precision, writing into output array
# Usage: math::matrix::addf::fast result scale "RxC" a b
math::matrix::addf::fast() {
    local -n _out="$1"; shift
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:3}"
    _out=()
    local i
    for (( i = 0; i < size; i++ )); do
        _out+=("$(math::bc "${_a[$i]} + ${_b[$i]}" "$scale")")
    done
}

# ==============================================================================
# math::matrix::sub — Element-wise subtraction
# ==============================================================================

# Subtract matrix b from matrix a element-wise
# Usage: math::matrix::sub "RxC" a b
# Returns: flat space-separated element list
math::matrix::sub() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:2}"
    local -a _result=()
    local i
    for (( i = 0; i < size; i++ )); do
        _result+=("$(( _a[$i] - _b[$i] ))")
    done
    echo "${_result[@]}"
}

# Subtract matrix b from matrix a element-wise, writing into output array
# Usage: math::matrix::sub::fast result "RxC" a b
math::matrix::sub::fast() {
    local -n _out="$1"; shift
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:2}"
    _out=()
    local i
    for (( i = 0; i < size; i++ )); do
        _out+=("$(( _a[$i] - _b[$i] ))")
    done
}

# Subtract matrix b from matrix a element-wise with floating point precision
# Usage: math::matrix::subf scale "RxC" a b
# Returns: flat space-separated element list
math::matrix::subf() {
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:3}"
    local -a _result=()
    local i
    for (( i = 0; i < size; i++ )); do
        _result+=("$(math::bc "${_a[$i]} - ${_b[$i]}" "$scale")")
    done
    echo "${_result[@]}"
}

# Subtract matrix b from matrix a element-wise with floating point precision, writing into output array
# Usage: math::matrix::subf::fast result scale "RxC" a b
math::matrix::subf::fast() {
    local -n _out="$1"; shift
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:3}"
    _out=()
    local i
    for (( i = 0; i < size; i++ )); do
        _out+=("$(math::bc "${_a[$i]} - ${_b[$i]}" "$scale")")
    done
}

# ==============================================================================
# math::matrix::scale — Scalar multiplication
# ==============================================================================

# Multiply every element of a matrix by a scalar
# Usage: math::matrix::scale "RxC" scalar a
# Returns: flat space-separated element list
math::matrix::scale() {
    local scalar=$2 rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"
    local -a _result=()
    local i
    for (( i = 0; i < size; i++ )); do
        _result+=("$(( _a[$i] * scalar ))")
    done
    echo "${_result[@]}"
}

# Multiply every element of a matrix by a scalar, writing into output array
# Usage: math::matrix::scale::fast result "RxC" scalar a
math::matrix::scale::fast() {
    local -n _out="$1"; shift
    local scalar=$2 rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"
    _out=()
    local i
    for (( i = 0; i < size; i++ )); do
        _out+=("$(( _a[$i] * scalar ))")
    done
}

# Multiply every element of a matrix by a scalar with floating point precision
# Usage: math::matrix::scalef scale "RxC" scalar a
# Returns: flat space-separated element list
math::matrix::scalef() {
    local scale=$1 scalar=$3 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:4}"
    local -a _result=()
    local i
    for (( i = 0; i < size; i++ )); do
        _result+=("$(math::bc "${_a[$i]} * $scalar" "$scale")")
    done
    echo "${_result[@]}"
}

# Multiply every element of a matrix by a scalar with floating point precision, writing into output array
# Usage: math::matrix::scalef::fast result scale "RxC" scalar a
math::matrix::scalef::fast() {
    local -n _out="$1"; shift
    local scale=$1 scalar=$3 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:4}"
    _out=()
    local i
    for (( i = 0; i < size; i++ )); do
        _out+=("$(math::bc "${_a[$i]} * $scalar" "$scale")")
    done
}

# ==============================================================================
# math::matrix::mul — Matrix multiplication
# ==============================================================================

# Multiply two matrices — cols of a must equal rows of b
# Usage: math::matrix::mul "RxC" "RxC" a b
# Returns: flat space-separated element list
# Warning: cols_a must equal rows_b — "2x3" * "3x2" is valid, "2x3" * "2x3" is not
math::matrix::mul() {
    local rows_a cols_a rows_b cols_b
    _math::matrix::dim "$1" rows_a cols_a
    _math::matrix::dim "$2" rows_b cols_b
    if (( cols_a != rows_b )); then
        echo "Error: math::matrix::mul: incompatible dimensions $1 * $2" >&2
        return 1
    fi
    local size_a=$(( rows_a * cols_a )) size_b=$(( rows_b * cols_b ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size_a" "$size_b" "${@:3}"
    local -a _result=()
    local i j k sum
    for (( i = 0; i < rows_a; i++ )); do
        for (( j = 0; j < cols_b; j++ )); do
            sum=0
            for (( k = 0; k < cols_a; k++ )); do
                sum=$(( sum + _a[$i * $cols_a + $k] * _b[$k * $cols_b + $j] ))
            done
            _result+=("$sum")
        done
    done
    echo "${_result[@]}"
}

# Multiply two matrices, writing result into output array
# Usage: math::matrix::mul::fast result "RxC" "RxC" a b
# Warning: cols_a must equal rows_b
math::matrix::mul::fast() {
    local -n _out="$1"; shift
    local rows_a cols_a rows_b cols_b
    _math::matrix::dim "$1" rows_a cols_a
    _math::matrix::dim "$2" rows_b cols_b
    if (( cols_a != rows_b )); then
        echo "Error: math::matrix::mul::fast: incompatible dimensions $1 * $2" >&2
        return 1
    fi
    local size_a=$(( rows_a * cols_a )) size_b=$(( rows_b * cols_b ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size_a" "$size_b" "${@:3}"
    _out=()
    local i j k sum
    for (( i = 0; i < rows_a; i++ )); do
        for (( j = 0; j < cols_b; j++ )); do
            sum=0
            for (( k = 0; k < cols_a; k++ )); do
                sum=$(( sum + _a[$i * $cols_a + $k] * _b[$k * $cols_b + $j] ))
            done
            _out+=("$sum")
        done
    done
}

# Multiply two matrices with floating point precision
# Usage: math::matrix::mulf scale "RxC" "RxC" a b
# Returns: flat space-separated element list
# Warning: cols_a must equal rows_b
math::matrix::mulf() {
    local scale=$1 rows_a cols_a rows_b cols_b
    _math::matrix::dim "$2" rows_a cols_a
    _math::matrix::dim "$3" rows_b cols_b
    if (( cols_a != rows_b )); then
        echo "Error: math::matrix::mulf: incompatible dimensions $2 * $3" >&2
        return 1
    fi
    local size_a=$(( rows_a * cols_a )) size_b=$(( rows_b * cols_b ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size_a" "$size_b" "${@:4}"
    local -a _result=()
    local i j k sum
    for (( i = 0; i < rows_a; i++ )); do
        for (( j = 0; j < cols_b; j++ )); do
            sum="0"
            for (( k = 0; k < cols_a; k++ )); do
                sum=$(math::bc "$sum + ${_a[$i * $cols_a + $k]} * ${_b[$k * $cols_b + $j]}" "$scale")
            done
            _result+=("$sum")
        done
    done
    echo "${_result[@]}"
}

# Multiply two matrices with floating point precision, writing into output array
# Usage: math::matrix::mulf::fast result scale "RxC" "RxC" a b
# Warning: cols_a must equal rows_b
math::matrix::mulf::fast() {
    local -n _out="$1"; shift
    local scale=$1 rows_a cols_a rows_b cols_b
    _math::matrix::dim "$2" rows_a cols_a
    _math::matrix::dim "$3" rows_b cols_b
    if (( cols_a != rows_b )); then
        echo "Error: math::matrix::mulf::fast: incompatible dimensions $2 * $3" >&2
        return 1
    fi
    local size_a=$(( rows_a * cols_a )) size_b=$(( rows_b * cols_b ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size_a" "$size_b" "${@:4}"
    _out=()
    local i j k sum
    for (( i = 0; i < rows_a; i++ )); do
        for (( j = 0; j < cols_b; j++ )); do
            sum="0"
            for (( k = 0; k < cols_a; k++ )); do
                sum=$(math::bc "$sum + ${_a[$i * $cols_a + $k]} * ${_b[$k * $cols_b + $j]}" "$scale")
            done
            _out+=("$sum")
        done
    done
}

# ==============================================================================
# math::matrix::transpose
# ==============================================================================

# Transpose a matrix — rows become columns
# Usage: math::matrix::transpose "RxC" a
# Returns: flat space-separated element list
math::matrix::transpose() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:2}"
    local -a _result=()
    local i j
    for (( j = 0; j < cols; j++ )); do
        for (( i = 0; i < rows; i++ )); do
            _result+=("${_a[$i * $cols + $j]}")
        done
    done
    echo "${_result[@]}"
}

# Transpose a matrix, writing into output array
# Usage: math::matrix::transpose::fast result "RxC" a
math::matrix::transpose::fast() {
    local -n _out="$1"; shift
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:2}"
    _out=()
    local i j
    for (( j = 0; j < cols; j++ )); do
        for (( i = 0; i < rows; i++ )); do
            _out+=("${_a[$i * $cols + $j]}")
        done
    done
}

# ==============================================================================
# math::matrix::identity
# ==============================================================================

# Generate an identity matrix of given size
# Usage: math::matrix::identity "NxN"
# Returns: flat space-separated element list
# Note: only square matrices have an identity — NxN only
math::matrix::identity() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local -a _result=()
    local i j
    for (( i = 0; i < rows; i++ )); do
        for (( j = 0; j < cols; j++ )); do
            (( i == j )) && _result+=(1) || _result+=(0)
        done
    done
    echo "${_result[@]}"
}

# Generate an identity matrix, writing into output array
# Usage: math::matrix::identity::fast result "NxN"
math::matrix::identity::fast() {
    local -n _out="$1"; shift
    local rows cols
    _math::matrix::dim "$1" rows cols
    _out=()
    local i j
    for (( i = 0; i < rows; i++ )); do
        for (( j = 0; j < cols; j++ )); do
            (( i == j )) && _out+=(1) || _out+=(0)
        done
    done
}

# ==============================================================================
# math::matrix::eq
# ==============================================================================

# Check if two matrices are equal element-wise
# Usage: math::matrix::eq "RxC" a b
# Returns: 0 if equal, 1 otherwise
math::matrix::eq() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:2}"
    local i
    for (( i = 0; i < size; i++ )); do
        [[ "${_a[$i]}" != "${_b[$i]}" ]] && return 1
    done
    return 0
}

# ==============================================================================
# math::matrix::is_square
# ==============================================================================

# Check if a matrix is square (rows == cols)
# Usage: math::matrix::is_square "RxC"
# Returns: 0 if square, 1 otherwise
math::matrix::is_square() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    (( rows == cols ))
}

# ==============================================================================
# math::matrix::trace
# ==============================================================================

# Sum of diagonal elements — square matrices only
# Usage: math::matrix::trace "NxN" a
# Returns: scalar integer
# Note: for float input use math::matrix::tracef
math::matrix::trace() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:2}"
    local sum=0 i
    for (( i = 0; i < rows; i++ )); do
        sum=$(( sum + _a[$i * $cols + $i] ))
    done
    echo "$sum"
}

# Sum of diagonal elements with floating point precision
# Usage: math::matrix::tracef scale "NxN" a
# Returns: scalar float
math::matrix::tracef() {
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"
    local sum="0" i
    for (( i = 0; i < rows; i++ )); do
        sum=$(math::bc "$sum + ${_a[$i * $cols + $i]}" "$scale")
    done
    echo "$sum"
}

# ==============================================================================
# math::matrix::diagonal
# ==============================================================================

# Extract diagonal elements as a flat list
# Usage: math::matrix::diagonal "NxN" a
# Returns: flat space-separated element list
math::matrix::diagonal() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:2}"
    local -a _result=()
    local i
    for (( i = 0; i < rows; i++ )); do
        _result+=("${_a[$i * $cols + $i]}")
    done
    echo "${_result[@]}"
}

# ==============================================================================
# math::matrix::flatten
# ==============================================================================

# Flatten a matrix to a newline-separated list (one element per line)
# Usage: math::matrix::flatten "RxC" a
# Returns: one element per line
math::matrix::flatten() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:2}"
    printf '%s\n' "${_a[@]}"
}

# ==============================================================================
# math::matrix::print
# ==============================================================================

# Print a matrix in row-major human-readable format
# Usage: math::matrix::print "RxC" a
math::matrix::print() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:2}"
    local i j
    for (( i = 0; i < rows; i++ )); do
        for (( j = 0; j < cols; j++ )); do
            printf '%s ' "${_a[$i * $cols + $j]}"
        done
        echo
    done
}

# ==============================================================================
# math::matrix::hadamard — Element-wise multiplication
# ==============================================================================

# Multiply two matrices element-wise (Hadamard product)
# Usage: math::matrix::hadamard "RxC" a b
# Returns: flat space-separated element list
math::matrix::hadamard() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:2}"
    local -a _result=()
    local i
    for (( i = 0; i < size; i++ )); do
        _result+=("$(( _a[$i] * _b[$i] ))")
    done
    echo "${_result[@]}"
}

# Hadamard product, writing into output array
# Usage: math::matrix::hadamard::fast result "RxC" a b
math::matrix::hadamard::fast() {
    local -n _out="$1"; shift
    local rows cols
    _math::matrix::dim "$1" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:2}"
    _out=()
    local i
    for (( i = 0; i < size; i++ )); do
        _out+=("$(( _a[$i] * _b[$i] ))")
    done
}

# Hadamard product with floating point precision
# Usage: math::matrix::hadamardf scale "RxC" a b
# Returns: flat space-separated element list
math::matrix::hadamardf() {
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:3}"
    local -a _result=()
    local i
    for (( i = 0; i < size; i++ )); do
        _result+=("$(math::bc "${_a[$i]} * ${_b[$i]}" "$scale")")
    done
    echo "${_result[@]}"
}

# Hadamard product with floating point precision, writing into output array
# Usage: math::matrix::hadamardf::fast result scale "RxC" a b
math::matrix::hadamardf::fast() {
    local -n _out="$1"; shift
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a _b
    _math::matrix::unpack2 _a _b "$size" "$size" "${@:3}"
    _out=()
    local i
    for (( i = 0; i < size; i++ )); do
        _out+=("$(math::bc "${_a[$i]} * ${_b[$i]}" "$scale")")
    done
}

# ==============================================================================
# math::matrix::minor
# ==============================================================================

# Compute the minor of a matrix — submatrix with row i and col j removed
# Usage: math::matrix::minor "NxN" row col a
# Returns: flat space-separated element list of the (N-1)x(N-1) submatrix
# Note: row and col are 0-indexed
math::matrix::minor() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    local skip_row=$2 skip_col=$3
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:4}"
    local -a _result=()
    local i j
    for (( i = 0; i < rows; i++ )); do
        (( i == skip_row )) && continue
        for (( j = 0; j < cols; j++ )); do
            (( j == skip_col )) && continue
            _result+=("${_a[$i * $cols + $j]}")
        done
    done
    echo "${_result[@]}"
}

# ==============================================================================
# math::matrix::determinant — via LU decomposition (float, requires bc)
# ==============================================================================

# Compute determinant of a square matrix — requires bc
# Usage: math::matrix::determinant scale "NxN" a
# Returns: scalar float
# Note: uses LU decomposition internally for O(n³) performance.
#   intermediate steps use scale+4 precision to reduce rounding drift.
#   bc represents fractions as repeating decimals, so results for integer
#   matrices may have small floating point drift (e.g. -2.00000004 instead
#   of -2). use a higher scale and round the result if exact integers are needed.
# Warning: scale 0 will produce incorrect results due to intermediate truncation
math::matrix::determinant() {
    local scale=$1 rows cols
    local work_scale=$(( scale + 4 ))
    _math::matrix::dim "$2" rows cols
    if (( rows != cols )); then
        echo "Error: math::matrix::determinant: matrix must be square" >&2
        return 1
    fi
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"

    # LU decomposition — Doolittle method
    # U stored in upper triangle, L in lower (diagonal of L is 1)
    local n=$rows
    local -a _lu=("${_a[@]}")
    local sign=1
    local i j k pivot tmp

    for (( k = 0; k < n; k++ )); do
        # Partial pivoting
        local max_val="${_lu[$k * $n + $k]}"
        local max_row=$k
        for (( i = k + 1; i < n; i++ )); do
            local val="${_lu[$i * $n + $k]}"
            local abs_val abs_max
            abs_val=$(math::bc "if ($val < 0) { -($val) } else { ($val) }" "$work_scale")
            abs_max=$(math::bc "if ($max_val < 0) { -($max_val) } else { ($max_val) }" "$work_scale")
            if [[ $(math::bc "$abs_val > $abs_max" "$work_scale") -eq 1 ]]; then
                max_val="$val"
                max_row=$i
            fi
        done

        # Swap rows if needed
        if (( max_row != k )); then
            for (( j = 0; j < n; j++ )); do
                tmp="${_lu[$k * $n + $j]}"
                _lu[$k * $n + $j]="${_lu[$max_row * $n + $j]}"
                _lu[$max_row * $n + $j]="$tmp"
            done
            sign=$(( sign * -1 ))
        fi

        local pivot_val="${_lu[$k * $n + $k]}"
        if [[ $(math::bc "$pivot_val == 0" "$work_scale") -eq 1 ]]; then
            echo "0"
            return 0
        fi

        for (( i = k + 1; i < n; i++ )); do
            local factor
            factor=$(math::bc "${_lu[$i * $n + $k]} / $pivot_val" "$work_scale")
            _lu[$i * $n + $k]="$factor"
            for (( j = k + 1; j < n; j++ )); do
                _lu[$i * $n + $j]=$(math::bc "${_lu[$i * $n + $j]} - $factor * ${_lu[$k * $n + $j]}" "$work_scale")
            done
        done
    done

    # Determinant = sign * product of U diagonal, rounded to requested scale
    local det="$sign"
    for (( i = 0; i < n; i++ )); do
        det=$(math::bc "$det * ${_lu[$i * $n + $i]}" "$work_scale")
    done
    math::bc "$det" "$scale"
}

# ==============================================================================
# math::matrix::lu — LU decomposition (requires bc)
# ==============================================================================

# LU decomposition of a square matrix — requires bc
# Writes L and U into separate output arrays
# Usage: math::matrix::lu scale "NxN" L_out U_out a
# Note: L is lower triangular with 1s on diagonal, U is upper triangular
math::matrix::lu() {
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    if (( rows != cols )); then
        echo "Error: math::matrix::lu: matrix must be square" >&2
        return 1
    fi
    local -n _L="$3" _U="$4"
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:5}"

    local n=$rows
    local -a _lu=("${_a[@]}")
    local i j k

    for (( k = 0; k < n; k++ )); do
        local pivot_val="${_lu[$k * $n + $k]}"
        for (( i = k + 1; i < n; i++ )); do
            local factor
            factor=$(math::bc "${_lu[$i * $n + $k]} / $pivot_val" "$scale")
            _lu[$i * $n + $k]="$factor"
            for (( j = k + 1; j < n; j++ )); do
                _lu[$i * $n + $j]=$(math::bc "${_lu[$i * $n + $j]} - $factor * ${_lu[$k * $n + $j]}" "$scale")
            done
        done
    done

    # Extract L and U
    _L=()
    _U=()
    for (( i = 0; i < n; i++ )); do
        for (( j = 0; j < n; j++ )); do
            if (( i > j )); then
                _L+=("${_lu[$i * $n + $j]}")
                _U+=(0)
            elif (( i == j )); then
                _L+=(1)
                _U+=("${_lu[$i * $n + $j]}")
            else
                _L+=(0)
                _U+=("${_lu[$i * $n + $j]}")
            fi
        done
    done
}

# ==============================================================================
# math::matrix::cofactor
# ==============================================================================

# Compute the cofactor matrix — requires bc
# Usage: math::matrix::cofactor scale "NxN" a
# Returns: flat space-separated element list
math::matrix::cofactor() {
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"
    local n=$rows
    local -a _result=()
    local i j sign minor_list det

    for (( i = 0; i < n; i++ )); do
        for (( j = 0; j < n; j++ )); do
            read -ra minor_list <<< "$(math::matrix::minor "${n}x${n}" "$i" "$j" "${_a[@]}")"
            local sub_dim="$(( n - 1 ))x$(( n - 1 ))"
            det=$(math::matrix::determinant "$scale" "$sub_dim" "${minor_list[@]}")
            sign=$(( (i + j) % 2 == 0 ? 1 : -1 ))
            _result+=("$(math::bc "$sign * $det" "$scale")")
        done
    done
    echo "${_result[@]}"
}

# ==============================================================================
# math::matrix::adjugate
# ==============================================================================

# Compute the adjugate (transpose of cofactor matrix) — requires bc
# Usage: math::matrix::adjugate scale "NxN" a
# Returns: flat space-separated element list
math::matrix::adjugate() {
    local scale=$1 dim=$2
    local rows cols
    _math::matrix::dim "$dim" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"
    local -a cof
    read -ra cof <<< "$(math::matrix::cofactor "$scale" "$dim" "${_a[@]}")"
    math::matrix::transpose "$dim" "${cof[@]}"
}

# ==============================================================================
# math::matrix::inverse — requires bc
# ==============================================================================

# Compute the inverse of a square matrix — requires bc
# Usage: math::matrix::inverse scale "NxN" a
# Returns: flat space-separated element list
# Warning: returns error if matrix is singular (determinant = 0)
math::matrix::inverse() {
    local scale=$1 dim=$2
    local rows cols
    _math::matrix::dim "$dim" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"

    local det
    det=$(math::matrix::determinant "$scale" "$dim" "${_a[@]}")
    if [[ $(math::bc "$det == 0" "$scale") -eq 1 ]]; then
        echo "Error: math::matrix::inverse: matrix is singular (determinant = 0)" >&2
        return 1
    fi

    local inv_det
    inv_det=$(math::bc "1 / $det" "$scale")
    local -a adj
    read -ra adj <<< "$(math::matrix::adjugate "$scale" "$dim" "${_a[@]}")"
    math::matrix::scalef "$scale" "$dim" "$inv_det" "${adj[@]}"
}

# ==============================================================================
# math::matrix::pow
# ==============================================================================

# Raise a square matrix to an integer power via repeated multiplication
# Usage: math::matrix::pow "NxN" exponent a
# Returns: flat space-separated element list
# Note: exponent must be a non-negative integer. pow 0 returns identity matrix.
math::matrix::pow() {
    local dim=$1 exp=$2
    local rows cols
    _math::matrix::dim "$dim" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"

    if (( exp == 0 )); then
        math::matrix::identity "$dim"
        return
    fi

    local -a _result=("${_a[@]}")
    local i
    for (( i = 1; i < exp; i++ )); do
        read -ra _result <<< "$(math::matrix::mul "$dim" "$dim" "${_result[@]}" "${_a[@]}")"
    done
    echo "${_result[@]}"
}

# Raise a square matrix to an integer power with floating point precision
# Usage: math::matrix::powf scale "NxN" exponent a
# Returns: flat space-separated element list
math::matrix::powf() {
    local scale=$1 dim=$2 exp=$3
    local rows cols
    _math::matrix::dim "$dim" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:4}"

    if (( exp == 0 )); then
        math::matrix::identity "$dim"
        return
    fi

    local -a _result=("${_a[@]}")
    local i
    for (( i = 1; i < exp; i++ )); do
        read -ra _result <<< "$(math::matrix::mulf "$scale" "$dim" "$dim" "${_result[@]}" "${_a[@]}")"
    done
    echo "${_result[@]}"
}

# ==============================================================================
# math::matrix::rank — via row reduction (requires bc)
# ==============================================================================

# Compute the rank of a matrix via Gaussian elimination — requires bc
# Usage: math::matrix::rank scale "RxC" a
# Returns: integer rank
math::matrix::rank() {
    local scale=$1 rows cols
    _math::matrix::dim "$2" rows cols
    local size=$(( rows * cols ))
    local -a _a
    _math::matrix::unpack _a "$size" "${@:3}"

    local -a _m=("${_a[@]}")
    local rank=0 row=0 i j k factor pivot

    for (( j = 0; j < cols && row < rows; j++ )); do
        # Find pivot in column j from row onwards
        local pivot_row=-1
        for (( i = row; i < rows; i++ )); do
            if [[ $(math::bc "${_m[$i * $cols + $j]} != 0" "$scale") -eq 1 ]]; then
                pivot_row=$i
                break
            fi
        done
        (( pivot_row == -1 )) && continue

        # Swap pivot row into position
        if (( pivot_row != row )); then
            local tmp
            for (( k = 0; k < cols; k++ )); do
                tmp="${_m[$row * $cols + $k]}"
                _m[$row * $cols + $k]="${_m[$pivot_row * $cols + $k]}"
                _m[$pivot_row * $cols + $k]="$tmp"
            done
        fi

        pivot="${_m[$row * $cols + $j]}"
        for (( i = row + 1; i < rows; i++ )); do
            factor=$(math::bc "${_m[$i * $cols + $j]} / $pivot" "$scale")
            for (( k = j; k < cols; k++ )); do
                _m[$i * $cols + $k]=$(math::bc "${_m[$i * $cols + $k]} - $factor * ${_m[$row * $cols + $k]}" "$scale")
            done
        done

        (( rank++ ))
        (( row++ ))
    done

    echo "$rank"
}

# ==============================================================================
# FLOATING POINT (requires bc)
# ==============================================================================

# Floor — largest integer ≤ n
math::floor() {
  local n
  if [[ $# -ge 1 ]]; then n="$1"; else n=$(cat); fi
    math::bc "scale=0; $n / 1"
}

# Ceiling — smallest integer ≥ n
math::ceil() {
  local n
  if [[ $# -ge 1 ]]; then n="$1"; else n=$(cat); fi
    math::bc "scale=0; if ($n == ($n / 1)) $n else if ($n > 0) ($n / 1) + 1 else ($n / 1)"
}


# Round to nearest integer (or to d decimal places)
# Usage: math::round n [decimal_places]
math::round() {
  local n
  if [[ $# -ge 1 ]]; then n="$1"; else n=$(cat); fi
    local d="${2:-0}"
    math::bc "scale=${d}; (${n} + 0.5 * (${n} > 0) - 0.5 * (${n} < 0)) / 1" "$d"
}

# Square root
math::sqrt() {
  local n
  if [[ $# -ge 1 ]]; then n="$1"; else n=$(cat); fi
    local scale="${2:-$MATH_SCALE}"
    math::bc "sqrt($n)" "$scale"
}

# Natural logarithm
math::log() {
    math::bc "l($1)"
}

# Log base 2
math::log2() {
    math::bc "l($1) / l(2)"
}

# Log base 10
math::log10() {
    math::bc "l($1) / l(10)"
}

# Log with arbitrary base
# Usage: math::logn value base
math::logn() {
    math::bc "l($1) / l($2)"
}

# Exponential e^n
math::exp() {
    math::bc "e($1)"
}

# Power (floating point)
# Usage: math::powf base exponent
math::powf() {
    math::bc "e($2 * l($1))"
}

# Sigmoid — array-primary, operates in one awk pass
# Usage: math::sigmoid arr_name [scale]
# arr_name is a nameref to an indexed array; result echoed as space-separated floats
math::sigmoid() {
    local -n _sig_in="$1"
    local scale="${2:-$MATH_SCALE}"
    local -a _result=()
    for x in "${_sig_in[@]}"; do
        _result+=("$(math::bc "1 / (1 + e(-($x)))" "$scale")")
    done
    echo "${_result[@]}"
}

# Sigmoid — single value escape hatch
# Use math::sigmoid for batch processing; this forks bc once per call
# Usage: math::sigmoid::singleton value [scale]
math::sigmoid::singleton() {
    local scale="${2:-$MATH_SCALE}"
    math::bc "1 / (1 + e(-($1)))" "$scale"
}

# Softmax — array-primary (singleton is degenerate: softmax of one value is always 1.0)
# Usage: math::softmax arr_name [temperature [scale]]
# arr_name is a nameref to an indexed array; result echoed as space-separated floats
math::softmax() {
    local -n _softmax_in="$1"
    local temperature="${2:-1}" scale="${3:-$MATH_SCALE}"
    local -a arr=("${_softmax_in[@]}")

    if ! math::has_bc; then
        echo "Error: math::softmax requires bc for floating point operation."
        return 1
    fi

    if [[ $(math::bc "$temperature < 0") -eq 1 ]]; then
        echo "Error: math::softmax: Temperature cannot be lower than 0." >&2
        return 1
    fi

    ## T=0 is treated as T=1 (neutral temperature, no sharpening or flattening)
    ## Values between 0 and 1 are valid and will sharpen the distribution

    if [[ ${#arr[@]} -lt 2 ]]; then
        echo "Error: math::softmax requires more than 1 value" >&2
        return 1
    fi

    local -a exp_arr
    local exp_x

    for x in "${arr[@]}"; do
        exp_x=$(math::bc "if ($temperature > 0) { e($x / $temperature) } else { e($x) }" $scale)
        exp_arr+=("$exp_x")
    done

    # To maintain reliability and accuracy of normalisation,
    # normaliser_sum will not have scale applied
    local normaliser_sum=0
    for x in "${exp_arr[@]}"; do
        normaliser_sum=$(math::bc "$normaliser_sum + $x")
    done

    local -a softarr
    local softx

    for x in "${exp_arr[@]}"; do
        softx=$(math::bc "$x / $normaliser_sum" $scale)
        softarr+=("$softx")
    done

    echo "${softarr[@]}"
}

# ==============================================================================
# TRIGONOMETRY (requires bc)
# All angles in radians unless noted
# ==============================================================================

math::sin() {
    math::bc "s($1)"
}

math::cos() {
    math::bc "c($1)"
}

math::tan() {
    math::bc "s($1) / c($1)"
}

math::asin() {
    math::bc "a($1 / sqrt(1 - $1^2))"
}

math::acos() {
    math::bc "a(sqrt(1 - $1^2) / $1)"
}

math::atan() {
    math::bc "a($1)"
}

math::atan2() {
    math::bc "a($1 / $2)"
}

# Convert degrees to radians
math::deg_to_rad() {
  local n
  if [[ $# -ge 1 ]]; then n="$1"; else n=$(cat); fi
    math::bc "$n * $MATH_PI / 180"
}

# Convert radians to degrees
math::rad_to_deg() {
  local n
  if [[ $# -ge 1 ]]; then n="$1"; else n=$(cat); fi
    math::bc "$n * 180 / $MATH_PI"
}

# ==============================================================================
# PERCENTAGE / RATIO
# ==============================================================================

# Calculate percentage: (part / total) * 100
# Usage: math::percent part total [scale]
math::percent() {
    local part="$1" total="$2" scale="${3:-2}"
    math::bc "($part / $total) * 100" "$scale"
}

# Calculate what value is p% of total
# Usage: math::percent_of percent total [scale]
math::percent_of() {
    local pct="$1" total="$2" scale="${3:-2}"
    math::bc "($pct / 100) * $total" "$scale"
}

# Percentage change from old to new
# Usage: math::percent_change old new [scale]
math::percent_change() {
    local old="$1" new="$2" scale="${3:-2}"
    math::bc "(($new - $old) / $old) * 100" "$scale"
}

# ==============================================================================
# INTERPOLATION / MAPPING
# ==============================================================================

# Linear interpolation between a and b by factor t (0.0 - 1.0)
# Usage: math::lerp a b t [scale]
math::lerp() {
    local a="$1" b="$2" t="$3" scale="${4:-$MATH_SCALE}"
    math::bc "$a + ($b - $a) * $(math::clampf "$t" 0 1)" "$scale"
}

math::lerp_unclamped() {
    local a="$1" b="$2" t="$3" scale="${4:-$MATH_SCALE}"
    math::bc "$a + $t * ($b - $a)" "$scale"
}

# Map a value from one range to another
# Usage: math::map value in_min in_max out_min out_max [scale]
math::map() {
    local v="$1" imin="$2" imax="$3" omin="$4" omax="$5" scale="${6:-$MATH_SCALE}"
    math::bc "($v - $imin) * ($omax - $omin) / ($imax - $imin) + $omin" "$scale"
}

# Normalise a value to 0.0-1.0 range
# Usage: math::normalize value min max [scale]
math::normalize() {
    local v="$1" lo="$2" hi="$3" scale="${4:-$MATH_SCALE}"
    math::bc "($v - $lo) / ($hi - $lo)" "$scale"
}

# ==============================================================================
# NUMBER THEORY / COMBINATORICS
# ==============================================================================

# Binomial coefficient C(n, k) — "n choose k"
# Usage: math::choose n k
math::choose() {
    local n="$1" k="$2"
    _math::is_float "$n" || _math::is_float "$k" && { echo "math::choose: float input — choose is integer-only" >&2; return 1; }
    (( k > n )) && echo 0 && return
    (( k == 0 || k == n )) && echo 1 && return
    # Use the smaller of k and n-k for efficiency
    (( k > n - k )) && k=$(( n - k ))
    local result=1 i
    for (( i=0; i<k; i++ )); do
        result=$(( result * (n - i) / (i + 1) ))
    done
    echo "$result"
}

# Number of permutations P(n, k)
# Usage: math::permute n k
math::permute() {
    local n="$1" k="$2" result=1 i
    _math::is_float "$n" || _math::is_float "$k" && { echo "math::permute: float input — permute is integer-only" >&2; return 1; }
    for (( i=0; i<k; i++ )); do
        result=$(( result * (n - i) ))
    done
    echo "$result"
}

# Sum of digits of an integer
math::digit_sum() {
    local n="${1#-}" sum=0  # strip sign
    while (( n > 0 )); do
        (( sum += n % 10 ))
        (( n /= 10 ))
    done
    echo "$sum"
}

# Count number of digits
math::digit_count() {
    local n="${1#-}"
    (( n == 0 )) && echo 1 && return
    local count=0
    while (( n > 0 )); do
        (( count++ ))
        (( n /= 10 ))
    done
    echo "$count"
}

# Reverse digits of an integer
math::digit_reverse() {
    local n="${1#-}" sign="" result=0
    [[ "$1" == -* ]] && sign="-"
    while (( n > 0 )); do
        result=$(( result * 10 + n % 10 ))
        (( n /= 10 ))
    done
    echo "${sign}${result}"
}

# Check if integer is a palindrome
math::is_palindrome() {
    local n="${1#-}"
    local rev
    rev=$(math::digit_reverse "$n")
    (( n == rev ))
}

# math::unitconvert — universal unit conversion dispatcher
# Usage: math::unitconvert from to value [scale]
# Example: math::unitconvert km mi 100
#          math::unitconvert femtosecond nanosecond 1000
#          math::unitconvert b gib 1073741824

math::unitconvert() {
    local from="${1,,}" to="${2,,}" value="$3" scale="${4:-$MATH_SCALE}"

    [[ -z "$from" || -z "$to" || -z "$value" ]] && {
        echo "Usage: math::unitconvert <from> <to> <value> [scale]" >&2
        return 1
    }

    # Normalise verbose/alternative names to canonical short keys
    # from and to is duplicated for optimisation
    case "$from" in
        celsius|centigrade)                          from="celsius" ;;
        fahrenheit)                                  from="fahrenheit" ;;
        kelvin)                                      from="kelvin" ;;
        femtometre|femtometer|femtometres|femtometers) from="fm" ;;
        picometre|picometer|picometres|picometers)   from="pm" ;;
        nanometre_si|nanometer_si)                   from="nm_si" ;;
        micrometre|micrometer|micrometres|micrometers|um) from="um" ;;
        millimetre|millimeter|millimetres|millimeters|mm) from="mm" ;;
        centimetre|centimeter|centimetres|centimeters|cm) from="cm" ;;
        metre|meter|metres|meters)                   from="m" ;;
        kilometre|kilometer|kilometres|kilometers|km) from="km" ;;
        inch|inches)                                 from="in" ;;
        foot|feet)                                   from="ft" ;;
        yard|yards)                                  from="yd" ;;
        mile|miles)                                  from="mi" ;;
        nautical_mile|nautical_miles)                from="nm" ;;
        astronomical_unit|astronomical_units)        from="au" ;;
        light_year|lightyear|light_years|lightyears) from="ly" ;;
        light_hour|lighthour|light_hours|lighthours) from="lh" ;;
        light_day|lightday|light_days|lightdays)     from="ld" ;;
        parsec|parsecs)                              from="pc" ;;
        microgram|micrograms)                        from="ug" ;;
        milligram|milligrams|mg)                     from="mg" ;;
        gram|grams)                                  from="g" ;;
        kilogram|kilograms|kg)                       from="kg" ;;
        tonne|metric_ton|metric_tons)                from="t" ;;
        ounce|ounces)                                from="oz" ;;
        pound|pounds|lbs)                            from="lb" ;;
        stone|stones)                                from="st" ;;
        millilitre|milliliter|millilitres|milliliters|ml) from="ml" ;;
        litre|liter|litres|liters)                   from="l" ;;
        cubic_metre|cubic_meter)                     from="m3" ;;
        teaspoon|teaspoons)                          from="tsp" ;;
        tablespoon|tablespoons)                      from="tbsp" ;;
        fluid_ounce|fluid_ounces)                    from="floz" ;;
        pint|pints)                                  from="pt" ;;
        quart|quarts)                                from="qt" ;;
        gallon|gallons)                              from="gal" ;;
        kph|km_h|kilometres_per_hour|kilometers_per_hour) from="kmh" ;;
        mph|miles_per_hour)                          from="mph" ;;
        m_s|metres_per_second|meters_per_second)     from="ms" ;;
        knot|knots)                                  from="knot" ;;
        mach)                                        from="mach" ;;
        speed_of_light)                              from="c" ;;
        pascal|pascals)                              from="pa" ;;
        kilopascal|kilopascals)                      from="kpa" ;;
        bar|bars)                                    from="bar" ;;
        atmosphere|atmospheres)                      from="atm" ;;
        pounds_per_square_inch)                      from="psi" ;;
        millimetre_of_mercury|millimeter_of_mercury|torr) from="mmhg" ;;
        joule|joules)                                from="j" ;;
        kilojoule|kilojoules)                        from="kj" ;;
        calorie|calories)                            from="cal" ;;
        kilocalorie|kilocalories)                    from="kcal" ;;
        kilowatt_hour|kilowatt_hours)                from="kwh" ;;
        electronvolt|electronvolts)                  from="ev" ;;
        british_thermal_unit|british_thermal_units)  from="btu" ;;
        watt|watts)                                  from="w" ;;
        kilowatt|kilowatts)                          from="kw" ;;
        horsepower)                                  from="hp" ;;
        bit|bits)                                    from="b" ;;
        kilobit|kilobits)                            from="kb" ;;
        megabit|megabits)                            from="mb" ;;
        gigabit|gigabits)                            from="gb" ;;
        terabit|terabits)                            from="tb" ;;
        petabit|petabits)                            from="pb" ;;
        kibibit|kibibits)                            from="kib" ;;
        mebibit|mebibits)                            from="mib" ;;
        gibibit|gibibits)                            from="gib" ;;
        tebibit|tebibits)                            from="tib" ;;
        pebibit|pebibits)                            from="pib" ;;
        sector|sectors|512b)                         from="sector" ;;
        sector4k|4k_sector|advanced_format)          from="sector4k" ;;
        femtosecond|femtoseconds)                    from="fs" ;;
        picosecond|picoseconds)                      from="ps" ;;
        nanosecond|nanoseconds|ns)                   from="ns" ;;
        microsecond|microseconds|us)                 from="us" ;;
        millisecond|milliseconds|ms)                 from="ms" ;;
        second|seconds|sec)                          from="s" ;;
        minute|minutes)                              from="min" ;;
        hour|hours|hr)                               from="h" ;;
        day|days)                                    from="d" ;;
        week|weeks)                                  from="week" ;;
        year|years|yr)                               from="year" ;;
        degree|degrees)                              from="deg" ;;
        radian|radians)                              from="rad" ;;
        gradian|gradians|gon)                        from="grad" ;;
        arcminute|arcminutes)                        from="arcmin" ;;
        arcsecond|arcseconds)                        from="arcsec" ;;
    esac

    case "$to" in
        celsius|centigrade)                          to="celsius" ;;
        fahrenheit)                                  to="fahrenheit" ;;
        kelvin)                                      to="kelvin" ;;
        femtometre|femtometer|femtometres|femtometers) to="fm" ;;
        picometre|picometer|picometres|picometers)   to="pm" ;;
        nanometre_si|nanometer_si)                   to="nm_si" ;;
        micrometre|micrometer|micrometres|micrometers|um) to="um" ;;
        millimetre|millimeter|millimetres|millimeters|mm) to="mm" ;;
        centimetre|centimeter|centimetres|centimeters|cm) to="cm" ;;
        metre|meter|metres|meters)                   to="m" ;;
        kilometre|kilometer|kilometres|kilometers|km) to="km" ;;
        inch|inches)                                 to="in" ;;
        foot|feet)                                   to="ft" ;;
        yard|yards)                                  to="yd" ;;
        mile|miles)                                  to="mi" ;;
        nautical_mile|nautical_miles)                to="nm" ;;
        astronomical_unit|astronomical_units)        to="au" ;;
        light_year|lightyear|light_years|lightyears) to="ly" ;;
        light_hour|lighthour|light_hours|lighthours) to="lh" ;;
        light_day|lightday|light_days|lightdays)     to="ld" ;;
        parsec|parsecs)                              to="pc" ;;
        microgram|micrograms)                        to="ug" ;;
        milligram|milligrams|mg)                     to="mg" ;;
        gram|grams)                                  to="g" ;;
        kilogram|kilograms|kg)                       to="kg" ;;
        tonne|metric_ton|metric_tons)                to="t" ;;
        ounce|ounces)                                to="oz" ;;
        pound|pounds|lbs)                            to="lb" ;;
        stone|stones)                                to="st" ;;
        millilitre|milliliter|millilitres|milliliters|ml) to="ml" ;;
        litre|liter|litres|liters)                   to="l" ;;
        cubic_metre|cubic_meter)                     to="m3" ;;
        teaspoon|teaspoons)                          to="tsp" ;;
        tablespoon|tablespoons)                      to="tbsp" ;;
        fluid_ounce|fluid_ounces)                    to="floz" ;;
        pint|pints)                                  to="pt" ;;
        quart|quarts)                                to="qt" ;;
        gallon|gallons)                              to="gal" ;;
        kph|km_h|kilometres_per_hour|kilometers_per_hour) to="kmh" ;;
        mph|miles_per_hour)                          to="mph" ;;
        m_s|metres_per_second|meters_per_second)     to="ms" ;;
        knot|knots)                                  to="knot" ;;
        mach)                                        to="mach" ;;
        speed_of_light)                              to="c" ;;
        pascal|pascals)                              to="pa" ;;
        kilopascal|kilopascals)                      to="kpa" ;;
        bar|bars)                                    to="bar" ;;
        atmosphere|atmospheres)                      to="atm" ;;
        pounds_per_square_inch)                      to="psi" ;;
        millimetre_of_mercury|millimeter_of_mercury|torr) to="mmhg" ;;
        joule|joules)                                to="j" ;;
        kilojoule|kilojoules)                        to="kj" ;;
        calorie|calories)                            to="cal" ;;
        kilocalorie|kilocalories)                    to="kcal" ;;
        kilowatt_hour|kilowatt_hours)                to="kwh" ;;
        electronvolt|electronvolts)                  to="ev" ;;
        british_thermal_unit|british_thermal_units)  to="btu" ;;
        watt|watts)                                  to="w" ;;
        kilowatt|kilowatts)                          to="kw" ;;
        horsepower)                                  to="hp" ;;
        bit|bits)                                    to="b" ;;
        kilobit|kilobits)                            to="kb" ;;
        megabit|megabits)                            to="mb" ;;
        gigabit|gigabits)                            to="gb" ;;
        terabit|terabits)                            to="tb" ;;
        petabit|petabits)                            to="pb" ;;
        kibibit|kibibits)                            to="kib" ;;
        mebibit|mebibits)                            to="mib" ;;
        gibibit|gibibits)                            to="gib" ;;
        tebibit|tebibits)                            to="tib" ;;
        pebibit|pebibits)                            to="pib" ;;
        sector|sectors|512b)                         to="sector" ;;
        sector4k|4k_sector|advanced_format)          to="sector4k" ;;
        femtosecond|femtoseconds)                    to="fs" ;;
        picosecond|picoseconds)                      to="ps" ;;
        nanosecond|nanoseconds|ns)                   to="ns" ;;
        microsecond|microseconds|us)                 to="us" ;;
        millisecond|milliseconds|ms)                 to="ms" ;;
        second|seconds|sec)                          to="s" ;;
        minute|minutes)                              to="min" ;;
        hour|hours|hr)                               to="h" ;;
        day|days)                                    to="d" ;;
        week|weeks)                                  to="week" ;;
        year|years|yr)                               to="year" ;;
        degree|degrees)                              to="deg" ;;
        radian|radians)                              to="rad" ;;
        gradian|gradians|gon)                        to="grad" ;;
        arcminute|arcminutes)                        to="arcmin" ;;
        arcsecond|arcseconds)                        to="arcsec" ;;
    esac

    [[ "$from" == "$to" ]] && echo "$value" && return 0


    local key="${from}:${to}"
    local expr

    case "$key" in

    # --- Temperature ---
    celsius:fahrenheit  | c:f)    expr="$value * 9/5 + 32" ;;
    fahrenheit:celsius  | f:c)    expr="($value - 32) * 5/9" ;;
    celsius:kelvin      | c:k)    expr="$value + 273.15" ;;
    kelvin:celsius      | k:c)    expr="$value - 273.15" ;;
    fahrenheit:kelvin   | f:k)    expr="($value - 32) * 5/9 + 273.15" ;;
    kelvin:fahrenheit   | k:f)    expr="($value - 273.15) * 9/5 + 32" ;;

    # --- Length ---
    km:mi)              expr="$value * 0.621371" ;;
    mi:km)              expr="$value * 1.609344" ;;
    m:ft)               expr="$value * 3.28084" ;;
    ft:m)               expr="$value * 0.3048" ;;
    cm:in)              expr="$value * 0.393701" ;;
    in:cm)              expr="$value * 2.54" ;;
    m:yd)               expr="$value * 1.09361" ;;
    yd:m)               expr="$value * 0.9144" ;;
    mm:in)              expr="$value * 0.0393701" ;;
    in:mm)              expr="$value * 25.4" ;;
    m:km)               expr="$value / 1000" ;;
    km:m)               expr="$value * 1000" ;;
    cm:m)               expr="$value / 100" ;;
    m:cm)               expr="$value * 100" ;;
    mm:m)               expr="$value / 1000" ;;
    m:mm)               expr="$value * 1000" ;;
    cm:mm)              expr="$value * 10" ;;
    mm:cm)              expr="$value / 10" ;;
    nm_si:m)            expr="$value / 1000000000" ;;
    m:nm_si)            expr="$value * 1000000000" ;;
    pm:m)               expr="$value / 1000000000000" ;;
    m:pm)               expr="$value * 1000000000000" ;;
    fm:m)               expr="$value / 1000000000000000" ;;
    m:fm)               expr="$value * 1000000000000000" ;;
    fm:pm)              expr="$value / 1000" ;;
    pm:fm)              expr="$value * 1000" ;;
    nm_si:pm)           expr="$value * 1000" ;;
    pm:nm_si)           expr="$value / 1000" ;;
    nm_si:fm)           expr="$value * 1000000" ;;
    fm:nm_si)           expr="$value / 1000000" ;;
    nm:km)              expr="$value * 1.852" ;;
    km:nm)              expr="$value / 1.852" ;;
    ly:km)              expr="$value * 9460730472580.8" ;;
    km:ly)              expr="$value / 9460730472580.8" ;;
    lh:km)              expr="$value * 1079251200" ;;
    km:lh)              expr="$value / 1079251200" ;;
    ld:km)              expr="$value * 25902068371.2" ;;
    km:ld)              expr="$value / 25902068371.2" ;;
    lh:ly)              expr="$value / 8765.81" ;;
    ly:lh)              expr="$value * 8765.81" ;;
    ld:ly)              expr="$value / 365.25" ;;
    ly:ld)              expr="$value * 365.25" ;;
    ld:lh)              expr="$value * 24" ;;
    lh:ld)              expr="$value / 24" ;;
    au:km)              expr="$value * 149597870.7" ;;
    km:au)              expr="$value / 149597870.7" ;;
    pc:ly)              expr="$value * 3.26156" ;;
    ly:pc)              expr="$value / 3.26156" ;;
    pc:km)              expr="$value * 30856775814913.7" ;;
    km:pc)              expr="$value / 30856775814913.7" ;;

    # --- Mass ---
    kg:lb)              expr="$value * 2.20462" ;;
    lb:kg)              expr="$value * 0.453592" ;;
    g:oz)               expr="$value * 0.035274" ;;
    oz:g)               expr="$value * 28.3495" ;;
    g:kg)               expr="$value / 1000" ;;
    kg:g)               expr="$value * 1000" ;;
    mg:g)               expr="$value / 1000" ;;
    g:mg)               expr="$value * 1000" ;;
    t:kg)               expr="$value * 1000" ;;
    kg:t)               expr="$value / 1000" ;;
    t:lb)               expr="$value * 2204.62" ;;
    lb:t)               expr="$value / 2204.62" ;;
    st:kg)              expr="$value * 6.35029" ;;
    kg:st)              expr="$value / 6.35029" ;;

    # --- Volume ---
    l:gal)              expr="$value * 0.264172" ;;
    gal:l)              expr="$value * 3.78541" ;;
    ml:floz)            expr="$value * 0.033814" ;;
    floz:ml)            expr="$value * 29.5735" ;;
    l:pt)               expr="$value * 2.11338" ;;
    pt:l)               expr="$value / 2.11338" ;;
    ml:l)               expr="$value / 1000" ;;
    l:ml)               expr="$value * 1000" ;;
    l:qt)               expr="$value * 1.05669" ;;
    qt:l)               expr="$value / 1.05669" ;;
    m3:l)               expr="$value * 1000" ;;
    l:m3)               expr="$value / 1000" ;;
    tsp:ml)             expr="$value * 4.92892" ;;
    ml:tsp)             expr="$value / 4.92892" ;;
    tbsp:ml)            expr="$value * 14.7868" ;;
    ml:tbsp)            expr="$value / 14.7868" ;;

    # --- Speed ---
    kmh:mph)            expr="$value * 0.621371" ;;
    mph:kmh)            expr="$value * 1.609344" ;;
    ms:kmh)             expr="$value * 3.6" ;;
    kmh:ms)             expr="$value / 3.6" ;;
    ms:mph)             expr="$value * 2.23694" ;;
    mph:ms)             expr="$value / 2.23694" ;;
    knot:kmh)           expr="$value * 1.852" ;;
    kmh:knot)           expr="$value / 1.852" ;;
    knot:mph)           expr="$value * 1.15078" ;;
    mph:knot)           expr="$value / 1.15078" ;;
    mach:ms)            expr="$value * 343" ;;
    ms:mach)            expr="$value / 343" ;;
    c:ms)               expr="299792458" ;;

    # --- Pressure ---
    pa:psi)             expr="$value * 0.000145038" ;;
    psi:pa)             expr="$value * 6894.76" ;;
    atm:pa)             expr="$value * 101325" ;;
    pa:atm)             expr="$value / 101325" ;;
    bar:pa)             expr="$value * 100000" ;;
    pa:bar)             expr="$value / 100000" ;;
    atm:bar)            expr="$value * 1.01325" ;;
    bar:atm)            expr="$value / 1.01325" ;;
    mmhg:pa)            expr="$value * 133.322" ;;
    pa:mmhg)            expr="$value / 133.322" ;;

    # --- Energy ---
    j:cal)              expr="$value * 0.239006" ;;
    cal:j)              expr="$value * 4.18400" ;;
    j:kwh)              expr="$value / 3600000" ;;
    kwh:j)              expr="$value * 3600000" ;;
    j:btu)              expr="$value * 0.000947817" ;;
    btu:j)              expr="$value / 0.000947817" ;;
    ev:j)               expr="$value * 0.0000000000000000001602176634" ;;
    j:ev)               expr="$value / 0.0000000000000000001602176634" ;;
    kcal:j)             expr="$value * 4184" ;;
    j:kcal)             expr="$value / 4184" ;;

    # --- Power ---
    w:hp)               expr="$value * 0.00134102" ;;
    hp:w)               expr="$value / 0.00134102" ;;
    w:kw)               expr="$value / 1000" ;;
    kw:w)               expr="$value * 1000" ;;
    kw:hp)              expr="$value * 1.34102" ;;
    hp:kw)              expr="$value / 1.34102" ;;

    # --- Digital storage ---
    b:kb)               expr="$value / 1000" ;;
    kb:b)               expr="$value * 1000" ;;
    b:mb)               expr="$value / 1000000" ;;
    mb:b)               expr="$value * 1000000" ;;
    b:gb)               expr="$value / 1000000000" ;;
    gb:b)               expr="$value * 1000000000" ;;
    b:tb)               expr="$value / 1000000000000" ;;
    tb:b)               expr="$value * 1000000000000" ;;
    kb:mb)              expr="$value / 1000" ;;
    mb:kb)              expr="$value * 1000" ;;
    mb:gb)              expr="$value / 1000" ;;
    gb:mb)              expr="$value * 1000" ;;
    gb:tb)              expr="$value / 1000" ;;
    tb:gb)              expr="$value * 1000" ;;
    tb:pb)              expr="$value / 1000" ;;
    pb:tb)              expr="$value * 1000" ;;
    b:kib)              expr="$value / 1024" ;;
    kib:b)              expr="$value * 1024" ;;
    b:mib)              expr="$value / 1048576" ;;
    mib:b)              expr="$value * 1048576" ;;
    b:gib)              expr="$value / 1073741824" ;;
    gib:b)              expr="$value * 1073741824" ;;
    b:tib)              expr="$value / 1099511627776" ;;
    tib:b)              expr="$value * 1099511627776" ;;
    kib:mib)            expr="$value / 1024" ;;
    mib:kib)            expr="$value * 1024" ;;
    mib:gib)            expr="$value / 1024" ;;
    gib:mib)            expr="$value * 1024" ;;
    gib:tib)            expr="$value / 1024" ;;
    tib:gib)            expr="$value * 1024" ;;
    tib:pib)            expr="$value / 1024" ;;
    pib:tib)            expr="$value * 1024" ;;
    sector:b)           expr="$value * 512" ;;
    b:sector)           expr="$value / 512" ;;
    sector:kb)          expr="$value / 2" ;;
    kb:sector)          expr="$value * 2" ;;
    sector:mb)          expr="$value / 2000" ;;
    mb:sector)          expr="$value * 2000" ;;
    sector:gb)          expr="$value / 2000000" ;;
    gb:sector)          expr="$value * 2000000" ;;
    sector:kib)         expr="$value / 2" ;;
    kib:sector)         expr="$value * 2" ;;
    sector:mib)         expr="$value / 2048" ;;
    mib:sector)         expr="$value * 2048" ;;
    sector:gib)         expr="$value / 2097152" ;;
    gib:sector)         expr="$value * 2097152" ;;
    sector4k:b)         expr="$value * 4096" ;;
    b:sector4k)         expr="$value / 4096" ;;
    sector4k:kib)       expr="$value * 4" ;;
    kib:sector4k)       expr="$value / 4" ;;
    sector4k:mib)       expr="$value / 256" ;;
    mib:sector4k)       expr="$value * 256" ;;
    sector4k:gib)       expr="$value / 262144" ;;
    gib:sector4k)       expr="$value * 262144" ;;
    sector:sector4k)    expr="$value / 8" ;;
    sector4k:sector)    expr="$value * 8" ;;

    # --- Time ---
    s:ms)               expr="$value * 1000" ;;
    ms:s)               expr="$value / 1000" ;;
    s:us)               expr="$value * 1000000" ;;
    us:s)               expr="$value / 1000000" ;;
    s:ns)               expr="$value * 1000000000" ;;
    ns:s)               expr="$value / 1000000000" ;;
    s:ps)               expr="$value * 1000000000000" ;;
    ps:s)               expr="$value / 1000000000000" ;;
    s:fs)               expr="$value * 1000000000000000" ;;
    fs:s)               expr="$value / 1000000000000000" ;;
    ms:us)              expr="$value * 1000" ;;
    us:ms)              expr="$value / 1000" ;;
    us:ns)              expr="$value * 1000" ;;
    ns:us)              expr="$value / 1000" ;;
    ns:ps)              expr="$value * 1000" ;;
    ps:ns)              expr="$value / 1000" ;;
    ps:fs)              expr="$value * 1000" ;;
    fs:ps)              expr="$value / 1000" ;;
    fs:ns)              expr="$value / 1000000" ;;
    ns:fs)              expr="$value * 1000000" ;;
    fs:us)              expr="$value / 1000000000" ;;
    us:fs)              expr="$value * 1000000000" ;;
    fs:ms)              expr="$value / 1000000000000" ;;
    ms:fs)              expr="$value * 1000000000000" ;;
    s:min)              expr="$value / 60" ;;
    min:s)              expr="$value * 60" ;;
    min:ms)             expr="$value * 60000" ;;
    ms:min)             expr="$value / 60000" ;;
    min:h)              expr="$value / 60" ;;
    h:min)              expr="$value * 60" ;;
    h:s)                expr="$value * 3600" ;;
    s:h)                expr="$value / 3600" ;;
    h:d)                expr="$value / 24" ;;
    d:h)                expr="$value * 24" ;;
    d:s)                expr="$value * 86400" ;;
    s:d)                expr="$value / 86400" ;;
    d:week)             expr="$value / 7" ;;
    week:d)             expr="$value * 7" ;;
    d:year)             expr="$value / 365.25" ;;
    year:d)             expr="$value * 365.25" ;;

    # --- Angle ---
    deg:rad)            expr="$value * 3.141592653589793238462643383279502884197169 / 180" ;;
    rad:deg)            expr="$value * 180 / 3.141592653589793238462643383279502884197169" ;;
    deg:grad)           expr="$value * 400 / 360" ;;
    grad:deg)           expr="$value * 360 / 400" ;;
    rad:grad)           expr="$value * 200 / 3.141592653589793238462643383279502884197169" ;;
    grad:rad)           expr="$value * 3.141592653589793238462643383279502884197169 / 200" ;;
    deg:arcmin)         expr="$value * 60" ;;
    arcmin:deg)         expr="$value / 60" ;;
    deg:arcsec)         expr="$value * 3600" ;;
    arcsec:deg)         expr="$value / 3600" ;;
    arcmin:arcsec)      expr="$value * 60" ;;
    arcsec:arcmin)      expr="$value / 60" ;;

    *)
        echo "math::unitconvert: unknown conversion '${from}' → '${to}'" >&2
        return 1
        ;;
    esac

    math::bc "$expr" "$scale"
}

# ==============================================================================
# TENSOR
# ==============================================================================
# Format: "shape N M K: v1 v2 v3 ..."  (row-major, space-separated)
# Generalizes math::matrix ("NxM" "a b c d") to N dimensions.

_math::tensor_shape() { local t=$1; echo "${t%%:*}"; }
_math::tensor_shape_dims() { local s; s=$(_math::tensor_shape "$1"); echo "${s#shape }"; }
_math::tensor_data() { local t=$1 d; d="${t#*: }"; [[ "$d" == "$t" ]] && echo "" || echo "$d"; }

# N-D coords (comma-sep) + dims → flat offset
_math::tensor_offset() {
    local dims=$1 indices=$2
    local -a d i
    read -ra d <<< "$dims"
    IFS=',' read -ra i <<< "$indices"
    local off=0 j
    for ((j = 0; j < ${#i[@]}; j++)); do
        (( off = off * d[j] + i[j] ))
    done
    echo "$off"
}

math::tensor::new() {
    local shape=$1 data=${2:-}
    local -a dims; read -ra dims <<< "$shape"
    local size=1 d
    for d in "${dims[@]}"; do (( size *= d )); done
    if [[ -n "$data" ]]; then
        echo "shape $shape: $data"
    else
        local z; z=$(printf '0 %.0s' $(seq 1 $size))
        echo "shape $shape: ${z% }"
    fi
}

math::tensor::shape()  { _math::tensor_shape_dims "$1"; }
math::tensor::rank()   { local d; d=$(_math::tensor_shape_dims "$1"); local -a a; read -ra a <<< "$d"; echo "${#a[@]}"; }
math::tensor::size()   { local d; d=$(_math::tensor_data "$1"); local -a a; read -ra a <<< "$d"; echo "${#a[@]}"; }

math::tensor::get() {
    local t=$1 idx=$2
    local dims data off
    dims=$(_math::tensor_shape_dims "$t")
    data=$(_math::tensor_data "$t")
    off=$(_math::tensor_offset "$dims" "$idx")
    local -a v; read -ra v <<< "$data"
    echo "${v[$off]}"
}

math::tensor::set() {
    local t=$1 idx=$2 val=$3
    local dims data off
    dims=$(_math::tensor_shape_dims "$t")
    data=$(_math::tensor_data "$t")
    off=$(_math::tensor_offset "$dims" "$idx")
    local -a v; read -ra v <<< "$data"
    v[$off]=$val
    echo "shape $dims: ${v[*]}"
}

math::tensor::add() {
    local da db
    da=$(_math::tensor_data "$1"); db=$(_math::tensor_data "$2")
    local -a va vb r
    read -ra va <<< "$da"; read -ra vb <<< "$db"
    local i
    for ((i = 0; i < ${#va[@]}; i++)); do
        r+=($(echo "${va[$i]} + ${vb[$i]}" | bc -l 2>/dev/null || pfloat::fixed::add "${va[$i]}" "${vb[$i]}"))
    done
    echo "shape $(_math::tensor_shape_dims "$1"): ${r[*]}"
}

math::tensor::sub() {
    local da db
    da=$(_math::tensor_data "$1"); db=$(_math::tensor_data "$2")
    local -a va vb r; read -ra va <<< "$da"; read -ra vb <<< "$db"
    local i
    for ((i = 0; i < ${#va[@]}; i++)); do
        r+=($(echo "${va[$i]} - ${vb[$i]}" | bc -l 2>/dev/null || pfloat::fixed::sub "${va[$i]}" "${vb[$i]}"))
    done
    echo "shape $(_math::tensor_shape_dims "$1"): ${r[*]}"
}

math::tensor::mul() {
    local da db
    da=$(_math::tensor_data "$1"); db=$(_math::tensor_data "$2")
    local -a va vb r; read -ra va <<< "$da"; read -ra vb <<< "$db"
    local i
    for ((i = 0; i < ${#va[@]}; i++)); do
        r+=($(echo "${va[$i]} * ${vb[$i]}" | bc -l 2>/dev/null || pfloat::fixed::mul "${va[$i]}" "${vb[$i]}"))
    done
    echo "shape $(_math::tensor_shape_dims "$1"): ${r[*]}"
}

math::tensor::scale() {
    local d f=$2; d=$(_math::tensor_data "$1")
    local -a v r; read -ra v <<< "$d"
    local i
    for ((i = 0; i < ${#v[@]}; i++)); do
        r+=($(echo "${v[$i]} * $f" | bc -l 2>/dev/null || pfloat::fixed::mul "${v[$i]}" "$f"))
    done
    echo "shape $(_math::tensor_shape_dims "$1"): ${r[*]}"
}

math::tensor::dot() {
    local da db; da=$(_math::tensor_data "$1"); db=$(_math::tensor_data "$2")
    local -a va vb; read -ra va <<< "$da"; read -ra vb <<< "$db"
    local i sum=0
    for ((i = 0; i < ${#va[@]}; i++)); do
        sum=$(echo "$sum + ${va[$i]} * ${vb[$i]}" | bc -l 2>/dev/null || { local p; p=$(pfloat::fixed::mul "${va[$i]}" "${vb[$i]}"); pfloat::fixed::add "$sum" "$p"; })
    done
    echo "$sum"
}

math::tensor::matmul() {
    local sa sb da db
    sa=$(_math::tensor_shape_dims "$1"); sb=$(_math::tensor_shape_dims "$2")
    da=$(_math::tensor_data "$1"); db=$(_math::tensor_data "$2")
    local -a ad bd av bv
    read -ra ad <<< "$sa"; read -ra bd <<< "$sb"
    read -ra av <<< "$da"; read -ra bv <<< "$db"
    local M=${ad[0]} K=${ad[-1]} N=${bd[-1]}
    local bc_scr; bc_scr=$(mktemp "/tmp/fsbshf-tmm.XXXXXX")
    echo "scale=10" > "$bc_scr"
    local i j k
    for ((i = 0; i < M; i++)); do
        for ((j = 0; j < N; j++)); do
            printf "0" >> "$bc_scr"
            for ((k = 0; k < K; k++)); do
                printf " + %s * %s" "${av[$((i * K + k))]}" "${bv[$((k * N + j))]}" >> "$bc_scr"
            done
            printf "\n" >> "$bc_scr"
        done
    done
    local -a r
    while IFS= read -r val; do r+=("$val"); done < <(bc -l "$bc_scr" 2>/dev/null)
    rm -f "$bc_scr"
    echo "shape $M $N: ${r[*]}"
}

math::tensor::transpose() {
    local t=$1 perm=$2
    local dims data; dims=$(_math::tensor_shape_dims "$t"); data=$(_math::tensor_data "$t")
    local -a d v pa nd; read -ra d <<< "$dims"; read -ra v <<< "$data"
    IFS=',' read -ra pa <<< "$perm"
    local r=${#d[@]} i total=1
    for ((i = 0; i < r; i++)); do nd+=("${d[${pa[$i]}]}"); (( total *= d[i] )); done

    # Compute old and new strides (row-major, last dim stride=1)
    local -a old_str new_str
    local s=1
    for ((i = r - 1; i >= 0; i--)); do old_str[$i]=$s; (( s *= d[i] )); done
    s=1
    for ((i = r - 1; i >= 0; i--)); do new_str[$i]=$s; (( s *= nd[i] )); done

    # Inverse permutation: perm[i] = old axis → new axis position
    local -a inv_pa
    for ((i = 0; i < r; i++)); do inv_pa[${pa[$i]}]=$i; done

    local -a res new_coords
    local n
    for ((n = 0; n < total; n++)); do
        local rem=$n old_off=0 c
        for ((c = 0; c < r; c++)); do
            new_coords[$c]=$((rem / new_str[c]))
            (( rem %= new_str[c] ))
        done
        # Map new coords → old coords: new axis c came from old axis pa[c]
        for ((c = 0; c < r; c++)); do
            (( old_off += new_coords[c] * old_str[${pa[$c]}] ))
        done
        res+=("${v[$old_off]}")
    done
    echo "shape ${nd[*]}: ${res[*]}"
}

math::tensor::reshape()  { echo "shape $2: $(_math::tensor_data "$1")"; }
math::tensor::flatten()  { local s; s=$(math::tensor::size "$1"); echo "shape $s: $(_math::tensor_data "$1")"; }

math::tensor::reduce::sum() {
    local t=$1 axis=${2:--1}
    local dims data; dims=$(_math::tensor_shape_dims "$t"); data=$(_math::tensor_data "$t")
    local -a d v; read -ra d <<< "$dims"; read -ra v <<< "$data"
    local r=${#d[@]}
    if (( axis == -1 )); then
        local s=0 x; for x in "${v[@]}"; do s=$(echo "$s + $x" | bc -l 2>/dev/null || pfloat::fixed::add "$s" "$x"); done
        echo "shape 1: $s"; return
    fi
    local -a nd=(); local i
    for ((i = 0; i < r; i++)); do (( i != axis )) && nd+=("${d[$i]}"); done
    [[ ${#nd[@]} -eq 0 ]] && nd=(1)
    local rsz=${d[$axis]} osz=1 isz=1
    for ((i = 0; i < axis; i++)); do (( osz *= d[i] )); done
    for ((i = axis + 1; i < r; i++)); do (( isz *= d[i] )); done
    local -a res; local o rr k
    for ((o = 0; o < osz; o++)); do
        for ((rr = 0; rr < isz; rr++)); do
            local sum=0
            for ((k = 0; k < rsz; k++)); do
                local off=$((o * rsz * isz + k * isz + rr))
                sum=$(echo "$sum + ${v[$off]}" | bc -l 2>/dev/null || pfloat::fixed::add "$sum" "${v[$off]}")
            done
            res+=("$sum")
        done
    done
    echo "shape ${nd[*]}: ${res[*]}"
}

math::tensor::reduce::max() {
    local t=$1 axis=${2:--1}
    local dims data; dims=$(_math::tensor_shape_dims "$t"); data=$(_math::tensor_data "$t")
    local -a d v; read -ra d <<< "$dims"; read -ra v <<< "$data"
    local r=${#d[@]}
    if (( axis == -1 )); then
        local mx=-999999999999999 x
        for x in "${v[@]}"; do (( $(echo "$x > $mx" | bc -l 2>/dev/null) )) && mx=$x; done
        echo "shape 1: $mx"; return
    fi
    local -a nd=(); local i
    for ((i = 0; i < r; i++)); do (( i != axis )) && nd+=("${d[$i]}"); done
    [[ ${#nd[@]} -eq 0 ]] && nd=(1)
    local rsz=${d[$axis]} osz=1 isz=1
    for ((i = 0; i < axis; i++)); do (( osz *= d[i] )); done
    for ((i = axis + 1; i < r; i++)); do (( isz *= d[i] )); done
    local -a res; local o rr k
    for ((o = 0; o < osz; o++)); do
        for ((rr = 0; rr < isz; rr++)); do
            local mx=-999999999999999
            for ((k = 0; k < rsz; k++)); do
                local off=$((o * rsz * isz + k * isz + rr))
                (( $(echo "${v[$off]} > $mx" | bc -l 2>/dev/null) )) && mx=${v[$off]}
            done
            res+=("$mx")
        done
    done
    echo "shape ${nd[*]}: ${res[*]}"
}
# net.sh — bash-frameheader networking lib
# Requires: runtime.sh (runtime::has_command)

# ==============================================================================
# CONNECTIVITY
# ==============================================================================

# Check if the system has a working internet connection
# Tries multiple endpoints in case one is down
net::is_online() {
    local endpoints=("8.8.8.8" "1.1.1.1" "9.9.9.9")
    for endpoint in "${endpoints[@]}"; do
        if ping -c 1 -W 2 "$endpoint" >/dev/null 2>&1; then
            return 0
        fi
    done
    return 1
}

# Check if a specific host is reachable
# Usage: net::can_reach host [timeout_seconds]
net::can_reach() {
    local host="$1" timeout="${2:-2}"
    ping -c 1 -W "$timeout" "$host" >/dev/null 2>&1
}

# Ping a host and return average round-trip time in ms
# Usage: net::ping host [count]
net::ping() {
    local host="$1" count="${2:-4}"
    ping -c "$count" "$host" 2>/dev/null | \
        tail -1 | awk -F'/' '{print $5}'
}

# Check if a TCP port is open on a host
# Usage: net::port::is_open host port [timeout]
net::port::is_open() {
    local host="$1" port="$2" timeout="${3:-2}"
    if runtime::has_command nc; then
        nc -z -w "$timeout" "$host" "$port" >/dev/null 2>&1
    elif runtime::has_command bash; then
        # Pure bash /dev/tcp trick
        (echo >/dev/tcp/"$host"/"$port") >/dev/null 2>&1
    else
        return 1
    fi
}

# Wait until a port is open (useful for service readiness checks)
# Usage: net::port::wait host port [timeout_seconds] [interval]
net::port::wait() {
    local host="$1" port="$2" timeout="${3:-30}" interval="${4:-1}"
    local elapsed=0
    while (( elapsed < timeout )); do
        net::port::is_open "$host" "$port" && return 0
        sleep "$interval"
        (( elapsed += interval ))
    done
    return 1
}

# Scan common ports on a host, print open ones
# Usage: net::port::scan host [start_port] [end_port]
net::port::scan() {
    local host="$1" start="${2:-1}" end="${3:-1024}"
    local port
    for (( port=start; port<=end; port++ )); do
        net::port::is_open "$host" "$port" 1 && echo "$port"
    done
}

# ==============================================================================
# IP ADDRESS
# ==============================================================================

# Get local IP address (first non-loopback)
net::ip::local() {
    if runtime::has_command ip; then
        ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}'
    elif runtime::has_command ifconfig; then
        ifconfig 2>/dev/null | awk '/inet /{print $2}' | grep -v '127.0.0.1' | head -1
    fi
}

# Get public IP address
# Tries multiple services with fallback
net::ip::public() {
    local services=(
        "https://api.ipify.org"
        "https://ifconfig.me/ip"
        "https://icanhazip.com"
        "https://checkip.amazonaws.com"
    )
    local fetcher
    if runtime::has_command curl; then
        fetcher="curl -sf --max-time 5"
    elif runtime::has_command wget; then
        fetcher="wget -qO- --timeout=5"
    else
        echo "net::ip::public: requires curl or wget" >&2
        return 1
    fi

    for svc in "${services[@]}"; do
        local result
        result=$($fetcher "$svc" 2>/dev/null | tr -d '[:space:]')
        if [[ -n "$result" ]]; then
            echo "$result"
            return 0
        fi
    done

    echo "net::ip::public: all endpoints failed" >&2
    return 1
}

# Get all local IP addresses (one per line)
net::ip::all() {
    if runtime::has_command ip; then
        ip addr show 2>/dev/null | awk '/inet /{gsub(/\/.*/, "", $2); print $2}'
    elif runtime::has_command ifconfig; then
        ifconfig 2>/dev/null | awk '/inet /{print $2}'
    fi
}

# Check if a string is a valid IPv4 address
net::ip::is_valid_v4() {
    local ip="$1"
    [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
    local IFS='.'
# shellcheck disable=SC2206
    local -a octets=($ip)
    for o in "${octets[@]}"; do
        (( o >= 0 && o <= 255 )) || return 1
    done
}

# Check if a string is a valid IPv6 address (basic check)
net::ip::is_valid_v6() {
    [[ "$1" =~ ^([0-9a-fA-F]{0,4}:){2,7}[0-9a-fA-F]{0,4}$ ]]
}

# Check if IP is in private range
net::ip::is_private() {
    local ip="$1"
    net::ip::is_valid_v4 "$ip" || return 1
    [[ "$ip" =~ ^10\. ]] && return 0
    [[ "$ip" =~ ^192\.168\. ]] && return 0
    [[ "$ip" =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]] && return 0
    return 1
}

# Check if IP is loopback
net::ip::is_loopback() {
    [[ "$1" == "127."* || "$1" == "::1" ]]
}

# ==============================================================================
# HOSTNAME / DNS
# ==============================================================================

# Get the system hostname
net::hostname() {
    hostname 2>/dev/null || cat /etc/hostname 2>/dev/null
}

# Get the fully qualified domain name
net::hostname::fqdn() {
    hostname -f 2>/dev/null
}

# Resolve hostname to IP
# Usage: net::resolve hostname
net::resolve() {
    if runtime::has_command dig; then
        dig +short "$1" 2>/dev/null | grep -E '^[0-9]+\.' | head -1
    elif runtime::has_command nslookup; then
        nslookup "$1" 2>/dev/null | awk '/^Address:/{print $2}' | grep -v '#' | head -1
    elif runtime::has_command getent; then
        getent hosts "$1" 2>/dev/null | awk '{print $1}' | head -1
    else
        ping -c 1 "$1" 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
    fi
}

# Reverse DNS lookup — IP to hostname
# Usage: net::resolve::reverse ip
net::resolve::reverse() {
    if runtime::has_command dig; then
        dig +short -x "$1" 2>/dev/null
    elif runtime::has_command nslookup; then
        nslookup "$1" 2>/dev/null | awk '/name =/{print $NF}'
    elif runtime::has_command getent; then
        getent hosts "$1" 2>/dev/null | awk '{print $NF}'
    fi
}

# Get all DNS records of a type
# Usage: net::dns::records hostname [type]
net::dns::records() {
    local host="$1" type="${2:-A}"
    if runtime::has_command dig; then
        dig +short "$host" "$type" 2>/dev/null
    elif runtime::has_command nslookup; then
        nslookup -type="$type" "$host" 2>/dev/null
    fi
}

# Get MX records for a domain
net::dns::mx() {
    net::dns::records "$1" MX
}

# Get TXT records (useful for SPF, DKIM etc.)
net::dns::txt() {
    net::dns::records "$1" TXT
}

# Get nameservers for a domain
net::dns::ns() {
    net::dns::records "$1" NS
}

# Check DNS propagation — query multiple public resolvers
# Usage: net::dns::propagation hostname
net::dns::propagation() {
    local host="$1"
    local -A resolvers=(
        ["Google"]="8.8.8.8"
        ["Cloudflare"]="1.1.1.1"
        ["Quad9"]="9.9.9.9"
        ["OpenDNS"]="208.67.222.222"
    )
    if ! runtime::has_command dig; then
        echo "net::dns::propagation: requires dig" >&2
        return 1
    fi
    for name in "${!resolvers[@]}"; do
        local ip="${resolvers[$name]}"
        local result
        result=$(dig +short "@$ip" "$host" 2>/dev/null | tr '\n' ' ')
        printf '%-12s %s\n' "$name" "${result:-[no result]}"
    done
}

# ==============================================================================
# NETWORK INTERFACES
# ==============================================================================

# List all network interfaces
net::interface::list() {
    if runtime::has_command ip; then
        ip link show 2>/dev/null | awk -F': ' '/^[0-9]+:/{print $2}' | tr -d ' '
    elif runtime::has_command ifconfig; then
        ifconfig -l 2>/dev/null | tr ' ' '\n'
    elif [[ -d /sys/class/net ]]; then
        ls /sys/class/net/
    fi
}

# Get MAC address of an interface
# Usage: net::mac interface
net::mac() {
    local iface="${1:-eth0}"
    if [[ -f "/sys/class/net/$iface/address" ]]; then
        cat "/sys/class/net/$iface/address"
    elif runtime::has_command ip; then
        ip link show "$iface" 2>/dev/null | awk '/ether/{print $2}'
    elif runtime::has_command ifconfig; then
        ifconfig "$iface" 2>/dev/null | awk '/ether|HWaddr/{print $2}'
    fi
}

# Get interface speed in Mbps
net::interface::speed() {
    local iface="${1:-eth0}"
    if [[ -f "/sys/class/net/$iface/speed" ]]; then
        cat "/sys/class/net/$iface/speed" > /dev/null 2>&1 || echo "Unknown"
    fi
}

# Check if an interface is up
net::interface::is_up() {
    local iface="$1"
    if [[ -f "/sys/class/net/$iface/operstate" ]]; then
        [[ "$(cat "/sys/class/net/$iface/operstate")" == "up" ]]
    elif runtime::has_command ip; then
        ip link show "$iface" 2>/dev/null | grep -q 'state UP'
    fi
}

# Get default gateway
net::gateway() {
    if runtime::has_command ip; then
        ip route show default 2>/dev/null | awk '{print $3; exit}'
    elif runtime::has_command route; then
        route -n 2>/dev/null | awk '/^0\.0\.0\.0/{print $2; exit}'
    fi
}

# Get network interface statistics (rx/tx bytes)
# Usage: net::interface::stats interface
net::interface::stat() {
    local iface="${1:-eth0}"
    local rx tx
    if [[ -f "/sys/class/net/$iface/statistics/rx_bytes" ]]; then
        rx=$(cat "/sys/class/net/$iface/statistics/rx_bytes")
        tx=$(cat "/sys/class/net/$iface/statistics/tx_bytes")
        echo "rx: $rx bytes"
        echo "tx: $tx bytes"
        return
    elif runtime::has_command ip; then
        ip -s link show "$iface" 2>/dev/null
        return
    fi

    return 1
}

net::interface::stat::rx() {
    local iface="${1:-eth0}"
    local rx
    if [[ -f "/sys/class/net/$iface/statistics/rx_bytes" ]]; then
        rx=$(cat "/sys/class/net/$iface/statistics/rx_bytes")
        echo "$rx bytes"
        return
    fi
    return 1
}

net::interface::stat::tx() {
    local iface="${1:-eth0}"
    local tx
    if [[ -f "/sys/class/net/$iface/statistics/tx_bytes" ]]; then
        tx=$(cat "/sys/class/net/$iface/statistics/tx_bytes")
        echo "$tx bytes"
        return
    fi
    return 1
}


# ==============================================================================
# FETCH / DOWNLOAD
# ==============================================================================

# Fetch URL contents — curl/wget with fallback
# Usage: net::fetch url [output_file]
net::fetch() {
    local url="$1" out="${2:--}"
    if runtime::has_command curl; then
        if [[ "$out" == "-" ]]; then
            curl -sfL --max-time 30 "$url"
        else
            curl -sfL --max-time 30 -o "$out" "$url"
        fi
    elif runtime::has_command wget; then
        if [[ "$out" == "-" ]]; then
            wget -qO- --timeout=30 "$url"
        else
            wget -qO "$out" --timeout=30 "$url"
        fi
    else
        echo "net::fetch: requires curl or wget" >&2
        return 1
    fi
}

# Fetch with progress bar
net::fetch::progress() {
    local url="$1"; local out="${2:-$(basename "$url")}"
    if runtime::has_command curl; then
        curl -L --progress-bar -o "$out" "$url"
    elif runtime::has_command wget; then
        wget --progress=bar -O "$out" "$url"
    else
        echo "net::fetch::progress: requires curl or wget" >&2
        return 1
    fi
}

# Fetch with retry on failure
# Usage: net::fetch::retry url [output] [retries] [delay]
net::fetch::retry() {
    local url="$1" out="${2:--}" retries="${3:-3}" delay="${4:-2}"
    local attempt=0
    while (( attempt < retries )); do
        net::fetch "$url" "$out" && return 0
        (( attempt++ ))
        echo "net::fetch::retry: attempt $attempt failed, retrying in ${delay}s..." >&2
        sleep "$delay"
    done
    echo "net::fetch::retry: all $retries attempts failed" >&2
    return 1
}

# Check HTTP status code of a URL
# Usage: net::http::status url
net::http::status() {
    if runtime::has_command curl; then
        curl -sLo /dev/null -w '%{http_code}' --max-time 10 "$1" 2>/dev/null
    elif runtime::has_command wget; then
        wget -qS --spider "$1" 2>&1 | awk '/HTTP\//{print $2}' | tail -1
    fi
}

# Check if a URL returns 200 OK
net::http::is_ok() {
    [[ "$(net::http::status "$1")" == "200" ]]
}

# Get response headers
net::http::headers() {
    if runtime::has_command curl; then
        curl -sI --max-time 10 "$1" 2>/dev/null
    elif runtime::has_command wget; then
        wget -qS --spider "$1" 2>&1
    fi
}

# ==============================================================================
# WHOIS / GEO
# ==============================================================================

# Basic whois lookup
net::whois() {
    if runtime::has_command whois; then
        whois "$1" 2>/dev/null
    else
        echo "net::whois: requires whois" >&2
        return 1
    fi
}

# Get geolocation info for an IP (uses ip-api.com free tier)
# Usage: net::ip::geo [ip]  (omit for public IP)
net::ip::geo() {
    local ip="${1:-}"
    local url="http://ip-api.com/json/${ip}"
    net::fetch "$url" 2>/dev/null
}
# needs runtime.sh
# i actually dont want to kms anymore i think
# shellcheck disable=SC2034,SC2046,SC2155
# numbers are scaled by 10^pfloat_SCALE
# pfloat_SCALE defaults to 5 (balance between precision and overflow prevention)
# For more precision, set pfloat_SCALE before sourcing (max recommended: 8 for 64-bit safety)
# Warning: setting scale to 10 will risk integer overflow.

pfloat_SCALE="${pfloat_SCALE:-5}"

_pfloat::_scale_factor() {
  local s="1" i
  for ((i = 0; i < pfloat_SCALE; i++)); do s+="0"; done
  echo "$s"
}

_pfloat::_to_scaled() {
  local num="$1"
  local sign="" int_part frac_part result

  if [[ "$num" == -* ]]; then
    sign="-"
    num="${num#-}"
  fi

  if [[ "$num" == *.* ]]; then
    int_part="${num%%.*}"
    frac_part="${num#*.}"
  else
    int_part="$num"
    frac_part=""
  fi

  int_part="${int_part#"${int_part%%[!0]*}"}"
  [[ -z "$int_part" ]] && int_part="0"

  while ((${#frac_part} < pfloat_SCALE)); do
    frac_part+="0"
  done
  frac_part="${frac_part:0:$pfloat_SCALE}"

  result="${int_part}${frac_part}"
  result="${result#"${result%%[!0]*}"}"
  [[ -z "$result" ]] && result="0"

  echo "${sign}${result}"
}

_pfloat::_from_scaled() {
  local num="$1"
  local sign="" int_part frac_part

  if [[ "$num" == -* ]]; then
    sign="-"
    num="${num#-}"
  fi

  num="${num#"${num%%[!0]*}"}"
  [[ -z "$num" ]] && num="0"

  while ((${#num} <= pfloat_SCALE)); do
    num="0${num}"
  done

  int_part="${num:0:${#num}-pfloat_SCALE}"
  frac_part="${num:${#num}-pfloat_SCALE}"

  while [[ "$frac_part" == *0 ]]; do
    frac_part="${frac_part%0}"
  done

  if [[ -z "$frac_part" ]]; then
    echo "${sign}${int_part}"
  else
    echo "${sign}${int_part}.${frac_part}"
  fi
}

_pfloat::_abs() {
  local n="$1"
  [[ "$n" == -* ]] && echo "${n#-}" || echo "$n"
}

# Check if a value is an integer (no decimal point)
_pfloat::_is_integer() {
  [[ "$1" =~ ^-?[0-9]+$ ]]
}

pfloat::fixed::add() {
  local a_scaled b_scaled result
  a_scaled=$(_pfloat::_to_scaled "$1")
  b_scaled=$(_pfloat::_to_scaled "$2")
  result=$((a_scaled + b_scaled))
  _pfloat::_from_scaled "$result"
}

pfloat::fixed::sub() {
  local a_scaled b_scaled result
  a_scaled=$(_pfloat::_to_scaled "$1")
  b_scaled=$(_pfloat::_to_scaled "$2")
  result=$((a_scaled - b_scaled))
  _pfloat::_from_scaled "$result"
}

pfloat::fixed::mul() {
  local a="$1" b="$2"

  # Fast path for integers - avoid overflow from scaling
  if _pfloat::_is_integer "$a" && _pfloat::_is_integer "$b"; then
    echo "$((a * b))"
    return
  fi

  local a_scaled b_scaled result scale_factor
  a_scaled=$(_pfloat::_to_scaled "$a")
  b_scaled=$(_pfloat::_to_scaled "$b")
  scale_factor=$(_pfloat::_scale_factor)
  result=$(((a_scaled * b_scaled) / scale_factor))
  _pfloat::_from_scaled "$result"
}

pfloat::fixed::div() {
  local a_scaled b_scaled result scale_factor
  a_scaled=$(_pfloat::_to_scaled "$1")
  b_scaled=$(_pfloat::_to_scaled "$2")

  if ((b_scaled == 0)); then
    echo "pfloat::fixed::div: division by zero" >&2
    return 1
  fi

  scale_factor=$(_pfloat::_scale_factor)
  result=$(((a_scaled * scale_factor) / b_scaled))
  _pfloat::_from_scaled "$result"
}

pfloat::fixed::mod() {
  local a_scaled b_scaled result
  a_scaled=$(_pfloat::_to_scaled "$1")
  b_scaled=$(_pfloat::_to_scaled "$2")

  if ((b_scaled == 0)); then
    echo "pfloat::fixed::mod: division by zero" >&2
    return 1
  fi

  result=$((a_scaled % b_scaled))
  _pfloat::_from_scaled "$result"
}

pfloat::fixed::neg() {
  local a_scaled
  a_scaled=$(_pfloat::_to_scaled "$1")
  _pfloat::_from_scaled "$((-a_scaled))"
}

pfloat::fixed::abs() {
  local a_scaled
  a_scaled=$(_pfloat::_to_scaled "$1")
  a_scaled=$(_pfloat::_abs "$a_scaled")
  _pfloat::_from_scaled "$a_scaled"
}

pfloat::fixed::eq() {
  local a b
  a=$(_pfloat::_to_scaled "$1")
  b=$(_pfloat::_to_scaled "$2")
  ((a == b))
}

pfloat::fixed::ne() {
  local a b
  a=$(_pfloat::_to_scaled "$1")
  b=$(_pfloat::_to_scaled "$2")
  ((a != b))
}

pfloat::fixed::lt() {
  local a b
  a=$(_pfloat::_to_scaled "$1")
  b=$(_pfloat::_to_scaled "$2")
  ((a < b))
}

pfloat::fixed::le() {
  local a b
  a=$(_pfloat::_to_scaled "$1")
  b=$(_pfloat::_to_scaled "$2")
  ((a <= b))
}

pfloat::fixed::gt() {
  local a b
  a=$(_pfloat::_to_scaled "$1")
  b=$(_pfloat::_to_scaled "$2")
  ((a > b))
}

pfloat::fixed::ge() {
  local a b
  a=$(_pfloat::_to_scaled "$1")
  b=$(_pfloat::_to_scaled "$2")
  ((a >= b))
}

pfloat::fixed::is_zero() {
  local a
  a=$(_pfloat::_to_scaled "$1")
  ((a == 0))
}

pfloat::fixed::is_positive() {
  local a
  a=$(_pfloat::_to_scaled "$1")
  ((a > 0))
}

pfloat::fixed::is_negative() {
  local a
  a=$(_pfloat::_to_scaled "$1")
  ((a < 0))
}

pfloat::fixed::floor() {
  local a="$1" sign="" int_part frac_part

  if [[ "$a" == -* ]]; then
    sign="-"
    a="${a#-}"
  fi

  if [[ "$a" == *.* ]]; then
    int_part="${a%%.*}"
    frac_part="${a#*.}"
  else
    echo "$a"
    return
  fi

  [[ -z "$int_part" ]] && int_part="0"

  if [[ "$sign" == "-" ]] && [[ "$frac_part" != "0" ]] && [[ "$frac_part" != "" ]]; then
    int_part=$((int_part + 1))
    echo "-${int_part}"
  else
    echo "${sign}${int_part}"
  fi
}

pfloat::fixed::ceil() {
  local a="$1" sign="" int_part frac_part

  if [[ "$a" == -* ]]; then
    sign="-"
    a="${a#-}"
  fi

  if [[ "$a" == *.* ]]; then
    int_part="${a%%.*}"
    frac_part="${a#*.}"
  else
    echo "$a"
    return
  fi

  [[ -z "$int_part" ]] && int_part="0"

  if [[ "$frac_part" =~ [1-9] ]]; then
    if [[ "$sign" == "-" ]]; then
      echo "${sign}${int_part}"
    else
      echo "$((int_part + 1))"
    fi
  else
    echo "${sign}${int_part}"
  fi
}

pfloat::fixed::round() {
  local a="$1" sign="" int_part frac_part first_digit

  if [[ "$a" == -* ]]; then
    sign="-"
    a="${a#-}"
  fi

  if [[ "$a" == *.* ]]; then
    int_part="${a%%.*}"
    frac_part="${a#*.}"
  else
    echo "$a"
    return
  fi

  [[ -z "$int_part" ]] && int_part="0"
  first_digit="${frac_part:0:1}"

  if ((first_digit >= 5)); then
    if [[ "$sign" == "-" ]]; then
      echo "-$((int_part + 1))"
    else
      echo "$((int_part + 1))"
    fi
  else
    echo "${sign}${int_part}"
  fi
}

pfloat::fixed::trunc() {
  local a="$1"

  if [[ "$a" == *.* ]]; then
    a="${a%%.*}"
  fi

  [[ -z "$a" ]] && a="0"
  echo "$a"
}

pfloat::fixed::min() {
  local a b
  a=$(_pfloat::_to_scaled "$1")
  b=$(_pfloat::_to_scaled "$2")
  if ((a < b)); then
    _pfloat::_from_scaled "$a"
  else
    _pfloat::_from_scaled "$b"
  fi
}

pfloat::fixed::max() {
  local a b
  a=$(_pfloat::_to_scaled "$1")
  b=$(_pfloat::_to_scaled "$2")
  if ((a > b)); then
    _pfloat::_from_scaled "$a"
  else
    _pfloat::_from_scaled "$b"
  fi
}

pfloat::fixed::clamp() {
  local val_s lo_s hi_s
  val_s=$(_pfloat::_to_scaled "$1")
  lo_s=$(_pfloat::_to_scaled "$2")
  hi_s=$(_pfloat::_to_scaled "$3")

  if ((val_s < lo_s)); then
    _pfloat::_from_scaled "$lo_s"
  elif ((val_s > hi_s)); then
    _pfloat::_from_scaled "$hi_s"
  else
    _pfloat::_from_scaled "$val_s"
  fi
}

pfloat::fixed::sqr() {
  pfloat::fixed::mul "$1" "$1"
}

pfloat::fixed::sqrt() {
  local num="$1" iterations="${2:-20}"
  local guess prev_guess i

  if pfloat::fixed::is_negative "$num"; then
    echo "pfloat::fixed::sqrt: negative input" >&2
    return 1
  fi

  if pfloat::fixed::is_zero "$num"; then
    echo "0"
    return
  fi

  if pfloat::fixed::gt "$num" "1"; then
    guess=$(pfloat::fixed::div "$num" "2")
  else
    guess="1"
  fi

  for ((i = 0; i < iterations; i++)); do
    prev_guess="$guess"
    guess=$(pfloat::fixed::div $(pfloat::fixed::add "$guess" $(pfloat::fixed::div "$num" "$guess")) "2")

    if pfloat::fixed::eq "$guess" "$prev_guess"; then
      break
    fi
  done

  echo "$guess"
}

pfloat::fixed::pow() {
  local base="$1" exp="$2"
  local result="1"
  local neg_exp=0

  if ((exp < 0)); then
    neg_exp=1
    exp=$((-exp))
  fi

  while ((exp > 0)); do
    if ((exp % 2 == 1)); then
      result=$(pfloat::fixed::mul "$result" "$base")
    fi
    base=$(pfloat::fixed::mul "$base" "$base")
    exp=$((exp / 2))
  done

  if ((neg_exp)); then
    pfloat::fixed::div "1" "$result"
  else
    echo "$result"
  fi
}

pfloat::fixed::cbrt() {
  local num="$1" iterations="${2:-30}"
  local guess i sign=""

  if pfloat::fixed::is_negative "$num"; then
    sign="-"
    num=$(pfloat::fixed::neg "$num")
  fi

  if pfloat::fixed::is_zero "$num"; then
    echo "0"
    return
  fi

  guess=$(pfloat::fixed::div "$num" "3")
  [[ "$guess" == "0" ]] && guess="1"

  for ((i = 0; i < iterations; i++)); do
    local x2
    x2=$(pfloat::fixed::mul "$guess" "$guess")
    guess=$(pfloat::fixed::div $(pfloat::fixed::add $(pfloat::fixed::mul "2" "$guess") $(pfloat::fixed::div "$num" "$x2")) "3")
  done

  if [[ -n "$sign" ]]; then
    echo "-${guess}"
  else
    echo "$guess"
  fi
}

pfloat::fixed::sum() {
  local total="0"
  for n in "$@"; do
    total=$(pfloat::fixed::add "$total" "$n")
  done
  echo "$total"
}

pfloat::fixed::avg() {
  local count=$#
  ((count == 0)) && {
    echo "pfloat::fixed::avg: no arguments" >&2
    return 1
  }

  local total
  total=$(pfloat::fixed::sum "$@")
  pfloat::fixed::div "$total" "$count"
}

pfloat::fixed::lerp() {
  local a="$1" b="$2" t="$3"
  local diff scaled
  diff=$(pfloat::fixed::sub "$b" "$a")
  scaled=$(pfloat::fixed::mul "$diff" "$t")
  pfloat::fixed::add "$a" "$scaled"
}

pfloat::fixed::inv_lerp() {
  local v="$1" a="$2" b="$3"
  local num den
  num=$(pfloat::fixed::sub "$v" "$a")
  den=$(pfloat::fixed::sub "$b" "$a")
  pfloat::fixed::div "$num" "$den"
}

pfloat::fixed::map() {
  local v="$1" imin="$2" imax="$3" omin="$4" omax="$5"
  local t
  t=$(pfloat::fixed::inv_lerp "$v" "$imin" "$imax")
  pfloat::fixed::lerp "$omin" "$omax" "$t"
}

pfloat::fixed::normalize() {
  local v="$1" lo="$2" hi="$3"
  pfloat::fixed::inv_lerp "$v" "$lo" "$hi"
}

pfloat::fixed::percent() {
  local part="$1" total="$2"
  local ratio
  ratio=$(pfloat::fixed::div "$part" "$total")
  pfloat::fixed::mul "$ratio" "100"
}

pfloat::fixed::percent_of() {
  local pct="$1" total="$2"
  pfloat::fixed::mul "$total" $(pfloat::fixed::div "$pct" "100")
}

pfloat::fixed::percent_change() {
  local old="$1" new="$2"
  local diff
  diff=$(pfloat::fixed::sub "$new" "$old")
  pfloat::fixed::mul $(pfloat::fixed::div "$diff" "$old") "100"
}

pfloat::fixed::dist2() {
  local x1="$1" y1="$2" x2="$3" y2="$4"
  local dx dy dx2 dy2 sum
  dx=$(pfloat::fixed::sub "$x1" "$x2")
  dy=$(pfloat::fixed::sub "$y1" "$y2")
  dx2=$(pfloat::fixed::mul "$dx" "$dx")
  dy2=$(pfloat::fixed::mul "$dy" "$dy")
  sum=$(pfloat::fixed::add "$dx2" "$dy2")
  pfloat::fixed::sqrt "$sum"
}

pfloat::fixed::dist3() {
  local x1="$1" y1="$2" z1="$3" x2="$4" y2="$5" z2="$6"
  local dx dy dz dx2 dy2 dz2 sum
  dx=$(pfloat::fixed::sub "$x1" "$x2")
  dy=$(pfloat::fixed::sub "$y1" "$y2")
  dz=$(pfloat::fixed::sub "$z1" "$z2")
  dx2=$(pfloat::fixed::mul "$dx" "$dx")
  dy2=$(pfloat::fixed::mul "$dy" "$dy")
  dz2=$(pfloat::fixed::mul "$dz" "$dz")
  sum=$(pfloat::fixed::add "$dx2" "$dy2" "$dz2")
  pfloat::fixed::sqrt "$sum"
}

pfloat::fixed::sign() {
  local a="$1"
  if pfloat::fixed::is_negative "$a"; then
    echo "-1"
  elif pfloat::fixed::is_positive "$a"; then
    echo "1"
  else
    echo "0"
  fi
}

pfloat::fixed::recip() {
  pfloat::fixed::div "1" "$1"
}

pfloat::fixed::mean() {
  pfloat::fixed::avg "$1" "$2"
}

pfloat::fixed::geomean() {
  local a="$1" b="$2"
  local prod
  prod=$(pfloat::fixed::mul "$a" "$b")
  pfloat::fixed::sqrt "$prod"
}

pfloat::fixed::harmean() {
  local a="$1" b="$2"
  local sum prod
  sum=$(pfloat::fixed::add "$a" "$b")
  prod=$(pfloat::fixed::mul "$a" "$b")
  pfloat::fixed::div $(pfloat::fixed::mul "2" "$prod") "$sum"
}

pfloat::fixed::factorial() {
  local n="$1"
  local result="1" i

  if [[ "$n" == -* ]]; then
    echo "pfloat::fixed::factorial: negative input" >&2
    return 1
  fi

  n=$(pfloat::fixed::trunc "$n")

  for ((i = 2; i <= n; i++)); do
    result=$(pfloat::fixed::mul "$result" "$i")
  done
  echo "$result"
}

pfloat::fixed::sigmoid() {
  local x="$1"
  local neg_x exp_val

  if pfloat::fixed::is_negative "$x"; then
    neg_x=$(pfloat::fixed::neg "$x")
    exp_val=$(_pfloat::fixed::exp_approx "$neg_x")
    pfloat::fixed::div "1" $(pfloat::fixed::add "1" "$exp_val")
  else
    exp_val=$(_pfloat::fixed::exp_approx "$x")
    pfloat::fixed::div "$exp_val" $(pfloat::fixed::add "1" "$exp_val")
  fi
}

_pfloat::fixed::exp_approx() {
  local x="$1"
  local result="1" term="$1" i

  for ((i = 1; i < 15; i++)); do
    term=$(pfloat::fixed::mul "$term" "$x")
    term=$(pfloat::fixed::div "$term" "$i")
    result=$(pfloat::fixed::add "$result" "$term")
  done
  echo "$result"
}

pfloat::fixed::softplus() {
  local x="$1"
  local exp_val one_plus_exp

  if pfloat::fixed::lt "$x" "-10"; then
    echo "0"
    return
  fi

  exp_val=$(_pfloat::fixed::exp_approx "$x")
  one_plus_exp=$(pfloat::fixed::add "1" "$exp_val")

  _pfloat::fixed::ln_approx "$one_plus_exp"
}

_pfloat::fixed::ln_approx() {
  local x="$1"
  local y="1" i iterations=20

  if pfloat::fixed::le "$x" "0"; then
    echo "0"
    return
  fi

  for ((i = 0; i < iterations; i++)); do
    local ey num den delta
    ey=$(_pfloat::fixed::exp_approx "$y")
    num=$(pfloat::fixed::mul "2" $(pfloat::fixed::sub "$x" "$ey"))
    den=$(pfloat::fixed::add "$x" "$ey")
    delta=$(pfloat::fixed::div "$num" "$den")
    y=$(pfloat::fixed::add "$y" "$delta")
  done
  echo "$y"
}

# ==============================================================================
# BACKWARD COMPATIBILITY WRAPPERS
# These aliases maintain compatibility with code using pfloat::* directly
# ==============================================================================

pfloat::add() { pfloat::fixed::add "$@"; }
pfloat::sub() { pfloat::fixed::sub "$@"; }
pfloat::mul() { pfloat::fixed::mul "$@"; }
pfloat::div() { pfloat::fixed::div "$@"; }
pfloat::mod() { pfloat::fixed::mod "$@"; }
pfloat::neg() { pfloat::fixed::neg "$@"; }
pfloat::abs() { pfloat::fixed::abs "$@"; }
pfloat::eq() { pfloat::fixed::eq "$@"; }
pfloat::ne() { pfloat::fixed::ne "$@"; }
pfloat::lt() { pfloat::fixed::lt "$@"; }
pfloat::le() { pfloat::fixed::le "$@"; }
pfloat::gt() { pfloat::fixed::gt "$@"; }
pfloat::ge() { pfloat::fixed::ge "$@"; }
pfloat::is_zero() { pfloat::fixed::is_zero "$@"; }
pfloat::is_positive() { pfloat::fixed::is_positive "$@"; }
pfloat::is_negative() { pfloat::fixed::is_negative "$@"; }
pfloat::floor() { pfloat::fixed::floor "$@"; }
pfloat::ceil() { pfloat::fixed::ceil "$@"; }
pfloat::round() { pfloat::fixed::round "$@"; }
pfloat::trunc() { pfloat::fixed::trunc "$@"; }
pfloat::min() { pfloat::fixed::min "$@"; }
pfloat::max() { pfloat::fixed::max "$@"; }
pfloat::clamp() { pfloat::fixed::clamp "$@"; }
pfloat::sqr() { pfloat::fixed::sqr "$@"; }
pfloat::sqrt() { pfloat::fixed::sqrt "$@"; }
pfloat::pow() { pfloat::fixed::pow "$@"; }
pfloat::cbrt() { pfloat::fixed::cbrt "$@"; }
pfloat::sum() { pfloat::fixed::sum "$@"; }
pfloat::avg() { pfloat::fixed::avg "$@"; }
pfloat::lerp() { pfloat::fixed::lerp "$@"; }
pfloat::inv_lerp() { pfloat::fixed::inv_lerp "$@"; }
pfloat::map() { pfloat::fixed::map "$@"; }
pfloat::normalize() { pfloat::fixed::normalize "$@"; }
pfloat::percent() { pfloat::fixed::percent "$@"; }
pfloat::percent_of() { pfloat::fixed::percent_of "$@"; }
pfloat::percent_change() { pfloat::fixed::percent_change "$@"; }
pfloat::dist2() { pfloat::fixed::dist2 "$@"; }
pfloat::dist3() { pfloat::fixed::dist3 "$@"; }
pfloat::sign() { pfloat::fixed::sign "$@"; }
pfloat::recip() { pfloat::fixed::recip "$@"; }
pfloat::mean() { pfloat::fixed::mean "$@"; }
pfloat::geomean() { pfloat::fixed::geomean "$@"; }
pfloat::harmean() { pfloat::fixed::harmean "$@"; }
pfloat::factorial() { pfloat::fixed::factorial "$@"; }
pfloat::sigmoid() { pfloat::fixed::sigmoid "$@"; }
pfloat::softplus() { pfloat::fixed::softplus "$@"; }

# ==============================================================================
# IEEE 754 DOUBLE-PRECISION IMPLEMENTATION
# Pure Bash IEEE 754 floating-point arithmetic
# Uses 64-bit fixed-point representation internally
# ==============================================================================

# IEEE 754 Double-precision constants
readonly IEEE754_SIGN_BIT=63
readonly IEEE754_EXP_BITS=11
readonly IEEE754_MANT_BITS=52
readonly IEEE754_EXP_BIAS=1023
readonly IEEE754_EXP_MAX=2047
readonly IEEE754_MANT_MASK=4503599627370495  # 0xFFFFFFFFFFFFF
readonly IEEE754_EXP_MASK=9218868437227405312  # 0x7FF0000000000000
readonly IEEE754_SIGN_MASK=9223372036854775808  # 0x8000000000000000

# Internal: Extract sign bit from 64-bit pattern
_ieee754::get_sign() {
  local bits="$1"
  echo $(( (bits >> 63) & 1 ))
}

# Internal: Extract exponent from 64-bit pattern
_ieee754::get_exp() {
  local bits="$1"
  echo $(( (bits >> 52) & 2047 ))
}

# Internal: Extract mantissa from 64-bit pattern
_ieee754::get_mant() {
  local bits="$1"
  echo $(( bits & 4503599627370495 ))
}

# Internal: Pack sign, exp, mant into 64-bit pattern
_ieee754::pack() {
  local sign="$1" exp="$2" mant="$3"
  echo $(( (sign << 63) | (exp << 52) | mant ))
}

# Internal: Check if value is NaN
_ieee754::is_nan() {
  local bits="$1"
  local exp=$(_ieee754::get_exp "$bits")
  local mant=$(_ieee754::get_mant "$bits")
  ((exp == 2047 && mant != 0))
}

# Internal: Check if value is Infinity
_ieee754::is_inf() {
  local bits="$1"
  local exp=$(_ieee754::get_exp "$bits")
  local mant=$(_ieee754::get_mant "$bits")
  ((exp == 2047 && mant == 0))
}

# Internal: Check if value is zero
_ieee754::is_zero() {
  local bits="$1"
  local exp=$(_ieee754::get_exp "$bits")
  local mant=$(_ieee754::get_mant "$bits")
  ((exp == 0 && mant == 0))
}

# Internal: Check if value is subnormal
_ieee754::is_subnormal() {
  local bits="$1"
  local exp=$(_ieee754::get_exp "$bits")
  ((exp == 0))
}

# Internal: Convert decimal string to IEEE 754 double
# Pure Bash implementation - converts decimal to binary IEEE 754 representation
_ieee754::from_string() {
  local str="$1"
  local sign=0

  # Handle sign
  if [[ "$str" == -* ]]; then
    sign=1
    str="${str#-}"
  fi

  # Handle special values
  case "$str" in
    inf|Inf|infinity|Infinity) echo $((sign << 63 | 2047 << 52)); return ;;
    nan|NaN) echo $((2047 << 52 | 1)); return ;;
  esac

  # Parse integer and fractional parts
  local int_part frac_part=""
  if [[ "$str" == *.* ]]; then
    int_part="${str%%.*}"
    frac_part="${str#*.}"
  else
    int_part="$str"
  fi

  # Remove leading zeros from int_part
  int_part="${int_part#"${int_part%%[!0]*}"}"
  [[ -z "$int_part" ]] && int_part="0"

  # Handle zero
  if [[ "$int_part" == "0" ]] && [[ -z "$frac_part" || "$frac_part" == "0" ]]; then
    echo $((sign << 63))
    return
  fi

  # Convert to a single integer numerator and power-of-10 denominator
  # value = (int_part * 10^frac_len + frac_part) / 10^frac_len
  local frac_len=${#frac_part}
  local numerator denominator

  if ((frac_len > 0)); then
    # Build numerator: concatenate int_part and frac_part as integers
    numerator=$((int_part * 10**frac_len + frac_part))
    denominator=$((10**frac_len))
  else
    numerator=$int_part
    denominator=1
  fi

  # Now convert numerator/denominator to IEEE 754
  # Find the binary exponent: we need 2^exp <= numerator/denominator < 2^(exp+1)
  # This means: exp = floor(log2(numerator) - log2(denominator))

  # Find log2(numerator) by counting bits
  local temp=$numerator
  local num_bits=0
  while ((temp > 0)); do
    temp=$((temp >> 1))
    ((num_bits++))
  done

  # Find log2(denominator) by counting bits
  temp=$denominator
  local den_bits=0
  while ((temp > 0)); do
    temp=$((temp >> 1))
    ((den_bits++))
  done

  # Approximate exponent: exp ≈ num_bits - den_bits
  # But we need to be more precise. Let's compute it exactly:
  # We want the largest exp such that: 2^exp <= numerator/denominator
  # i.e., 2^exp * denominator <= numerator

  local exp=$((num_bits - den_bits))

  # Adjust exponent if needed
  local power_of_2
  if ((exp >= 0)); then
    power_of_2=$((1 << exp))
    while ((power_of_2 * denominator > numerator)); do
      ((exp--))
      power_of_2=$((power_of_2 / 2))
    done
    while ((power_of_2 * 2 * denominator <= numerator)); do
      ((exp++))
      power_of_2=$((power_of_2 * 2))
    done
  else
    # exp is negative
    power_of_2=1
    local abs_exp=$((-exp))
    local i
    for ((i=0; i<abs_exp; i++)); do
      power_of_2=$((power_of_2 * 2))
    done
    # Check: numerator/denominator >= 2^exp means numerator * 2^(-exp) >= denominator
    while ((numerator * power_of_2 < denominator)); do
      ((exp--))
      power_of_2=$((power_of_2 * 2))
    done
    while ((numerator * power_of_2 * 2 >= denominator)); do
      ((exp++))
      power_of_2=$((power_of_2 / 2))
    done
  fi

  # Now calculate mantissa: mantissa = (numerator/denominator) / 2^exp * 2^52
  # = numerator * 2^52 / (denominator * 2^exp)
  # Use bc for precision
  local mantissa
  if ((exp >= 0)); then
    mantissa=$(echo "($numerator * 4503599627370496) / ($denominator * 2^$exp)" | bc)
  else
    mantissa=$(echo "($numerator * 4503599627370496 * 2^$((-exp))) / $denominator" | bc)
  fi

  # Normalize mantissa to ensure bit 52 is set (for normalized numbers)
  if ((mantissa > 0)); then
    while ((mantissa < 4503599627370496 && mantissa > 0)); do
      mantissa=$((mantissa << 1))
      ((exp--))
    done
    while ((mantissa >= 9007199254740992)); do
      mantissa=$((mantissa >> 1))
      ((exp++))
    done
  fi

  # Calculate IEEE 754 exponent (with bias)
  local ieee_exp=$((exp + 1023))

  # Check for overflow/underflow
  if ((ieee_exp >= 2047)); then
    echo $((sign << 63 | 2047 << 52))  # Infinity
    return
  fi
  if ((ieee_exp <= 0)); then
    # Subnormal or zero
    echo $((sign << 63))
    return
  fi

  # Remove implicit leading 1 (bit 52) and mask to 52 bits
  mantissa=$((mantissa & 4503599627370495))

  # Pack and return
  echo $(( (sign << 63) | (ieee_exp << 52) | mantissa ))
}

# Internal: Convert IEEE 754 double to decimal string
_ieee754::to_string() {
  local bits="$1"

  # Check for special values
  if _ieee754::is_nan "$bits"; then
    echo "NaN"
    return
  fi

  if _ieee754::is_inf "$bits"; then
    if [[ $( _ieee754::get_sign "$bits" ) -eq 1 ]]; then
      echo "-Inf"
    else
      echo "Inf"
    fi
    return
  fi

  if _ieee754::is_zero "$bits"; then
    echo "0"
    return
  fi

  # Extract components
  local sign=$(_ieee754::get_sign "$bits")
  local exp=$(_ieee754::get_exp "$bits")
  local mant=$(_ieee754::get_mant "$bits")

  # Add implicit leading 1 for normalized numbers
  if ((exp > 0)); then
    mant=$((mant | 4503599627370496))  # Add 2^52
  fi

  # Calculate the actual value using bc for precision
  # value = mant * 2^(exp - 1023 - 52)
  local exponent=$((exp - 1023 - 52))

  # Convert to decimal string using bc
  local value
  if ((exponent >= 0)); then
    value=$(echo "$mant * 2^$exponent" | bc)
  else
    # For negative exponents, we need decimal places
    # Multiply by 10^15 first, then divide by 2^|exponent|
    local scale=1000000000000000
    value=$(echo "($mant * $scale) / 2^$((-exponent))" | bc)
  fi

  # Format output
  local int_part frac_part

  if ((exponent >= 0)); then
    # Integer result
    echo "$value"
  else
    # Decimal result
    int_part=$((value / 1000000000000000))
    frac_part=$((value % 1000000000000000))

    # Remove trailing zeros from fraction
    while ((frac_part % 10 == 0 && frac_part > 0)); do
      frac_part=$((frac_part / 10))
    done

    # Build result string
    local result="$int_part"
    if ((frac_part > 0)); then
      result="${result}.${frac_part}"
    fi

    # Add sign if negative
    if ((sign)); then
      result="-${result}"
    fi

    echo "$result"
  fi
}

# IEEE 754: Addition
# Usage: pfloat::ieee754::add bits_a bits_b
pfloat::ieee754::add() {
  local a="$1" b="$2"
  
  # Extract components
  local sign_a=$(_ieee754::get_sign "$a")
  local sign_b=$(_ieee754::get_sign "$b")
  local exp_a=$(_ieee754::get_exp "$a")
  local exp_b=$(_ieee754::get_exp "$b")
  local mant_a=$(_ieee754::get_mant "$a")
  local mant_b=$(_ieee754::get_mant "$b")
  
  # Add implicit leading 1 for normalized numbers
  if ((exp_a > 0)); then mant_a=$((mant_a | 4503599627370496)); fi
  if ((exp_b > 0)); then mant_b=$((mant_b | 4503599627370496)); fi
  
  # Handle special cases
  if ((exp_a == 2047 || exp_b == 2047)); then
    # NaN or Inf
    echo "$a"  # Simplified - should handle NaN propagation
    return
  fi
  
  # Align exponents (shift smaller mantissa)
  if ((exp_a > exp_b)); then
    local diff=$((exp_a - exp_b))
    ((diff > 52)) && diff=53
    mant_b=$((mant_b >> diff))
    exp_b=$exp_a
  elif ((exp_b > exp_a)); then
    local diff=$((exp_b - exp_a))
    ((diff > 52)) && diff=53
    mant_a=$((mant_a >> diff))
    exp_a=$exp_b
  fi
  
  # Add or subtract mantissas based on signs
  local result_mant result_sign
  if ((sign_a == sign_b)); then
    result_mant=$((mant_a + mant_b))
    result_sign=$sign_a
  else
    if ((mant_a >= mant_b)); then
      result_mant=$((mant_a - mant_b))
      result_sign=$sign_a
    else
      result_mant=$((mant_b - mant_a))
      result_sign=$sign_b
    fi
  fi
  
  # Normalize result
  local result_exp=$exp_a
  if ((result_mant > 0)); then
    while ((result_mant < 4503599627370496 && result_exp > 0)); do
      result_mant=$((result_mant << 1))
      ((result_exp--))
    done
    while ((result_mant >= 9007199254740992)); do
      result_mant=$((result_mant >> 1))
      ((result_exp++))
    done
  fi
  
  # Check for overflow
  if ((result_exp >= 2047)); then
    echo $((result_sign << 63 | 2047 << 52))  # Infinity
    return
  fi

  # Handle zero result (before masking)
  if ((result_mant == 0)); then
    echo 0
    return
  fi

  # Remove implicit leading 1 and pack
  result_mant=$((result_mant & 4503599627370495))

  _ieee754::pack "$result_sign" "$result_exp" "$result_mant"
}

# IEEE 754: Subtraction (uses addition with negated operand)
pfloat::ieee754::sub() {
  local a="$1" b="$2"
  # Flip sign bit of b and add
  local neg_b=$((b ^ 9223372036854775808))
  pfloat::ieee754::add "$a" "$neg_b"
}

# IEEE 754: Multiplication
# Uses chunked multiplication (26-bit halves) to avoid 64-bit overflow
pfloat::ieee754::mul() {
  local a="$1" b="$2"

  # Extract components
  local sign_a=$(_ieee754::get_sign "$a")
  local sign_b=$(_ieee754::get_sign "$b")
  local exp_a=$(_ieee754::get_exp "$a")
  local exp_b=$(_ieee754::get_exp "$b")
  local mant_a=$(_ieee754::get_mant "$a")
  local mant_b=$(_ieee754::get_mant "$b")

  # Handle special cases
  if ((exp_a == 2047 || exp_b == 2047)); then
    echo $(( (sign_a ^ sign_b) << 63 | 2047 << 52 ))  # Inf or NaN
    return
  fi

  # Result sign
  local result_sign=$((sign_a ^ sign_b))

  # Result exponent (subtract bias)
  local result_exp=$((exp_a + exp_b - 1023))

  # Add implicit leading 1
  if ((exp_a > 0)); then mant_a=$((mant_a | 4503599627370496)); fi
  if ((exp_b > 0)); then mant_b=$((mant_b | 4503599627370496)); fi

  # Multiply mantissas using shift-and-add (pure Bash)
  # Split 53-bit numbers into 26-bit chunks to avoid 64-bit overflow
  local a_lo=$((mant_a & 0x3FFFFFF))
  local a_hi=$((mant_a >> 26))
  local b_lo=$((mant_b & 0x3FFFFFF))
  local b_hi=$((mant_b >> 26))

  # Partial products
  local p0=$((a_lo * b_lo))
  local p1=$((a_hi * b_lo + a_lo * b_hi))
  local p2=$((a_hi * b_hi))

  # Combine: result = p2 + (p1 >> 26) + carry_from_lower_bits
  local p1_lo=$((p1 & 0x3FFFFFF))
  local carry=$(( ((p1_lo << 26) + p0) >> 52 ))
  local result_mant=$((p2 + (p1 >> 26) + carry))

  # Normalize
  while ((result_mant >= 9007199254740992)); do
    result_mant=$((result_mant >> 1))
    ((result_exp++))
  done

  # Check for overflow/underflow
  if ((result_exp >= 2047)); then
    echo $((result_sign << 63 | 2047 << 52))  # Infinity
    return
  fi
  if ((result_exp <= 0)); then
    # Subnormal or zero
    echo $((result_sign << 63))
    return
  fi

  # Remove implicit leading 1 and pack
  result_mant=$((result_mant & 4503599627370495))
  _ieee754::pack "$result_sign" "$result_exp" "$result_mant"
}

# IEEE 754: Division
# Uses restoring division algorithm (pure Bash)
pfloat::ieee754::div() {
  local a="$1" b="$2"

  # Extract components
  local sign_a=$(_ieee754::get_sign "$a")
  local sign_b=$(_ieee754::get_sign "$b")
  local exp_a=$(_ieee754::get_exp "$a")
  local exp_b=$(_ieee754::get_exp "$b")
  local mant_a=$(_ieee754::get_mant "$a")
  local mant_b=$(_ieee754::get_mant "$b")

  # Handle division by zero
  if _ieee754::is_zero "$b"; then
    if _ieee754::is_zero "$a"; then
      echo "NaN" >&2
      echo $((2047 << 52 | 1))  # NaN
      return
    fi
    echo $(( (sign_a ^ sign_b) << 63 | 2047 << 52 ))  # Infinity
    return
  fi

  # Handle special cases
  if ((exp_a == 2047 || exp_b == 2047)); then
    echo $(( (sign_a ^ sign_b) << 63 | 2047 << 52 ))
    return
  fi

  # Result sign
  local result_sign=$((sign_a ^ sign_b))

  # Result exponent (add bias)
  local result_exp=$((exp_a - exp_b + 1023))

  # Add implicit leading 1
  if ((exp_a > 0)); then mant_a=$((mant_a | 4503599627370496)); fi
  if ((exp_b > 0)); then mant_b=$((mant_b | 4503599627370496)); fi

  # Divide mantissas using bc for arbitrary precision
  # Compute 53-bit quotient directly
  local q
  q=$(echo "($mant_a * 4503599627370496) / $mant_b" | bc)  # 2^52

  # Normalize q to [2^52, 2^53) range
  local shift=0
  while ((q >= 9007199254740992)); do
    q=$((q >> 1))
    ((shift++))
  done
  while ((q < 4503599627370496 && q > 0)); do
    q=$((q << 1))
    ((shift--))
  done

  ((result_exp += shift))
  local result_mant=$((q & 4503599627370495))

  # Check for overflow/underflow
  if ((result_exp >= 2047)); then
    echo $((result_sign << 63 | 2047 << 52))
    return
  fi

  # Remove implicit leading 1 and pack
  result_mant=$((result_mant & 4503599627370495))
  _ieee754::pack "$result_sign" "$result_exp" "$result_mant"
}

# IEEE 754: Square root (Newton-Raphson iteration)
pfloat::ieee754::sqrt() {
  local a="$1"

  # Handle negative input
  if [[ $(_ieee754::get_sign "$a") -eq 1 ]]; then
    echo "NaN" >&2
    echo $((2047 << 52 | 1))  # NaN
    return
  fi
  
  # Handle special cases
  local exp=$(_ieee754::get_exp "$a")
  if ((exp == 2047)); then
    echo "$a"  # sqrt(Inf) = Inf, sqrt(NaN) = NaN
    return
  fi
  
  if _ieee754::is_zero "$a"; then
    echo 0
    return
  fi
  
  # Initial guess: exp/2
  local guess_exp=$((exp / 2 + 512))  # 512 = bias/2
  local guess=$((guess_exp << 52))
  
  # Newton-Raphson: x = (x + a/x) / 2
  local i
  for ((i = 0; i < 10; i++)); do
    local a_div_guess=$(pfloat::ieee754::div "$a" "$guess")
    local sum=$(pfloat::ieee754::add "$guess" "$a_div_guess")
    # Divide by 2 (just decrement exponent)
    guess=$((sum - (1 << 52)))
  done
  
  echo "$guess"
}

# IEEE 754: Comparison (returns 0 for true, 1 for false)
pfloat::ieee754::eq() {
  local a="$1" b="$2"
  # Handle signed zero
  local abs_a=$((a & ~9223372036854775808))
  local abs_b=$((b & ~9223372036854775808))
  ((abs_a == abs_b))
}

pfloat::ieee754::ne() {
  local a="$1" b="$2"
  local abs_a=$((a & ~9223372036854775808))
  local abs_b=$((b & ~9223372036854775808))
  ((abs_a != abs_b))
}

pfloat::ieee754::lt() {
  local a="$1" b="$2"
  local sign_a=$(_ieee754::get_sign "$a")
  local sign_b=$(_ieee754::get_sign "$b")

  if ((sign_a && ! sign_b)); then return 0; fi  # Negative < Positive
  if ((! sign_a && sign_b)); then return 1; fi  # Positive >= Negative

  # Same sign - compare as integers (reverse for negative)
  if ((sign_a)); then
    ((a > b))
  else
    ((a < b))
  fi
}

pfloat::ieee754::le() {
  local a="$1" b="$2"
  pfloat::ieee754::lt "$a" "$b" || pfloat::ieee754::eq "$a" "$b"
}

pfloat::ieee754::gt() {
  local a="$1" b="$2"
  ! pfloat::ieee754::le "$a" "$b"
}

pfloat::ieee754::ge() {
  local a="$1" b="$2"
  ! pfloat::ieee754::lt "$a" "$b"
}

# IEEE 754: Classification
pfloat::ieee754::is_nan() {
  _ieee754::is_nan "$1"
}

pfloat::ieee754::is_inf() {
  _ieee754::is_inf "$1"
}

pfloat::ieee754::is_finite() {
  local exp=$(_ieee754::get_exp "$1")
  ((exp < 2047))
}

pfloat::ieee754::is_zero() {
  _ieee754::is_zero "$1"
}

pfloat::ieee754::is_negative() {
  local sign=$(_ieee754::get_sign "$1")
  ((sign == 1))
}

pfloat::ieee754::is_positive() {
  local bits="$1"
  local sign=$(_ieee754::get_sign "$bits")
  ((sign == 0)) && ! _ieee754::is_zero "$bits"
}

# IEEE 754: Negation
pfloat::ieee754::neg() {
  echo $(( $1 ^ 9223372036854775808 ))
}

# IEEE 754: Absolute value
pfloat::ieee754::abs() {
  echo $(( $1 & ~9223372036854775808 ))
}

# IEEE 754: Sign (-1, 0, or 1)
pfloat::ieee754::sign() {
  local bits="$1"
  if _ieee754::is_zero "$bits"; then
    echo 0
  elif [[ $(_ieee754::get_sign "$bits") -eq 1 ]]; then
    echo -1
  else
    echo 1
  fi
}

# IEEE 754: Convert from decimal string
pfloat::ieee754::from_string() {
  _ieee754::from_string "$1"
}

# IEEE 754: Convert to decimal string
pfloat::ieee754::to_string() {
  _ieee754::to_string "$1"
}

# IEEE 754: Dump bit layout for diagnostics
# Usage: pfloat::ieee754::dump bits
# Output: Value: 1.5, Int: 4609434218613702656, Sign: 0, Exp: 1023 (01111111111), Mant: 2251799813685248 (1000000000000000000000000000000000000000000000000000)
pfloat::ieee754::dump() {
  local bits="$1"
  local sign=$(_ieee754::get_sign "$bits")
  local exp=$(_ieee754::get_exp "$bits")
  local mant=$(_ieee754::get_mant "$bits")
  local value
  value=$(pfloat::ieee754::to_string "$bits")

  # Convert exponent and mantissa to binary strings
  local exp_bin="" mant_bin=""
  local temp=$exp i
  for ((i=0; i<11; i++)); do
    exp_bin="$((temp & 1))$exp_bin"
    temp=$((temp >> 1))
  done
  temp=$mant
  for ((i=0; i<52; i++)); do
    mant_bin="$((temp & 1))$mant_bin"
    temp=$((temp >> 1))
  done

  printf "Value: %s, Int: %s, Sign: %s, Exp: %s (%s), Mant: %s (%s)\n" \
    "$value" "$bits" "$sign" "$exp" "$exp_bin" "$mant" "$mant_bin"
}

# IEEE 754: Convert from 64-bit integer (raw bit pattern)
# Usage: pfloat::ieee754::from_int 4607182418800017408
pfloat::ieee754::from_int() {
  echo "$1"
}

# IEEE 754: Convert to 64-bit integer (raw bit pattern)
# Usage: pfloat::ieee754::to_int bits
pfloat::ieee754::to_int() {
  echo "$1"
}

# IEEE 754: Convert from binary string
# Usage: pfloat::ieee754::from_binary "0011111111111000..."          # flat (64 chars)
#        pfloat::ieee754::from_binary "0" "01111111111" "1000..."   # 3 args (1+11+52)
pfloat::ieee754::from_binary() {
  local raw
  if (( $# == 1 )); then
    raw="${1//_/}"
    if ((${#raw} != 64)); then
      echo "pfloat::ieee754::from_binary: expected 64-bit flat binary, got ${#raw}" >&2
      return 1
    fi
  elif (( $# == 3 )); then
    local s="${1//_/}" e="${2//_/}" m="${3//_/}"
    if ((${#s} != 1)); then
      echo "pfloat::ieee754::from_binary: sign must be 1 bit, got ${#s}" >&2
      return 1
    fi
    if ((${#e} != 11)); then
      echo "pfloat::ieee754::from_binary: exponent must be 11 bits, got ${#e}" >&2
      return 1
    fi
    if ((${#m} != 52)); then
      echo "pfloat::ieee754::from_binary: mantissa must be 52 bits, got ${#m}" >&2
      return 1
    fi
    raw="${s}${e}${m}"
  else
    echo "pfloat::ieee754::from_binary: expected 1 arg (flat 64-bit) or 3 args (sign exp mant)" >&2
    return 1
  fi

  # Convert binary string to integer
  local result=0 i
  for ((i=0; i<64; i++)); do
    result=$(( (result << 1) | ${raw:$i:1} ))
  done
  echo "$result"
}

# IEEE 754: Convert to binary string
# Usage: pfloat::ieee754::to_binary bits [separator]
# Default separator: space between sign, exponent, mantissa
pfloat::ieee754::to_binary() {
  local bits="$1"
  local sep
  if [[ $# -ge 2 ]]; then sep="$2"; else sep=" "; fi
  local sign=$(_ieee754::get_sign "$bits")
  local exp=$(_ieee754::get_exp "$bits")
  local mant=$(_ieee754::get_mant "$bits")

  # Convert to binary strings
  local exp_bin="" mant_bin="" i temp
  temp=$exp
  for ((i=0; i<11; i++)); do
    exp_bin="$((temp & 1))$exp_bin"
    temp=$((temp >> 1))
  done
  temp=$mant
  for ((i=0; i<52; i++)); do
    mant_bin="$((temp & 1))$mant_bin"
    temp=$((temp >> 1))
  done

  printf "%s%s%s%s%s\n" "$sign" "$sep" "$exp_bin" "$sep" "$mant_bin"
}
pm::install() {
  local packages=("$@")
  local pm
  pm=$(runtime::pm)

  case "$pm" in
  apt) sudo apt-get install -y "${packages[@]}" ;;
  pacman) sudo pacman -S --noconfirm "${packages[@]}" ;;
  dnf) sudo dnf install -y "${packages[@]}" ;;
  yum) sudo yum install -y "${packages[@]}" ;;
  zypper) sudo zypper install -y "${packages[@]}" ;;
  apk) sudo apk add "${packages[@]}" ;;
  brew) brew install "${packages[@]}" ;;
  pkg) sudo pkg install -y "${packages[@]}" ;;
  xbps) sudo xbps-install -y "${packages[@]}" ;;
  nix) nix-env -iA "${packages[@]}" ;;
  *)
    echo "pm::install: unknown package manager" >&2
    return 1
    ;;
  esac
}

pm::sync() {
  local pm
  pm=$(runtime::pm)

  case "$pm" in
  apt) sudo apt-get update ;;
  pacman) sudo pacman -Sy ;;
  dnf) sudo dnf check-update ;;
  yum) sudo yum check-update ;;
  zypper) sudo zypper refresh ;;
  apk) sudo apk update ;;
  brew) brew update ;;
  pkg) sudo pkg update ;;
  xbps) sudo xbps-install -S ;;
  nix) nix-channel --update ;;
  *)
    echo "pm::sync: unknown package manager" >&2
    return 1
    ;;
  esac
}

pm::update() {
  local pm
  pm=$(runtime::pm)

  case "$pm" in
  apt) sudo apt-get upgrade -y ;;
  pacman) sudo pacman -Su --noconfirm ;;
  dnf) sudo dnf upgrade -y ;;
  yum) sudo yum update -y ;;
  zypper) sudo zypper update -y ;;
  apk) sudo apk upgrade ;;
  brew) brew upgrade ;;
  pkg) sudo pkg upgrade -y ;;
  xbps) sudo xbps-install -u ;;
  nix) nix-env -u ;;
  *)
    echo "pm::update: unknown package manager" >&2
    return 1
    ;;
  esac
}

pm::uninstall() {
  local packages=("$@")
  local pm
  pm=$(runtime::pm)

  case "$pm" in
  apt) sudo apt-get remove -y "${packages[@]}" ;;
  pacman) sudo pacman -R --noconfirm "${packages[@]}" ;;
  dnf) sudo dnf remove -y "${packages[@]}" ;;
  yum) sudo yum remove -y "${packages[@]}" ;;
  zypper) sudo zypper remove -y "${packages[@]}" ;;
  apk) sudo apk del "${packages[@]}" ;;
  brew) brew uninstall "${packages[@]}" ;;
  pkg) sudo pkg delete -y "${packages[@]}" ;;
  xbps) sudo xbps-remove -y "${packages[@]}" ;;
  nix) nix-env -e "${packages[@]}" ;;
  *)
    echo "pm::uninstall: unknown package manager" >&2
    return 1
    ;;
  esac
}

pm::search() {
  local query="$1"
  local pm
  pm=$(runtime::pm)

  case "$pm" in
  apt) apt-cache search "$query" ;;
  pacman) pacman -Ss "$query" ;;
  dnf) dnf search "$query" ;;
  yum) yum search "$query" ;;
  zypper) zypper search "$query" ;;
  apk) apk search "$query" ;;
  brew) brew search "$query" ;;
  pkg) pkg search "$query" ;;
  xbps) xbps-query -Rs "$query" ;;
  nix) nix-env -qaP "$query" ;;
  *)
    echo "pm::search: unknown package manager" >&2
    return 1
    ;;
  esac
}
# process.sh — bash-frameheader process management lib
# Requires: runtime.sh (runtime::has_command)

# ==============================================================================
# QUERY
# ==============================================================================

# Check if a process is running by PID
# Usage: process::is_running pid
process::is_running() {
    kill -0 "$1" 2>/dev/null
}

# Check if a process is running by name
# Usage: process::is_running::name name
process::is_running::name() {
    pgrep -x "$1" >/dev/null 2>&1
}

# Get PID(s) of a named process (one per line)
# Usage: process::pid name
process::pid() {
    pgrep -x "$1" 2>/dev/null
}

# Get parent PID of a process
# Usage: process::ppid pid
process::ppid() {
    local pid="${1:-$$}"
    awk '{print $4}' "/proc/$pid/stat" 2>/dev/null || \
        ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' '
}

# Get PID of current shell
process::self() {
    echo "$$"
}

# Get process name from PID
# Usage: process::name pid
process::name() {
    local pid="${1:-$$}"
    if [[ -f "/proc/$pid/comm" ]]; then
        cat "/proc/$pid/comm"
    else
        ps -o comm= -p "$pid" 2>/dev/null
    fi
}

# Get command line of a process
# Usage: process::cmdline pid
process::cmdline() {
    local pid="${1:-$$}"
    if [[ -f "/proc/$pid/cmdline" ]]; then
        tr '\0' ' ' < "/proc/$pid/cmdline"
    else
        ps -o args= -p "$pid" 2>/dev/null
    fi
}

# Get process state (R=running, S=sleeping, Z=zombie, etc.)
# Usage: process::state pid
process::state() {
    local pid="$1"
    if [[ -f "/proc/$pid/status" ]]; then
        awk '/^State:/{print $2}' "/proc/$pid/status"
    else
        ps -o state= -p "$pid" 2>/dev/null
    fi
}

# Check if a process is a zombie
process::is_zombie() {
    [[ "$(process::state "$1")" == "Z" ]]
}

# Get process working directory
# Usage: process::cwd pid
process::cwd() {
    local pid="${1:-$$}"
    readlink "/proc/$pid/cwd" 2>/dev/null || \
        lsof -p "$pid" 2>/dev/null | awk '$4=="cwd"{print $9}'
}

# Get process environment variable
# Usage: process::env pid varname
process::env() {
    local pid="$1" var="$2"
    if [[ -f "/proc/$pid/environ" ]]; then
        tr '\0' '\n' < "/proc/$pid/environ" | grep "^${var}=" | cut -d= -f2-
    fi
}

# List all running processes (PID and name)
process::list() {
    ps -eo pid,comm --no-headers 2>/dev/null || \
        ps -eo pid,comm 2>/dev/null | tail -n +2
}

# Find processes matching a pattern (name or cmdline)
# Usage: process::find pattern
process::find() {
    pgrep -a "$1" 2>/dev/null || ps -eo pid,args | grep "$1" | grep -v grep
}

# Get process tree from a PID
# Usage: process::tree [pid]
process::tree() {
    local pid="${1:-1}"
    if runtime::has_command pstree; then
        pstree -p "$pid"
    else
        ps -eo pid,ppid,comm | awk -v root="$pid" '
            NR==1{next}
            {parent[$1]=$2; name[$1]=$3}
            function show(p, indent,    c) {
                print indent p " " name[p]
                for (c in parent)
                    if (parent[c]==p) show(c, indent "  ")
            }
            END{show(root, "")}
        '
    fi
}

# ==============================================================================
# RESOURCE USAGE
# ==============================================================================

# Get CPU usage percentage for a PID
# Usage: process::cpu pid
process::cpu() {
    ps -o pcpu= -p "$1" 2>/dev/null | tr -d ' '
}

# Get memory usage in KB for a PID
# Usage: process::memory pid
process::memory() {
    if [[ -f "/proc/$1/status" ]]; then
        awk '/^VmRSS:/{print $2}' "/proc/$1/status"
    else
        ps -o rss= -p "$1" 2>/dev/null | tr -d ' '
    fi
}

# Get memory usage as percentage
process::memory::percent() {
    ps -o pmem= -p "$1" 2>/dev/null | tr -d ' '
}

# Get number of open file descriptors for a PID
process::fd_count() {
    ls "/proc/$1/fd" 2>/dev/null | wc -l
}

# Get number of threads for a PID
process::thread_count() {
    if [[ -f "/proc/$1/status" ]]; then
        awk '/^Threads:/{print $2}' "/proc/$1/status"
    else
        ps -o nlwp= -p "$1" 2>/dev/null | tr -d ' '
    fi
}

# Get process start time (unix timestamp)
process::start_time() {
    local pid="$1"
    if runtime::has_command ps; then
        ps -o lstart= -p "$pid" 2>/dev/null
    fi
}

# Get process uptime in seconds
process::uptime() {
    local pid="$1"
    if [[ -f "/proc/$pid/stat" ]]; then
        local clk_tck start_ticks uptime_secs
        clk_tck=$(getconf CLK_TCK 2>/dev/null || echo 100)
        start_ticks=$(awk '{print $22}' "/proc/$pid/stat")
        uptime_secs=$(awk '{print $1}' /proc/uptime)
        echo "$(( ${uptime_secs%.*} - start_ticks / clk_tck ))"
    fi
}

# ==============================================================================
# CONTROL
# ==============================================================================

# Send a signal to a process
# Usage: process::signal pid signal
process::signal() {
    kill -"$2" "$1" 2>/dev/null
}

# Terminate a process (SIGTERM)
process::kill() {
    kill -TERM "$1" 2>/dev/null
}

# Force kill a process (SIGKILL)
process::kill::force() {
    kill -KILL "$1" 2>/dev/null
}

# Kill all processes matching a name
process::kill::name() {
    pkill -x "$1" 2>/dev/null
}

# Graceful kill — SIGTERM, wait, then SIGKILL if still running
# Usage: process::kill::graceful pid [timeout_seconds]
process::kill::graceful() {
    local pid="$1" timeout="${2:-5}"
    process::is_running "$pid" || return 0

    # SIGCONT first — a stopped process ignores SIGTERM
    kill -CONT "$pid" 2>/dev/null
    kill -TERM "$pid" 2>/dev/null

    local elapsed=0
    while (( elapsed < timeout )); do
        process::is_running "$pid" || return 0
        sleep 1
        (( elapsed++ ))
    done

    # Still running after timeout — force kill
    kill -KILL "$pid" 2>/dev/null
    local i
    for (( i = 0; i < 5; i++ )); do
        process::is_running "$pid" || return 0
        sleep 0.2
    done
    return 1
}

# Suspend a process (SIGSTOP)
process::suspend() {
    kill -STOP "$1" 2>/dev/null
}

# Resume a suspended process (SIGCONT)
process::resume() {
    kill -CONT "$1" 2>/dev/null
}

# Reload a process config (SIGHUP)
process::reload() {
    kill -HUP "$1" 2>/dev/null
}

# Wait for a process to finish
# Usage: process::wait pid [timeout_seconds]
process::wait() {
    local pid="$1" timeout="${2:-}"
    if [[ -z "$timeout" ]]; then
        wait "$pid" 2>/dev/null
        return $?
    fi

    local elapsed=0
    while process::is_running "$pid"; do
        sleep 1
        (( elapsed++ ))
        (( elapsed >= timeout )) && return 1
    done
    return 0
}

# Change process priority (nice value, -20 to 19)
# Usage: process::renice pid value
process::renice() {
    renice -n "$2" -p "$1" 2>/dev/null
}

# ==============================================================================
# BACKGROUND JOBS
# ==============================================================================

# Run a command in the background, print its PID
# Usage: process::run_bg command [args...]
process::run_bg() {
    "$@" &
    echo $!
}

# Run a command in the background, redirect output to a log file
# Usage: process::run_bg::log logfile command [args...]
process::run_bg::log() {
    local logfile="$1"; shift
    "$@" >> "$logfile" 2>&1 &
    echo $!
}

# Run a command in the background with a timeout
# Usage: process::run_bg::timeout seconds command [args...]
process::run_bg::timeout() {
    local timeout="$1"; shift
    (
        "$@" &
        local pid=$!
        sleep "$timeout"
        process::kill::graceful "$pid"
    ) &
    echo $!
}

# List current shell's background jobs
process::job::list() {
    jobs -l
}

# Wait for all background jobs to finish
process::job::wait_all() {
    wait
}

# Wait for a specific background job by PID
process::job::wait() {
    wait "$1" 2>/dev/null
    return $?
}

# Get exit status of last background job
process::job::status() {
    wait "$1" 2>/dev/null
    echo $?
}

# ==============================================================================
# LOCKING
# Prevent concurrent execution of a script/function
# ==============================================================================

# Acquire a lock — returns 1 if already locked
# Usage: process::lock::acquire lockname
process::lock::acquire() {
    local lockfile="/tmp/fsbshf_${1}.lock"
    if ( set -o noclobber; echo "$$" > "$lockfile" ) 2>/dev/null; then
        # shellcheck disable=SC2064
        trap "process::lock::release '${1}'" EXIT
        return 0
    fi
    # Check if the locking process is still alive
    local locked_pid
    locked_pid=$(cat "$lockfile" 2>/dev/null)
    if [[ -n "$locked_pid" ]] && ! process::is_running "$locked_pid"; then
        rm -f "$lockfile"
        ( set -o noclobber; echo "$$" > "$lockfile" ) 2>/dev/null
        # shellcheck disable=SC2064
        trap "process::lock::release '${1}'" EXIT
        return 0
    fi
    return 1
}

# Release a lock
# Usage: process::lock::release lockname
process::lock::release() {
    rm -f "/tmp/fsbshf_${1}.lock"
}

# Check if a lock is held
# Usage: process::lock::is_locked lockname
process::lock::is_locked() {
    local lockfile="/tmp/fsbshf_${1}.lock"
    [[ -f "$lockfile" ]] && process::is_running "$(cat "$lockfile" 2>/dev/null)"
}

# Wait for a lock to become available
# Usage: process::lock::wait lockname [timeout]
process::lock::wait() {
    local name="$1" timeout="${2:-30}" elapsed=0
    while ! process::lock::acquire "$name"; do
        sleep 1
        (( elapsed++ ))
        (( elapsed >= timeout )) && return 1
    done
    return 0
}

# ==============================================================================
# DAEMON / SERVICE
# ==============================================================================

# Check if a systemd service is running
# Usage: process::service::is_running service_name
process::service::is_running() {
    if runtime::has_command systemctl; then
        systemctl is-active --quiet "$1" 2>/dev/null
    elif runtime::has_command service; then
        service "$1" status >/dev/null 2>&1
    else
        process::is_running::name "$1"
    fi
}

# Start a systemd service
process::service::start() {
    if runtime::has_command systemctl; then
        systemctl start "$1"
    elif runtime::has_command service; then
        service "$1" start
    fi
}

# Stop a systemd service
process::service::stop() {
    if runtime::has_command systemctl; then
        systemctl stop "$1"
    elif runtime::has_command service; then
        service "$1" stop
    fi
}

# Restart a systemd service
process::service::restart() {
    if runtime::has_command systemctl; then
        systemctl restart "$1"
    elif runtime::has_command service; then
        service "$1" restart
    fi
}

# Check if a service is enabled at boot
process::service::is_enabled() {
    if runtime::has_command systemctl; then
        systemctl is-enabled --quiet "$1" 2>/dev/null
    fi
}

# ==============================================================================
# MISC
# ==============================================================================

# Run a command and return its execution time in seconds
# Usage: process::time command [args...]
process::time() {
    local start end
    start=$(date +%s%N 2>/dev/null || date +%s)
    "$@"
    local ret=$?
    end=$(date +%s%N 2>/dev/null || date +%s)
    # nanosecond precision if available
    if [[ "${#start}" -gt 10 ]]; then
        echo "$(( (end - start) / 1000000 ))ms"
    else
        echo "$(( end - start ))s"
    fi
    return $ret
}

# Run a command with a timeout, kill it if it exceeds
# Usage: process::timeout seconds command [args...]
process::timeout() {
    local timeout="$1"; shift
    if runtime::has_command timeout; then
        timeout "$timeout" "$@"
    else
        # Pure bash fallback
        "$@" &
        local pid=$!
        ( sleep "$timeout"; process::kill::graceful "$pid" ) &
        local watcher=$!
        wait "$pid" 2>/dev/null
        local ret=$?
        kill "$watcher" 2>/dev/null
        return $ret
    fi
}

# Retry a command n times with a delay between attempts
# Usage: process::retry times delay command [args...]
process::retry() {
    local tries="$1" delay="$2"; shift 2
    local attempt=0
    while (( attempt < tries )); do
        "$@" && return 0
        (( attempt++ ))
        (( attempt < tries )) && sleep "$delay"
    done
    return 1
}

# Run command only if not already running (singleton)
# Usage: process::singleton lockname command [args...]
process::singleton() {
    local name="$1"; shift
    if process::lock::acquire "$name"; then
        "$@"
    else
        echo "process::singleton: '$name' is already running" >&2
        return 1
    fi
}

# pubsub.sh -- bash::framehead named-pipe publish/subscribe
#
# In-process IPC via named pipes (FIFOs). Subscribers create pipes under a
# topic directory and read from them; publishers write to all pipes in a topic.
# Useful for background worker coordination, parallel job fan-out, and simple
# message passing between shell processes.
#
# CONFIGURATION:
#   PUBSUB_ROOT     Root directory for pipes. Default: /tmp/fsbshf-pubsub-$$
#
# EXAMPLE:
#   # Terminal 1 — subscriber
#   source bash-framehead.sh
#   pipe=$(pubsub::subscribe "mytopic")
#   while read -r msg; do echo "got: $msg"; done < "$pipe"
#
#   # Terminal 2 — publisher
#   source bash-framehead.sh
#   echo "hello world" | pubsub::publish "mytopic"
#
#   # Count subscribers
#   pubsub::count "mytopic"

# ==============================================================================
# CONSTANTS
# ==============================================================================

readonly _PUBSUB_DEFAULT_ROOT="/tmp/fsbshf-pubsub-$$"

# ==============================================================================
# INTERNAL
# ==============================================================================

# Ensure PUBSUB_ROOT is set and the directory exists.
# Called lazily by subscribe/publish so callers don't need to call pubsub::init.
_pubsub::ensure_root() {
    if [[ -z "${PUBSUB_ROOT:-}" ]]; then
        PUBSUB_ROOT="$_PUBSUB_DEFAULT_ROOT"
    fi
    [[ -d "$PUBSUB_ROOT" ]] || mkdir -p "$PUBSUB_ROOT" 2>/dev/null || {
        echo "pubsub: failed to create PUBSUB_ROOT '$PUBSUB_ROOT'" >&2
        return 1
    }
}

# Echo the directory path for a given topic (no side effects).
_pubsub::topic_dir() {
    local topic="$1"
    echo "$PUBSUB_ROOT/$topic"
}

# Validate that a pipe path is within PUBSUB_ROOT (safety check for unsubscribe).
_pubsub::validate_pipe() {
    local pipe="$1"
    [[ "$pipe" == "$PUBSUB_ROOT/"* ]] && [[ -p "$pipe" ]]
}

# ==============================================================================
# PUBLIC API
# ==============================================================================

# Set PUBSUB_ROOT default if not already configured by the caller.
# Usage: pubsub::init
pubsub::init() {
    PUBSUB_ROOT="${PUBSUB_ROOT:-$_PUBSUB_DEFAULT_ROOT}"
    mkdir -p "$PUBSUB_ROOT" 2>/dev/null || {
        echo "pubsub::init: failed to create PUBSUB_ROOT '$PUBSUB_ROOT'" >&2
        return 1
    }
}

# Create a named FIFO subscription on a topic. Prints the pipe path to stdout.
# The caller opens the pipe for reading (blocks until a publisher writes).
# Usage: pipe=$(pubsub::subscribe <topic>)
pubsub::subscribe() {
    local topic="$1"
    if [[ -z "$topic" ]]; then
        echo "pubsub::subscribe: topic required" >&2
        return 1
    fi
    _pubsub::ensure_root || return 1

    local topic_dir
    topic_dir=$(_pubsub::topic_dir "$topic")
    mkdir -p "$topic_dir" 2>/dev/null || {
        echo "pubsub::subscribe: failed to create topic dir '$topic_dir'" >&2
        return 1
    }

    local pipe_path max_attempts=10 attempt=0
    while (( attempt < max_attempts )); do
        pipe_path="$topic_dir/pipe.${RANDOM}${RANDOM}.$$"
        if mkfifo -m 600 "$pipe_path" 2>/dev/null; then
            echo "$pipe_path"
            return 0
        fi
        (( attempt++ ))
    done
    echo "pubsub::subscribe: failed to create FIFO after $max_attempts attempts" >&2
    return 1
}

# Remove a subscription pipe. Validates the path is under PUBSUB_ROOT.
# Usage: pubsub::unsubscribe <pipe>
pubsub::unsubscribe() {
    local pipe="$1"
    if [[ -z "$pipe" ]]; then
        echo "pubsub::unsubscribe: pipe path required" >&2
        return 1
    fi
    _pubsub::ensure_root || return 1
    if ! _pubsub::validate_pipe "$pipe"; then
        echo "pubsub::unsubscribe: path is not a valid subscription pipe: $pipe" >&2
        return 1
    fi
    rm -f "$pipe"
}

# Publish a message (from stdin) to all subscribers on a topic.
# Uses fan-out: each subscriber gets a copy. Non-blocking per subscriber
# so a dead subscriber never stalls the publisher.
# Usage: echo "message" | pubsub::publish <topic>
pubsub::publish() {
    local topic="$1"
    if [[ -z "$topic" ]]; then
        echo "pubsub::publish: topic required" >&2
        return 1
    fi
    _pubsub::ensure_root || return 1

    local topic_dir
    topic_dir=$(_pubsub::topic_dir "$topic")
    [[ -d "$topic_dir" ]] || return 0  # no topic dir = no subscribers, silent no-op

    local pipes=() pipe
    while IFS= read -r pipe; do
        pipes+=("$pipe")
    done < <(find "$topic_dir" -type p 2>/dev/null)

    if (( ${#pipes[@]} == 0 )); then
        return 0  # no subscribers
    fi

    local input
    input=$(cat)  # read entire stdin

    # Fan out with timeout — a blocked subscriber must not stall the publisher.
    # Write to each pipe in the background with a 2-second timeout.
    local pids=() pid
    for pipe in "${pipes[@]}"; do
        if command -v timeout &>/dev/null; then
            ( timeout 2 bash -c 'echo "$1" > "$2"' _ "$input" "$pipe" 2>/dev/null || true ) &
        else
            ( echo "$input" > "$pipe" 2>/dev/null || true ) &
        fi
        pids+=($!)
    done

    for pid in "${pids[@]}"; do
        wait "$pid" 2>/dev/null || true
    done
}

# List active topic names (one per line).
# Usage: pubsub::topics
pubsub::topics() {
    _pubsub::ensure_root || return 1
    find "$PUBSUB_ROOT" -maxdepth 1 -type d ! -path "$PUBSUB_ROOT" -printf '%f\n' 2>/dev/null
}

# Count current subscribers on a topic. Prints an integer to stdout.
# Usage: pubsub::count <topic>
pubsub::count() {
    local topic="$1"
    if [[ -z "$topic" ]]; then
        echo "0"
        return 0
    fi
    _pubsub::ensure_root || return 1
    local topic_dir
    topic_dir=$(_pubsub::topic_dir "$topic")
    [[ -d "$topic_dir" ]] || { echo "0"; return 0; }
    find "$topic_dir" -type p 2>/dev/null | wc -l
}
# random.sh — bash-frameheader PRNG museum lib
#
# A collection of pseudorandom number generator algorithms, from historical
# curiosities to modern high-quality generators. Each is self-contained and
# educational. All operate on caller-supplied state — no hidden globals.
#
# IMPORTANT: None of these are cryptographically secure. For security-sensitive
# use, read from /dev/urandom directly.
#
# NOTE ON BASH ARITHMETIC:
# Bash uses signed 64-bit integers. 32-bit algorithms mask results to
# 0xFFFFFFFF to simulate unsigned 32-bit overflow correctly. 64-bit algorithms
# are subject to signed overflow on very large values — results may differ
# from reference C implementations.

# ==============================================================================
# HELPERS
# ==============================================================================

# Mask a value to unsigned 32-bit range
_random::mask32() {
    echo $(( $1 & 0xFFFFFFFF ))
}

# Rotate left (32-bit)
_random::rotl32() {
    local x="$1" n="$2"
    echo $(( ((x << n) | (x >> (32 - n))) & 0xFFFFFFFF ))
}

# Rotate left (64-bit, best-effort under signed 64-bit bash arithmetic)
_random::rotl64() {
    local x="$1" n="$2"
    echo $(( (x << n) | (x >> (64 - n)) ))
}

# Seed from /dev/urandom — returns a 32-bit unsigned integer
random::seed32() {
    od -An -N4 -tu4 /dev/urandom 2>/dev/null | tr -d ' \n' || echo "$RANDOM"
}

# Seed from /dev/urandom — returns a 64-bit value (may be negative in bash)
random::seed64() {
    od -An -N8 -tu8 /dev/urandom 2>/dev/null | tr -d ' \n' \
        || echo "$(( RANDOM * 32768 + RANDOM ))"
}

# ==============================================================================
# NATIVE
# Period: 2^15. Quality: poor. Use: quick throwaway needs only.
# Bash's built-in $RANDOM — 15-bit LCG, reseeds from PID+time on subshell.
# ==============================================================================

random::native() {
    echo "$RANDOM"
}

# Returns a value in [min, max] inclusive
# Usage: random::native::range min max
random::native::range() {
    local min="$1" max="$2"
    echo $(( (RANDOM % (max - min + 1)) + min ))
}

# ==============================================================================
# MIDDLE SQUARE
# Period: variable, often very short. Quality: very poor. Use: historical demo.
# John von Neumann, 1946. The original PRNG. Notorious for degenerating to
# zero for many seeds. Use only for educational purposes.
# ==============================================================================

# Usage: random::middle_square seed
# Returns: next value (4-digit middle square extract)
# WARNING: Degenerates to 0 for many seeds. Short cycles are common.
random::middle_square() {
    local x="$1"
    local squared=$(( x * x ))
    echo $(( (squared / 100) % 10000 ))
}

# ==============================================================================
# LINEAR CONGRUENTIAL GENERATOR (LCG)
# Period: 2^32. Quality: poor-moderate. Use: simple simulations, not security.
# Classic algorithm, used in early C stdlib rand() implementations.
# Numerical Recipes parameters (Press et al.)
# ==============================================================================

# Usage: random::lcg state
# Returns: next state (also the output value)
random::lcg() {
    _random::mask32 $(( $1 * 1664525 + 1013904223 ))
}

# Glibc rand() parameters
random::lcg::glibc() {
    _random::mask32 $(( $1 * 1103515245 + 12345 ))
}

# ==============================================================================
# XORSHIFT32
# Period: 2^32-1. Quality: moderate. Use: fast non-secure generation.
# George Marsaglia, 2003. Simple bitwise operations only.
# ==============================================================================

# Usage: random::xorshift32 state
# Returns: next state (also the output value)
random::xorshift32() {
    local x
    x=$(_random::mask32 "$1")
    x=$(( x ^ (x << 13) )); x=$(_random::mask32 $x)
    x=$(( x ^ (x >> 17) ))
    x=$(( x ^ (x << 5)  )); x=$(_random::mask32 $x)
    echo "$x"
}

# ==============================================================================
# XORSHIFT64
# Period: 2^64-1. Quality: moderate. Use: fast non-secure generation.
# George Marsaglia, 2003. 64-bit variant.
# ==============================================================================

# Usage: random::xorshift64 state
# Returns: next state (also the output value)
random::xorshift64() {
    local x="$1"
    x=$(( x ^ (x << 13) ))
    x=$(( x ^ (x >> 7)  ))
    x=$(( x ^ (x << 17) ))
    echo "$x"
}

# ==============================================================================
# XORSHIFT128+
# Period: 2^128-1. Quality: good (passes most BigCrush tests). Use: general purpose.
# Sebastiano Vigna, 2014. Used in V8, SpiderMonkey, and WebKit Math.random().
# State: two 64-bit values (s0, s1).
# ==============================================================================

# Usage: random::xorshiftr128plus s0 s1
# Returns: "result s0_new s1_new"
# Caller must unpack and pass s0_new/s1_new on the next call:
#   read -r val s0 s1 <<< "$(random::xorshiftr128plus $s0 $s1)"
random::xorshiftr128plus() {
    local s0="$1" s1="$2"

    local result=$(( s0 + s1 ))
    s1=$(( s1 ^ s0 ))
    s0=$(( $(_random::rotl64 $s0 23) ^ s1 ^ (s1 << 17) ))
    s1=$(_random::rotl64 $s1 26)

    echo "$result $s0 $s1"
}

# ==============================================================================
# XOSHIRO256** (star-star)
# Period: 2^256-1. Quality: excellent. Use: general purpose, floating point.
# Blackman & Vigna, 2018. Successor to xorshift128+. State: four 64-bit values.
# ==============================================================================

# Usage: random::xoshiro256ss s0 s1 s2 s3
# Returns: "result s0_new s1_new s2_new s3_new"
#   read -r val s0 s1 s2 s3 <<< "$(random::xoshiro256ss $s0 $s1 $s2 $s3)"
random::xoshiro256ss() {
    local s0="$1" s1="$2" s2="$3" s3="$4"

    local result
    result=$(_random::rotl64 $(( s1 * 5 )) 7)
    result=$(( result * 9 ))
    local t=$(( s1 << 17 ))

    s2=$(( s2 ^ s0 ))
    s3=$(( s3 ^ s1 ))
    s1=$(( s1 ^ s2 ))
    s0=$(( s0 ^ s3 ))
    s2=$(( s2 ^ t ))
    s3=$(_random::rotl64 $s3 45)

    echo "$result $s0 $s1 $s2 $s3"
}

# Xoshiro256+ — faster output, slightly weaker low bits
# Usage: same as xoshiro256ss
random::xoshiro256p() {
    local s0="$1" s1="$2" s2="$3" s3="$4"

    local result=$(( s0 + s3 ))
    local t=$(( s1 << 17 ))

    s2=$(( s2 ^ s0 ))
    s3=$(( s3 ^ s1 ))
    s1=$(( s1 ^ s2 ))
    s0=$(( s0 ^ s3 ))
    s2=$(( s2 ^ t ))
    s3=$(_random::rotl64 $s3 45)

    echo "$result $s0 $s1 $s2 $s3"
}

# ==============================================================================
# PCG32 (Permuted Congruential Generator)
# Period: 2^64. Quality: excellent. Use: general purpose, simulation.
# Melissa O'Neill, 2014. LCG base with permutation output function.
# Passes all known statistical tests. inc must be odd (enforced internally).
# ==============================================================================

# Usage: random::pcg32 state inc
# Returns: "result new_state"
#   read -r val state <<< "$(random::pcg32 $state $inc)"
random::pcg32() {
    local state="$1" inc="$2"

    local oldstate="$state"
    state=$(( oldstate * 6364136223846793005 + (inc | 1) ))

    local xorshifted=$(( ((oldstate >> 18) ^ oldstate) >> 27 ))
    local rot=$(( oldstate >> 59 ))
    local result
    result=$(_random::mask32 $(( (xorshifted >> rot) | (xorshifted << ((-rot) & 31)) )))

    echo "$result $state"
}

# PCG32 fast — hardcoded increment, same quality
# Usage: random::pcg32::fast state
# Returns: "result new_state"
random::pcg32::fast() {
    local state="$1"

    local oldstate="$state"
    state=$(( oldstate * 6364136223846793005 + 1442695040888963407 ))

    local xorshifted=$(( ((oldstate >> 18) ^ oldstate) >> 27 ))
    local rot=$(( oldstate >> 59 ))
    local result
    result=$(_random::mask32 $(( (xorshifted >> rot) | (xorshifted << ((-rot) & 31)) )))

    echo "$result $state"
}

# ==============================================================================
# SPLITMIX64
# Period: 2^64. Quality: good. Use: seeding other PRNGs, fast generation.
# Guy Steele, Doug Lea, Christine Flood — Java 8, 2014.
# Particularly useful for expanding a single seed into multi-word PRNG state.
# ==============================================================================

# Usage: random::splitmix64 state
# Returns: "result new_state"
#   read -r val state <<< "$(random::splitmix64 $state)"
random::splitmix64() {
    local state=$(( $1 + 0x9e3779b97f4a7c15 ))
    local z="$state"
    z=$(( (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9 ))
    z=$(( (z ^ (z >> 27)) * 0x94d049bb133111eb ))
    z=$(( z ^ (z >> 31) ))
    echo "$z $state"
}

# Expand a single 64-bit seed into four words for xoshiro256 initialisation
# Usage: random::splitmix64::seed_xoshiro seed
# Returns: "s0 s1 s2 s3"
random::splitmix64::seed_xoshiro() {
    local seed="$1" val state s0 s1 s2 s3
    state="$seed"
    read -r val state <<< "$(random::splitmix64 $state)"; s0="$val"
    read -r val state <<< "$(random::splitmix64 $state)"; s1="$val"
    read -r val state <<< "$(random::splitmix64 $state)"; s2="$val"
    read -r val state <<< "$(random::splitmix64 $state)"; s3="$val"
    echo "$s0 $s1 $s2 $s3"
}

# ==============================================================================
# MULBERRY32
# Period: 2^32. Quality: good for 32-bit. Use: simple fast 32-bit generation.
# Tommy Ettinger. Single 32-bit state, excellent avalanche properties.
# ==============================================================================

# Usage: random::mulberry32 state
# Returns: "result new_state"
random::mulberry32() {
    local state
    state=$(_random::mask32 $(( $1 + 0x6D2B79F5 )))
    local z="$state"
    z=$(_random::mask32 $(( (z ^ (z >> 15)) * (1 | (z << 1)) )))
    z=$(_random::mask32 $(( z ^ (z >> 7) ^ ( (z ^ (z >> 7)) * (61 | (z << 3)) ) )))
    echo "$(( z ^ (z >> 14) )) $state"
}

# ==============================================================================
# WYRAND
# Period: 2^64. Quality: excellent. Use: hashing, fast generation.
# Wang Yi, 2019. Passes BigCrush. The output function of the wyhash family.
# ==============================================================================

# Usage: random::wyrand state
# Returns: "result new_state"
random::wyrand() {
    local state=$(( $1 + 0xa0761d6478bd642f ))
    local a=$(( state ^ 0xe7037ed1a0b428db ))
    # Approximate 128-bit multiply via two halves (best-effort in bash)
    local hi=$(( (state >> 32) * (a >> 32) ))
    local lo=$(( (state & 0xFFFFFFFF) * (a & 0xFFFFFFFF) ))
    local result=$(( hi ^ lo ))
    echo "$result $state"
}

# ==============================================================================
# WELL512 (Well Equidistributed Long-period Linear)
# Period: 2^512-1. Quality: excellent. Use: simulation, games.
# Panneton, L'Ecuyer & Matsumoto, 2006. Better equidistribution than Mersenne
# Twister at similar speed. State: 16 x 32-bit words + index.
# ==============================================================================

# Initialise WELL512 state from a single seed via splitmix64
# Usage: random::well512::init seed
# Returns: "0 s0 s1 ... s15"
random::well512::init() {
    local seed="$1" val state
    state="$seed"
    local -a words=()
    for (( i=0; i<16; i++ )); do
        read -r val state <<< "$(random::splitmix64 $state)"
        words+=( "$(_random::mask32 $val)" )
    done
    echo "0 ${words[*]}"
}

# Usage: random::well512 index s0 s1 ... s15
# Returns: "result new_index s0 ... s15"
# Example:
#   read -r val idx s0 s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 s14 s15 \
#       <<< "$(random::well512 $idx $s0 ... $s15)"
random::well512() {
    local index="$1"; shift
    local -a s=("$@")

    local a="${s[$index]}"
    local c="${s[$(( (index + 13) & 15 ))]}"
    local b
    b=$(_random::mask32 $(( (a ^ (a << 16)) ^ (c ^ (c << 15)) )))
    local d="${s[$(( (index + 9) & 15 ))]}"
    d=$(( d ^ (d >> 11) ))
    s[$index]=$(_random::mask32 $(( b ^ d )))
    local e="${s[$index]}"
    local result
    result=$(_random::mask32 $(( e ^ ((e << 5) & 0xDA442D24) )))
    index=$(( (index + 15) & 15 ))
    a="${s[$index]}"
    s[$index]=$(_random::mask32 $(( a ^ b ^ d ^ (a << 2) ^ (b << 18) ^ (c << 28) )))
    result=$(_random::mask32 $(( result ^ s[$index] )))

    echo "$result $index ${s[*]}"
}

# ==============================================================================
# ISAAC (Indirection, Shift, Accumulate, Add, Count)
# Period: 2^8295. Quality: cryptographic-adjacent. Use: security-adjacent tasks.
# Robert Jenkins, 1996. Not considered cryptographically secure by modern
# standards but far stronger than the other algorithms here.
# NOTE: Full ISAAC requires 256-word state — this is a simplified single-round
# demonstration using a 8-word state for educational purposes.
# ==============================================================================

# Initialise simplified ISAAC state
# Usage: random::isaac::init seed
# Returns: "a b c s0 s1 s2 s3 s4 s5 s6 s7"
random::isaac::init() {
    local seed="$1" val state
    state="$seed"
    local -a words=()
    for (( i=0; i<8; i++ )); do
        read -r val state <<< "$(random::splitmix64 $state)"
        words+=( "$(_random::mask32 $val)" )
    done
    echo "0 0 0 ${words[*]}"
}

# Usage: random::isaac a b c s0..s7
# Returns: "result new_a new_b new_c s0..s7"
random::isaac() {
    local a="$1" b="$2" c="$3"; shift 3
    local -a s=("$@")

    c=$(( c + 1 ))
    b=$(( b + c ))
    a=$(( (a ^ (a << 13)) & 0xFFFFFFFF ))
    local x="${s[0]}"
    a=$(( (a + s[4]) & 0xFFFFFFFF ))
    local y=$(( (x + a + b) & 0xFFFFFFFF ))
    s[0]=$(( (y ^ (y >> 13)) & 0xFFFFFFFF ))
    b=$(( (s[0] + x) & 0xFFFFFFFF ))
    local result="$b"

    # Rotate state
    local tmp="${s[0]}"
    for (( i=0; i<7; i++ )); do s[$i]="${s[$((i+1))]}"; done
    s[7]="$tmp"

    echo "$result $a $b $c ${s[*]}"
}
runtime::is_terminal() {
  # Thorough check for all standard file descriptors (stdin, stdout, stderr)
  [[ -t 0 && -t 1 && -t 2 ]]
}

runtime::is_terminal::stdin() {
  [[ -t 0 ]]
}

runtime::is_terminal::stdout() {
  [[ -t 1 ]]
}

runtime::is_terminal::stderr() {
  [[ -t 2 ]]
}

runtime::is_traced() {
    [[ "$-" == *x* ]] || [[ -n "$BASH_XTRACEFD" ]]
}

runtime::is_verbose() {
    [[ "$-" == *v* ]]
}

runtime::errexit_enabled() {
    [[ "$-" == *e* ]]
}

runtime::nounset_enabled() {
    [[ "$-" == *u* ]]
}

runtime::noclobber_enabled() {
    [[ "$-" == *C* ]]
}

runtime::is_interactive() {
  [[ $- == *i* ]]
}

runtime::has_flag() {
    local flag="$1"
    [[ "$-" == *"$flag"* ]]
}

runtime::is_login() {
  shopt -q login_shell
}

runtime::is_sourced() {
  [[ "${BASH_SOURCE[0]}" != "${0}" ]]
}

runtime::is_bash() {
  [[ -n "$BASH_VERSION" ]]
}

runtime::is_pipe() {
  # Check if stdin is a pipe
  [[ -p /dev/stdin ]] && return 0

  # Check if stdin is redirected from a file
  [[ ! -t 0 ]] && return 0

  # Only check jobs if we're not interactive
  if ! runtime::is_interactive && [[ -n "$(jobs -p)" ]]; then
    return 0
  fi

  return 1
}

runtime::is_redirected() {
  # Check if any std descriptor is redirected
  [[ ! -t 0 ]] || [[ ! -t 1 ]] || [[ ! -t 2 ]]
}

runtime::is_subshell() {
    [[ "$BASH_SUBSHELL" -gt 0 ]]
}

runtime::job_controlled() {
    [[ "$-" == *m* ]]
}

runtime::debug_trapped() {
    [[ -n "$(trap -p DEBUG)" ]]
}

runtime::braceexpand_enabled() {
    [[ "$-" == *B* ]]
}

runtime::histexpand_enabled() {
    [[ "$-" == *H* ]]
}

runtime::physical_cd_enabled() {
    [[ "$-" == *P* ]]
}


runtime::has_command() {
  command -v "$1" >/dev/null 2>&1
}

runtime::is_root() {
  [[ $EUID -eq 0 ]]
}

runtime::is_desktop() {
  [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]
}

runtime::de() {
    if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
        echo "none"; return
    fi

    local _s="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-${GDMSESSION:-}}}"
    case "${_s,,}" in
        *gnome*)    echo "gnome";    return ;;
        *kde*)      echo "kde";      return ;;
        *xfce*)     echo "xfce";     return ;;
        *lxqt*)     echo "lxqt";     return ;;
        *lxde*)     echo "lxde";     return ;;
        *mate*)     echo "mate";     return ;;
        *cinnamon*) echo "cinnamon"; return ;;
        *budgie*)   echo "budgie";   return ;;
        *deepin*)   echo "deepin";   return ;;
        *pantheon*) echo "pantheon"; return ;;
        *unity*)    echo "unity";    return ;;
        *cosmic*)   echo "cosmic";   return ;;
    esac

    local -A _procs=(
        [gnome-shell]=gnome   [plasmashell]=kde      [xfce4-session]=xfce
        [lxqt-session]=lxqt   [lxsession]=lxde       [mate-session]=mate
        [cinnamon]=cinnamon   [budgie-daemon]=budgie  [deepin-session]=deepin
        [pantheon]=pantheon   [unity]=unity           [cosmic-session]=cosmic
    )
    local _p
    for _p in "${!_procs[@]}"; do
        pgrep -x "$_p" >/dev/null 2>&1 && echo "${_procs[$_p]}" && return
    done

    # Display present but only a bare WM — let caller query runtime::wm
    local _wm; _wm=$(runtime::wm)
    [[ "$_wm" != "unknown" ]] && echo "wm-only" && return

    echo "unknown"
}

runtime::wm() {
    if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
        echo "none"; return
    fi

    local _s="${XDG_SESSION_DESKTOP:-}"
    case "${_s,,}" in
        *hyprland*) echo "hyprland"; return ;;
        *sway*)     echo "sway";     return ;;
        *wayfire*)  echo "wayfire";  return ;;
        *river*)    echo "river";    return ;;
    esac

    if runtime::has_command xprop && [[ -n "${DISPLAY:-}" ]]; then
        local _n
        _n=$(xprop -root -notype _NET_WM_NAME 2>/dev/null | sed 's/.*= *"//;s/".*//')
        [[ -n "$_n" ]] && echo "${_n,,}" && return
    fi

    local -A _procs=(
        [hyprland]=hyprland      [sway]=sway          [wayfire]=wayfire
        [river]=river            [mutter]=mutter       [kwin_wayland]=kwin
        [kwin_x11]=kwin          [xfwm4]=xfwm4        [openbox]=openbox
        [i3]=i3                  [bspwm]=bspwm         [awesome]=awesome
        [herbstluftwm]=herbstluftwm                   [fluxbox]=fluxbox
        [icewm]=icewm            [jwm]=jwm             [qtile]=qtile
        [xmonad]=xmonad          [marco]=marco         [metacity]=metacity
        [compiz]=compiz          [enlightenment]=enlightenment
    )
    local _p
    for _p in "${!_procs[@]}"; do
        pgrep -x "$_p" >/dev/null 2>&1 && echo "${_procs[$_p]}" && return
    done

    echo "unknown"
}

runtime::is_wayland() { [[ -n "${WAYLAND_DISPLAY:-}" ]]; }
runtime::is_x11()     { [[ -n "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; }

runtime::sysinit() {
  ps -p 1 -o comm=
}

runtime::is_sudo() {
  [[ -n "$SUDO_USER" ]]
}


runtime::is_ci() {
  [[ -n "$CI" ]] ||
    [[ -n "$GITHUB_ACTIONS" ]] ||
    [[ -n "$GITLAB_CI" ]] ||
    [[ -n "$CIRCLECI" ]] ||
    [[ -n "$TRAVIS" ]] ||
    [[ -n "$JENKINS_URL" ]] ||
    [[ -n "$BITBUCKET_BUILD_NUMBER" ]] ||
    [[ -n "$TEAMCITY_VERSION" ]] ||
    [[ -n "$DRONE" ]] ||
    [[ -n "$CODEBUILD_BUILD_ID" ]] ||
    [[ -n "$AZURE_HTTP_USER_AGENT" ]] ||  # Azure DevOps
    [[ -n "$BUILDKITE" ]]  # Buildkite
}

runtime::kernel_version() {
  [[ $(runtime::os) == "linux" ]] || return 1
  # Number only, case of checks where you don't care about types
  local v
  v=$(uname -r)
  printf '%s\n' "${v%%-*}"
}

runtime::exec_root() {
  # Already root, nothing to do
  if runtime::is_root; then
    return 0
  fi

  if runtime::has_command sudo; then
    # In a non-terminal context, check if sudo can run without a password prompt
    # -n flag makes sudo fail immediately instead of hanging if password is needed
    if ! runtime::is_terminal && ! sudo -n true 2>/dev/null; then
      echo "runtime::request_root: sudo requires a password but no terminal is available, will attempt alternatives." >&2
      # Fall through to other methods
    else
      sudo "$@"
      return $?
    fi
  fi

  if runtime::has_command pkexec && runtime::is_desktop; then
    pkexec "$@"
  elif runtime::has_command doas; then
    doas "$@"
  elif runtime::has_command su; then
    # su -c takes a single string, fragile with spaces in arguments
    su -c "exec $(printf '%q ' "$@")" root
  else
    echo "runtime::request_root: no privilege escalation method found" >&2
    return 1
  fi
}

runtime::is_wsl() {
  [[ -f /proc/version ]] && grep -qi "microsoft" /proc/version
}

runtime::os() {
  if runtime::is_wsl; then
    echo "wsl"
    return
  fi

  case "$(uname -s)" in
  Linux*) echo "linux" ;;
  Darwin*) echo "darwin" ;;
  CYGWIN*) echo "cygwin" ;;
  MINGW*) echo "mingw" ;;
  *) echo "unknown" ;;
  esac
}

runtime::arch() {
  case "$(uname -m)" in
  x86_64) echo "amd64" ;;
  i386) echo "386" ;;
  armv7l) echo "armv7" ;;
  aarch64) echo "arm64" ;;
  *) echo "unknown" ;;
  esac
}

runtime::distro() {
  if [[ -f /etc/os-release ]]; then
    (. /etc/os-release && echo "$ID")
  else
    echo "unknown"
  fi
}

runtime::bash_version() {
  echo "${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}.${BASH_VERSINFO[2]}"
}

runtime::bash_version::major() {
  echo "${BASH_VERSINFO[0]}"
}

# Default to 3, assuming that's what's at least needed for this framework (not final)
runtime::is_minimum_bash() {
  ((BASH_VERSINFO[0] >= ${1:-3}))
}

runtime::is_container() {
  [[ -f /.dockerenv ]] ||
  [[ -f /run/.containerenv ]] ||
  grep -q "docker\|lxc\|kubepods" /proc/1/cgroup 2>/dev/null ||
  [[ -n "$CONTAINER" ]] ||
  [[ -n "$KUBERNETES_SERVICE_HOST" ]]
}

runtime::supports_color() {
  # Check if terminal supports color
  [[ -t 1 ]] && [[ "$TERM" != "dumb" ]] && {
    [[ -n "$COLORTERM" ]] ||
    [[ "$TERM" =~ ^(xterm|screen|vt100|linux|ansi) ]] || {
      local colors
      colors=$(tput colors 2>/dev/null)
      [[ -n "$colors" && "$colors" -ge 8 ]]
    }
  }
}


runtime::supports_truecolor() {
  [[ -n "$COLORTERM" ]] && [[ "$COLORTERM" =~ ^(truecolor|24bit) ]]
}

runtime::is_multiplexer() {
  [[ -n "$STY" ]] || [[ -n "$TMUX" ]]
}

runtime::is_tmux() {
  [[ -n "$TMUX" ]]
}

runtime::screen_session() {
  echo "${STY:-${TMUX:-none}}"
}

runtime::is_ssh() {
  [[ -n "$SSH_CLIENT" ]] ||
  [[ -n "$SSH_TTY" ]] ||
  [[ -n "$SSH_CONNECTION" ]]
}

runtime::ssh_client() {
  echo "${SSH_CLIENT%% *}"  # First part is client IP
}

runtime::is_tty() {
  # Check if we have a controlling terminal
  [[ -t 0 ]] && tty -s 2>/dev/null
}

runtime::tty_name() {
  tty 2>/dev/null || echo "not a tty"
}

runtime::is_pty() {
  # Check if we're in a pseudo-terminal
  [[ "$(tty)" =~ ^/dev/pts/[0-9]+ ]]
}


runtime::is_virtualized() {
  if [[ $(runtime::os) == "linux" ]]; then
    if [[ -f /proc/cpuinfo ]]; then
      grep -q "hypervisor" /proc/cpuinfo && return 0
    fi
    if [[ -f /sys/class/dmi/id/product_name ]]; then
      local product
      product=$(cat /sys/class/dmi/id/product_name 2>/dev/null)
      [[ "$product" =~ (VirtualBox|VMware|KVM|QEMU|Xen|Hyper-V) ]] && return 0
    fi
  fi
  return 1
}


runtime::pm() {
  if runtime::has_command apt-get; then
    echo "apt"
  elif runtime::has_command pacman; then
    echo "pacman"
  elif runtime::has_command dnf; then
    echo "dnf"
  elif runtime::has_command yum; then
    echo "yum"
  elif runtime::has_command zypper; then
    echo "zypper"
  elif runtime::has_command apk; then
    echo "apk"
  elif runtime::has_command brew; then
    echo "brew"
  elif runtime::has_command pkg; then
    echo "pkg"
  elif runtime::has_command xbps-install; then
    echo "xbps"
  elif runtime::has_command nix-env; then
    echo "nix"
  else
    echo "unknown"
  fi
}

# ==============================================================================
# COPROC
# ==============================================================================

# Active coproc tracking array.
declare -a _RUNTIME_COPROCS=()

# Start a named coprocess. Stores name for tracking.
# Usage: runtime::coproc::start <name> <command...>
runtime::coproc::start() {
    local name=$1; shift
    if [[ -z "$name" ]]; then
        echo "runtime::coproc::start: name required" >&2
        return 1
    fi
    if [[ " ${_RUNTIME_COPROCS[*]} " == *" $name "* ]]; then
        echo "runtime::coproc::start: coproc '$name' already exists" >&2
        return 1
    fi
    coproc "$name" { "$@" 2>&1; }
    _RUNTIME_COPROCS+=("$name")
}

# Send data to a coproc's stdin.
# Usage: runtime::coproc::send <name> <data>
runtime::coproc::send() {
    local name=$1 data=$2
    local -n _cs_fd="${name}[1]"
    printf '%s\n' "$data" >&${_cs_fd}
}

# Read one line from a coproc's stdout (blocks until data available).
# Usage: runtime::coproc::read <name>
runtime::coproc::read() {
    local name=$1 line
    local -n _cr_fd="${name}[0]"
    IFS= read -r -t 5 line <&${_cr_fd} || true
    echo "$line"
}

# Read all available output from a coproc (non-blocking).
# Usage: runtime::coproc::read_all <name>
runtime::coproc::read_all() {
    local name=$1 line
    local -n _cra_fd="${name}[0]"
    while IFS= read -r -t 0.1 line <&${_cra_fd} 2>/dev/null; do
        echo "$line"
    done
}

# Return 0 if the named coproc is alive.
# Usage: runtime::coproc::alive <name>
runtime::coproc::alive() {
    local pid; pid=$(runtime::coproc::pid "$1" 2>/dev/null) || return 1
    kill -0 "$pid" 2>/dev/null
}

# Echo the PID of a named coproc.
# Usage: runtime::coproc::pid <name>
runtime::coproc::pid() {
    local -n _cp_var="${1}_PID"
    echo "${_cp_var:-}"
}

# Stop a named coproc (kill process, close fds).
# Usage: runtime::coproc::stop <name>
runtime::coproc::stop() {
    local name=$1
    local pid; pid=$(runtime::coproc::pid "$name" 2>/dev/null) || return 1

    local -n _cs_fd="${name}[0]" 2>/dev/null && eval "exec ${_cs_fd}<&-" 2>/dev/null
    local -n _cs_fd1="${name}[1]" 2>/dev/null && eval "exec ${_cs_fd1}>&-" 2>/dev/null

    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true

    local i new_arr=()
    for i in "${_RUNTIME_COPROCS[@]}"; do
        [[ "$i" != "$name" ]] && new_arr+=("$i")
    done
    _RUNTIME_COPROCS=("${new_arr[@]}")
}

# List active tracked coprocs.
# Usage: runtime::coproc::list
runtime::coproc::list() {
    local name
    for name in "${_RUNTIME_COPROCS[@]}"; do
        local pid; pid=$(runtime::coproc::pid "$name" 2>/dev/null)
        local alive="dead"
        runtime::coproc::alive "$name" 2>/dev/null && alive="alive"
        echo "$name pid=$pid $alive"
    done
}

# ==============================================================================
# PROCESS
# ==============================================================================

# Cache for /proc/<pid>/stat parsing: _RUNTIME_PROC_CACHE[<pid>:<field>]
declare -A _RUNTIME_PROC_CACHE

# Internal: parse /proc/<pid>/stat and cache all fields.
_runtime::parse_stat() {
    local pid=$1
    local cache_key="${pid}:parsed"
    [[ -n "${_RUNTIME_PROC_CACHE[$cache_key]:-}" ]] && return 0

    [[ "$(runtime::os)" != "linux" ]] && return 1

    local stat_file="/proc/$pid/stat"
    [[ -f "$stat_file" ]] || return 1

    local raw; raw=$(cat "$stat_file" 2>/dev/null)
    [[ -z "$raw" ]] && return 1

    # Split: "1234 (comm) S 5678 ..." → extract comm between parens
    local comm_start comm_end rest
    comm_start="${raw#*(}"
    comm_end="${comm_start%)*}"
    rest="${comm_start#*) }"

    local -a fields
    read -ra fields <<< "$rest"

    _RUNTIME_PROC_CACHE["$pid:pid"]="$pid"
    _RUNTIME_PROC_CACHE["$pid:comm"]="$comm_end"
    _RUNTIME_PROC_CACHE["$pid:state"]="${fields[0]}"
    _RUNTIME_PROC_CACHE["$pid:ppid"]="${fields[1]}"
    _RUNTIME_PROC_CACHE["$pid:threads"]="${fields[17]}"
    _RUNTIME_PROC_CACHE["$pid:rss"]="$(( ${fields[21]} * 4 ))"
    _RUNTIME_PROC_CACHE["$pid:vsize"]="${fields[20]}"
    _RUNTIME_PROC_CACHE["$pid:utime"]="${fields[12]}"
    _RUNTIME_PROC_CACHE["$pid:stime"]="${fields[13]}"
    _RUNTIME_PROC_CACHE["$pid:starttime"]="${fields[19]}"

    local clk_tck=100 uptime boot_ticks
    uptime=$(awk '{printf "%.0f", $1}' /proc/uptime 2>/dev/null)
    boot_ticks=$(( ${_RUNTIME_PROC_CACHE["$pid:starttime"]} / clk_tck ))
    _RUNTIME_PROC_CACHE["$pid:uptime"]=$(( uptime - boot_ticks ))

    _RUNTIME_PROC_CACHE[$cache_key]=1
}

# Check if a PID exists.
# Usage: runtime::process::exists <pid>
runtime::process::exists() {
    kill -0 "$1" 2>/dev/null
}

# Echo the parent PID.
# Usage: runtime::process::ppid <pid>
runtime::process::ppid() {
    _runtime::parse_stat "$1" || { echo "0"; return 1; }
    echo "${_RUNTIME_PROC_CACHE[$1:ppid]}"
}

# Echo the process state: R/S/D/Z/T.
# Usage: runtime::process::state <pid>
runtime::process::state() {
    _runtime::parse_stat "$1" || return 1
    echo "${_RUNTIME_PROC_CACHE[$1:state]}"
}

# Echo resident memory in KB.
# Usage: runtime::process::rss <pid>
runtime::process::rss() {
    _runtime::parse_stat "$1" || { echo "0"; return 1; }
    echo "${_RUNTIME_PROC_CACHE[$1:rss]}"
}

# Echo virtual memory in KB.
# Usage: runtime::process::vsize <pid>
runtime::process::vsize() {
    _runtime::parse_stat "$1" || { echo "0"; return 1; }
    echo "${_RUNTIME_PROC_CACHE[$1:vsize]}"
}

# Echo the full command line (null-separated args joined with spaces).
# Usage: runtime::process::cmdline <pid>
runtime::process::cmdline() {
    [[ "$(runtime::os)" == "linux" && -f "/proc/$1/cmdline" ]] || return 1
    tr '\0' ' ' < "/proc/$1/cmdline"
}

# Echo the short command name (comm).
# Usage: runtime::process::comm <pid>
runtime::process::comm() {
    _runtime::parse_stat "$1" || return 1
    echo "${_RUNTIME_PROC_CACHE[$1:comm]}"
}

# Echo the thread count.
# Usage: runtime::process::threads <pid>
runtime::process::threads() {
    _runtime::parse_stat "$1" || { echo "0"; return 1; }
    echo "${_RUNTIME_PROC_CACHE[$1:threads]}"
}

# Echo seconds since process start.
# Usage: runtime::process::uptime <pid>
runtime::process::uptime() {
    _runtime::parse_stat "$1" || { echo "0"; return 1; }
    echo "${_RUNTIME_PROC_CACHE[$1:uptime]}"
}

# List child PIDs (space-separated).
# Usage: runtime::process::children <pid>
runtime::process::children() {
    [[ "$(runtime::os)" == "linux" ]] || return 1
    local children; children=$(pgrep -P "$1" 2>/dev/null | tr '\n' ' ')
    echo "${children% }"
}

# Parse full /proc/<pid>/stat and output all fields or a specific one.
# Usage: runtime::process::info <pid> [field]
runtime::process::info() {
    local pid=$1 field=$2
    _runtime::parse_stat "$pid" || return 1

    if [[ -n "$field" ]]; then
        echo "${_RUNTIME_PROC_CACHE[$pid:$field]:-}"
        return
    fi

    for field in pid comm state ppid threads rss vsize utime stime uptime; do
        printf '%s=%s\n' "$field" "${_RUNTIME_PROC_CACHE[$pid:$field]:-}"
    done
}
# string.sh — bash-frameheader string lib
# Pure bash where possible — no external tools unless noted.

# ==============================================================================
# STDIN HELPER
# ==============================================================================

# Internal: read primary input from arg or stdin
# Usage: _string::read_input result_var [arg]
# If $2 is provided (even if empty string), uses it. Otherwise reads stdin if
# available. Callers that need to distinguish "no arg" from "empty arg" must
# use the [[ $# -ge 2 ]] check themselves before calling.
_string::read_input() {
  local -n _string_read_result="$1"
  if [[ $# -ge 2 ]]; then
    _string_read_result="$2"
  elif [[ ! -t 0 ]]; then
    _string_read_result=$(cat)
  else
    _string_read_result=""
  fi
}

# ==============================================================================
# INSPECTION
# ==============================================================================

# Length of a string
# Usage: string::length str
#        echo "str" | string::length
string::length() {
  local input; _string::read_input input "$@"
  echo "${#input}"
}

# Check if string is empty
#        echo "str" | string::is_empty
string::is_empty() {
  local input; _string::read_input input "$@"
  [[ -z "$input" ]]
}

# Check if string is non-empty
#        echo "str" | string::is_not_empty
string::is_not_empty() {
  local input; _string::read_input input "$@"
  [[ -n "$input" ]]
}

# Check if string contains substring
# Usage: string::contains haystack needle
#        echo "haystack" | string::contains needle
string::contains() {
  local input
  if [[ $# -ge 2 ]]; then input="$1"; shift; else input=$(cat); fi
  [[ "$input" == *"$1"* ]]
}

# Check if string starts with prefix
# Usage: string::starts_with str prefix
#        echo "str" | string::starts_with prefix
string::starts_with() {
  local input
  if [[ $# -ge 2 ]]; then input="$1"; shift; else input=$(cat); fi
  [[ "$input" == "$1"* ]]
}

# Check if string ends with suffix
# Usage: string::ends_with str suffix
#        echo "str" | string::ends_with suffix
string::ends_with() {
  local input
  if [[ $# -ge 2 ]]; then input="$1"; shift; else input=$(cat); fi
  [[ "$input" == *"$1" ]]
}

# Check if string matches a regex
# Usage: string::matches str regex
#        echo "str" | string::matches regex
string::matches() {
  local input
  if [[ $# -ge 2 ]]; then input="$1"; shift; else input=$(cat); fi
  [[ "$input" =~ $1 ]]
}

# Check if string is a valid integer
string::is_integer() {
  local input; _string::read_input input "$@"
  [[ "$input" =~ ^-?[0-9]+$ ]]
}

# Check if string is a valid float
string::is_float() {
  local input; _string::read_input input "$@"
  [[ "$input" =~ ^-?[0-9]+(\.[0-9]+)?([Ee][+-]?[0-9]+)?$ ]]
}

string::is_hex() {
  local input; _string::read_input input "$@"
  [[ "$input" =~ ^(0[xX])?[0-9A-Fa-f]+$ ]]
}

string::is_bin() {
  local input; _string::read_input input "$@"
  [[ "$input" =~ ^0b[01]+$ ]]
}

string::is_octal() {
  local input; _string::read_input input "$@"
  [[ "$input" =~ ^0[0-7]+$ ]]
}

string::is_numeric() {
  # accepts int, float, hex, binary, octal
  local input; _string::read_input input "$@"
  string::is_integer "$input" || string::is_float "$input" ||
    string::is_hex "$input" || string::is_bin "$input" ||
    string::is_octal "$input"
}

# Check if string is alphanumeric only
string::is_alnum() {
  local input; _string::read_input input "$@"
  [[ "$input" =~ ^[a-zA-Z0-9]+$ ]]
}

# Check if string is alphabetic only
string::is_alpha() {
  local input; _string::read_input input "$@"
  [[ "$input" =~ ^[a-zA-Z]+$ ]]
}

# ==============================================================================
# CASE
# ==============================================================================

# Convert to uppercase
# Usage: string::upper str
#        echo "str" | string::upper
string::upper() {
  local input; _string::read_input input "$@"
  echo "${input^^}"
}

# Fast variant using nameref
# Usage: string::upper::fast result_var str
string::upper::fast() {
  local -n _string_upper_result="$1"
  _string_upper_result="${2^^}"
}

# Convert to uppercase (Bash 3 compatible)
string::upper::legacy() {
  local input; _string::read_input input "$@"
  echo "$input" | tr '[:lower:]' '[:upper:]'
}

# Convert to lowercase
# Usage: string::lower str
#        echo "str" | string::lower
string::lower() {
  local input; _string::read_input input "$@"
  echo "${input,,}"
}

# Fast variant using nameref
# Usage: string::lower::fast result_var str
string::lower::fast() {
  local -n _string_lower_result="$1"
  _string_lower_result="${2,,}"
}

# Convert to lowercase (Bash 3 compatible)
string::lower::legacy() {
  local input; _string::read_input input "$@"
  echo "$input" | tr '[:upper:]' '[:lower:]'
}

# Capitalise first character only
# Usage: string::capitalise str
#        echo "str" | string::capitalise
string::capitalise() {
  local input; _string::read_input input "$@"
  echo "${input^}"
}

# Fast variant using nameref
# Usage: string::capitalise::fast result_var str
string::capitalise::fast() {
  local -n _string_capitalise_result="$1"
  _string_capitalise_result="${2^}"
}

# Capitalise first character (Bash 3 compatible)
string::capitalise::legacy() {
  local input; _string::read_input input "$@"
  echo "$(echo "${input:0:1}" | tr '[:lower:]' '[:upper:]')${input:1}"
}

# Convert to title case (capitalise first letter of each word)
# Requires: awk
# Usage: string::title str
#        echo "str" | string::title
string::title() {
  local input; _string::read_input input "$@"
  echo "$input" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2)); print}'
}

# Fast variant using nameref (requires awk)
# Usage: string::title::fast result_var str
string::title::fast() {
  local -n _string_title_result="$1"
  _string_title_result=$(echo "$2" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2)); print}')
}

# ==============================================================================
# NAMING CONVENTION CONVERSION
#
# Naming matrix — all pairwise conversions:
#
#   plain    → space-separated words  "hello world"
#   snake    → underscore_separated   "hello_world"
#   kebab    → hyphen-separated       "hello-world"
#   camel    → camelCase              "helloWorld"
#   pascal   → PascalCase             "HelloWorld"
#   constant → SCREAMING_SNAKE        "HELLO_WORLD"
#   dot      → dot.separated          "hello.world"
#   path     → slash/separated        "hello/world"
#
# Conversion helpers — split any known format into words array
# then reassemble into target format.
# ==============================================================================

# Internal: split any common convention into space-separated words (lowercase)
_string::to_words() {
  local s="$1"
  # Insert space before uppercase runs (camel/pascal → words)
  s="$(echo "$s" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')"
  # Replace common separators with spaces
  s="${s//_/ }"
  s="${s//-/ }"
  s="${s//./ }"
  s="${s//\// }"
  # Lowercase everything
  echo "${s,,}"
}

# plain (space-separated) → snake_case
# Usage: string::plain_to_snake "hello world" → "hello_world"
#        echo "hello world" | string::plain_to_snake
string::plain_to_snake() {
  local input; _string::read_input input "$@"
  local s="${input// /_}"
  echo "${s,,}"
}

# Fast variant using nameref
# Usage: string::plain_to_snake::fast result_var "hello world"
string::plain_to_snake::fast() {
  local -n _string_plain_to_snake_result="$1"
  _string_plain_to_snake_result="${2// /_}"
  _string_plain_to_snake_result="${_string_plain_to_snake_result,,}"
}

# plain → kebab-case
#        echo "hello world" | string::plain_to_kebab
string::plain_to_kebab() {
  local input; _string::read_input input "$@"
  local s="${input// /-}"
  echo "${s,,}"
}

# Fast variant using nameref
string::plain_to_kebab::fast() {
  local -n _string_plain_to_kebab_result="$1"
  _string_plain_to_kebab_result="${2// /-}"
  _string_plain_to_kebab_result="${_string_plain_to_kebab_result,,}"
}

# plain → camelCase
#        echo "hello world" | string::plain_to_camel
string::plain_to_camel() {
  local input; _string::read_input input "$@"
  local result="" first=true
  for word in $input; do
    if $first; then
      result+="${word,,}"
      first=false
    else result+="${word^}"; fi
  done
  echo "$result"
}

# Fast variant using nameref
string::plain_to_camel::fast() {
  local -n _string_plain_to_camel_result="$1"
  local result="" first=true
  for word in $2; do
    if $first; then
      result+="${word,,}"
      first=false
    else result+="${word^}"; fi
  done
  _string_plain_to_camel_result="$result"
}

# plain → PascalCase
#        echo "hello world" | string::plain_to_pascal
string::plain_to_pascal() {
  local input; _string::read_input input "$@"
  local result=""
  for word in $input; do result+="${word^}"; done
  echo "$result"
}

# Fast variant using nameref
string::plain_to_pascal::fast() {
  local -n _string_plain_to_pascal_result="$1"
  local result=""
  for word in $2; do result+="${word^}"; done
  _string_plain_to_pascal_result="$result"
}

# plain → CONSTANT_CASE
#        echo "hello world" | string::plain_to_constant
string::plain_to_constant() {
  local input; _string::read_input input "$@"
  local s="${input// /_}"
  echo "${s^^}"
}

# Fast variant using nameref
string::plain_to_constant::fast() {
  local -n _string_plain_to_constant_result="$1"
  _string_plain_to_constant_result="${2// /_}"
  _string_plain_to_constant_result="${_string_plain_to_constant_result^^}"
}

# plain → dot.case
#        echo "hello world" | string::plain_to_dot
string::plain_to_dot() {
  local input; _string::read_input input "$@"
  local s="${input// /.}"
  echo "${s,,}"
}

# Fast variant using nameref
string::plain_to_dot::fast() {
  local -n _string_plain_to_dot_result="$1"
  _string_plain_to_dot_result="${2// /.}"
  _string_plain_to_dot_result="${_string_plain_to_dot_result,,}"
}

# plain → path/case
#        echo "hello world" | string::plain_to_path
string::plain_to_path() {
  local input; _string::read_input input "$@"
  local s="${input// //}"
  echo "${s,,}"
}

# Fast variant using nameref
string::plain_to_path::fast() {
  local -n _string_plain_to_path_result="$1"
  _string_plain_to_path_result="${2// //}"
  _string_plain_to_path_result="${_string_plain_to_path_result,,}"
}

# snake_case → plain
string::snake_to_plain() {
  local input; _string::read_input input "$@"
  echo "${input//_/ }"
}

# Fast variant using nameref
string::snake_to_plain::fast() {
  local -n _string_snake_to_plain_result="$1"
  _string_snake_to_plain_result="${2//_/ }"
}

# snake_case → kebab-case
string::snake_to_kebab() {
  local input; _string::read_input input "$@"
  echo "${input//_/-}"
}

# Fast variant using nameref
string::snake_to_kebab::fast() {
  local -n _string_snake_to_kebab_result="$1"
  _string_snake_to_kebab_result="${2//_/-}"
}

# snake_case → camelCase
string::snake_to_camel() {
  local input; _string::read_input input "$@"
  string::plain_to_camel "${input//_/ }"
}

# Fast variant using nameref
string::snake_to_camel::fast() {
  local -n _string_snake_to_camel_result="$1"
  local words="${2//_/ }"
  local result="" first=true
  for word in $words; do
    if $first; then
      result+="${word,,}"
      first=false
    else result+="${word^}"; fi
  done
  _string_snake_to_camel_result="$result"
}

# snake_case → PascalCase
string::snake_to_pascal() {
  local input; _string::read_input input "$@"
  string::plain_to_pascal "${input//_/ }"
}

# Fast variant using nameref
string::snake_to_pascal::fast() {
  local -n _string_snake_to_pascal_result="$1"
  local result=""
  for word in ${2//_/ }; do result+="${word^}"; done
  _string_snake_to_pascal_result="$result"
}

# snake_case → CONSTANT_CASE
string::snake_to_constant() {
  local input; _string::read_input input "$@"
  echo "${input^^}"
}

# Fast variant using nameref
string::snake_to_constant::fast() {
  local -n _string_snake_to_constant_result="$1"
  _string_snake_to_constant_result="${2^^}"
}

# snake_case → dot.case
string::snake_to_dot() {
  local input; _string::read_input input "$@"
  echo "${input//_/.}"
}

# Fast variant using nameref
string::snake_to_dot::fast() {
  local -n _string_snake_to_dot_result="$1"
  _string_snake_to_dot_result="${2//_/.}"
}

# snake_case → path/case
string::snake_to_path() {
  local input; _string::read_input input "$@"
  echo "${input//_//}"
}

# Fast variant using nameref
string::snake_to_path::fast() {
  local -n _string_snake_to_path_result="$1"
  _string_snake_to_path_result="${2//_//}"
}

# kebab-case → plain
string::kebab_to_plain() {
  local input; _string::read_input input "$@"
  echo "${input//-/ }"
}

# Fast variant using nameref
string::kebab_to_plain::fast() {
  local -n _string_kebab_to_plain_result="$1"
  _string_kebab_to_plain_result="${2//-/ }"
}

# kebab-case → snake_case
string::kebab_to_snake() {
  local input; _string::read_input input "$@"
  echo "${input//-/_}"
}

# Fast variant using nameref
string::kebab_to_snake::fast() {
  local -n _string_kebab_to_snake_result="$1"
  _string_kebab_to_snake_result="${2//-/_}"
}

# kebab-case → camelCase
string::kebab_to_camel() {
  local input; _string::read_input input "$@"
  string::plain_to_camel "${input//-/ }"
}

# Fast variant using nameref
string::kebab_to_camel::fast() {
  local -n _string_kebab_to_camel_result="$1"
  local words="${2//-/ }"
  local result="" first=true
  for word in $words; do
    if $first; then
      result+="${word,,}"
      first=false
    else result+="${word^}"; fi
  done
  _string_kebab_to_camel_result="$result"
}

# kebab-case → PascalCase
string::kebab_to_pascal() {
  local input; _string::read_input input "$@"
  string::plain_to_pascal "${input//-/ }"
}

# Fast variant using nameref
string::kebab_to_pascal::fast() {
  local -n _string_kebab_to_pascal_result="$1"
  local result=""
  for word in ${2//-/ }; do result+="${word^}"; done
  _string_kebab_to_pascal_result="$result"
}

# kebab-case → CONSTANT_CASE
string::kebab_to_constant() {
  local input; _string::read_input input "$@"
  local s="${input//-/_}"
  echo "${s^^}"
}

# Fast variant using nameref
string::kebab_to_constant::fast() {
  local -n _string_kebab_to_constant_result="$1"
  _string_kebab_to_constant_result="${2//-/_}"
  _string_kebab_to_constant_result="${_string_kebab_to_constant_result^^}"
}

# kebab-case → dot.case
string::kebab_to_dot() {
  local input; _string::read_input input "$@"
  echo "${input//-/.}"
}

# Fast variant using nameref
string::kebab_to_dot::fast() {
  local -n _string_kebab_to_dot_result="$1"
  _string_kebab_to_dot_result="${2//-/.}"
}

# kebab-case → path/case
string::kebab_to_path() {
  local input; _string::read_input input "$@"
  echo "${input//-//}"
}

# Fast variant using nameref
string::kebab_to_path::fast() {
  local -n _string_kebab_to_path_result="$1"
  _string_kebab_to_path_result="${2//-//}"
}

# camelCase → plain
string::camel_to_plain() {
  local input; _string::read_input input "$@"
  _string::to_words "$input"
}

# Fast variant using nameref
string::camel_to_plain::fast() {
  local -n _string_camel_to_plain_result="$1"
  local s="$2"
  s="$(echo "$s" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')"
  s="${s//_/ }"
  s="${s//-/ }"
  s="${s//./ }"
  s="${s//\// }"
  _string_camel_to_plain_result="${s,,}"
}

# camelCase → snake_case
string::camel_to_snake() {
  local input; _string::read_input input "$@"
  local words
  words=$(_string::to_words "$input")
  echo "${words// /_}"
}

# Fast variant using nameref
string::camel_to_snake::fast() {
  local -n _string_camel_to_snake_result="$1"
  local s="$2"
  s="$(echo "$s" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')"
  s="${s//_/ }"
  s="${s//-/ }"
  s="${s//./ }"
  s="${s//\// }"
  s="${s,,}"
  _string_camel_to_snake_result="${s// /_}"
}

# camelCase → kebab-case
string::camel_to_kebab() {
  local input; _string::read_input input "$@"
  local words
  words=$(_string::to_words "$input")
  echo "${words// /-}"
}

# Fast variant using nameref
string::camel_to_kebab::fast() {
  local -n _string_camel_to_kebab_result="$1"
  local s="$2"
  s="$(echo "$s" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')"
  s="${s//_/ }"
  s="${s//-/ }"
  s="${s//./ }"
  s="${s//\// }"
  s="${s,,}"
  _string_camel_to_kebab_result="${s// /-}"
}

# camelCase → PascalCase
string::camel_to_pascal() {
  local input; _string::read_input input "$@"
  string::plain_to_pascal "$(_string::to_words "$input")"
}

# Fast variant using nameref
string::camel_to_pascal::fast() {
  local -n _string_camel_to_pascal_result="$1"
  local s="$2"
  s="$(echo "$s" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')"
  s="${s//_/ }"
  s="${s//-/ }"
  s="${s//./ }"
  s="${s//\// }"
  s="${s,,}"
  local result=""
  for word in $s; do result+="${word^}"; done
  _string_camel_to_pascal_result="$result"
}

# camelCase → CONSTANT_CASE
string::camel_to_constant() {
  local input; _string::read_input input "$@"
  local words
  words=$(_string::to_words "$input")
  local s="${words// /_}"
  echo "${s^^}"
}

# Fast variant using nameref
string::camel_to_constant::fast() {
  local -n _string_camel_to_constant_result="$1"
  local s="$2"
  s="$(echo "$s" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')"
  s="${s//_/ }"
  s="${s//-/ }"
  s="${s//./ }"
  s="${s//\// }"
  s="${s,,}"
  _string_camel_to_constant_result="${s// /_}"
  _string_camel_to_constant_result="${_string_camel_to_constant_result^^}"
}

# camelCase → dot.case
string::camel_to_dot() {
  local input; _string::read_input input "$@"
  local words
  words=$(_string::to_words "$input")
  echo "${words// /.}"
}

# Fast variant using nameref
string::camel_to_dot::fast() {
  local -n _string_camel_to_dot_result="$1"
  local s="$2"
  s="$(echo "$s" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')"
  s="${s//_/ }"
  s="${s//-/ }"
  s="${s//./ }"
  s="${s//\// }"
  s="${s,,}"
  _string_camel_to_dot_result="${s// /.}"
}

# camelCase → path/case
string::camel_to_path() {
  local input; _string::read_input input "$@"
  local words
  words=$(_string::to_words "$input")
  echo "${words// //}"
}

# Fast variant using nameref
string::camel_to_path::fast() {
  local -n _string_camel_to_path_result="$1"
  local s="$2"
  s="$(echo "$s" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')"
  s="${s//_/ }"
  s="${s//-/ }"
  s="${s//./ }"
  s="${s//\// }"
  s="${s,,}"
  _string_camel_to_path_result="${s// //}"
}

# PascalCase → plain
string::pascal_to_plain() {
  local input; _string::read_input input "$@"
  _string::to_words "$input"
}

# Fast variant using nameref
string::pascal_to_plain::fast() {
  local -n _string_pascal_to_plain_result="$1"
  local s="$2"
  s="$(echo "$s" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')"
  s="${s//_/ }"
  s="${s//-/ }"
  s="${s//./ }"
  s="${s//\// }"
  _string_pascal_to_plain_result="${s,,}"
}

# PascalCase → snake_case
string::pascal_to_snake() {
  local input; _string::read_input input "$@"
  string::camel_to_snake "$input"
}

# Fast variant using nameref
string::pascal_to_snake::fast() {
  local -n _string_pascal_to_snake_result="$1"
  local s="$2"
  s="$(echo "$s" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')"
  s="${s//_/ }"
  s="${s//-/ }"
  s="${s//./ }"
  s="${s//\// }"
  s="${s,,}"
  _string_pascal_to_snake_result="${s// /_}"
}

# PascalCase → kebab-case
string::pascal_to_kebab() {
  local input; _string::read_input input "$@"
  string::camel_to_kebab "$input"
}

# Fast variant using nameref
string::pascal_to_kebab::fast() {
  local -n _string_pascal_to_kebab_result="$1"
  local s="$2"
  s="$(echo "$s" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')"
  s="${s//_/ }"
  s="${s//-/ }"
  s="${s//./ }"
  s="${s//\// }"
  s="${s,,}"
  _string_pascal_to_kebab_result="${s// /-}"
}

# PascalCase → camelCase
string::pascal_to_camel() {
  local input; _string::read_input input "$@"
  local words
  words=$(_string::to_words "$input")
  string::plain_to_camel "$words"
}

# Fast variant using nameref
string::pascal_to_camel::fast() {
  local -n _string_pascal_to_camel_result="$1"
  local s="$2"
  s="$(echo "$s" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')"
  s="${s//_/ }"
  s="${s//-/ }"
  s="${s//./ }"
  s="${s//\// }"
  s="${s,,}"
  local result="" first=true
  for word in $s; do
    if $first; then
      result+="${word,,}"
      first=false
    else result+="${word^}"; fi
  done
  _string_pascal_to_camel_result="$result"
}

# PascalCase → CONSTANT_CASE
string::pascal_to_constant() {
  local input; _string::read_input input "$@"
  string::camel_to_constant "$input"
}

# Fast variant using nameref
string::pascal_to_constant::fast() {
  local -n _string_pascal_to_constant_result="$1"
  local s="$2"
  s="$(echo "$s" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')"
  s="${s//_/ }"
  s="${s//-/ }"
  s="${s//./ }"
  s="${s//\// }"
  s="${s,,}"
  _string_pascal_to_constant_result="${s// /_}"
  _string_pascal_to_constant_result="${_string_pascal_to_constant_result^^}"
}

# PascalCase → dot.case
string::pascal_to_dot() {
  local input; _string::read_input input "$@"
  string::camel_to_dot "$input"
}

# Fast variant using nameref
string::pascal_to_dot::fast() {
  local -n _string_pascal_to_dot_result="$1"
  local s="$2"
  s="$(echo "$s" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')"
  s="${s//_/ }"
  s="${s//-/ }"
  s="${s//./ }"
  s="${s//\// }"
  s="${s,,}"
  _string_pascal_to_dot_result="${s// /.}"
}

# PascalCase → path/case
string::pascal_to_path() {
  local input; _string::read_input input "$@"
  string::camel_to_path "$input"
}

# Fast variant using nameref
string::pascal_to_path::fast() {
  local -n _string_pascal_to_path_result="$1"
  local s="$2"
  s="$(echo "$s" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')"
  s="${s//_/ }"
  s="${s//-/ }"
  s="${s//./ }"
  s="${s//\// }"
  s="${s,,}"
  _string_pascal_to_path_result="${s// //}"
}

# CONSTANT_CASE → plain
string::constant_to_plain() {
  local input; _string::read_input input "$@"
  local s="${input//_/ }"
  echo "${s,,}"
}

# Fast variant using nameref
string::constant_to_plain::fast() {
  local -n _string_constant_to_plain_result="$1"
  _string_constant_to_plain_result="${2//_/ }"
  _string_constant_to_plain_result="${_string_constant_to_plain_result,,}"
}

# CONSTANT_CASE → snake_case
string::constant_to_snake() {
  local input; _string::read_input input "$@"
  echo "${input,,}"
}

# Fast variant using nameref
string::constant_to_snake::fast() {
  local -n _string_constant_to_snake_result="$1"
  _string_constant_to_snake_result="${2,,}"
}

# CONSTANT_CASE → kebab-case
string::constant_to_kebab() {
  local input; _string::read_input input "$@"
  local s="${input//_/-}"
  echo "${s,,}"
}

# Fast variant using nameref
string::constant_to_kebab::fast() {
  local -n _string_constant_to_kebab_result="$1"
  _string_constant_to_kebab_result="${2//_/-}"
  _string_constant_to_kebab_result="${_string_constant_to_kebab_result,,}"
}

# CONSTANT_CASE → camelCase
string::constant_to_camel() {
  local input; _string::read_input input "$@"
  string::snake_to_camel "${input,,}"
}

# Fast variant using nameref
string::constant_to_camel::fast() {
  local -n _string_constant_to_camel_result="$1"
  local words="${2,,}"
  words="${words//_/ }"
  local result="" first=true
  for word in $words; do
    if $first; then
      result+="${word,,}"
      first=false
    else result+="${word^}"; fi
  done
  _string_constant_to_camel_result="$result"
}

# CONSTANT_CASE → PascalCase
string::constant_to_pascal() {
  local input; _string::read_input input "$@"
  string::snake_to_pascal "${input,,}"
}

# Fast variant using nameref
string::constant_to_pascal::fast() {
  local -n _string_constant_to_pascal_result="$1"
  local result="" words="${2,,}"
  words="${words//_/ }"
  for word in $words; do result+="${word^}"; done
  _string_constant_to_pascal_result="$result"
}

# CONSTANT_CASE → dot.case
string::constant_to_dot() {
  local input; _string::read_input input "$@"
  local s="${input//_/.}"
  echo "${s,,}"
}

# Fast variant using nameref
string::constant_to_dot::fast() {
  local -n _string_constant_to_dot_result="$1"
  _string_constant_to_dot_result="${2//_/.}"
  _string_constant_to_dot_result="${_string_constant_to_dot_result,,}"
}

# CONSTANT_CASE → path/case
string::constant_to_path() {
  local input; _string::read_input input "$@"
  local s="${input//_//}"
  echo "${s,,}"
}

# Fast variant using nameref
string::constant_to_path::fast() {
  local -n _string_constant_to_path_result="$1"
  _string_constant_to_path_result="${2//_//}"
  _string_constant_to_path_result="${_string_constant_to_path_result,,}"
}

# dot.case → plain
string::dot_to_plain() {
  local input; _string::read_input input "$@"
  echo "${input//./ }"
}

# Fast variant using nameref
string::dot_to_plain::fast() {
  local -n _string_dot_to_plain_result="$1"
  _string_dot_to_plain_result="${2//./ }"
}

# dot.case → snake_case
string::dot_to_snake() {
  local input; _string::read_input input "$@"
  echo "${input//./_}"
}

# Fast variant using nameref
string::dot_to_snake::fast() {
  local -n _string_dot_to_snake_result="$1"
  _string_dot_to_snake_result="${2//./_}"
}

# dot.case → kebab-case
string::dot_to_kebab() {
  local input; _string::read_input input "$@"
  echo "${input//./-}"
}

# Fast variant using nameref
string::dot_to_kebab::fast() {
  local -n _string_dot_to_kebab_result="$1"
  _string_dot_to_kebab_result="${2//./-}"
}

# dot.case → camelCase
string::dot_to_camel() {
  local input; _string::read_input input "$@"
  string::plain_to_camel "${input//./ }"
}

# Fast variant using nameref
string::dot_to_camel::fast() {
  local -n _string_dot_to_camel_result="$1"
  local words="${2//./ }"
  local result="" first=true
  for word in $words; do
    if $first; then
      result+="${word,,}"
      first=false
    else result+="${word^}"; fi
  done
  _string_dot_to_camel_result="$result"
}

# dot.case → PascalCase
string::dot_to_pascal() {
  local input; _string::read_input input "$@"
  string::plain_to_pascal "${input//./ }"
}

# Fast variant using nameref
string::dot_to_pascal::fast() {
  local -n _string_dot_to_pascal_result="$1"
  local result=""
  for word in ${2//./ }; do result+="${word^}"; done
  _string_dot_to_pascal_result="$result"
}

# dot.case → CONSTANT_CASE
string::dot_to_constant() {
  local input; _string::read_input input "$@"
  local s="${input//./_}"
  echo "${s^^}"
}

# Fast variant using nameref
string::dot_to_constant::fast() {
  local -n _string_dot_to_constant_result="$1"
  _string_dot_to_constant_result="${2//./_}"
  _string_dot_to_constant_result="${_string_dot_to_constant_result^^}"
}

# dot.case → path/case
string::dot_to_path() {
  local input; _string::read_input input "$@"
  echo "${input//.//}"
}

# Fast variant using nameref
string::dot_to_path::fast() {
  local -n _string_dot_to_path_result="$1"
  _string_dot_to_path_result="${2//.//}"
}

# path/case → plain
string::path_to_plain() {
  local input; _string::read_input input "$@"
  echo "${input//\// }"
}

# Fast variant using nameref
string::path_to_plain::fast() {
  local -n _string_path_to_plain_result="$1"
  _string_path_to_plain_result="${2//\// }"
}

# path/case → snake_case
string::path_to_snake() {
  local input; _string::read_input input "$@"
  echo "${input//\//_}"
}

# Fast variant using nameref
string::path_to_snake::fast() {
  local -n _string_path_to_snake_result="$1"
  _string_path_to_snake_result="${2//\//_}"
}

# path/case → kebab-case
string::path_to_kebab() {
  local input; _string::read_input input "$@"
  local path="$input"
  path="${path//\\/-}"  # Replace backslashes
  path="${path//\//-}"  # Replace forward slashes
  echo "$path"
}

# Fast variant using nameref
string::path_to_kebab::fast() {
  local -n _string_path_to_kebab_result="$1"
  _string_path_to_kebab_result="${2//\\/-}"
  _string_path_to_kebab_result="${_string_path_to_kebab_result//\//-}"
}

# path/case → camelCase
string::path_to_camel() {
  local input; _string::read_input input "$@"
  string::plain_to_camel "${input//\// }"
}

# Fast variant using nameref
string::path_to_camel::fast() {
  local -n _string_path_to_camel_result="$1"
  local words="${2//\// }"
  local result="" first=true
  for word in $words; do
    if $first; then
      result+="${word,,}"
      first=false
    else result+="${word^}"; fi
  done
  _string_path_to_camel_result="$result"
}

# path/case → PascalCase
string::path_to_pascal() {
  local input; _string::read_input input "$@"
  string::plain_to_pascal "${input//\// }"
}

# Fast variant using nameref
string::path_to_pascal::fast() {
  local -n _string_path_to_pascal_result="$1"
  local result=""
  for word in ${2//\// }; do result+="${word^}"; done
  _string_path_to_pascal_result="$result"
}

# path/case → CONSTANT_CASE
string::path_to_constant() {
  local input; _string::read_input input "$@"
  local s="${input//\//_}"
  echo "${s^^}"
}

# Fast variant using nameref
string::path_to_constant::fast() {
  local -n _string_path_to_constant_result="$1"
  _string_path_to_constant_result="${2//\//_}"
  _string_path_to_constant_result="${_string_path_to_constant_result^^}"
}

# path/case → dot.case
string::path_to_dot() {
  local input; _string::read_input input "$@"
  echo "${input//\//.}"
}

# Fast variant using nameref
string::path_to_dot::fast() {
  local -n _string_path_to_dot_result="$1"
  _string_path_to_dot_result="${2//\//.}"
}

# ==============================================================================
# TRIMMING
# ==============================================================================

# Trim leading whitespace
# Usage: string::trim_left str
string::trim_left() {
  local input; _string::read_input input "$@"
  input="${input#"${input%%[![:space:]]*}"}"
  echo "$input"
}

# Fast variant using nameref
# Usage: string::trim_left::fast result_var str
string::trim_left::fast() {
  local -n _string_trim_left_result="$1"
  _string_trim_left_result="${2#"${2%%[![:space:]]*}"}"
}

# Trim trailing whitespace
# Usage: string::trim_right str
string::trim_right() {
  local input; _string::read_input input "$@"
  input="${input%"${input##*[![:space:]]}"}"
  echo "$input"
}

# Fast variant using nameref
# Usage: string::trim_right::fast result_var str
string::trim_right::fast() {
  local -n _string_trim_right_result="$1"
  _string_trim_right_result="${2%"${2##*[![:space:]]}"}"
}

# Trim both leading and trailing whitespace
# Usage: string::trim str
string::trim() {
  local input; _string::read_input input "$@"
  input="${input#"${input%%[![:space:]]*}"}"
  input="${input%"${input##*[![:space:]]}"}"
  echo "$input"
}

# Fast variant using nameref
# Usage: string::trim::fast result_var str
string::trim::fast() {
  local -n _string_trim_result="$1"
  _string_trim_result="${2#"${2%%[![:space:]]*}"}"
  _string_trim_result="${_string_trim_result%"${_string_trim_result##*[![:space:]]}"}"
}

# Collapse multiple consecutive spaces into one
# Usage: string::collapse_spaces str
string::collapse_spaces() {
  local input; _string::read_input input "$@"
  echo "$input" | tr -s ' '
}

# Fast variant using nameref (requires tr)
# Usage: string::collapse_spaces::fast result_var str
string::collapse_spaces::fast() {
  local -n _string_collapse_spaces_result="$1"
  _string_collapse_spaces_result=$(echo "$2" | tr -s ' ')
}

# Remove all whitespace
# Usage: string::strip_spaces str
string::strip_spaces() {
  local input; _string::read_input input "$@"
  echo "${input//[[:space:]]/}"
}

# Fast variant using nameref
# Usage: string::strip_spaces::fast result_var str
string::strip_spaces::fast() {
  local -n _string_strip_spaces_result="$1"
  _string_strip_spaces_result="${2//[[:space:]]/}"
}

# ==============================================================================
# SUBSTRINGS
# ==============================================================================

# Extract substring
# Usage: string::substr str start [length]
string::substr() {
  local input start len
  if [[ $# -ge 2 ]]; then
    input="$1"; start="$2"; len="${3:-}"
  else
    input=$(cat); start="$1"; len="${2:-}"
  fi
  if [[ -n "$len" ]]; then
    echo "${input:$start:$len}"
  else
    echo "${input:$start}"
  fi
}

# Fast variant using nameref
# Usage: string::substr::fast result_var str start [length]
string::substr::fast() {
  local -n _string_substr_result="$1"
  local s="$2" start="$3" len="${4:-}"
  if [[ -n "$len" ]]; then
    _string_substr_result="${s:$start:$len}"
  else
    _string_substr_result="${s:$start}"
  fi
}

# Index of first occurrence of substring (-1 if not found)
# Usage: string::index_of haystack needle
string::index_of() {
  local input needle
  if [[ $# -ge 2 ]]; then
    input="$1"; needle="$2"
  else
    input=$(cat); needle="$1"
  fi
  local before="${input%%"$needle"*}"
  if [[ "$before" == "$input" ]]; then
    echo -1
  else
    echo "${#before}"
  fi
}

# Return everything before the first occurrence of delimiter
# Usage: string::before str delimiter
string::before() {
  local input
  if [[ $# -ge 2 ]]; then input="$1"; shift; else input=$(cat); fi
  echo "${input%%"$1"*}"
}

# Fast variant using nameref
# Usage: string::before::fast result_var str delimiter
string::before::fast() {
  local -n _string_before_result="$1"
  _string_before_result="${2%%"$3"*}"
}

# Return everything after the first occurrence of delimiter
# Usage: string::after str delimiter
string::after() {
  local input
  if [[ $# -ge 2 ]]; then input="$1"; shift; else input=$(cat); fi
  echo "${input#*"$1"}"
}

# Fast variant using nameref
# Usage: string::after::fast result_var str delimiter
string::after::fast() {
  local -n _string_after_result="$1"
  _string_after_result="${2#*"$3"}"
}

# Return everything before the last occurrence of delimiter
# Usage: string::before_last str delimiter
string::before_last() {
  local input
  if [[ $# -ge 2 ]]; then input="$1"; shift; else input=$(cat); fi
  echo "${input%"$1"*}"
}

# Fast variant using nameref
# Usage: string::before_last::fast result_var str delimiter
string::before_last::fast() {
  local -n _string_before_last_result="$1"
  _string_before_last_result="${2%"$3"*}"
}

# Return everything after the last occurrence of delimiter
# Usage: string::after_last str delimiter
string::after_last() {
  local input
  if [[ $# -ge 2 ]]; then input="$1"; shift; else input=$(cat); fi
  echo "${input##*"$1"}"
}

# Fast variant using nameref
# Usage: string::after_last::fast result_var str delimiter
string::after_last::fast() {
  local -n _string_after_last_result="$1"
  _string_after_last_result="${2##*"$3"}"
}

# ==============================================================================
# MANIPULATION
# ==============================================================================

# Replace first occurrence of search with replace
# Usage: string::replace str search replace
string::replace() {
  local input
  if [[ $# -ge 2 ]]; then input="$1"; shift; else input=$(cat); fi
  echo "${input/"$1"/"$2"}"
}

# Fast variant using nameref
# Usage: string::replace::fast result_var str search replace
string::replace::fast() {
  local -n _string_replace_result="$1"
  _string_replace_result="${2/"$3"/"$4"}"
}

# Replace all occurrences of search with replace
# Usage: string::replace_all str search replace
string::replace_all() {
  local input
  if [[ $# -ge 2 ]]; then input="$1"; shift; else input=$(cat); fi
  echo "${input//"$1"/"$2"}"
}

# Fast variant using nameref
# Usage: string::replace_all::fast result_var str search replace
string::replace_all::fast() {
  local -n _string_replace_all_result="$1"
  _string_replace_all_result="${2//"$3"/"$4"}"
}

# Remove all occurrences of a substring
# Usage: string::remove str substring
string::remove() {
  local input
  if [[ $# -ge 2 ]]; then input="$1"; shift; else input=$(cat); fi
  echo "${input//"$1"/}"
}

# Fast variant using nameref
# Usage: string::remove::fast result_var str substring
string::remove::fast() {
  local -n _string_remove_result="$1"
  _string_remove_result="${2//"$3"/}"
}

# Remove first occurrence of a substring
# Usage: string::remove_first str substring
string::remove_first() {
  local input
  if [[ $# -ge 2 ]]; then input="$1"; shift; else input=$(cat); fi
  echo "${input/"$1"/}"
}

# Fast variant using nameref
# Usage: string::remove_first::fast result_var str substring
string::remove_first::fast() {
  local -n _string_remove_first_result="$1"
  _string_remove_first_result="${2/"$3"/}"
}

# Reverse a string
# Requires: rev (coreutils) — falls back to awk
# Usage: string::reverse str
string::reverse() {
  local input; _string::read_input input "$@"
  if runtime::has_command rev; then
    echo "$input" | rev
  else
    echo "$input" | awk '{for(i=length;i>0;i--) printf substr($0,i,1); print ""}'
  fi
}

# Fast variant using nameref (requires rev or awk)
# Usage: string::reverse::fast result_var str
string::reverse::fast() {
  local -n _string_reverse_result="$1"
  if runtime::has_command rev; then
    _string_reverse_result=$(echo "$2" | rev)
  else
    _string_reverse_result=$(echo "$2" | awk '{for(i=length;i>0;i--) printf substr($0,i,1); print ""}')
  fi
}

# Repeat a string n times
# Usage: string::repeat str n
#        echo "str" | string::repeat n
string::repeat() {
  local input n
  if [[ $# -ge 2 ]]; then
    input="$1"; n="$2"
  else
    input=$(cat); n="$1"
  fi
  local result=""
  for ((i = 0; i < n; i++)); do result+="$input"; done
  echo "$result"
}

# Fast variant using nameref
# Usage: string::repeat::fast result_var str n
string::repeat::fast() {
  local -n _string_repeat_result="$1"
  local str="$2" n="$3" result=""
  for ((i = 0; i < n; i++)); do result+="$str"; done
  _string_repeat_result="$result"
}

# Pad string on the left to a given width
# Usage: string::pad_left str width [char]
string::pad_left() {
  local input width char
  if [[ $# -ge 2 ]]; then
    input="$1"; width="$2"; char="${3:- }"
  else
    input=$(cat); width="$1"; char="${2:- }"
  fi
  local len="${#input}"
  if ((len >= width)); then echo "$input"; return; fi
  local pad
  pad=$(string::repeat "$char" $((width - len)))
  echo "${pad}${input}"
}

# Fast variant using nameref
# Usage: string::pad_left::fast result_var str width [char]
string::pad_left::fast() {
  local -n _string_pad_left_result="$1"
  local s="$2" width="$3" char="${4:- }"
  local len="${#s}"
  if ((len >= width)); then
    _string_pad_left_result="$s"
    return
  fi
  local pad result=""
  for ((i = 0; i < width - len; i++)); do result+="$char"; done
  _string_pad_left_result="${result}${s}"
}

# Pad string on the right to a given width
# Usage: string::pad_right str width [char]
string::pad_right() {
  local input width char
  if [[ $# -ge 2 ]]; then
    input="$1"; width="$2"; char="${3:- }"
  else
    input=$(cat); width="$1"; char="${2:- }"
  fi
  local len="${#input}"
  if ((len >= width)); then echo "$input"; return; fi
  local pad
  pad=$(string::repeat "$char" $((width - len)))
  echo "${input}${pad}"
}

# Fast variant using nameref
# Usage: string::pad_right::fast result_var str width [char]
string::pad_right::fast() {
  local -n _string_pad_right_result="$1"
  local s="$2" width="$3" char="${4:- }"
  local len="${#s}"
  if ((len >= width)); then
    _string_pad_right_result="$s"
    return
  fi
  local result=""
  for ((i = 0; i < width - len; i++)); do result+="$char"; done
  _string_pad_right_result="${s}${result}"
}

# Centre a string within a given width
# Usage: string::pad_center str width [char]
string::pad_center() {
  local input width char
  if [[ $# -ge 2 ]]; then
    input="$1"; width="$2"; char="${3:- }"
  else
    input=$(cat); width="$1"; char="${2:- }"
  fi
  local len="${#input}"
  if ((len >= width)); then echo "$input"; return; fi
  local total=$((width - len))
  local left=$((total / 2))
  local right=$((total - left))
  local lpad rpad
  lpad=$(string::repeat "$char" $left)
  rpad=$(string::repeat "$char" $right)
  echo "${lpad}${input}${rpad}"
}

# Fast variant using nameref
# Usage: string::pad_center::fast result_var str width [char]
string::pad_center::fast() {
  local -n _string_pad_center_result="$1"
  local s="$2" width="$3" char="${4:- }"
  local len="${#s}"
  if ((len >= width)); then
    _string_pad_center_result="$s"
    return
  fi
  local total=$((width - len))
  local left=$((total / 2))
  local right=$((total - left))
  local lpad="" rpad=""
  for ((i = 0; i < left; i++)); do lpad+="$char"; done
  for ((i = 0; i < right; i++)); do rpad+="$char"; done
  _string_pad_center_result="${lpad}${s}${rpad}"
}

# Truncate a string to max length, appending suffix if truncated
# Usage: string::truncate str max [suffix]
string::truncate() {
  local input max
  if [[ $# -ge 2 ]]; then
    input="$1"; max="$2"
  else
    input=$(cat); max="$1"
  fi
  local suffix

  if ((${#input} <= max)); then
    echo "$input"
    return 0
  fi

  # Handle very small max values
  if ((max <= 1)); then
    # Can only show suffix
    echo "…"
    return 0
  elif ((max == 2)); then
    # Can show 1 char + single ellipsis
    echo "${input:0:1}…"
    return 0
  fi

  # Determine which suffix to use based on available space
  local available_chars=$((max - 3))  # Try with 3-dot suffix first

  if ((available_chars < 3)); then
    # If we'd have less than 3 chars from original with 3-dot suffix,
    # use single ellipsis instead
    suffix="…"
    available_chars=$((max - 1))
  else
    suffix="..."
  fi

  echo "${input:0:$available_chars}${suffix}"
}

# Fast variant using nameref
# Usage: string::truncate::fast result_var str max [suffix]
string::truncate::fast() {
  local -n _string_truncate_result="$1"
  local s="$2" max="$3"
  local suffix

  if ((${#s} <= max)); then
    _string_truncate_result="$s"
    return 0
  fi

  # Handle very small max values
  if ((max <= 1)); then
    _string_truncate_result="…"
    return 0
  elif ((max == 2)); then
    _string_truncate_result="${s:0:1}…"
    return 0
  fi

  # Determine which suffix to use based on available space
  local available_chars=$((max - 3))

  if ((available_chars < 3)); then
    suffix="…"
    available_chars=$((max - 1))
  else
    suffix="..."
  fi

  _string_truncate_result="${s:0:$available_chars}${suffix}"
}

# ==============================================================================
# SPLITTING / JOINING
# ==============================================================================

# Split a string by delimiter into lines (one element per line)
# Usage: string::split str delimiter
string::split() {
  local input delim
  if [[ $# -ge 2 ]]; then
    input="$1"; delim="$2"
  else
    input=$(cat); delim="$1"
  fi
  local IFS="$delim"
  set -- $input
  printf '%s\n' "$@"
}


# Fast split — writes directly into the named array via nameref.
# No subshell, no cat, no temp files.
# Usage: string::split::fast result_var delimiter string
string::split::fast() {
  local -n _split_out="$1"
  local _split_delim="$2" _split_str="$3"
  local IFS="$_split_delim"
  set -- $_split_str
  _split_out=("$@")
}

# Join an array of arguments with a delimiter
# Usage: string::join delimiter arg1 arg2 ...
string::join() {
  local delim="$1"
  shift
  local result=""
  local first=true
  for part in "$@"; do
    if $first; then
      result="$part"
      first=false
    else
      result+="${delim}${part}"
    fi
  done
  echo "$result"
}

# Fast variant using nameref
# Usage: string::join::fast result_var delimiter arg1 arg2 ...
string::join::fast() {
  local -n _string_join_result="$1"
  local delim="$2"
  shift 2
  local result=""
  local first=true
  for part in "$@"; do
    if $first; then
      result="$part"
      first=false
    else
      result+="${delim}${part}"
    fi
  done
  _string_join_result="$result"
}

# ==============================================================================
# ENCODING / HASHING
# ==============================================================================

# URL-encode a string
# Usage: string::url_encode str
string::url_encode() {
    local input; _string::read_input input "$@"
    local s="$input" encoded="" i char hex
    for (( i=0; i<${#s}; i++ )); do
        char="${s:$i:1}"
        case "$char" in
            [a-zA-Z0-9.~_-]) encoded+="$char" ;;
            *) printf -v hex '%02X' "'$char"
               encoded+="%$hex" ;;
        esac
    done
    echo "$encoded"
}

# Fast variant using nameref
# Usage: string::url_encode::fast result_var str
string::url_encode::fast() {
    local -n _string_url_encode_result="$1"
    local s="$2" encoded="" i char hex
    for (( i=0; i<${#s}; i++ )); do
        char="${s:$i:1}"
        case "$char" in
            [a-zA-Z0-9.~_-]) encoded+="$char" ;;
            *) printf -v hex '%02X' "'$char"
               encoded+="%$hex" ;;
        esac
    done
    _string_url_encode_result="$encoded"
}

string::url_decode() {
    local input; _string::read_input input "$@"
    local s="${input//+/ }"  # replace + with space first
    printf '%b\n' "${s//%/\\x}"
}

# Fast variant using nameref
# Usage: string::url_decode::fast result_var str
string::url_decode::fast() {
    local -n _string_url_decode_result="$1"
    local s="${2//+/ }"
    _string_url_decode_result=$(printf '%b\n' "${s//%/\\x}")
}

# Base64 encode
# Usage: string::base64_encode str
string::base64_encode() {
    local input; _string::read_input input "$@"
    case "$(runtime::os)" in
    darwin) echo -n "$input" | base64 ;;
    *)      echo -n "$input" | base64 -w 0 ;;
    esac
}

# Fast variant using nameref
# Usage: string::base64_encode::fast result_var str
string::base64_encode::fast() {
    local -n _string_base64_encode_result="$1"
    case "$(runtime::os)" in
    darwin) _string_base64_encode_result=$(echo -n "$2" | base64) ;;
    *)      _string_base64_encode_result=$(echo -n "$2" | base64 -w 0) ;;
    esac
}

# Base64 decode
# Usage: string::base64_decode str
string::base64_decode() {
    local input; _string::read_input input "$@"
    case "$(runtime::os)" in
    darwin) echo -n "$input" | base64 -D ;;
    *)      echo -n "$input" | base64 --decode ;;
    esac
}

# Fast variant using nameref
# Usage: string::base64_decode::fast result_var str
string::base64_decode::fast() {
    local -n _string_base64_decode_result="$1"
    case "$(runtime::os)" in
    darwin) _string_base64_decode_result=$(echo -n "$2" | base64 -D) ;;
    *)      _string_base64_decode_result=$(echo -n "$2" | base64 --decode) ;;
    esac
}

string::base64_encode::pure() {
    local input; _string::read_input input "$@"
    local s="$input" out="" i a b c
    local _B64="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    for (( i=0; i<${#s}; i+=3 )); do
        a=$(printf '%d' "'${s:$i:1}")
        b=$(( i+1 < ${#s} ? $(printf '%d' "'${s:$((i+1)):1}") : 0 ))
        c=$(( i+2 < ${#s} ? $(printf '%d' "'${s:$((i+2)):1}") : 0 ))

        out+="${_B64:$(( (a >> 2) & 63 )):1}"
        out+="${_B64:$(( ((a << 4) | (b >> 4)) & 63 )):1}"
        out+="${_B64:$(( i+1 < ${#s} ? ((b << 2) | (c >> 6)) & 63 : 64 )):1}"
        out+="${_B64:$(( i+2 < ${#s} ? c & 63 : 64 )):1}"
    done

    echo "$out"
}

string::base64_decode::pure() {
    local input; _string::read_input input "$@"
    local s="$input" i
    local -i a b c d byte1 byte2 byte3
    local _B64="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    # strip padding
    s="${s//=}"

    for (( i=0; i<${#s}; i+=4 )); do
        local c0="${s:$i:1}" c1="${s:$((i+1)):1}" c2="${s:$((i+2)):1}" c3="${s:$((i+3)):1}"
        # Use case for reliable index lookup (avoids issues with +/ in patterns)
        case "$c0" in A) a=0;; B) a=1;; C) a=2;; D) a=3;; E) a=4;; F) a=5;; G) a=6;; H) a=7;; I) a=8;; J) a=9;; K) a=10;; L) a=11;; M) a=12;; N) a=13;; O) a=14;; P) a=15;; Q) a=16;; R) a=17;; S) a=18;; T) a=19;; U) a=20;; V) a=21;; W) a=22;; X) a=23;; Y) a=24;; Z) a=25;; a) a=26;; b) a=27;; c) a=28;; d) a=29;; e) a=30;; f) a=31;; g) a=32;; h) a=33;; i) a=34;; j) a=35;; k) a=36;; l) a=37;; m) a=38;; n) a=39;; o) a=40;; p) a=41;; q) a=42;; r) a=43;; s) a=44;; t) a=45;; u) a=46;; v) a=47;; w) a=48;; x) a=49;; y) a=50;; z) a=51;; 0) a=52;; 1) a=53;; 2) a=54;; 3) a=55;; 4) a=56;; 5) a=57;; 6) a=58;; 7) a=59;; 8) a=60;; 9) a=61;; +) a=62;; /) a=63;; *) a=0;; esac
        case "$c1" in A) b=0;; B) b=1;; C) b=2;; D) b=3;; E) b=4;; F) b=5;; G) b=6;; H) b=7;; I) b=8;; J) b=9;; K) b=10;; L) b=11;; M) b=12;; N) b=13;; O) b=14;; P) b=15;; Q) b=16;; R) b=17;; S) b=18;; T) b=19;; U) b=20;; V) b=21;; W) b=22;; X) b=23;; Y) b=24;; Z) b=25;; a) b=26;; b) b=27;; c) b=28;; d) b=29;; e) b=30;; f) b=31;; g) b=32;; h) b=33;; i) b=34;; j) b=35;; k) b=36;; l) b=37;; m) b=38;; n) b=39;; o) b=40;; p) b=41;; q) b=42;; r) b=43;; s) b=44;; t) b=45;; u) b=46;; v) b=47;; w) b=48;; x) b=49;; y) b=50;; z) b=51;; 0) b=52;; 1) b=53;; 2) b=54;; 3) b=55;; 4) b=56;; 5) b=57;; 6) b=58;; 7) b=59;; 8) b=60;; 9) b=61;; +) b=62;; /) b=63;; *) b=0;; esac
        case "$c2" in A) c=0;; B) c=1;; C) c=2;; D) c=3;; E) c=4;; F) c=5;; G) c=6;; H) c=7;; I) c=8;; J) c=9;; K) c=10;; L) c=11;; M) c=12;; N) c=13;; O) c=14;; P) c=15;; Q) c=16;; R) c=17;; S) c=18;; T) c=19;; U) c=20;; V) c=21;; W) c=22;; X) c=23;; Y) c=24;; Z) c=25;; a) c=26;; b) c=27;; c) c=28;; d) c=29;; e) c=30;; f) c=31;; g) c=32;; h) c=33;; i) c=34;; j) c=35;; k) c=36;; l) c=37;; m) c=38;; n) c=39;; o) c=40;; p) c=41;; q) c=42;; r) c=43;; s) c=44;; t) c=45;; u) c=46;; v) c=47;; w) c=48;; x) c=49;; y) c=50;; z) c=51;; 0) c=52;; 1) c=53;; 2) c=54;; 3) c=55;; 4) c=56;; 5) c=57;; 6) c=58;; 7) c=59;; 8) c=60;; 9) c=61;; +) c=62;; /) c=63;; *) c=0;; esac
        case "$c3" in A) d=0;; B) d=1;; C) d=2;; D) d=3;; E) d=4;; F) d=5;; G) d=6;; H) d=7;; I) d=8;; J) d=9;; K) d=10;; L) d=11;; M) d=12;; N) d=13;; O) d=14;; P) d=15;; Q) d=16;; R) d=17;; S) d=18;; T) d=19;; U) d=20;; V) d=21;; W) d=22;; X) d=23;; Y) d=24;; Z) d=25;; a) d=26;; b) d=27;; c) d=28;; d) d=29;; e) d=30;; f) d=31;; g) d=32;; h) d=33;; i) d=34;; j) d=35;; k) d=36;; l) d=37;; m) d=38;; n) d=39;; o) d=40;; p) d=41;; q) d=42;; r) d=43;; s) d=44;; t) d=45;; u) d=46;; v) d=47;; w) d=48;; x) d=49;; y) d=50;; z) d=51;; 0) d=52;; 1) d=53;; 2) d=54;; 3) d=55;; 4) d=56;; 5) d=57;; 6) d=58;; 7) d=59;; 8) d=60;; 9) d=61;; +) d=62;; /) d=63;; *) d=0;; esac

        byte1=$(( (a << 2) | (b >> 4) ))
        byte2=$(( ((b & 15) << 4) | (c >> 2) ))
        byte3=$(( ((c & 3) << 6) | d ))

        printf "\\$(printf '%03o' $byte1)"
        (( i+2 < ${#s} )) && printf "\\$(printf '%03o' $byte2)"
        (( i+3 < ${#s}  )) && printf "\\$(printf '%03o' $byte3)"
    done
    echo
}

string::base32_encode() {
    local input; _string::read_input input "$@"
    if runtime::has_command base32; then
        echo -n "$input" | base32
    elif runtime::has_command gbase32; then  # homebrew coreutils on macOS
        echo -n "$1" | gbase32
    else
        echo "string::base32_encode: requires base32 (GNU coreutils)" >&2
        return 1
    fi
}

# Fast variant using nameref
# Usage: string::base32_encode::fast result_var str
string::base32_encode::fast() {
    local -n _string_base32_encode_result="$1"
    if runtime::has_command base32; then
        _string_base32_encode_result=$(echo -n "$2" | base32)
    elif runtime::has_command gbase32; then
        _string_base32_encode_result=$(echo -n "$2" | gbase32)
    else
        echo "string::base32_encode::fast: requires base32 (GNU coreutils)" >&2
        return 1
    fi
}

string::base32_decode() {
    local input; _string::read_input input "$@"
    if runtime::has_command base32; then
        echo -n "$input" | base32 --decode
    elif runtime::has_command gbase32; then
        echo -n "$1" | gbase32 --decode
    else
        echo "string::base32_decode: requires base32 (GNU coreutils)" >&2
        return 1
    fi
}

# Fast variant using nameref
# Usage: string::base32_decode::fast result_var str
string::base32_decode::fast() {
    local -n _string_base32_decode_result="$1"
    if runtime::has_command base32; then
        _string_base32_decode_result=$(echo -n "$2" | base32 --decode)
    elif runtime::has_command gbase32; then
        _string_base32_decode_result=$(echo -n "$2" | gbase32 --decode)
    else
        echo "string::base32_decode::fast: requires base32 (GNU coreutils)" >&2
        return 1
    fi
}

string::base32_encode::pure() {
    local input; _string::read_input input "$@"
    local _B32="ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    local s="$input" out="" i a b c d e

    for (( i=0; i<${#s}; i+=5 )); do
        a=$(printf '%d' "'${s:$i:1}")
        b=$(( i+1 < ${#s} ? $(printf '%d' "'${s:$((i+1)):1}") : 0 ))
        c=$(( i+2 < ${#s} ? $(printf '%d' "'${s:$((i+2)):1}") : 0 ))
        d=$(( i+3 < ${#s} ? $(printf '%d' "'${s:$((i+3)):1}") : 0 ))
        e=$(( i+4 < ${#s} ? $(printf '%d' "'${s:$((i+4)):1}") : 0 ))

        out+="${_B32:$(( (a >> 3) & 31 )):1}"
        out+="${_B32:$(( ((a << 2) | (b >> 6)) & 31 )):1}"
        out+="${_B32:$(( i+1 < ${#s} ? (b >> 1) & 31 : 32 )):1}"
        out+="${_B32:$(( i+1 < ${#s} ? ((b << 4) | (c >> 4)) & 31 : 32 )):1}"
        out+="${_B32:$(( i+2 < ${#s} ? ((c << 1) | (d >> 7)) & 31 : 32 )):1}"
        out+="${_B32:$(( i+3 < ${#s} ? (d >> 2) & 31 : 32 )):1}"
        out+="${_B32:$(( i+3 < ${#s} ? ((d << 3) | (e >> 5)) & 31 : 32 )):1}"
        out+="${_B32:$(( i+4 < ${#s} ? e & 31 : 32 )):1}"
    done

    echo "$out"
}

string::base32_decode::pure() {
    local input; _string::read_input input "$@"
    local s="${input//=}" i
    local -i a b c d e f g h

    # uppercase input since base32 alphabet is uppercase only
    s="${s^^}"

    for (( i=0; i<${#s}; i+=8 )); do
        local c0="${s:$i:1}" c1="${s:$((i+1)):1}" c2="${s:$((i+2)):1}" c3="${s:$((i+3)):1}"
        local c4="${s:$((i+4)):1}" c5="${s:$((i+5)):1}" c6="${s:$((i+6)):1}" c7="${s:$((i+7)):1}"
        # Use case for reliable index lookup (base32 alphabet: A-Z, 2-7)
        case "$c0" in A) a=0;; B) a=1;; C) a=2;; D) a=3;; E) a=4;; F) a=5;; G) a=6;; H) a=7;; I) a=8;; J) a=9;; K) a=10;; L) a=11;; M) a=12;; N) a=13;; O) a=14;; P) a=15;; Q) a=16;; R) a=17;; S) a=18;; T) a=19;; U) a=20;; V) a=21;; W) a=22;; X) a=23;; Y) a=24;; Z) a=25;; 2) a=26;; 3) a=27;; 4) a=28;; 5) a=29;; 6) a=30;; 7) a=31;; *) a=0;; esac
        case "$c1" in A) b=0;; B) b=1;; C) b=2;; D) b=3;; E) b=4;; F) b=5;; G) b=6;; H) b=7;; I) b=8;; J) b=9;; K) b=10;; L) b=11;; M) b=12;; N) b=13;; O) b=14;; P) b=15;; Q) b=16;; R) b=17;; S) b=18;; T) b=19;; U) b=20;; V) b=21;; W) b=22;; X) b=23;; Y) b=24;; Z) b=25;; 2) b=26;; 3) b=27;; 4) b=28;; 5) b=29;; 6) b=30;; 7) b=31;; *) b=0;; esac
        case "$c2" in A) c=0;; B) c=1;; C) c=2;; D) c=3;; E) c=4;; F) c=5;; G) c=6;; H) c=7;; I) c=8;; J) c=9;; K) c=10;; L) c=11;; M) c=12;; N) c=13;; O) c=14;; P) c=15;; Q) c=16;; R) c=17;; S) c=18;; T) c=19;; U) c=20;; V) c=21;; W) c=22;; X) c=23;; Y) c=24;; Z) c=25;; 2) c=26;; 3) c=27;; 4) c=28;; 5) c=29;; 6) c=30;; 7) c=31;; *) c=0;; esac
        case "$c3" in A) d=0;; B) d=1;; C) d=2;; D) d=3;; E) d=4;; F) d=5;; G) d=6;; H) d=7;; I) d=8;; J) d=9;; K) d=10;; L) d=11;; M) d=12;; N) d=13;; O) d=14;; P) d=15;; Q) d=16;; R) d=17;; S) d=18;; T) d=19;; U) d=20;; V) d=21;; W) d=22;; X) d=23;; Y) d=24;; Z) d=25;; 2) d=26;; 3) d=27;; 4) d=28;; 5) d=29;; 6) d=30;; 7) d=31;; *) d=0;; esac
        case "$c4" in A) e=0;; B) e=1;; C) e=2;; D) e=3;; E) e=4;; F) e=5;; G) e=6;; H) e=7;; I) e=8;; J) e=9;; K) e=10;; L) e=11;; M) e=12;; N) e=13;; O) e=14;; P) e=15;; Q) e=16;; R) e=17;; S) e=18;; T) e=19;; U) e=20;; V) e=21;; W) e=22;; X) e=23;; Y) e=24;; Z) e=25;; 2) e=26;; 3) e=27;; 4) e=28;; 5) e=29;; 6) e=30;; 7) e=31;; *) e=0;; esac
        case "$c5" in A) f=0;; B) f=1;; C) f=2;; D) f=3;; E) f=4;; F) f=5;; G) f=6;; H) f=7;; I) f=8;; J) f=9;; K) f=10;; L) f=11;; M) f=12;; N) f=13;; O) f=14;; P) f=15;; Q) f=16;; R) f=17;; S) f=18;; T) f=19;; U) f=20;; V) f=21;; W) f=22;; X) f=23;; Y) f=24;; Z) f=25;; 2) f=26;; 3) f=27;; 4) f=28;; 5) f=29;; 6) f=30;; 7) f=31;; *) f=0;; esac
        case "$c6" in A) g=0;; B) g=1;; C) g=2;; D) g=3;; E) g=4;; F) g=5;; G) g=6;; H) g=7;; I) g=8;; J) g=9;; K) g=10;; L) g=11;; M) g=12;; N) g=13;; O) g=14;; P) g=15;; Q) g=16;; R) g=17;; S) g=18;; T) g=19;; U) g=20;; V) g=21;; W) g=22;; X) g=23;; Y) g=24;; Z) g=25;; 2) g=26;; 3) g=27;; 4) g=28;; 5) g=29;; 6) g=30;; 7) g=31;; *) g=0;; esac
        case "$c7" in A) h=0;; B) h=1;; C) h=2;; D) h=3;; E) h=4;; F) h=5;; G) h=6;; H) h=7;; I) h=8;; J) h=9;; K) h=10;; L) h=11;; M) h=12;; N) h=13;; O) h=14;; P) h=15;; Q) h=16;; R) h=17;; S) h=18;; T) h=19;; U) h=20;; V) h=21;; W) h=22;; X) h=23;; Y) h=24;; Z) h=25;; 2) h=26;; 3) h=27;; 4) h=28;; 5) h=29;; 6) h=30;; 7) h=31;; *) h=0;; esac

        printf "\\$(printf '%03o' $(( (a << 3) | (b >> 2) )))"
        (( i+2 < ${#s} )) && printf "\\$(printf '%03o' $(( ((b & 3) << 6) | (c << 1) | (d >> 4) )))"
        (( i+4 < ${#s} )) && printf "\\$(printf '%03o' $(( ((d & 15) << 4) | (e >> 1) )))"
        (( i+5 < ${#s} )) && printf "\\$(printf '%03o' $(( ((e & 1) << 7) | (f << 2) | (g >> 3) )))"
        (( i+7 < ${#s} )) && printf "\\$(printf '%03o' $(( ((g & 7) << 5) | h )))"
    done
    echo
}

# MD5 hash of a string
# Requires: md5sum (Linux) or md5 (macOS)
string::md5() {
  local input; _string::read_input input "$@"
  if command -v md5sum >/dev/null 2>&1; then
    echo -n "$input" | md5sum | cut -d' ' -f1
  elif command -v md5 >/dev/null 2>&1; then
    echo -n "$input" | md5
  else
    echo "string::md5: requires md5sum or md5" >&2
    return 1
  fi
}

# SHA256 hash of a string
# Requires: sha256sum (Linux) or shasum (macOS)
string::sha256() {
  local input; _string::read_input input "$@"
  if command -v sha256sum >/dev/null 2>&1; then
    echo -n "$input" | sha256sum | cut -d' ' -f1
  elif command -v shasum >/dev/null 2>&1; then
    echo -n "$input" | shasum -a 256 | cut -d' ' -f1
  else
    echo "string::sha256: requires sha256sum or shasum" >&2
    return 1
  fi
}

# ==============================================================================
# GENERATION
# ==============================================================================

# Generate a random alphanumeric string of given length
# Usage: string::random [length]
string::random() {
  local input; _string::read_input input "$@"
  local len="${input:-16}"
  cat /dev/urandom 2>/dev/null |
    tr -dc 'a-zA-Z0-9' |
    head -c "$len" ||
    echo "string::random: /dev/urandom unavailable" >&2
}

# Generate a UUID v4 (random)
string::uuid() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen | tr '[:upper:]' '[:lower:]'
  elif [[ -f /proc/sys/kernel/random/uuid ]]; then
    cat /proc/sys/kernel/random/uuid
  else
    # Manual construction from /dev/urandom
    local b
    b=$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')
    printf '%s-%s-4%s-%s%s-%s\n' \
      "${b:0:8}" "${b:8:4}" "${b:13:3}" \
      "$(((16#${b:16:1} & 3) | 8))${b:17:3}" \
      "${b:20:4}" "${b:24:12}"
  fi
}
# terminal.sh — bash-frameheader terminal lib
# Requires: runtime.sh (runtime::has_command)

# ==============================================================================
# CAPABILITY DETECTION
# ==============================================================================

# Check if stdout is a terminal
terminal::is_tty() {
    [[ -t 1 ]]
}

# Check if stdin is a terminal
terminal::is_tty::stdin() {
    [[ -t 0 ]]
}

# Check if stderr is a terminal
terminal::is_tty::stderr() {
    [[ -t 2 ]]
}

# Get terminal width in columns
terminal::width() {
    tput cols 2>/dev/null || echo "80"
}

# Get terminal height in rows
terminal::height() {
    tput lines 2>/dev/null || echo "24"
}

# Get both as "cols rows"
terminal::size() {
    echo "$(terminal::width) $(terminal::height)"
}

# Check if terminal supports colours
terminal::has_colour() {
    [[ -t 1 ]] && (( $(tput colors 2>/dev/null) >= 8 ))
}

# Check if terminal supports 256 colours
terminal::has_256colour() {
    [[ -t 1 ]] && (( $(tput colors 2>/dev/null) >= 256 ))
}

# Check if terminal supports true colour
terminal::has_truecolour() {
    [[ "$COLORTERM" == "truecolor" || "$COLORTERM" == "24bit" ]]
}

# Return the terminal emulator name if detectable
terminal::name() {
    if [[ -n "$TERM_PROGRAM" ]]; then
        echo "$TERM_PROGRAM"
    elif [[ -n "$TERMINAL" ]]; then
        echo "$TERMINAL"
    elif [[ -n "$TERM" ]]; then
        echo "$TERM"
    else
        echo "unknown"
    fi
}

# ==============================================================================
# CURSOR
# ==============================================================================

terminal::cursor::show() {
    printf '\033[?25h'
}

terminal::cursor::hide() {
    printf '\033[?25l'
}

terminal::cursor::toggle() {
    # Tracks state via a global flag
    if [[ "${_TERMINAL_CURSOR_HIDDEN:-0}" == "1" ]]; then
        terminal::cursor::show
        _TERMINAL_CURSOR_HIDDEN=0
    else
        terminal::cursor::hide
        _TERMINAL_CURSOR_HIDDEN=1
    fi
}

# Save cursor position
terminal::cursor::save() {
    printf '\033[s'
}

# Restore cursor to saved position
terminal::cursor::restore() {
    printf '\033[u'
}

# Move cursor to row, col (1-indexed)
# Usage: terminal::cursor::move row col
terminal::cursor::move() {
    printf '\033[%s;%sH' "$1" "$2"
}

# Move cursor up n rows
terminal::cursor::up() {
    printf '\033[%sA' "${1:-1}"
}

# Move cursor down n rows
terminal::cursor::down() {
    printf '\033[%sB' "${1:-1}"
}

# Move cursor right n cols
terminal::cursor::right() {
    printf '\033[%sC' "${1:-1}"
}

# Move cursor left n cols
terminal::cursor::left() {
    printf '\033[%sD' "${1:-1}"
}

# Move cursor to start of line n lines down
terminal::cursor::next_line() {
    printf '\033[%sE' "${1:-1}"
}

# Move cursor to start of line n lines up
terminal::cursor::prev_line() {
    printf '\033[%sF' "${1:-1}"
}

# Move cursor to column n on current line
terminal::cursor::col() {
    printf '\033[%sG' "${1:-1}"
}

# Move cursor to top-left (home)
terminal::cursor::home() {
    printf '\033[H'
}

# ==============================================================================
# SCREEN
# ==============================================================================

# Clear entire screen
terminal::clear() {
    printf '\033[2J'
    terminal::cursor::home
}

# Clear from cursor to end of screen
terminal::clear::to_end() {
    printf '\033[0J'
}

# Clear from cursor to beginning of screen
terminal::clear::to_start() {
    printf '\033[1J'
}

# Clear current line
terminal::clear::line() {
    printf '\033[2K'
}

# Clear from cursor to end of line
terminal::clear::line_end() {
    printf '\033[0K'
}

# Clear from cursor to start of line
terminal::clear::line_start() {
    printf '\033[1K'
}

# Enter alternate screen buffer (like vim/less do)
terminal::screen::alternate() {
    printf '\033[?1049h'
}

# Return to normal screen buffer
terminal::screen::normal() {
    printf '\033[?1049l'
}

# Enter alternate screen, run a command, return to normal screen
# Usage: terminal::screen::wrap command [args...]
terminal::screen::wrap() {
    terminal::screen::alternate
    "$@"
    local ret=$?
    terminal::screen::normal
    return $ret
}

terminal::screen::alternate_enter() {
    terminal::screen::alternate
    terminal::cursor::home
    terminal::clear
    trap 'terminal::screen::normal' EXIT INT TERM
}

terminal::screen::alternate_exit() {
    terminal::screen::normal
    trap - EXIT INT TERM
}

# Scroll up n lines
terminal::scroll::up() {
    printf '\033[%sS' "${1:-1}"
}

# Scroll down n lines
terminal::scroll::down() {
    printf '\033[%sT' "${1:-1}"
}

# Set terminal title (works in most modern terminal emulators)
# Usage: terminal::title "My Script"
terminal::title() {
    printf '\033]0;%s\007' "$1"
}

# Ring the terminal bell
terminal::bell() {
    printf '\007'
}

# ==============================================================================
# INPUT
# ==============================================================================

# Read a single keypress without requiring Enter
# Usage: terminal::read_key varname
terminal::read_key() {
    local _var="${1:-_TERMINAL_KEY}"
    local _key
    IFS= read -r -s -n1 _key
    printf -v "$_var" '%s' "$_key"
}

# Read a single keypress with a timeout
# Usage: terminal::read_key::timeout varname seconds
terminal::read_key::timeout() {
    local _var="${1:-_TERMINAL_KEY}" _timeout="${2:-5}"
    local _key
    IFS= read -r -s -n1 -t "$_timeout" _key
    printf -v "$_var" '%s' "$_key"
}

# Prompt user for y/n, returns 0 for yes, 1 for no
# Usage: terminal::confirm "Are you sure?"
# Note: Will return 1 on non-'y' input (defaults to no)
terminal::confirm() {
    local prompt="${1:-Are you sure?} [y/N] "
    local key
    printf '%s' "$prompt"
    terminal::read_key key
    printf '\n'
    [[ "${key,,}" == "y" ]]
}

# Prompt with a default choice shown
# Usage: terminal::confirm::default yes "Proceed?"
terminal::confirm::default() {
    local default="${1:-yes}" prompt="${2:-Are you sure?}"
    local label
    [[ "$default" == "yes" ]] && label="[Y/n]" || label="[y/N]"
    printf '%s %s ' "$prompt" "$label"
    local key
    terminal::read_key key
    printf '\n'
    if [[ -z "$key" ]]; then
        [[ "$default" == "yes" ]]
    else
        [[ "${key,,}" == "y" ]]
    fi
}

# Disable terminal echo (e.g. for password input)
terminal::echo::off() {
    stty -echo 2>/dev/null
}

# Re-enable terminal echo
terminal::echo::on() {
    stty echo 2>/dev/null
}

# Read a password (no echo)
# Usage: terminal::read_password varname [prompt]
terminal::read_password() {
    local _var="$1" _prompt="${2:-Password: }"
    local _pass
    printf '%s' "$_prompt"
    terminal::echo::off
    IFS= read -r _pass
    terminal::echo::on
    printf '\n'
    printf -v "$_var" '%s' "$_pass"
}

# ==============================================================================
# SHOPT WRAPPERS
# Convenience wrappers around bash's shopt builtin
# ==============================================================================

# Enable a shopt option, return 1 if unsupported
terminal::shopt::enable() {
    shopt -s "$1" 2>/dev/null
}

# Disable a shopt option
terminal::shopt::disable() {
    shopt -u "$1" 2>/dev/null
}

# Check if a shopt option is enabled
terminal::shopt::is_enabled() {
    shopt -q "$1" 2>/dev/null
}

# Get current value of a shopt option ("on" or "off")
terminal::shopt::get() {
    shopt "$1" 2>/dev/null | awk '{print $2}'
}

# List all enabled shopt options
terminal::shopt::list::enabled() {
    shopt | awk '$2 == "on" {print $1}'
}

# List all disabled shopt options
terminal::shopt::list::disabled() {
    shopt | awk '$2 == "off" {print $1}'
}

# Save current shopt state (prints a restore command)
# Usage: eval "$(terminal::shopt::save)"
terminal::shopt::save() {
    shopt | awk '$2 == "on"  {print "shopt -s " $1 ";"}'
    shopt | awk '$2 == "off" {print "shopt -u " $1 ";"}'
}

# Restore state from a variable
# Usage: terminal::shopt::load varname
terminal::shopt::load() {
    local _var="${1:-_SHOPT_STATE}"
    eval "${!_var}"
}

# Common shopt convenience toggles
terminal::shopt::globstar::enable()      { shopt -s globstar     2>/dev/null; }  # ** recursive glob
terminal::shopt::globstar::disable()     { shopt -u globstar     2>/dev/null; }
terminal::shopt::nullglob::enable()      { shopt -s nullglob     2>/dev/null; }  # failed globs → empty
terminal::shopt::nullglob::disable()     { shopt -u nullglob     2>/dev/null; }
terminal::shopt::dotglob::enable()       { shopt -s dotglob      2>/dev/null; }  # globs match dotfiles
terminal::shopt::dotglob::disable()      { shopt -u dotglob      2>/dev/null; }
terminal::shopt::extglob::enable()       { shopt -s extglob      2>/dev/null; }  # extended patterns
terminal::shopt::extglob::disable()      { shopt -u extglob      2>/dev/null; }
terminal::shopt::nocaseglob::enable()    { shopt -s nocaseglob   2>/dev/null; }  # case-insensitive glob
terminal::shopt::nocaseglob::disable()   { shopt -u nocaseglob   2>/dev/null; }
terminal::shopt::autocd::enable()        { shopt -s autocd       2>/dev/null; }  # cd by typing dir name
terminal::shopt::autocd::disable()       { shopt -u autocd       2>/dev/null; }
terminal::shopt::checkwinsize::enable()  { shopt -s checkwinsize 2>/dev/null; }  # update LINES/COLUMNS
terminal::shopt::checkwinsize::disable() { shopt -u checkwinsize 2>/dev/null; }
terminal::shopt::histappend::enable()    { shopt -s histappend   2>/dev/null; }  # append to history
terminal::shopt::histappend::disable()   { shopt -u histappend   2>/dev/null; }
terminal::shopt::cdspell::enable()       { shopt -s cdspell      2>/dev/null; }  # autocorrect cd typos
terminal::shopt::cdspell::disable()      { shopt -u cdspell      2>/dev/null; }
terminal::shopt::nocasematch::enable()   { shopt -s nocasematch  2>/dev/null; }  # case-insensitive [[ =~
terminal::shopt::nocasematch::disable()  { shopt -u nocasematch  2>/dev/null; }
# timedate.sh — bash-frameheader time and date lib
#
# PORTABILITY NOTE: GNU date and BSD date (macOS) have different syntax.
# date arithmetic uses GNU date where available, falls back to pure bash.
# Pure bash calendar math works on Bash 3+.

# ==============================================================================
# INTERNAL HELPERS
# ==============================================================================

# Detect if GNU date is available
_timedate::has_gnu_date() {
    date --version >/dev/null 2>&1
}

# Portable date formatting
# Usage: _timedate::format format [timestamp]
_timedate::format() {
    local fmt="$1" ts="${2:-}"
    if [[ -n "$ts" ]]; then
        if _timedate::has_gnu_date; then
            date -d "@$ts" +"$fmt" 2>/dev/null
        else
            date -r "$ts" +"$fmt" 2>/dev/null
        fi
    else
        date +"$fmt"
    fi
}

# ==============================================================================
# TIMESTAMP
# ==============================================================================

# Current unix timestamp (seconds since epoch)
timedate::timestamp::unix() {
    date +%s
}

# Current unix timestamp in milliseconds
timedate::timestamp::unix_ms() {
    if _timedate::has_gnu_date; then
        date +%s%3N
    else
        # macOS fallback — python if available
        if runtime::has_command python3; then
            python3 -c "import time; print(int(time.time() * 1000))"
        else
            echo "$(date +%s)000"
        fi
    fi
}

# Current unix timestamp in nanoseconds
timedate::timestamp::unix_ns() {
    if _timedate::has_gnu_date; then
        date +%s%N
    elif runtime::has_command python3; then
        python3 -c "import time; print(int(time.time() * 1e9))"
    else
        echo "$(date +%s)000000000"
    fi
}

# Convert unix timestamp to human-readable
# Usage: timedate::timestamp::to_human timestamp [format]
timedate::timestamp::to_human() {
    local ts="$1" fmt="${2:-%Y-%m-%d %H:%M:%S}"
    _timedate::format "$fmt" "$ts"
}

# Convert human-readable date to unix timestamp
# Usage: timedate::timestamp::from_human "2024-01-15 12:00:00"
timedate::timestamp::from_human() {
    if _timedate::has_gnu_date; then
        date -d "$1" +%s 2>/dev/null
    else
        date -j -f "%Y-%m-%d %H:%M:%S" "$1" +%s 2>/dev/null
    fi
}

# ==============================================================================
# DATE
# ==============================================================================

# Current date in YYYY-MM-DD format
timedate::date::today() {
    date +%Y-%m-%d
}

# Current date in a custom format
# Usage: timedate::date::format [format] [timestamp]
timedate::date::format() {
    local fmt="${1:-%Y-%m-%d}" ts="${2:-}"
    _timedate::format "$fmt" "$ts"
}

# Get year
timedate::date::year()  { date +%Y; }

# Get month (01-12)
timedate::date::month() { date +%m; }

# Get day of month (01-31)
timedate::date::day()   { date +%d; }

# Get day of week (1=Monday, 7=Sunday, ISO 8601)
timedate::date::day_of_week() {
    date +%u
}

# Get day of week name
timedate::date::day_name() {
    date +%A
}

# Get day of week short name
timedate::date::day_name::short() {
    date +%a
}

# Get day of year (001-366)
timedate::date::day_of_year() {
    date +%j
}

# Get week of year (ISO 8601, 01-53)
timedate::date::week_of_year() {
    date +%V
}

# Get quarter (1-4)
timedate::date::quarter() {
    local month
    month=$(date +%m)
    echo $(( (10#$month - 1) / 3 + 1 ))
}

# Get last day of a given month
# Usage: timedate::date::days_in_month year month
timedate::date::days_in_month() {
    local year="$1" month="$2"
    # Remove leading zero to avoid octal interpretation
    month=$(( 10#$month ))
    case "$month" in
    1|3|5|7|8|10|12) echo 31 ;;
    4|6|9|11)         echo 30 ;;
    2)
        if timedate::calendar::is_leap_year "$year"; then
            echo 29
        else
            echo 28
        fi
        ;;
    esac
}

# Add n days to a date
# Usage: timedate::date::add_days YYYY-MM-DD n
timedate::date::add_days() {
    local date_str="$1" n="$2"
    if _timedate::has_gnu_date; then
        date -d "$date_str + $n days" +%Y-%m-%d 2>/dev/null
    else
        date -v+"${n}d" -j -f "%Y-%m-%d" "$date_str" +%Y-%m-%d 2>/dev/null
    fi
}

# Subtract n days from a date
timedate::date::sub_days() {
    timedate::date::add_days "$1" "$(( -$2 ))"
}

# Add n months to a date
timedate::date::add_months() {
    local date_str="$1" n="$2"
    if _timedate::has_gnu_date; then
        date -d "$date_str + $n months" +%Y-%m-%d 2>/dev/null
    else
        date -v+"${n}m" -j -f "%Y-%m-%d" "$date_str" +%Y-%m-%d 2>/dev/null
    fi
}

# Add n years to a date
timedate::date::add_years() {
    local date_str="$1" n="$2"
    if _timedate::has_gnu_date; then
        date -d "$date_str + $n years" +%Y-%m-%d 2>/dev/null
    else
        date -v+"${n}y" -j -f "%Y-%m-%d" "$date_str" +%Y-%m-%d 2>/dev/null
    fi
}

# Number of days between two dates
# Usage: timedate::date::days_between YYYY-MM-DD YYYY-MM-DD
timedate::date::days_between() {
    local ts1 ts2
    ts1=$(timedate::timestamp::from_human "$1 00:00:00")
    ts2=$(timedate::timestamp::from_human "$2 00:00:00")
    echo $(( (ts2 - ts1) / 86400 ))
}

# Get yesterday's date
timedate::date::yesterday() {
    timedate::date::add_days "$(timedate::date::today)" -1
}

# Get tomorrow's date
timedate::date::tomorrow() {
    timedate::date::add_days "$(timedate::date::today)" 1
}

# Get start of current week (Monday)
timedate::date::week_start() {
    local dow
    dow=$(timedate::date::day_of_week)
    timedate::date::add_days "$(timedate::date::today)" "$(( -(dow - 1) ))"
}

# Get end of current week (Sunday)
timedate::date::week_end() {
    local dow
    dow=$(timedate::date::day_of_week)
    timedate::date::add_days "$(timedate::date::today)" "$(( 7 - dow ))"
}

# Get start of current month
timedate::date::month_start() {
    date +%Y-%m-01
}

# Get end of current month
timedate::date::month_end() {
    local year month days
    year=$(date +%Y)
    month=$(date +%m)
    days=$(timedate::date::days_in_month "$year" "$month")
    printf '%s-%s-%02d\n' "$year" "$month" "$days"
}

# Get start of current year
timedate::date::year_start() {
    date +%Y-01-01
}

# Get end of current year
timedate::date::year_end() {
    date +%Y-12-31
}

# Next occurrence of a weekday from today
# Usage: timedate::date::next_weekday weekday_number (1=Mon, 7=Sun)
timedate::date::next_weekday() {
    local target="$1"
    local current_dow
    current_dow=$(timedate::date::day_of_week)
    local diff=$(( (target - current_dow + 7) % 7 ))
    (( diff == 0 )) && diff=7
    timedate::date::add_days "$(timedate::date::today)" "$diff"
}

# Previous occurrence of a weekday
timedate::date::prev_weekday() {
    local target="$1"
    local current_dow
    current_dow=$(timedate::date::day_of_week)
    local diff=$(( (current_dow - target + 7) % 7 ))
    (( diff == 0 )) && diff=7
    timedate::date::add_days "$(timedate::date::today)" "$(( -diff ))"
}

# Compare two dates — returns -1, 0, or 1
# Usage: timedate::date::compare YYYY-MM-DD YYYY-MM-DD
timedate::date::compare() {
    local ts1 ts2
    ts1=$(timedate::timestamp::from_human "$1 00:00:00")
    ts2=$(timedate::timestamp::from_human "$2 00:00:00")
    if (( ts1 < ts2 ));   then echo -1
    elif (( ts1 > ts2 )); then echo 1
    else                       echo 0
    fi
}

# Check if a date is before another
timedate::date::is_before() {
    [[ "$(timedate::date::compare "$1" "$2")" == "-1" ]]
}

# Check if a date is after another
timedate::date::is_after() {
    [[ "$(timedate::date::compare "$1" "$2")" == "1" ]]
}

# Check if a date is between two dates (inclusive)
timedate::date::is_between() {
    local d="$1" start="$2" end="$3"
    ! timedate::date::is_before "$d" "$start" && \
    ! timedate::date::is_after  "$d" "$end"
}

# ==============================================================================
# TIME
# ==============================================================================

# Current time in HH:MM:SS
timedate::time::now() {
    date +%H:%M:%S
}

# Current time in a custom format
timedate::time::format() {
    local fmt="${1:-%H:%M:%S}"
    date +"$fmt"
}

# Get hour (00-23)
timedate::time::hour()   { date +%H; }

# Get minute (00-59)
timedate::time::minute() { date +%M; }

# Get second (00-59)
timedate::time::second() { date +%S; }

# Get timezone abbreviation
timedate::time::timezone() {
    date +%Z
}

# Get timezone offset from UTC (e.g. +0800)
timedate::time::timezone_offset() {
    date +%z
}

# Check if current time is before a given time
# Usage: timedate::time::is_before HH:MM
timedate::time::is_before() {
    local target="$1"
    local current
    current=$(date +%H:%M)
    [[ "$current" < "$target" ]]
}

# Check if current time is after a given time
timedate::time::is_after() {
    local target="$1"
    local current
    current=$(date +%H:%M)
    [[ "$current" > "$target" ]]
}

# Check if current time is between two times (HH:MM)
# Usage: timedate::time::is_between HH:MM HH:MM
timedate::time::is_between() {
    local start="$1" end="$2"
    local current
    current=$(date +%H:%M)
    [[ "$current" > "$start" && "$current" < "$end" ]]
}

# Check if currently business hours (09:00-17:00 Mon-Fri)
# Usage: timedate::time::is_business_hours [start_hour] [end_hour]
timedate::time::is_business_hours() {
    local start="${1:-09:00}" end="${2:-17:00}"
    local dow
    dow=$(timedate::date::day_of_week)
    (( dow >= 1 && dow <= 5 )) || return 1
    timedate::time::is_between "$start" "$end"
}

# Check if currently morning (00:00-11:59)
timedate::time::is_morning() {
    local hour
    hour=$(( 10#$(date +%H) ))
    (( hour < 12 ))
}

# Check if currently afternoon (12:00-17:59)
timedate::time::is_afternoon() {
    local hour
    hour=$(( 10#$(date +%H) ))
    (( hour >= 12 && hour < 18 ))
}

# Check if currently evening (18:00-23:59)
timedate::time::is_evening() {
    local hour
    hour=$(( 10#$(date +%H) ))
    (( hour >= 18 ))
}

# Sleep with a progress indicator
# Usage: timedate::time::sleep seconds [message]
timedate::time::sleep() {
    local secs="$1" msg="${2:-Waiting}"
    local i
    for (( i=secs; i>0; i-- )); do
        printf '\r%s... %ds ' "$msg" "$i"
        sleep 1
    done
    printf '\r%s... done\n' "$msg"
}

# Stopwatch — start, returns a token
# Usage: token=$(timedate::time::stopwatch::start)
timedate::time::stopwatch::start() {
    timedate::timestamp::unix_ms
}

# Stopwatch — stop, returns elapsed ms
# Usage: timedate::time::stopwatch::stop token
timedate::time::stopwatch::stop() {
    local start="$1"
    local now
    now=$(timedate::timestamp::unix_ms)
    echo $(( now - start ))
}

# ==============================================================================
# DURATION
# ==============================================================================

# Format seconds into human-readable duration
# Usage: timedate::duration::format seconds
# Output: 1d 2h 3m 4s
timedate::duration::format() {
    local total="$1"
    local neg=""
    (( total < 0 )) && neg="-" && total=$(( -total ))

    local days=$(( total / 86400 ))
    local hours=$(( (total % 86400) / 3600 ))
    local mins=$(( (total % 3600) / 60 ))
    local secs=$(( total % 60 ))

    local result=""
    (( days  > 0 )) && result+="${days}d "
    (( hours > 0 )) && result+="${hours}h "
    (( mins  > 0 )) && result+="${mins}m "
    (( secs  > 0 || total == 0 )) && result+="${secs}s"

    echo "${neg}${result% }"
}

# Format milliseconds into human-readable duration
timedate::duration::format_ms() {
    local ms="$1"
    if (( ms < 1000 )); then
        echo "${ms}ms"
    elif (( ms < 60000 )); then
        echo "$(( ms / 1000 ))s $(( ms % 1000 ))ms"
    else
        timedate::duration::format "$(( ms / 1000 ))"
    fi
}

# Parse a duration string into seconds
# Usage: timedate::duration::parse "1d 2h 3m 4s"
timedate::duration::parse() {
    local input="$1" total=0
    # shellcheck disable=SC2206
    local -a tokens=($input)
    for token in "${tokens[@]}"; do
        local val unit
        val="${token%[dhms]*}"
        unit="${token##*[0-9]}"
        case "$unit" in
        d) (( total += val * 86400 )) ;;
        h) (( total += val * 3600  )) ;;
        m) (( total += val * 60    )) ;;
        s) (( total += val         )) ;;
        esac
    done
    echo "$total"
}

# Human-readable relative time from a unix timestamp
# Usage: timedate::duration::relative timestamp
# Output: "3 hours ago", "in 2 days"
timedate::duration::relative() {
    local ts="$1"
    local now
    now=$(timedate::timestamp::unix)
    local diff=$(( now - ts ))
    local abs_diff=$(( diff < 0 ? -diff : diff ))
    local future=false
    (( diff < 0 )) && future=true

    local result
    if   (( abs_diff < 60 ));     then result="${abs_diff} second$( (( abs_diff != 1 )) && echo s)"
    elif (( abs_diff < 3600 ));   then
        local m=$(( abs_diff / 60 ))
        result="$m minute$( (( m != 1 )) && echo s)"
    elif (( abs_diff < 86400 ));  then
        local h=$(( abs_diff / 3600 ))
        result="$h hour$( (( h != 1 )) && echo s)"
    elif (( abs_diff < 2592000 )); then
        local d=$(( abs_diff / 86400 ))
        result="$d day$( (( d != 1 )) && echo s)"
    elif (( abs_diff < 31536000 )); then
        local mo=$(( abs_diff / 2592000 ))
        result="$mo month$( (( mo != 1 )) && echo s)"
    else
        local y=$(( abs_diff / 31536000 ))
        result="$y year$( (( y != 1 )) && echo s)"
    fi

    $future && echo "in $result" || echo "$result ago"
}

# ==============================================================================
# CALENDAR
# ==============================================================================

# Check if a year is a leap year
# Usage: timedate::calendar::is_leap_year year
timedate::calendar::is_leap_year() {
    local year="$1"
    (( year % 4 == 0 && (year % 100 != 0 || year % 400 == 0) ))
}

# Get number of days in a year
timedate::calendar::days_in_year() {
    timedate::calendar::is_leap_year "$1" && echo 366 || echo 365
}

# Check if a date falls on a weekend
# Usage: timedate::calendar::is_weekend YYYY-MM-DD
timedate::calendar::is_weekend() {
    local dow
    if _timedate::has_gnu_date; then
        dow=$(date -d "$1" +%u 2>/dev/null)
    else
        dow=$(date -j -f "%Y-%m-%d" "$1" +%u 2>/dev/null)
    fi
    (( dow >= 6 ))
}

# Check if a date falls on a weekday
timedate::calendar::is_weekday() {
    ! timedate::calendar::is_weekend "$1"
}

# Get ISO week number for a date
# Usage: timedate::calendar::iso_week YYYY-MM-DD
timedate::calendar::iso_week() {
    if _timedate::has_gnu_date; then
        date -d "$1" +%V 2>/dev/null
    else
        date -j -f "%Y-%m-%d" "$1" +%V 2>/dev/null
    fi
}

# Get day of year for a date
# Usage: timedate::calendar::day_of_year YYYY-MM-DD
timedate::calendar::day_of_year() {
    if _timedate::has_gnu_date; then
        date -d "$1" +%j 2>/dev/null
    else
        date -j -f "%Y-%m-%d" "$1" +%j 2>/dev/null
    fi
}

# Get quarter for a date
# Usage: timedate::calendar::quarter YYYY-MM-DD
timedate::calendar::quarter() {
    local month
    if _timedate::has_gnu_date; then
        month=$(date -d "$1" +%m 2>/dev/null)
    else
        month=$(date -j -f "%Y-%m-%d" "$1" +%m 2>/dev/null)
    fi
    echo $(( (10#$month - 1) / 3 + 1 ))
}

# Calculate Easter date for a given year (Meeus/Jones/Butcher algorithm)
# Usage: timedate::calendar::easter year
# Output: YYYY-MM-DD
timedate::calendar::easter() {
    local year="$1"
    local a b c d e f g h i k l m n p

    a=$(( year % 19 ))
    b=$(( year / 100 ))
    c=$(( year % 100 ))
    d=$(( b / 4 ))
    e=$(( b % 4 ))
    f=$(( (b + 8) / 25 ))
    g=$(( (b - f + 1) / 3 ))
    h=$(( (19 * a + b - d - g + 15) % 30 ))
    i=$(( c / 4 ))
    k=$(( c % 4 ))
    l=$(( (32 + 2 * e + 2 * i - h - k) % 7 ))
    m=$(( (a + 11 * h + 22 * l) / 451 ))
    n=$(( (h + l - 7 * m + 114) / 31 ))
    p=$(( (h + l - 7 * m + 114) % 31 + 1 ))

    printf '%d-%02d-%02d\n' "$year" "$n" "$p"
}

# Number of weekdays between two dates
# Usage: timedate::calendar::weekdays_between YYYY-MM-DD YYYY-MM-DD
timedate::calendar::weekdays_between() {
    local start="$1" end="$2"
    local count=0 current="$start"
    while ! timedate::date::is_after "$current" "$end"; do
        timedate::calendar::is_weekday "$current" && (( count++ ))
        current=$(timedate::date::add_days "$current" 1)
    done
    echo "$count"
}

# Get the calendar for a month (like cal command)
# Usage: timedate::calendar::month [year] [month]
timedate::calendar::month() {
    local year="${1:-$(date +%Y)}" month="${2:-$(date +%m)}"
    if runtime::has_command cal; then
        cal "$month" "$year"
    else
        # Pure bash fallback — basic grid
        local days
        days=$(timedate::date::days_in_month "$year" "$month")
        local first_dow
        if _timedate::has_gnu_date; then
            first_dow=$(date -d "${year}-${month}-01" +%u 2>/dev/null)
        else
            first_dow=$(date -j -f "%Y-%m-%d" "${year}-${month}-01" +%u 2>/dev/null)
        fi
        printf '%s %s\n' "$(date -d "${year}-${month}-01" +"%B %Y" 2>/dev/null || echo "$year-$month")" ""
        printf 'Mo Tu We Th Fr Sa Su\n'
        local pad=$(( first_dow - 1 ))
        local i col=1
        printf '%s' "$(printf '   %.0s' $(seq 1 $pad))"
        col=$(( pad + 1 ))
        for (( i=1; i<=days; i++ )); do
            printf '%2d ' "$i"
            (( col % 7 == 0 )) && printf '\n'
            (( col++ ))
        done
        printf '\n'
    fi
}

# ==============================================================================
# TIMEZONE
# ==============================================================================

# Convert a timestamp to a different timezone
# Usage: timedate::tz::convert timestamp timezone
# Example: timedate::tz::convert 1700000000 "America/New_York"
timedate::tz::convert() {
    local ts="$1" tz="$2"
    if _timedate::has_gnu_date; then
        TZ="$tz" date -d "@$ts" "+%Y-%m-%d %H:%M:%S %Z" 2>/dev/null
    else
        TZ="$tz" date -r "$ts" "+%Y-%m-%d %H:%M:%S %Z" 2>/dev/null
    fi
}

# Get current time in a specific timezone
# Usage: timedate::tz::now timezone
timedate::tz::now() {
    TZ="$1" date "+%Y-%m-%d %H:%M:%S %Z" 2>/dev/null
}

# Get current timezone name
timedate::tz::current() {
    date +%Z
}

# Get UTC offset in seconds
timedate::tz::offset_seconds() {
    local offset
    offset=$(date +%z)
    local sign="${offset:0:1}"
    local hours=$(( 10#${offset:1:2} ))
    local mins=$(( 10#${offset:3:2} ))
    local total=$(( hours * 3600 + mins * 60 ))
    [[ "$sign" == "-" ]] && total=$(( -total ))
    echo "$total"
}

# Check if currently in daylight saving time
timedate::tz::is_dst() {
    local dst
    dst=$(date +%Z)
    # Most DST zones have a different abbreviation (EDT vs EST, BST vs GMT, etc.)
    # This is a heuristic — not universally reliable
    [[ "$dst" =~ DT$|BST|CEST|IST|NZDT|AEDT|AEST ]]
}

# List all available timezones
timedate::tz::list() {
    if [[ -d /usr/share/zoneinfo ]]; then
        find /usr/share/zoneinfo -type f -o -type l | \
            sed 's|/usr/share/zoneinfo/||' | \
            grep -v '^\.' | \
            sort
    elif runtime::has_command timedatectl; then
        timedatectl list-timezones 2>/dev/null
    else
        echo "timedate::tz::list: no timezone database found" >&2
        return 1
    fi
}

# List timezones filtered by region
# Usage: timedate::tz::list::region America
timedate::tz::list::region() {
    timedate::tz::list | grep "^${1}/"
}
