#!/usr/bin/env bash
# array.sh — bash-frameheader array lib
# Requires: runtime.sh (runtime::is_minimum_bash)
#
# USAGE NOTE: Bash arrays cannot be passed by value — callers must use
# nameref (Bash 4.3+) or pass elements as individual arguments.
# Functions that take arrays expect elements as "$@" unless noted.
#
# BASH 5 FEATURES: Some functions use associative array tricks or features
# only available in Bash 5+. These are guarded with runtime::is_minimum_bash 5
# and will print an error and return 1 if called on an older version.

# ==============================================================================
# CONSTRUCTION
# ==============================================================================

# Splits a string into elements based on a custom delimiter.
# Reach for this when processing structured data like CSV rows, 
# colon-separated config paths, or any string where spaces aren't 
# the primary separator.
#
# Usage: array::from_string delimiter input_string [output_array_name]
#   array::from_string "," "apple,banana,cherry" my_fruit_array
#
# Returns: echoes elements on new lines OR populates the named array; returns 0
#
# Example:
#   # Splitting a CSV line and storing it in a variable
#   csv_row="id,101,active,admin"
#   array::from_string "," "$csv_row" user_data
#   echo "Status: ${user_data[2]}"
#
# Note: If an array name is provided as the third argument, the 
# function uses 'readarray' to populate that variable in the 
# current shell environment. Without it, elements are printed to
# stdout, which is useful for piping into other commands.
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

# Converts a newline-delimited string into a set of individual elements.
# Reach for this when you have multiline output from a command or a 
# file (like a list of paths or usernames) and need to prepare it for 
# other array functions.
#
# Usage: array::from_lines "string_with_newlines"
#   array::from_lines "$(cat list.txt)"
#
# Returns: echoes each line as a separate element; returns 0
#
# Example:
#   # Converting a list of files into a format for array::contains
#   file_list=$(ls -1 *.log)
#   if array::contains "error.log" $(array::from_lines "$file_list"); then
#       echo "Error log found"
#   fi
#
# Note: This function temporarily sets IFS to a newline character 
# to ensure that spaces within a single line do not cause the line 
# to be split into multiple elements. Input is received as a single
# argument, so very large strings may hit shell argument length limits (ARG_MAX).
array::from_lines() {
    local IFS=$'\n'
    local -a parts=($1)
    printf '%s\n' "${parts[@]}"
}

# Generates a sequence of integers from a start value to an end value.
# Reach for this when you need to drive a loop with a specific 
# numeric range, create a list of indices, or generate a sequence 
# of ports or IDs.
#
# Usage: array::range start end [step]
#   array::range 1 10
#   array::range 0 100 20
#
# Returns: echoes each number in the range on a new line; returns 0
#
# Example:
#   # Generating even numbers up to 10
#   evens=$(array::range 2 10 2)
#   
#   # Using the range to run a task 5 times
#   for i in $(array::range 1 5); do
#       echo "Processing iteration $i..."
#   done
#
# Note: The 'step' argument is optional and defaults to 1. If 'start'
# is already greater than 'end', the function returns nothing.
#
# Tip: Unlike {start..end} brace expansion, this function 
# handles variables perfectly:
#   limit=10; array::range 1 "$limit"
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

# Returns the total number of elements in a list.
# Reach for this when you need to validate the size of a dataset 
# or check if a required number of arguments has been provided 
# before continuing a script.
#
# Usage: array::length element1 element2 ...
#   array::length "one" "two" "three"
#
# Returns: the numeric count of elements as an echoed string; returns 0
#
# Example:
#   # Checking if a script received the expected number of arguments
#   count=$(array::length "$@")
#   echo "Received $count arguments."
#
# Note: Counts arguments, not characters. A single quoted string containing
# spaces (e.g., "a b c") counts as 1. To count elements in an array,
# always expand it using "${my_array[@]}".
array::length() {
    echo "$#"
}

# Checks if a list contains zero elements.
# Reach for this when you need to skip logic that requires data 
# (e.g., avoiding a loop or preventing an API call if there are 
# no items to process).
#
# Usage: array::is_empty element1 element2 ...
#   if array::is_empty "${my_array[@]}"; then ...
#
# Returns: 0 if the list is empty, 1 if it contains at least one element
#
# Example:
#   # Guarding a process that requires input
#   files=(*.txt)
#   if array::is_empty "${files[@]}"; then
#       echo "No text files found to process."
#       exit 0
#   fi
#
# Note: Counts arguments, not string content. An array with a single empty
# string element (e.g. arr=("")) will return 1 (not empty) because one
# argument was still passed.
array::is_empty() {
    [[ "$#" -eq 0 ]]
}

