# `array`

Array manipulation — construction, inspection, transformation, filtering, aggregation, set operations, and sorting. **42 functions.** Most have `::fast` variants that use namerefs to avoid subshell overhead. Functions operate on positional arguments (elements passed as `"$@"`).

---

## Input Convention

Array functions operate on elements passed as arguments — you expand your array with `"${arr[@]}"`:

```bash
my_arr=(apple banana cherry)
array::length "${my_arr[@]}"       # → 3
array::contains "banana" "${my_arr[@]}"  # → true
```

Fast variants write results to a nameref variable without forking:

```bash
array::reverse::fast reversed "${my_arr[@]}"
echo "${reversed[@]}"  # → cherry banana apple
```

---

## Construction

| Function | Description |
|----------|-------------|
| `array::from_string` | Build an array from a delimited string |
| `array::from_lines` | Build an array from newline-delimited input |
| `array::range` | Build a range of integers |

```bash
readarray -t arr < <(array::from_string "," "a,b,c")
readarray -t arr < <(array::range 1 10 2)  # → 1 3 5 7 9
```

## Inspection

| Function | Description | Fast |
|----------|-------------|------|
| `array::length` | Number of elements | `::fast` |
| `array::is_empty` | Check if array is empty | — |
| `array::contains` | Check if array contains a value | — |
| `array::index_of` | Return index of first match (-1 if not found) | `::fast` |
| `array::first` | Return first element | `::fast` |
| `array::last` | Return last element | `::fast` |
| `array::get` | Return element at index | `::fast` |
| `array::count_of` | Count occurrences of a value | `::fast` |

```bash
array::first "${my_arr[@]}"           # → apple
array::index_of "cherry" "${my_arr[@]}"  # → 2
array::count_of "apple" "${my_arr[@]}"   # → 1
```

## Transformation

| Function | Description | Fast |
|----------|-------------|------|
| `array::print` | Print each element on its own line | — |
| `array::reverse` | Reverse order of elements | `::fast` |
| `array::flatten` | Flatten one level — splits elements by whitespace | — |
| `array::slice` | Slice a subarray by start and length | `::fast` |
| `array::push` | Append elements | `::fast` |
| `array::pop` | Remove last element | `::fast` |
| `array::unshift` | Prepend an element | `::fast` |
| `array::shift` | Remove first element | `::fast` |
| `array::remove_at` | Remove element at index | `::fast` |
| `array::remove` | Remove all occurrences of a value | `::fast` |
| `array::set` | Replace element at index with new value | `::fast` |
| `array::insert_at` | Insert element at index | `::fast` |

```bash
array::slice 1 2 "${my_arr[@]}"     # → banana cherry
array::push "date" "${my_arr[@]}"   # → apple banana cherry date
array::shift "${my_arr[@]}"         # → banana cherry
```

## Filtering

| Function | Description | Fast |
|----------|-------------|------|
| `array::filter` | Keep elements matching a regex | `::fast` |
| `array::reject` | Remove elements matching a regex | `::fast` |
| `array::compact` | Remove empty elements | `::fast` |

```bash
array::filter "^b" "${my_arr[@]}"    # → banana
array::compact "" "a" "" "b"         # → a b
```

## Aggregation

| Function | Description | Fast |
|----------|-------------|------|
| `array::join` | Join elements with a delimiter | `::fast` |
| `array::sum` | Sum all numeric elements | `::fast` |
| `array::min` | Minimum value (numeric) | `::fast` |
| `array::max` | Maximum value (numeric) | `::fast` |

```bash
array::join ", " "${my_arr[@]}"       # → "apple, banana, cherry"
array::sum 1 2 3 4 5                  # → 15
array::max 3 1 4 1 5 9               # → 9
```

## Set Operations

Each set operation takes arrays as single space-separated string arguments.

| Function | Description | Fast |
|----------|-------------|------|
| `array::intersect` | Intersection — elements in both arrays | `::fast` |
| `array::diff` | Difference — elements in first not in second | `::fast` |
| `array::union` | Union — all unique elements from both | `::fast` |
| `array::unique` | Remove duplicates (preserves first occurrence order) | `::fast` |

```bash
array::intersect "a b c" "b c d"      # → b c
array::diff "a b c" "b c d"           # → a
array::union "a b" "b c"              # → a b c
array::unique "a b a c b"             # → a b c
```

## Sorting

| Function | Description |
|----------|-------------|
| `array::sort` | Sort elements alphabetically |
| `array::sort::reverse` | Sort in reverse alphabetical order |
| `array::sort::numeric` | Sort elements numerically |
| `array::sort::numeric_reverse` | Sort numerically in reverse |

```bash
array::sort 3 1 4 1 5               # → 1 1 3 4 5
array::sort::numeric 10 2 1         # → 1 2 10
array::sort::numeric_reverse 10 2 1 # → 10 2 1
```

## Advanced

| Function | Description | Fast |
|----------|-------------|------|
| `array::equals` | Check if two arrays are equal (same elements, same order) | `::fast` |
| `array::zip` | Zip two arrays — pairs elements by index | `::fast` |
| `array::rotate` | Rotate array left by n positions | `::fast` |
| `array::chunk` | Chunk array into groups of n | `::fast` |

```bash
array::equals "a b c" "a b c"        # → true (exit code 0)
array::zip "a b" "1 2"               # → a 1⏎b 2 (each pair on own line)
array::rotate 2 "a b c d e"          # → c d e a b
array::chunk 3 "a b c d e f g"       # → a b c⏎d e f⏎g
```

## Dependencies

- **Requires**: `runtime`
- **Bash 5.0+** required for `array::unique::fast` (uses associative arrays)