# Checks if a specific value exists within a list of elements.
# Use this in conditional statements to determine if a value is 
# present before performing an action (e.g., checking if a flag is 
# in a list of arguments).
#
# Usage: array::contains needle element1 element2 ...
#   array::contains "target" "apple" "banana" "target"
#
# Returns: 0 if the value is found, 1 if not found
#
# Example:
#   # Checking if a user is in an allowed list
#   allowed=("admin" "moderator" "editor")
#   if array::contains "guest" "${allowed[@]}"; then
#       echo "Access granted"
#   else
#       echo "Access denied"
#   fi
#
# Note: The comparison is an exact match and is case-sensitive. 
# "Apple" will not match "apple".
array::contains() {
    local needle="$1"; shift
    local el
    for el in "$@"; do
        [[ "$el" == "$needle" ]] && return 0
    done
    return 1
}

# Finds the numerical position of the first occurrence of a value.
# Reach for this when you need to know *where* an item sits in a 
# list, perhaps to use that index to retrieve a corresponding 
# value from a different, parallel array.
#
# Usage: array::index_of needle element0 element1 ...
#   array::index_of "target" "apple" "target" "banana"
#
# Returns: echoes the 0-based index if found; echoes -1 and returns 1 if not found
#
# Example:
#   # Finding a user's position in a queue
#   queue=("alice" "bob" "charlie")
#   pos=$(array::index_of "bob" "${queue[@]}")
#   if [[ "$pos" -ge 0 ]]; then
#       echo "Bob is at position $pos"
#   fi
#
# Note: The search stops at the first match. Case-sensitive — "BOB"
# will not match "bob". Returns -1 and exit code 1 when not found,
# making it easy to use directly in 'if' statements.
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

# Returns the first element from a list of arguments.
# Use this when you only need the initial item from a collection, 
# such as the primary entry in a prioritized list or the first 
# result from a sorted set.
#
# Usage: array::first element1 element2 ...
#   array::first "primary" "secondary" "tertiary"
#
# Returns: echoes the first element; returns 0
#
# Example:
#   # Getting the most recent file from a sorted list
#   files=("file_c.txt" "file_b.txt" "file_a.txt")
#   latest=$(array::first "${files[@]}")
#
# Note: If no arguments are provided, the function echoes an empty string.
array::first() {
    echo "$1"
}

# Returns the very last element from a list of arguments.
# Use this when you need the final item in a sequence, such as 
# the most recently added entry or the tail end of a file path.
#
# Usage: array::last element1 element2 ... elementN
#   array::last "start" "middle" "end"
#
# Returns: echoes the last element; returns 0
#
# Example:
#   # Getting the last argument passed to a script
#   last_arg=$(array::last "$@")
#
# Note: If no arguments are provided, the function echoes an empty string.
#
# Tip: This is significantly faster than calculating the length 
# and subtracting one to access the index manually.
array::last() {
    eval echo "\${$#}"
}

# Retrieves a specific element from a list based on its position.
# Reach for this when you need to access data at a known offset, 
# such as getting the third column from a parsed CSV row or 
# accessing a specific configuration flag.
#
# Usage: array::get index element0 element1 element2 ...
#   array::get 1 "apple" "banana" "cherry"
#
# Returns: echoes the element at the specified index; returns 0
#
# Example:
#   # Accessing the second argument in a list
#   colors=("red" "green" "blue")
#   selected=$(array::get 1 "${colors[@]}")
#   echo "You chose: $selected"
#
# Note: Uses zero-based indexing ('0' is the first element). Out-of-bounds
# indices echo an empty string with no error.
#
# Tip: In Bash 4.2+, you can use negative indices (e.g., -1) to 
# access elements starting from the end of the array.
array::get() {
    local idx="$1"; shift
    local -a arr=("$@")
    echo "${arr[$idx]}"
}

# Counts how many times a specific value appears in a list.
# Reach for this when you need to calculate frequency or verify 
# multiple instances of an element (e.g., counting failed login 
# attempts in a log array).
#
# Usage: array::count_of needle element1 element2 ...
#   array::count_of "error" "info" "error" "warn" "error"
#
# Returns: the numeric count of occurrences as an echoed string; returns 0
#
# Example:
#   # Counting occurrences of a tag
#   tags=("bash" "shell" "bash" "script" "bash")
#   bash_count=$(array::count_of "bash" "${tags[@]}")
#   echo "Bash appeared $bash_count times."
#
# Note: Like other array functions in this module, the comparison 
# is an exact, case-sensitive match.
array::count_of() {
    local needle="$1" count=0; shift
    for el in "$@"; do
        [[ "$el" == "$needle" ]] && (( count++ ))
    done
    echo "$count"
}

# ==============================================================================
# TRANSFORMATION
# ==============================================================================

# Outputs each element on a new line to standardize list formatting.
# Reach for this when you need to hand off Bash array data to external 
# command-line utilities that expect one item per line (like sort, 
# grep, or wc).
#
# Usage: array::print element1 element2 ...
#   array::print "${my_array[@]}"
#
# Returns: echoes each element followed by a newline; returns 0
#
# Example:
#   # Sorting a Bash array and removing duplicates
#   fruits=("orange" "apple" "orange" "banana")
#   unique_fruits=$(array::print "${fruits[@]}" | sort | uniq)
#
# Note: This is a safer alternative to 'echo' because 'printf' 
# correctly handles elements that start with a hyphen (-) or 
# contain backslashes. Elements that themselves contain a newline
# will be split across multiple output lines.
array::print() {
    printf '%s\n' "$@"
}

# Reverses the sequence of elements in a list.
# Reach for this when you need to process items in reverse 
# chronological order, backtrack through a history log, or 
# invert a sorted list.
#
# Usage: array::reverse element1 element2 ...
#   array::reverse "first" "second" "third"
#
# Returns: echoes each element in reverse order on a new line; returns 0
#
# Example:
#   # Reversing a list of directory changes to "undo" them
#   steps=("cd /tmp" "mkdir test" "touch file")
#   undo_order=$(array::reverse "${steps[@]}")
#
# Note: This function creates a local copy of the array and 
# iterates backwards through the indices.
#
# Tip: This is often used in conjunction with 'sort' to perform 
# a reverse alphabetical or numeric sort if the standard 'sort -r' 
# isn't applicable to your specific data structure.
array::reverse() {
    local -a arr=("$@")
    local i
    for (( i=${#arr[@]}-1; i>=0; i-- )); do
        echo "${arr[$i]}"
    done
}

# Flattens a list by breaking multi-word elements into individual items.
# Use this when you have a collection of strings that might contain 
# space-separated values and you need to process every single word 
# as a standalone element.
#
# Usage: array::flatten element1 "element2 element3" ...
#   array::flatten "A B" "C" "D E F"
#
# Returns: echoes each word on a new line; returns 0
#
# Example:
#   # Merging mixed input sources into a flat list
#   tags=("web linux" "security" "devops cloud")
#   for tag in $(array::flatten "${tags[@]}"); do
#       echo "Tag: $tag"
#   done
#
# Note: This function relies on the shell's default word splitting 
# (IFS). It effectively "unquotes" space-separated strings.
#
# Warning: This will split elements containing any whitespace. If 
# you have an element like "Program Files" that must stay together, 
# do not use this function as it will result in "Program" and "Files".
array::flatten() {
    for el in "$@"; do
        for word in $el; do
            echo "$word"
        done
    done
}

# Extracts a subset of elements from a list starting at a specific index.
# Reach for this when you need to paginate data, grab a specific 
# "window" of results, or skip a fixed header to process 
# the remaining body of a list.
#
# Usage: array::slice start length element0 element1 ...
#   array::slice 1 2 "apple" "banana" "cherry" "date"
#
# Returns: echoes the sliced elements line by line; returns 0
#
# Example:
#   # Getting the first 3 items (index 0, length 3)
#   top_three=$(array::slice 0 3 "${results[@]}")
#
#   # Skipping the first item and taking the next two
#   middle_chunk=$(array::slice 1 2 "${results[@]}")
#
# Note: Uses zero-based indexing. If the requested length exceeds the
# available elements, Bash silently returns everything from the start
# index to the end of the array.
#
# Tip: To slice from a starting point all the way to the end 
# of the list, you can provide the total array length as the 
# second argument.
array::slice() {
    local start="$1" len="$2"; shift 2
    local -a arr=("$@")
    printf '%s\n' "${arr[@]:$start:$len}"
}

# Appends a new value to the end of a list.
# Reach for this when you are building a collection dynamically 
# or treating a list as a queue (FIFO) or stack (LIFO).
#
# Usage: array::push new_element existing_element1 existing_element2 ...
#   array::push "cherry" "apple" "banana"
#
# Returns: echoes the updated list (original elements + the new one); returns 0
#
# Example:
#   # Adding a new log file to a processing queue
#   queue=("log1.txt" "log2.txt")
#   queue=$(array::push "log3.txt" "${queue[@]}")
#
# Note: The new element is the first argument, and the existing 
# array elements follow it. To update an actual Bash array variable,
# capture the output with readarray.
#
# Tip: Unlike a standard 'push' in many languages, the new item 
# goes as the FIRST argument in the function call, but ends up 
# LAST in the output.
array::push() {
    local new="$1"; shift
    printf '%s\n' "$@" "$new"
}

# Removes the last element from a list and returns the remaining items.
# Reach for this when you are treating a list as a stack (LIFO) or 
# when you need to discard a trailing value, such as removing a 
# filename extension or a trailing metadata flag.
#
# Usage: array::pop element1 element2 ... elementN
#   array::pop "apple" "banana" "cherry"
#
# Returns: echoes the remaining elements line by line; returns 0
#
# Example:
#   # Removing the last directory from a path-like list
#   path_segments=(usr local bin)
#   parent_path=$(array::pop "${path_segments[@]}")
#
# Note: Requires Bash 4.3+ (uses negative index unset). If the input
# list has only one element, returns an empty string.
#
# Tip: To capture the result back into an array, use:
#   readarray -t new_array < <(array::pop "${old_array[@]}")
array::pop() {
    local -a arr=("$@")
    unset 'arr[-1]'
    printf '%s\n' "${arr[@]}"
}

# Prepends a new value to the beginning of a list.
# Reach for this when you need to prioritize a new item, add a 
# header to a data stream, or implement a stack where the "top" 
# is the first element.
#
# Usage: array::unshift new_element existing_element1 existing_element2 ...
#   array::unshift "zero" "one" "two" "three"
#
# Returns: echoes the updated list (new element followed by originals); returns 0
#
# Example:
#   # Adding a high-priority task to the front of a queue
#   tasks=("task1" "task2")
#   tasks=$(array::unshift "urgent_task" "${tasks[@]}")
#   # Result: urgent_task, task1, task2
#
# Note: Like array::push, the new element is the first argument, 
# and the existing array elements follow it. To update a Bash array
# variable, capture the output with readarray.
array::unshift() {
    local new="$1"; shift
    printf '%s\n' "$new" "$@"
}

# Removes the first element from a list and returns the rest.
# Reach for this when you are processing a queue (FIFO) or when 
# you need to discard a header, a command name, or a primary 
# key from a dataset.
#
# Usage: array::shift element1 element2 element3 ...
#   array::shift "first" "second" "third"
#
# Returns: echoes the remaining elements line by line; returns 0
#
# Example:
#   # Removing the script name from a list of arguments
#   args=("./run.sh" "upload" "file.txt")
#   params=$(array::shift "${args[@]}")
#   # Result: upload, file.txt
#
# Note: This is a direct wrapper around the Bash 'shift' builtin. 
# Passing only one element returns an empty string.
#
# Tip: To handle the shifted value and the remaining list 
# separately in your code:
#   first_item="$1"
#   remaining_items=$(array::shift "$@")
array::shift() {
    shift
    printf '%s\n' "$@"
}

# Deletes an element from a list based on its numerical position.
# Reach for this when you need to remove an item you've already 
# located (perhaps via 'array::index_of') or when managing 
# fixed-position data like columns in a row.
#
# Usage: array::remove_at index element0 element1 ...
#   array::remove_at 1 "apple" "banana" "cherry"
#
# Returns: echoes the remaining elements line by line; returns 0
#
# Example:
#   # Removing the second item from a list
#   items=("ticket_01" "ticket_02" "ticket_03")
#   remaining=$(array::remove_at 1 "${items[@]}")
#
# Note: Uses zero-based indexing. If the index exceeds the array length,
# the original list is returned unchanged.
array::remove_at() {
    local idx="$1" i=0; shift
    for el in "$@"; do
        [[ "$i" -ne "$idx" ]] && echo "$el"
        (( i++ ))
    done
}

# Deletes every instance of a specific value from a list.
# Reach for this when you need to scrub a known unwanted value, 
# such as removing a "placeholder" entry from a dataset or 
# withdrawing a specific user from an access list.
#
# Usage: array::remove target_value element1 element2 ...
#   array::remove "DELETE_ME" "keep1" "DELETE_ME" "keep2"
#
# Returns: echoes the remaining elements line by line; returns 0
#
# Example:
#   # Removing a specific directory from a PATH-like array
#   dirs=("/usr/bin" "/tmp" "/usr/local/bin")
#   clean_dirs=$(array::remove "/tmp" "${dirs[@]}")
#
# Note: Exact string match only — partial matches are not removed.
#
# Warning: Removes ALL occurrences of the target value, not just the first.
array::remove() {
    local target="$1"; shift
    for el in "$@"; do
        [[ "$el" != "$target" ]] && echo "$el"
    done
}

# Replaces an element at a specific index with a new value.
# Reach for this when you need to update a specific record in a 
# list, such as changing a status flag, updating a counter, 
# or correcting a specific entry in a configuration array.
#
# Usage: array::set index new_value element0 element1 ...
#   array::set 1 "banana" "apple" "original" "cherry"
#
# Returns: echoes the updated list line by line; returns 0
#
# Example:
#   # Updating a specific server status in a list
#   nodes=("node1:up" "node2:down" "node3:up")
#   nodes=$(array::set 1 "node2:up" "${nodes[@]}")
#
# Note: Uses zero-based indexing. If the index is out of bounds,
# the original list is returned unchanged.
#
# Tip: If the provided index is out of bounds (larger than the 
# list), the function will return the original list without 
# adding the new value.
array::set() {
    local idx="$1" val="$2" i=0; shift 2
    for el in "$@"; do
        [[ "$i" -eq "$idx" ]] && echo "$val" || echo "$el"
        (( i++ ))
    done
}

# Inserts a new value into a list at a specific index.
# Reach for this when you need to maintain a specific order but 
# need to inject an element into the middle of an existing sequence 
# (e.g., inserting a priority task into a job queue).
#
# Usage: array::insert_at index value element0 element1 ...
#   array::insert_at 1 "new_item" "first" "second"
#
# Returns: echoes the new sequence of elements line by line; returns 0
#
# Example:
#   # Injecting a middle name into a list
#   names=("John" "Doe")
#   full_name=$(array::insert_at 1 "Quincy" "${names[@]}")
#
# Note: If the index provided is greater than or equal to the number 
# of elements, the new value will be appended to the end of the list.
#
# Tip: Using an index of 0 will effectively prepend the value to 
# the beginning of the list.
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

# ==============================================================================
# FILTERING
# ==============================================================================

# Filters a list of elements by keeping only those that match a regular expression.
# Reach for this when you need to extract specific items from a larger 
# collection, such as finding all filenames with a certain extension 
# or identifying strings that follow a specific naming convention.
#
# Usage: array::filter regex element1 element2 ...
#   array::filter "^user_" "user_alice" "admin_bob" "user_charlie"
#
# Returns: echoes each matching element on a new line; returns 0
#
# Example:
#   # Extracting log entries that contain "ERROR" or "CRITICAL"
#   logs=("INFO: ok" "ERROR: fail" "DEBUG: trace" "CRITICAL: halt")
#   failures=$(array::filter "ERROR|CRITICAL" "${logs[@]}")
#
# Note: Uses Bash's native regular expression operator (=~), which
# follows Extended Regular Expression (ERE) syntax.
#
# Warning: An invalid or unescaped regex pattern may cause silent
# failures or unexpected matches. Test complex patterns separately.
array::filter() {
    local regex="$1"; shift
    for el in "$@"; do
        [[ "$el" =~ $regex ]] && echo "$el"
    done
}

# Excludes elements that match a specific regular expression.
# Reach for this when you want to "blacklist" certain items, such as 
# removing hidden files (starting with .) from a list or filtering 
# out error logs from a status report.
#
# Usage: array::reject "regex" element1 element2 ...
#   array::reject "^temp_" "temp_file.txt" "real_file.txt"
#
# Returns: echoes non-matching elements line by line; returns 0
#
# Example:
#   # Filtering out system accounts (starting with '_')
#   users=("admin" "_spotlight" "guest" "_www")
#   human_users=$(array::reject "^_" "${users[@]}")
#
# Note: Uses Bash's native ERE regex via (=~). Provide the regex as
# a variable reference, not a quoted pattern, for reliable matching.
#
# Tip: This is the perfect companion to 'array::filter'. Use 
# 'filter' to keep what you want, and 'reject' to throw away 
# what you don't.
array::reject() {
    local regex="$1"; shift
    for el in "$@"; do
        [[ ! "$el" =~ $regex ]] && echo "$el"
    done
}
# Filters out empty strings from a list of elements.
# Reach for this when processing data that might contain "holes" or 
# null values, ensuring only valid data is passed to the next step.
#
# Usage: array::compact element1 "" element2 " " element3
#   array::compact "${my_array[@]}"
#
# Returns: echoes each non-empty element on a new line; returns 0
#
# Example:
#   # Removing empty entries from a list of user-provided tags
#   tags=("bash" "" "linux" "" "coding")
#   clean_tags=$(array::compact "${tags[@]}")
#
# Note: Checks for non-zero string length. A string containing only
# whitespace (like " ") is technically non-empty and will be preserved.
# Elements containing newline characters will be split into multiple lines.
array::compact() {
    for el in "$@"; do
        [[ -n "$el" ]] && echo "$el"
    done
}

# ==============================================================================
# AGGREGATION
# ==============================================================================

# Combines multiple elements into a single string separated by a delimiter.
# Reach for this when you need to format data for output, such as 
# creating a comma-separated list for a report or building a 
# colon-separated PATH variable.
#
# Usage: array::join delimiter element1 element2 ...
#   array::join ", " "apple" "banana" "cherry"
#
# Returns: echoes the joined string; returns 0
#
# Example:
#   # Creating a comma-separated list of IDs
#   ids=(101 102 103)
#   id_string=$(array::join "," "${ids[@]}")
#   echo "Selected IDs: $id_string"
#
# Note: The delimiter is only placed *between* elements, not at the
# start or end. If elements already contain the delimiter character,
# the resulting string may be ambiguous to split later.
#
# Tip: You can pass an empty string as the delimiter if you want to 
# concatenate elements directly together with no separation.   
array::join() {
    local delim="$1" result="" first=true; shift
    for el in "$@"; do
        if $first; then result="$el"; first=false
        else result+="${delim}${el}"; fi
    done
    echo "$result"
}

# Calculates the total sum of all numeric elements in a list.
# Reach for this when you need to aggregate data, such as totaling 
# file sizes, counting the number of occurrences across multiple 
# logs, or calculating the final result of a numeric sequence.
#
# Usage: array::sum number1 number2 number3 ...
#   array::sum 10 20 30
#
# Returns: echoes the final integer total; returns 0
#
# Example:
#   # Adding up a list of storage usage values (in GB)
#   usage=(15 40 10 5)
#   total_used=$(array::sum "${usage[@]}")
#   echo "Total disk usage: ${total_used}GB"
#
# Note: Uses Bash arithmetic ($(( ))). Integers only — no floating-point
# support. Non-numeric strings may be treated as 0 or as variable names.
array::sum() {
    local total=0
    for el in "$@"; do
        total=$(( total + el ))
    done
    echo "$total"
}

# Finds the smallest number in a list of elements.
# Reach for this when you need to find a minimum threshold, such as 
# identifying the lowest available port, the oldest timestamp, 
# or the minimum free space in a set of drives.
#
# Usage: array::min number1 number2 number3 ...
#   array::min 10 55 23 8
#
# Returns: the lowest numeric value as an echoed string; returns 0
#
# Example:
#   # Finding the lowest latency in a set of pings
#   latencies=(45 12 88 34)
#   best_ping=$(array::min "${latencies[@]}")
#   echo "Lowest latency: ${best_ping}ms"
#
# Note: Uses Bash arithmetic. Integers only. Assumes the first argument
# is a valid number as the initial baseline. Returns empty if called
# with no arguments.
array::min() {
    local min="$1"; shift
    for el in "$@"; do
        (( el < min )) && min="$el"
    done
    echo "$min"
}

# Finds the largest number in a list of elements.
# Reach for this when you need to determine a peak value, such as 
# identifying the highest process ID, the most recent timestamp, 
# or the maximum disk usage percentage in a set of readings.
#
# Usage: array::max number1 number2 number3 ...
#   array::max 10 55 23 8
#
# Returns: the highest numeric value as an echoed string; returns 0
#
# Example:
#   # Finding the highest score in a list
#   scores=(88 92 75 99 84)
#   top_score=$(array::max "${scores[@]}")
#   echo "The winning score is $top_score"
#
# Note: Uses Bash arithmetic. Integers only. Assumes the first argument
# is a valid number as the initial baseline. Non-numeric strings may
# be treated as 0 or variable names.
array::max() {
    local max="$1"; shift
    for el in "$@"; do
        (( el > max )) && max="$el"
    done
    echo "$max"
}

# ==============================================================================
# SET OPERATIONS
# ==============================================================================

# Returns elements that are present in both the first and second list.
# Reach for this when you need to find commonalities between two 
# datasets, such as identifying users who belong to two different 
# groups or finding files that exist in both a source and a backup.
#
# Usage: array::intersect "list 1" "list 2"
#   array::intersect "apple banana cherry" "banana cherry date"
#
# Returns: echoes each common element on a new line; returns 0
#
# Example:
#   # Finding common dependencies between two projects
#   proj_a="curl git jq"
#   proj_b="git vim jq"
#   common=$(array::intersect "$proj_a" "$proj_b")
#
# Note: Exact, case-sensitive match. Uses a nested loop (O(n*m)).
#
# Warning: Expects two quoted, space-separated strings — not expanded
# arrays. Passing "${arr[@]}" will only compare the first elements.
array::intersect() {
    local -a a=($1) b=($2)
    for el in "${a[@]}"; do
        for other in "${b[@]}"; do
            [[ "$el" == "$other" ]] && echo "$el" && break
        done
    done
}

# Returns elements present in the first list but absent from the second.
# Reach for this when comparing two sets of data to find "missing" 
# items or to calculate the delta between a current state and a target state.
#
# Usage: array::diff "space separated list 1" "space separated list 2"
#   array::diff "apple banana cherry" "banana date"
#
# Returns: echoes each unique element on a new line; returns 0
#
# Example:
#   # Finding which required packages are not yet installed
#   required="curl git vim"
#   installed="git tmux"
#   array::diff "$required" "$installed"
#
# Note: Exact, case-sensitive match. Uses a nested loop (O(n*m)).
#
# Warning: Expects two quoted, space-separated strings — not expanded
# arrays. Passing "${arr[@]}" will only process the first element.
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

# Merges two lists and removes any duplicate elements.
# Reach for this when you need to combine two sources of data—such 
# as two server lists or two sets of IDs—into a single master list 
# where no item is repeated.
#
# Usage: array::union "list1" "list2"
#   array::union "${array_a[*]}" "${array_b[*]}"
#
# Returns: echoes the unique combined elements line by line; returns 0
#
# Example:
#   # Combining two sets of authorized users
#   admins="alice bob"
#   editors="bob charlie"
#   all_staff=$(array::union "$admins" "$editors")
#   # Result: alice, bob, charlie
#
# Note: Expects two space-separated strings as arguments.
#
# Warning: Elements containing internal spaces will be split
# incorrectly when the strings are expanded into arrays.
array::union() {
    local -a a=($1) b=($2)
    array::unique "${a[@]}" "${b[@]}"
}

# ==============================================================================
# SORTING
# ==============================================================================

# Sorts elements in ascending alphabetical order.
# Reach for this when you need to organize a list for human 
# readability, prepare data for unique filtering, or ensure 
# consistent output regardless of the input order.
#
# Usage: array::sort element1 element2 ...
#   array::sort "cherry" "apple" "banana"
#
# Returns: echoes the sorted elements line by line; returns 0
#
# Example:
#   # Alphabetizing a list of names
#   names=("Zoe" "Adam" "Charlie")
#   sorted_names=$(array::sort "${names[@]}")
#
# Note: Uses the system 'sort' command, so output order depends on
# your LC_COLLATE locale setting. This is an alphabetical sort —
# for numeric sorting use array::sort::numeric.
#
# Tip: Combine this with 'array::unique' to get a sorted list 
# of distinct values.
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

# Checks if two lists are identical in both content and order.
# Reach for this when you need to verify that a sequence of items 
# remains unchanged, such as comparing a current configuration 
# against a known-good baseline.
#
# Usage: array::equals "list 1" "list 2"
#   array::equals "red green blue" "red green blue"
#
# Returns: 0 if lists are identical; 1 if lengths or contents differ
#
# Example:
#   # Verifying step-by-step process results
#   expected="step1 step2 step3"
#   actual="step1 step2 step4"
#   if array::equals "$expected" "$actual"; then
#       echo "Sequence verified."
#   else
#       echo "Sequence mismatch detected!"
#   fi
#
# Note: Requires an exact match for every element at every index.
# Same elements in a different order will return 1.
#
# Warning: Expects two quoted, space-separated strings — not expanded
# arrays. Passing "${arr[@]}" will not work as intended.

array::equals() {
    local -a a=($1) b=($2)
    [[ "${#a[@]}" -ne "${#b[@]}" ]] && return 1
    local i
    for (( i=0; i<${#a[@]}; i++ )); do
        [[ "${a[$i]}" != "${b[$i]}" ]] && return 1
    done
    return 0
}

# Pairs elements from two lists by their index.
# Reach for this when you have two related sets of data—such as 
# keys and values, or filenames and their sizes—and you need to 
# process them as single, space-separated records.
#
# Usage: array::zip "list1" "list2"
#   array::zip "${keys[*]}" "${values[*]}"
#
# Returns: echoes pairs (element_a element_b) line by line; returns 0
#
# Example:
#   # Mapping users to their respective home directories
#   users="alice bob"
#   homes="/home/alice /home/bob"
#   mapping=$(array::zip "$users" "$homes")
#   # Result:
#   # alice /home/alice
#   # bob /home/bob
#
# Note: Uses "shortest-wins" logic — stops at the end of the shorter list.
#
# Warning: Expects space-separated strings. Elements containing internal
# spaces will be split incorrectly when expanded into arrays.
#
# Tip: To process the results of a zip in a loop:
#   while read -r key val; do
#       echo "User $key lives at $val"
#   done < <(array::zip "$users" "$homes")
array::zip() {
    local -a a=($1) b=($2)
    local len=$(( ${#a[@]} < ${#b[@]} ? ${#a[@]} : ${#b[@]} ))
    local i
    for (( i=0; i<len; i++ )); do
        echo "${a[$i]} ${b[$i]}"
    done
}

# Shifts elements to the left by a specified number of positions.
# Reach for this when you need to reorder a circular queue, cycle 
# through a list of servers for load balancing, or implement 
# simple sliding window logic.
#
# Usage: array::rotate n element1 element2 ...
#   array::rotate 1 "a" "b" "c" "d"
#
# Returns: echoes the rotated elements line by line; returns 0
#
# Example:
#   # Rotating a list of backup servers to pick a new primary
#   servers=("srv1" "srv2" "srv3")
#   new_order=$(array::rotate 1 "${servers[@]}")
#   # Result: srv2 srv3 srv1
#
# Note: Uses modulo so rotating by more than the array length wraps
# correctly. Only rotates left — to rotate right, subtract the
# desired shift from the total length.
#
# Tip: Providing a rotation of 0 or a multiple of the array's 
# length will return the list in its original order.
array::rotate() {
    local n="$1"; shift
    local -a arr=("$@")
    local len="${#arr[@]}"
    n=$(( n % len ))
    printf '%s\n' "${arr[@]:$n}" "${arr[@]:0:$n}"
}

# Splits an array into smaller arrays of a specified size.
# Use this when you need to process a large list of items in smaller, 
# manageable batches (e.g., sending 10 API requests at a time).
#
# Usage: array::chunk size element1 element2 ...
#   array::chunk 2 "apple" "banana" "cherry" "date" "elderberry"
#
# Returns: echoes each chunk as a space-separated string on a new line; returns 0
#
# Example:
#   # Processing users in batches of 3
#   users=("alice" "bob" "charlie" "david" "eve")
#   array::chunk 3 "${users[@]}" | while read -r batch; do
#       echo "Processing batch: $batch"
#   done
#
# Note: If the total element count isn't evenly divisible by the chunk
# size, the final chunk contains the remainder. Elements with internal
# spaces may be difficult to parse in the space-separated output.
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
# ==============================================================================
# BASH 5+ FEATURES
# ==============================================================================

# Filters out duplicate values from a list while keeping the first 
# instance of each.
# Reach for this when you need a "clean" list of unique items—such 
# as unique IP addresses from a log or a list of distinct 
# contributors—without shuffling their original sequence.
#
# Usage: array::unique element1 element2 element3 ...
#   array::unique "apple" "banana" "apple" "cherry"
#
# Returns: echoes each unique element on a new line; returns 0
#
# Example:
#   # Deduplicating a path list while keeping the priority order
#   raw_paths=("/usr/bin" "/bin" "/usr/bin" "/usr/local/bin")
#   clean_paths=$(array::unique "${raw_paths[@]}")
#   # Result: /usr/bin, /bin, /usr/local/bin
#
# Note: Uses an associative array for O(n) lookup, so it's efficient
# on large datasets. Requires Bash 4.0+ (associative arrays).
#
# Tip: Because it preserves order, it is often superior to 
# 'sort -u' if the sequence of your data carries meaning (like 
# search priorities or chronological events).
array::unique() {
    local -A seen=()
    for el in "$@"; do
        if [[ -z "${seen[$el]+x}" ]]; then
            seen["$el"]=1
            echo "$el"
        fi
    done
}
