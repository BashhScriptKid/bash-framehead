# Function Dictionary

Alphabetical index of all functions in bash-framehead. **1117 functions** across 18 modules.

Per-module listings: [`array`](array.md), [`colour`](colour.md), [`device`](device.md), [`fs`](fs.md), [`git`](git.md), [`hardware`](hardware.md), [`hash`](hash.md), [`log`](log.md), [`math`](math.md), [`net`](net.md), [`pfloat`](pfloat.md), [`pm`](pm.md), [`process`](process.md), [`random`](random.md), [`runtime`](runtime.md), [`string`](string.md), [`terminal`](terminal.md), [`timedate`](timedate.md)


## A

| Function | Signature | Module | Description |
|----------|-----------|--------|-------------|
| [`array::chunk`](array/chunk.md) | `array::chunk(size, el1, el2, ...)` | [`array`](array.md) | Chunk array into groups of n |
| [`array::chunk::fast`](array/chunk/fast.md) | `array::chunk::fast(result_arr, size, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::compact`](array/compact.md) | `array::compact(el1, el2, ...)` | [`array`](array.md) | Return only elements that are non-empty |
| [`array::compact::fast`](array/compact/fast.md) | `array::compact::fast(result_arr, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::contains`](array/contains.md) | `array::contains(needle, el1, el2, ...)` | [`array`](array.md) | Check if array contains a value |
| [`array::count_of`](array/count_of.md) | `array::count_of(needle, el1, el2, ...)` | [`array`](array.md) | Count occurrences of a value |
| [`array::count_of::fast`](array/count_of/fast.md) | `array::count_of::fast(result_var, needle, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::diff`](array/diff.md) | `array::diff(el1, el2, el3, el2, el3, el4)` | [`array`](array.md) | Difference — elements in first array not in second |
| [`array::diff::fast`](array/diff/fast.md) | `array::diff::fast(result_arr, el1, el2, el3, el2, el3, el4)` | [`array`](array.md) | Fast variant using nameref |
| [`array::equals`](array/equals.md) | `array::equals(el1, el2, el1, el2)` | [`array`](array.md) | Check if two arrays are equal (same elements, same order) |
| [`array::equals::fast`](array/equals/fast.md) | `array::equals::fast(result_var, el1, el2, el1, el2)` | [`array`](array.md) | Fast variant using nameref |
| [`array::filter`](array/filter.md) | `array::filter(regex, el1, el2, ...)` | [`array`](array.md) | Filter elements matching a regex |
| [`array::filter::fast`](array/filter/fast.md) | `array::filter::fast(result_arr, regex, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::first`](array/first.md) | `array::first(el1, el2, ...)` | [`array`](array.md) | Return first element |
| [`array::first::fast`](array/first/fast.md) | `array::first::fast(result_var, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::flatten`](array/flatten.md) | `array::flatten(el1, el2a, el2b, el3)` | [`array`](array.md) | Flatten one level — splits each element by whitespace |
| [`array::from_lines`](array/from_lines.md) | `array::from_lines(line1\nline2\nline3)` | [`array`](array.md) | Build an array from lines of stdin or a string (newline-delimited) |
| [`array::from_string`](array/from_string.md) | `array::from_string(delimiter, string)` | [`array`](array.md) | Build an array from a delimited string |
| [`array::get`](array/get.md) | `array::get(index, el1, el2, ...)` | [`array`](array.md) | Return element at index |
| [`array::get::fast`](array/get/fast.md) | `array::get::fast(result_var, index, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::index_of`](array/index_of.md) | `array::index_of(needle, el1, el2, ...)` | [`array`](array.md) | Return index of first match (-1 if not found) |
| [`array::index_of::fast`](array/index_of/fast.md) | `array::index_of::fast(result_var, needle, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::insert_at`](array/insert_at.md) | `array::insert_at(index, value, el1, el2, ...)` | [`array`](array.md) | Insert element at index |
| [`array::insert_at::fast`](array/insert_at/fast.md) | `array::insert_at::fast(result_arr, index, value, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::intersect`](array/intersect.md) | `array::intersect(el1, el2, el3, el2, el3, el4)` | [`array`](array.md) | Intersection — elements present in both arrays |
| [`array::intersect::fast`](array/intersect/fast.md) | `array::intersect::fast(result_arr, el1, el2, el3, el2, el3, el4)` | [`array`](array.md) | Fast variant using nameref |
| [`array::is_empty`](array/is_empty.md) | `array::is_empty($@)` | [`array`](array.md) | Check if array is empty |
| [`array::join`](array/join.md) | `array::join(delimiter, el1, el2, ...)` | [`array`](array.md) | Join elements with a delimiter |
| [`array::join::fast`](array/join/fast.md) | `array::join::fast(result_var, delimiter, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::last`](array/last.md) | `array::last(el1, el2, ...)` | [`array`](array.md) | Return last element |
| [`array::last::fast`](array/last/fast.md) | `array::last::fast(result_var, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::length`](array/length.md) | `array::length(el1, el2, ...)` | [`array`](array.md) | Number of elements |
| [`array::length::fast`](array/length/fast.md) | `array::length::fast(result_var, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::max`](array/max.md) | `array::max(el1, el2, ...)` | [`array`](array.md) | Maximum value (numeric) |
| [`array::max::fast`](array/max/fast.md) | `array::max::fast(result_var, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::min`](array/min.md) | `array::min(el1, el2, ...)` | [`array`](array.md) | Minimum value (numeric) |
| [`array::min::fast`](array/min/fast.md) | `array::min::fast(result_var, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::pop`](array/pop.md) | `array::pop(el1, el2, ...)` | [`array`](array.md) | Remove last element |
| [`array::pop::fast`](array/pop/fast.md) | `array::pop::fast(result_arr, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::print`](array/print.md) | `array::print()` | [`array`](array.md) | Print each element on its own line (normalise for piping) |
| [`array::push`](array/push.md) | `array::push(new_el, el1, el2, ...)` | [`array`](array.md) | Append elements (print existing + new) |
| [`array::push::fast`](array/push/fast.md) | `array::push::fast(result_arr, new_el, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::range`](array/range.md) | `array::range(start, end, [step])` | [`array`](array.md) | Build a range of integers |
| [`array::reject`](array/reject.md) | `array::reject(regex, el1, el2, ...)` | [`array`](array.md) | Filter elements NOT matching a regex |
| [`array::reject::fast`](array/reject/fast.md) | `array::reject::fast(result_arr, regex, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::remove`](array/remove.md) | `array::remove(value, el1, el2, ...)` | [`array`](array.md) | Remove all occurrences of a value |
| [`array::remove_at`](array/remove_at.md) | `array::remove_at(index, el1, el2, ...)` | [`array`](array.md) | Remove element at index |
| [`array::remove_at::fast`](array/remove_at/fast.md) | `array::remove_at::fast(result_arr, index, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::remove::fast`](array/remove/fast.md) | `array::remove::fast(result_arr, value, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::reverse`](array/reverse.md) | `array::reverse(el1, el2, ...)` | [`array`](array.md) | Reverse order of elements |
| [`array::reverse::fast`](array/reverse/fast.md) | `array::reverse::fast(result_arr, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::rotate`](array/rotate.md) | `array::rotate(n, el1, el2, ...)` | [`array`](array.md) | Rotate array left by n positions |
| [`array::rotate::fast`](array/rotate/fast.md) | `array::rotate::fast(result_arr, n, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::set`](array/set.md) | `array::set(index, value, el1, el2, ...)` | [`array`](array.md) | Replace element at index with new value |
| [`array::set::fast`](array/set/fast.md) | `array::set::fast(result_arr, index, value, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::shift`](array/shift.md) | `array::shift(el1, el2, ...)` | [`array`](array.md) | Remove first element |
| [`array::shift::fast`](array/shift/fast.md) | `array::shift::fast(result_arr, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::slice`](array/slice.md) | `array::slice(start, length, el1, el2, ...)` | [`array`](array.md) | Slice a subarray |
| [`array::slice::fast`](array/slice/fast.md) | `array::slice::fast(result_arr, start, length, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::sort`](array/sort.md) | `array::sort(el1, el2, ...)` | [`array`](array.md) | Sort elements alphabetically |
| [`array::sort::numeric`](array/sort/numeric.md) | `array::sort::numeric()` | [`array`](array.md) | Sort elements numerically |
| [`array::sort::numeric_reverse`](array/sort/numeric_reverse.md) | `array::sort::numeric_reverse()` | [`array`](array.md) | Sort elements numerically in reverse |
| [`array::sort::reverse`](array/sort/reverse.md) | `array::sort::reverse()` | [`array`](array.md) | Sort elements in reverse |
| [`array::sum`](array/sum.md) | `array::sum(el1, el2, ...)` | [`array`](array.md) | Sum all numeric elements |
| [`array::sum::fast`](array/sum/fast.md) | `array::sum::fast(result_var, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::union`](array/union.md) | `array::union(el1, el2, el2, el3)` | [`array`](array.md) | Union — all unique elements from both arrays |
| [`array::union::fast`](array/union/fast.md) | `array::union::fast(result_arr, el1, el2, el2, el3)` | [`array`](array.md) | Fast variant using nameref |
| [`array::unique`](array/unique.md) | `array::unique(el1, el2, ...)` | [`array`](array.md) | Remove duplicate elements (preserves first occurrence order) |
| [`array::unique::fast`](array/unique/fast.md) | `array::unique::fast(result_arr, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref (Bash 5+) |
| [`array::unshift`](array/unshift.md) | `array::unshift(new_el, el1, el2, ...)` | [`array`](array.md) | Prepend an element |
| [`array::unshift::fast`](array/unshift/fast.md) | `array::unshift::fast(result_arr, new_el, el1, el2, ...)` | [`array`](array.md) | Fast variant using nameref |
| [`array::zip`](array/zip.md) | `array::zip(a1, a2, a3, b1, b2, b3)` | [`array`](array.md) | Zip two arrays together — pairs elements by index |
| [`array::zip::fast`](array/zip/fast.md) | `array::zip::fast(result_arr, a1, a2, a3, b1, b2, b3)` | [`array`](array.md) | Fast variant using nameref |

## C

| Function | Signature | Module | Description |
|----------|-----------|--------|-------------|
| [`colour::bg::black`](colour/bg/black.md) | `colour::bg::black()` | [`colour`](colour.md) | Background |
| [`colour::bg::blue`](colour/bg/blue.md) | `colour::bg::blue()` | [`colour`](colour.md) | _No description available._ |
| [`colour::bg::bright_black`](colour/bg/bright_black.md) | `colour::bg::bright_black()` | [`colour`](colour.md) | _No description available._ |
| [`colour::bg::bright_blue`](colour/bg/bright_blue.md) | `colour::bg::bright_blue()` | [`colour`](colour.md) | _No description available._ |
| [`colour::bg::bright_cyan`](colour/bg/bright_cyan.md) | `colour::bg::bright_cyan()` | [`colour`](colour.md) | _No description available._ |
| [`colour::bg::bright_green`](colour/bg/bright_green.md) | `colour::bg::bright_green()` | [`colour`](colour.md) | _No description available._ |
| [`colour::bg::bright_magenta`](colour/bg/bright_magenta.md) | `colour::bg::bright_magenta()` | [`colour`](colour.md) | _No description available._ |
| [`colour::bg::bright_red`](colour/bg/bright_red.md) | `colour::bg::bright_red()` | [`colour`](colour.md) | _No description available._ |
| [`colour::bg::bright_white`](colour/bg/bright_white.md) | `colour::bg::bright_white()` | [`colour`](colour.md) | _No description available._ |
| [`colour::bg::bright_yellow`](colour/bg/bright_yellow.md) | `colour::bg::bright_yellow()` | [`colour`](colour.md) | _No description available._ |
| [`colour::bg::cyan`](colour/bg/cyan.md) | `colour::bg::cyan()` | [`colour`](colour.md) | _No description available._ |
| [`colour::bg::green`](colour/bg/green.md) | `colour::bg::green()` | [`colour`](colour.md) | _No description available._ |
| [`colour::bg::magenta`](colour/bg/magenta.md) | `colour::bg::magenta()` | [`colour`](colour.md) | _No description available._ |
| [`colour::bg::red`](colour/bg/red.md) | `colour::bg::red()` | [`colour`](colour.md) | _No description available._ |
| [`colour::bg::white`](colour/bg/white.md) | `colour::bg::white()` | [`colour`](colour.md) | _No description available._ |
| [`colour::bg::yellow`](colour/bg/yellow.md) | `colour::bg::yellow()` | [`colour`](colour.md) | _No description available._ |
| [`colour::blink`](colour/blink.md) | `colour::blink()` | [`colour`](colour.md) | _No description available._ |
| [`colour::bold`](colour/bold.md) | `colour::bold()` | [`colour`](colour.md) | _No description available._ |
| [`colour::depth`](colour/depth.md) | `colour::depth()` | [`colour`](colour.md) | Return the number of colours the terminal supports |
| [`colour::dim`](colour/dim.md) | `colour::dim()` | [`colour`](colour.md) | _No description available._ |
| [`colour::esc`](colour/esc.md) | `colour::esc(bit, fg_bg, colour, [colour...])` | [`colour`](colour.md) | Generate a raw ANSI escape sequence |
| [`colour::fg::black`](colour/fg/black.md) | `colour::fg::black()` | [`colour`](colour.md) | Foreground |
| [`colour::fg::blue`](colour/fg/blue.md) | `colour::fg::blue()` | [`colour`](colour.md) | _No description available._ |
| [`colour::fg::bright_black`](colour/fg/bright_black.md) | `colour::fg::bright_black()` | [`colour`](colour.md) | _No description available._ |
| [`colour::fg::bright_blue`](colour/fg/bright_blue.md) | `colour::fg::bright_blue()` | [`colour`](colour.md) | _No description available._ |
| [`colour::fg::bright_cyan`](colour/fg/bright_cyan.md) | `colour::fg::bright_cyan()` | [`colour`](colour.md) | _No description available._ |
| [`colour::fg::bright_green`](colour/fg/bright_green.md) | `colour::fg::bright_green()` | [`colour`](colour.md) | _No description available._ |
| [`colour::fg::bright_magenta`](colour/fg/bright_magenta.md) | `colour::fg::bright_magenta()` | [`colour`](colour.md) | _No description available._ |
| [`colour::fg::bright_red`](colour/fg/bright_red.md) | `colour::fg::bright_red()` | [`colour`](colour.md) | _No description available._ |
| [`colour::fg::bright_white`](colour/fg/bright_white.md) | `colour::fg::bright_white()` | [`colour`](colour.md) | _No description available._ |
| [`colour::fg::bright_yellow`](colour/fg/bright_yellow.md) | `colour::fg::bright_yellow()` | [`colour`](colour.md) | _No description available._ |
| [`colour::fg::cyan`](colour/fg/cyan.md) | `colour::fg::cyan()` | [`colour`](colour.md) | _No description available._ |
| [`colour::fg::green`](colour/fg/green.md) | `colour::fg::green()` | [`colour`](colour.md) | _No description available._ |
| [`colour::fg::magenta`](colour/fg/magenta.md) | `colour::fg::magenta()` | [`colour`](colour.md) | _No description available._ |
| [`colour::fg::red`](colour/fg/red.md) | `colour::fg::red()` | [`colour`](colour.md) | _No description available._ |
| [`colour::fg::white`](colour/fg/white.md) | `colour::fg::white()` | [`colour`](colour.md) | _No description available._ |
| [`colour::fg::yellow`](colour/fg/yellow.md) | `colour::fg::yellow()` | [`colour`](colour.md) | _No description available._ |
| [`colour::has_colour`](colour/has_colour.md) | `colour::has_colour(arg1)` | [`colour`](colour.md) | Check if a string contains any ANSI escape codes |
| [`colour::hidden`](colour/hidden.md) | `colour::hidden()` | [`colour`](colour.md) | _No description available._ |
| [`colour::index::4bit`](Get 4-bit ANSI colour code index|colour/index/4bit.md) | `colour::index::4bit(colour_name, [fg` | [`bg])`](bg]).md) | colour |
| [`colour::index::8bit`](colour/index/8bit.md) | `colour::index::8bit(colour_name)` | [`colour`](colour.md) | Get 8-bit colour index (0-255) |
| [`colour::italic`](colour/italic.md) | `colour::italic()` | [`colour`](colour.md) | _No description available._ |
| [`colour::print`](colour/print.md) | `colour::print(bit, fg_bg, colour, text)` | [`colour`](colour.md) | Print text wrapped in colour, auto-reset after |
| [`colour::println`](colour/println.md) | `colour::println()` | [`colour`](colour.md) | Print text in colour followed by newline |
| [`colour::reset`](colour/reset.md) | `colour::reset()` | [`colour`](colour.md) | _No description available._ |
| [`colour::reset::bg`](colour/reset/bg.md) | `colour::reset::bg()` | [`colour`](colour.md) | _No description available._ |
| [`colour::reset::blink`](colour/reset/blink.md) | `colour::reset::blink()` | [`colour`](colour.md) | _No description available._ |
| [`colour::reset::bold`](colour/reset/bold.md) | `colour::reset::bold()` | [`colour`](colour.md) | Reset individual attributes |
| [`colour::reset::dim`](colour/reset/dim.md) | `colour::reset::dim()` | [`colour`](colour.md) | _No description available._ |
| [`colour::reset::fg`](colour/reset/fg.md) | `colour::reset::fg()` | [`colour`](colour.md) | _No description available._ |
| [`colour::reset::hidden`](colour/reset/hidden.md) | `colour::reset::hidden()` | [`colour`](colour.md) | _No description available._ |
| [`colour::reset::italic`](colour/reset/italic.md) | `colour::reset::italic()` | [`colour`](colour.md) | _No description available._ |
| [`colour::reset::reverse`](colour/reset/reverse.md) | `colour::reset::reverse()` | [`colour`](colour.md) | _No description available._ |
| [`colour::reset::strike`](colour/reset/strike.md) | `colour::reset::strike()` | [`colour`](colour.md) | _No description available._ |
| [`colour::reset::underline`](colour/reset/underline.md) | `colour::reset::underline()` | [`colour`](colour.md) | _No description available._ |
| [`colour::reverse`](colour/reverse.md) | `colour::reverse()` | [`colour`](colour.md) | _No description available._ |
| [`colour::safe_esc`](colour/safe_esc.md) | `colour::safe_esc(bit, fg_bg, colour)` | [`colour`](colour.md) | Gracefully degrade — return escape code only if terminal supports the depth |
| [`colour::strike`](colour/strike.md) | `colour::strike()` | [`colour`](colour.md) | _No description available._ |
| [`colour::strip`](colour/strip.md) | `colour::strip(text)` | [`colour`](colour.md) | Strip all ANSI escape codes from a string |
| [`colour::supports`](colour/supports.md) | `colour::supports()` | [`colour`](colour.md) | Check if the terminal supports any colour |
| [`colour::supports_256`](colour/supports_256.md) | `colour::supports_256()` | [`colour`](colour.md) | Check if terminal supports 256 colours |
| [`colour::supports_truecolor`](colour/supports_truecolor.md) | `colour::supports_truecolor()` | [`colour`](colour.md) | Check if terminal supports true colour (24-bit) |
| [`colour::underline`](colour/underline.md) | `colour::underline()` | [`colour`](colour.md) | _No description available._ |
| [`colour::visible_length`](colour/visible_length.md) | `colour::visible_length(arg1)` | [`colour`](colour.md) | Return the visible length of a string (excluding escape codes) |
| [`colour::wrap`](colour/wrap.md) | `colour::wrap(bit, fg_bg, colour, text)` | [`colour`](colour.md) | Wrap text in escape codes and return as string (no direct print) |

## D

| Function | Signature | Module | Description |
|----------|-----------|--------|-------------|
| [`device::exists`](device/exists.md) | `device::exists(arg1)` | [`device`](device.md) | Check if device exists (block or character) |
| [`device::filesystem`](device/filesystem.md) | `device::filesystem(arg1, arg2)` | [`device`](device.md) | Returns the filesystem on a block device (if mounted or detectable) |
| [`device::has_processes`](device/has_processes.md) | `device::has_processes(arg1)` | [`device`](device.md) | Check if device has open file handles via lsof |
| [`device::is_block`](device/is_block.md) | `device::is_block(arg1)` | [`device`](device.md) | Check if path is a block device |
| [`device::is_device`](device/is_device.md) | `device::is_device(arg1)` | [`device`](device.md) | Check if path is a character device |
| [`device::is_loop`](device/is_loop.md) | `device::is_loop(arg1)` | [`device`](device.md) | Check if device is a loop device |
| [`device::is_mounted`](device/is_mounted.md) | `device::is_mounted(arg1)` | [`device`](device.md) | Check if a block device is mounted |
| [`device::is_occupied`](device/is_occupied.md) | `device::is_occupied()` | [`device`](device.md) | Check if device is occupied via /proc (no lsof needed) |
| [`device::is_ram`](device/is_ram.md) | `device::is_ram(arg1)` | [`device`](device.md) | Check if device is a RAM disk |
| [`device::is_readable`](device/is_readable.md) | `device::is_readable(arg1)` | [`device`](device.md) | Check if device is readable |
| [`device::is_virtual`](device/is_virtual.md) | `device::is_virtual(arg1)` | [`device`](device.md) | Check if device is a virtual/pseudo device |
| [`device::is_writeable`](device/is_writeable.md) | `device::is_writeable(arg1)` | [`device`](device.md) | Check if device is writable |
| [`device::list::block`](device/list/block.md) | `device::list::block(arg1)` | [`device`](device.md) | List all block devices |
| [`device::list::char`](device/list/char.md) | `device::list::char()` | [`device`](device.md) | List all character devices |
| [`device::list::loop`](device/list/loop.md) | `device::list::loop()` | [`device`](device.md) | List all loop devices |
| [`device::list::mounted`](device/list/mounted.md) | `device::list::mounted(arg1, arg2, arg3)` | [`device`](device.md) | List mounted devices with their mount points |
| [`device::list::tty`](device/list/tty.md) | `device::list::tty()` | [`device`](device.md) | List all TTY devices |
| [`device::mount_point`](device/mount_point.md) | `device::mount_point(arg1, arg2)` | [`device`](device.md) | Returns the mount point of a block device (empty if not mounted) |
| [`device::null_ok`](device/null_ok.md) | `device::null_ok()` | [`device`](device.md) | Check if /dev/null is functional (sanity check) |
| [`device::number`](device/number.md) | `device::number(arg1, arg2)` | [`device`](device.md) | Returns the major:minor device number |
| [`device::random`](device/random.md) | `device::random([bytes])` | [`device`](device.md) | Read n random bytes from /dev/urandom |
| [`device::size_bytes`](device/size_bytes.md) | `device::size_bytes(arg1, arg2)` | [`device`](device.md) | Returns the size of a block device in bytes |
| [`device::size_mb`](device/size_mb.md) | `device::size_mb(arg1)` | [`device`](device.md) | Returns the size of a block device in MB |
| [`device::type`](device/type.md) | `device::type(arg1)` | [`device`](device.md) | Returns the type of a device as a string |
| [`device::zero`](device/zero.md) | `device::zero(target, [bytes])` | [`device`](device.md) | Write n bytes of zeros to a device or file (wraps /dev/zero) |

## F

| Function | Signature | Module | Description |
|----------|-----------|--------|-------------|
| [`fs::append`](fs/append.md) | `fs::append(arg1, arg2)` | [`fs`](fs.md) | Append content to file |
| [`fs::appendln`](fs/appendln.md) | `fs::appendln(arg1, arg2)` | [`fs`](fs.md) | Append with newline |
| [`fs::char_count`](fs/char_count.md) | `fs::char_count(arg1)` | [`fs`](fs.md) | Count characters in a file |
| [`fs::checksum::md5`](fs/checksum/md5.md) | `fs::checksum::md5(arg1)` | [`fs`](fs.md) | _No description available._ |
| [`fs::checksum::sha1`](fs/checksum/sha1.md) | `fs::checksum::sha1(arg1)` | [`fs`](fs.md) | _No description available._ |
| [`fs::checksum::sha256`](fs/checksum/sha256.md) | `fs::checksum::sha256(arg1)` | [`fs`](fs.md) | _No description available._ |
| [`fs::contains`](fs/contains.md) | `fs::contains(path, string)` | [`fs`](fs.md) | Check if file contains a string |
| [`fs::copy`](fs/copy.md) | `fs::copy(src, dst)` | [`fs`](fs.md) | Copy file or directory |
| [`fs::created`](fs/created.md) | `fs::created(arg1)` | [`fs`](fs.md) | Creation time (unix timestamp) — not available on all filesystems |
| [`fs::delete`](fs/delete.md) | `fs::delete(arg1)` | [`fs`](fs.md) | Delete file or directory |
| [`fs::dir::count`](fs/dir/count.md) | `fs::dir::count()` | [`fs`](fs.md) | Count items in directory |
| [`fs::dir::is_empty`](fs/dir/is_empty.md) | `fs::dir::is_empty()` | [`fs`](fs.md) | Check if directory is empty |
| [`fs::dir::size`](fs/dir/size.md) | `fs::dir::size(arg1)` | [`fs`](fs.md) | Get total size of directory |
| [`fs::dir::size::human`](fs/dir/size/human.md) | `fs::dir::size::human(arg1)` | [`fs`](fs.md) | Get total size of directory, human readable |
| [`fs::exists`](fs/exists.md) | `fs::exists(arg1)` | [`fs`](fs.md) | _No description available._ |
| [`fs::find`](fs/find.md) | `fs::find(path, pattern)` | [`fs`](fs.md) | Recursive find by name pattern |
| [`fs::find::larger_than`](fs/find/larger_than.md) | `fs::find::larger_than()` | [`fs`](fs.md) | Find files larger than n bytes |
| [`fs::find::recent`](fs/find/recent.md) | `fs::find::recent()` | [`fs`](fs.md) | Find files modified within n minutes |
| [`fs::find::smaller_than`](fs/find/smaller_than.md) | `fs::find::smaller_than()` | [`fs`](fs.md) | Find files smaller than n bytes |
| [`fs::find::type`](fs/find/type.md) | `fs::find::type(arg2)` | [`fs`](fs.md) | Recursive find by type (f=file, d=dir, l=symlink) |
| [`fs::hardlink`](fs/hardlink.md) | `fs::hardlink(arg1, arg2)` | [`fs`](fs.md) | Create a hard link |
| [`fs::inode`](fs/inode.md) | `fs::inode(arg1)` | [`fs`](fs.md) | Inode number |
| [`fs::is_dir`](fs/is_dir.md) | `fs::is_dir(arg1)` | [`fs`](fs.md) | _No description available._ |
| [`fs::is_empty`](fs/is_empty.md) | `fs::is_empty(arg1)` | [`fs`](fs.md) | _No description available._ |
| [`fs::is_executable`](fs/is_executable.md) | `fs::is_executable(arg1)` | [`fs`](fs.md) | _No description available._ |
| [`fs::is_file`](fs/is_file.md) | `fs::is_file(arg1)` | [`fs`](fs.md) | _No description available._ |
| [`fs::is_identical`](fs/is_identical.md) | `fs::is_identical(arg1, arg2)` | [`fs`](fs.md) | Check if two files are identical (by content) |
| [`fs::is_readable`](fs/is_readable.md) | `fs::is_readable(arg1)` | [`fs`](fs.md) | _No description available._ |
| [`fs::is_same`](fs/is_same.md) | `fs::is_same(arg1, arg2)` | [`fs`](fs.md) | Check if two paths resolve to the same file (inode comparison) |
| [`fs::is_symlink`](fs/is_symlink.md) | `fs::is_symlink(arg1)` | [`fs`](fs.md) | _No description available._ |
| [`fs::is_writable`](fs/is_writable.md) | `fs::is_writable(arg1)` | [`fs`](fs.md) | _No description available._ |
| [`fs::line`](fs/line.md) | `fs::line(path, line_number)` | [`fs`](fs.md) | Read a specific line number (1-indexed) |
| [`fs::line_count`](fs/line_count.md) | `fs::line_count(arg1)` | [`fs`](fs.md) | Count lines in a file |
| [`fs::lines`](fs/lines.md) | `fs::lines(path, start, end)` | [`fs`](fs.md) | Read a range of lines |
| [`fs::link_count`](fs/link_count.md) | `fs::link_count(arg1)` | [`fs`](fs.md) | Number of hard links |
| [`fs::ls`](fs/ls.md) | `fs::ls()` | [`fs`](fs.md) | List directory contents (one per line) |
| [`fs::ls::all`](fs/ls/all.md) | `fs::ls::all()` | [`fs`](fs.md) | List with hidden files |
| [`fs::ls::dirs`](fs/ls/dirs.md) | `fs::ls::dirs()` | [`fs`](fs.md) | List only directories |
| [`fs::ls::files`](fs/ls/files.md) | `fs::ls::files()` | [`fs`](fs.md) | List only files |
| [`fs::matches`](fs/matches.md) | `fs::matches(arg1, arg2)` | [`fs`](fs.md) | Check if file matches a regex |
| [`fs::mime_type`](fs/mime_type.md) | `fs::mime_type(arg1)` | [`fs`](fs.md) | MIME type |
| [`fs::mkdir`](fs/mkdir.md) | `fs::mkdir(arg1)` | [`fs`](fs.md) | Create directory (including parents) |
| [`fs::modified`](fs/modified.md) | `fs::modified(arg1)` | [`fs`](fs.md) | Last modified time (unix timestamp) |
| [`fs::modified::human`](fs/modified/human.md) | `fs::modified::human(arg1)` | [`fs`](fs.md) | Last modified time (human readable) |
| [`fs::move`](fs/move.md) | `fs::move(arg1, arg2)` | [`fs`](fs.md) | Move/rename |
| [`fs::owner`](fs/owner.md) | `fs::owner(arg1)` | [`fs`](fs.md) | Owner username |
| [`fs::owner::group`](fs/owner/group.md) | `fs::owner::group(arg1)` | [`fs`](fs.md) | Owner group |
| [`fs::path::absolute`](fs/path/absolute.md) | `fs::path::absolute(arg1)` | [`fs`](fs.md) | Get absolute path (resolves . and .. without requiring the path to exist) |
| [`fs::path::basename`](fs/path/basename.md) | `fs::path::basename()` | [`fs`](fs.md) | Get filename from path (like basename) |
| [`fs::path::dirname`](fs/path/dirname.md) | `fs::path::dirname(arg1)` | [`fs`](fs.md) | Get directory from path (like dirname) |
| [`fs::path::extension`](fs/path/extension.md) | `fs::path::extension(file.tar.gz, →, gz)` | [`fs`](fs.md) | Get file extension (without dot) |
| [`fs::path::extensions`](fs/path/extensions.md) | `fs::path::extensions(file.tar.gz, →, tar.gz)` | [`fs`](fs.md) | Get all extensions for multi-part extensions |
| [`fs::path::is_absolute`](fs/path/is_absolute.md) | `fs::path::is_absolute(arg1)` | [`fs`](fs.md) | Check if a path is absolute |
| [`fs::path::is_relative`](fs/path/is_relative.md) | `fs::path::is_relative(arg1)` | [`fs`](fs.md) | Check if a path is relative |
| [`fs::path::join`](fs/path/join.md) | `fs::path::join(part1, part2, ...)` | [`fs`](fs.md) | Join path components |
| [`fs::path::relative`](fs/path/relative.md) | `fs::path::relative(/a/b/c, /a, →, b/c)` | [`fs`](fs.md) | Get path relative to a base |
| [`fs::path::stem`](fs/path/stem.md) | `fs::path::stem()` | [`fs`](fs.md) | Strip extension from filename |
| [`fs::permissions`](fs/permissions.md) | `fs::permissions(arg1)` | [`fs`](fs.md) | Octal permissions |
| [`fs::permissions::symbolic`](fs/permissions/symbolic.md) | `fs::permissions::symbolic(arg1)` | [`fs`](fs.md) | Symbolic permissions (e.g. -rwxr-xr-x) |
| [`fs::prepend`](fs/prepend.md) | `fs::prepend(arg1, arg2)` | [`fs`](fs.md) | Prepend content to file |
| [`fs::read`](fs/read.md) | `fs::read(arg1)` | [`fs`](fs.md) | Read entire file contents |
| [`fs::rename`](fs/rename.md) | `fs::rename(old_path, new_name)` | [`fs`](fs.md) | Rename just the filename, keeping directory |
| [`fs::replace`](fs/replace.md) | `fs::replace(path, old, new)` | [`fs`](fs.md) | Replace string in file (in-place) |
| [`fs::size`](fs/size.md) | `fs::size(arg1)` | [`fs`](fs.md) | File size in bytes |
| [`fs::size::human`](fs/size/human.md) | `fs::size::human(arg1)` | [`fs`](fs.md) | Human-readable file size |
| [`fs::symlink`](fs/symlink.md) | `fs::symlink(target, link_name)` | [`fs`](fs.md) | Create a symlink |
| [`fs::symlink::resolve`](fs/symlink/resolve.md) | `fs::symlink::resolve(arg1)` | [`fs`](fs.md) | Resolved symlink target (follows chain) |
| [`fs::symlink::target`](fs/symlink/target.md) | `fs::symlink::target(arg1)` | [`fs`](fs.md) | Symlink target |
| [`fs::temp::dir`](fs/temp/dir.md) | `fs::temp::dir(tmpdir=$(fs::temp::dir, [prefix]))` | [`fs`](fs.md) | Create a temporary directory, print its path |
| [`fs::temp::dir::auto`](fs/temp/dir/auto.md) | `fs::temp::dir::auto(arg1)` | [`fs`](fs.md) | Create a temp dir and register cleanup on EXIT |
| [`fs::temp::file`](fs/temp/file.md) | `fs::temp::file(tmpfile=$(fs::temp::file, [prefix]))` | [`fs`](fs.md) | Create a temporary file, print its path |
| [`fs::temp::file::auto`](fs/temp/file/auto.md) | `fs::temp::file::auto([prefix])` | [`fs`](fs.md) | Create a temp file and register cleanup on EXIT |
| [`fs::touch`](fs/touch.md) | `fs::touch(arg1)` | [`fs`](fs.md) | Touch a file (create or update timestamp) |
| [`fs::trash`](fs/trash.md) | `fs::trash(path)` | [`fs`](fs.md) | Safely delete to a trash dir instead of permanent delete |
| [`fs::watch`](fs/watch.md) | `fs::watch(path, callback, [interval_seconds])` | [`fs`](fs.md) | Watch a file for changes, run callback on change |
| [`fs::watch::timeout`](fs/watch/timeout.md) | `fs::watch::timeout(path, callback, timeout, [interval])` | [`fs`](fs.md) | Watch with a timeout (seconds) |
| [`fs::word_count`](fs/word_count.md) | `fs::word_count(arg1)` | [`fs`](fs.md) | Count words in a file |
| [`fs::write`](fs/write.md) | `fs::write(path, content)` | [`fs`](fs.md) | Write content to file (overwrites) |
| [`fs::writeln`](fs/writeln.md) | `fs::writeln(arg1, arg2)` | [`fs`](fs.md) | Write with newline |

## G

| Function | Signature | Module | Description |
|----------|-----------|--------|-------------|
| [`git::ahead_count`](git/ahead_count.md) | `git::ahead_count()` | [`git`](git.md) | _No description available._ |
| [`git::behind_count`](git/behind_count.md) | `git::behind_count()` | [`git`](git.md) | _No description available._ |
| [`git::branch::current`](git/branch/current.md) | `git::branch::current()` | [`git`](git.md) | _No description available._ |
| [`git::branch::exists`](git/branch/exists.md) | `git::branch::exists(arg1)` | [`git`](git.md) | _No description available._ |
| [`git::branch::exists::remote`](git/branch/exists/remote.md) | `git::branch::exists::remote(arg1)` | [`git`](git.md) | _No description available._ |
| [`git::branch::list`](git/branch/list.md) | `git::branch::list()` | [`git`](git.md) | _No description available._ |
| [`git::branch::list::all`](git/branch/list/all.md) | `git::branch::list::all()` | [`git`](git.md) | _No description available._ |
| [`git::branch::list::remote`](git/branch/list/remote.md) | `git::branch::list::remote()` | [`git`](git.md) | _No description available._ |
| [`git::commit::author`](git/commit/author.md) | `git::commit::author()` | [`git`](git.md) | _No description available._ |
| [`git::commit::author::email`](git/commit/author/email.md) | `git::commit::author::email()` | [`git`](git.md) | _No description available._ |
| [`git::commit::count`](git/commit/count.md) | `git::commit::count()` | [`git`](git.md) | _No description available._ |
| [`git::commit::date`](git/commit/date.md) | `git::commit::date()` | [`git`](git.md) | _No description available._ |
| [`git::commit::date::relative`](git/commit/date/relative.md) | `git::commit::date::relative()` | [`git`](git.md) | _No description available._ |
| [`git::commit::hash`](git/commit/hash.md) | `git::commit::hash()` | [`git`](git.md) | _No description available._ |
| [`git::commit::message`](git/commit/message.md) | `git::commit::message()` | [`git`](git.md) | _No description available._ |
| [`git::commit::short_hash`](git/commit/short_hash.md) | `git::commit::short_hash()` | [`git`](git.md) | _No description available._ |
| [`git::exec`](git/exec.md) | `git::exec()` | [`git`](git.md) | _No description available._ |
| [`git::has_remote`](git/has_remote.md) | `git::has_remote()` | [`git`](git.md) | _No description available._ |
| [`git::is_ahead`](git/is_ahead.md) | `git::is_ahead()` | [`git`](git.md) | _No description available._ |
| [`git::is_behind`](git/is_behind.md) | `git::is_behind()` | [`git`](git.md) | _No description available._ |
| [`git::is_dirty`](git/is_dirty.md) | `git::is_dirty()` | [`git`](git.md) | _No description available._ |
| [`git::is_repo`](git/is_repo.md) | `git::is_repo()` | [`git`](git.md) | _No description available._ |
| [`git::is_staged`](git/is_staged.md) | `git::is_staged()` | [`git`](git.md) | _No description available._ |
| [`git::is_stashed`](git/is_stashed.md) | `git::is_stashed()` | [`git`](git.md) | _No description available._ |
| [`git::log`](git/log.md) | `git::log()` | [`git`](git.md) | _No description available._ |
| [`git::remote::list`](git/remote/list.md) | `git::remote::list()` | [`git`](git.md) | _No description available._ |
| [`git::remote::url`](git/remote/url.md) | `git::remote::url()` | [`git`](git.md) | _No description available._ |
| [`git::root_dir`](git/root_dir.md) | `git::root_dir()` | [`git`](git.md) | _No description available._ |
| [`git::staged::count`](git/staged/count.md) | `git::staged::count()` | [`git`](git.md) | _No description available._ |
| [`git::stash::count`](git/stash/count.md) | `git::stash::count()` | [`git`](git.md) | _No description available._ |
| [`git::tag::exists`](git/tag/exists.md) | `git::tag::exists(arg1)` | [`git`](git.md) | _No description available._ |
| [`git::tag::latest`](git/tag/latest.md) | `git::tag::latest()` | [`git`](git.md) | _No description available._ |
| [`git::tag::list`](git/tag/list.md) | `git::tag::list()` | [`git`](git.md) | _No description available._ |
| [`git::unstaged::count`](git/unstaged/count.md) | `git::unstaged::count()` | [`git`](git.md) | _No description available._ |
| [`git::untracked::count`](git/untracked/count.md) | `git::untracked::count()` | [`git`](git.md) | _No description available._ |

## H

| Function | Signature | Module | Description |
|----------|-----------|--------|-------------|
| [`hardware::battery::capacity`](hardware/battery/capacity.md) | `hardware::battery::capacity(arg2)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::battery::health`](hardware/battery/health.md) | `hardware::battery::health(arg2)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::battery::is_charging`](hardware/battery/is_charging.md) | `hardware::battery::is_charging()` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::battery::percentage`](hardware/battery/percentage.md) | `hardware::battery::percentage(arg2)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::battery::present`](hardware/battery/present.md) | `hardware::battery::present()` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::battery::status`](hardware/battery/status.md) | `hardware::battery::status(arg4)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::battery::time_remaining`](hardware/battery/time_remaining.md) | `hardware::battery::time_remaining(arg4, arg5)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::cpu::core_count::logical`](hardware/cpu/core_count/logical.md) | `hardware::cpu::core_count::logical(arg2)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::cpu::core_count::physical`](hardware/cpu/core_count/physical.md) | `hardware::cpu::core_count::physical(arg2)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::cpu::core_count::total`](hardware/cpu/core_count/total.md) | `hardware::cpu::core_count::total()` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::cpu::frequencyMHz`](hardware/cpu/frequencyMHz.md) | `hardware::cpu::frequencyMHz(arg1, arg2)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::cpu::name`](hardware/cpu/name.md) | `hardware::cpu::name(arg1, arg2, arg4)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::cpu::temp`](hardware/cpu/temp.md) | `hardware::cpu::temp(arg1, arg2)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::cpu::thread_count`](hardware/cpu/thread_count.md) | `hardware::cpu::thread_count()` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::disk::count::physical`](hardware/disk/count/physical.md) | `hardware::disk::count::physical()` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::disk::count::total`](hardware/disk/count/total.md) | `hardware::disk::count::total()` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::disk::count::virtual`](hardware/disk/count/virtual.md) | `hardware::disk::count::virtual()` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::disk::devices`](hardware/disk/devices.md) | `hardware::disk::devices(arg1)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::disk::name`](hardware/disk/name.md) | `hardware::disk::name(arg2)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::gpu`](hardware/gpu.md) | `hardware::gpu(arg2)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::gpu::vramMB`](hardware/gpu/vramMB.md) | `hardware::gpu::vramMB()` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::partition::count`](hardware/partition/count.md) | `hardware::partition::count()` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::partition::freeSpaceMB`](hardware/partition/freeSpaceMB.md) | `hardware::partition::freeSpaceMB(arg4)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::partition::info`](hardware/partition/info.md) | `hardware::partition::info([mountpoint])` | [`hardware`](hardware.md) | Returns human-readable disk info for a mount point (default: /) |
| [`hardware::partition::totalSpaceMB`](hardware/partition/totalSpaceMB.md) | `hardware::partition::totalSpaceMB(arg2)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::partition::usagePercent`](hardware/partition/usagePercent.md) | `hardware::partition::usagePercent(arg5)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::partition::usedSpaceMB`](hardware/partition/usedSpaceMB.md) | `hardware::partition::usedSpaceMB(arg3)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::ram::freeSpaceMB`](hardware/ram/freeSpaceMB.md) | `hardware::ram::freeSpaceMB(arg2, arg3)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::ram::percentage`](hardware/ram/percentage.md) | `hardware::ram::percentage()` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::ram::totalSpaceMB`](hardware/ram/totalSpaceMB.md) | `hardware::ram::totalSpaceMB(arg1, arg2)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::ram::usedSpaceMB`](hardware/ram/usedSpaceMB.md) | `hardware::ram::usedSpaceMB(arg2, arg3, arg4, arg5)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::swap::freeSpaceMB`](hardware/swap/freeSpaceMB.md) | `hardware::swap::freeSpaceMB(arg2)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::swap::totalSpaceMB`](hardware/swap/totalSpaceMB.md) | `hardware::swap::totalSpaceMB(arg2, arg3)` | [`hardware`](hardware.md) | _No description available._ |
| [`hardware::swap::usedSpaceMB`](hardware/swap/usedSpaceMB.md) | `hardware::swap::usedSpaceMB(arg2, arg3)` | [`hardware`](hardware.md) | _No description available._ |
| [`hash::adler32`](hash/adler32.md) | `hash::adler32()` | [`hash`](hash.md) | Adler-32 — fast checksum used in zlib/PNG |
| [`hash::blake2b`](hash/blake2b.md) | `hash::blake2b(arg1)` | [`hash`](hash.md) | BLAKE2b hash of a string |
| [`hash::combine`](hash/combine.md) | `hash::combine(val1, val2, val3, ...)` | [`hash`](hash.md) | Hash multiple values into one — useful for cache keys from multiple inputs |
| [`hash::crc32`](hash/crc32.md) | `hash::crc32(string)` | [`hash`](hash.md) | CRC32 — delegates to system tools, pure bash fallback is too slow for real use |
| [`hash::djb2`](hash/djb2.md) | `hash::djb2(string)` | [`hash`](hash.md) | DJB2 — Daniel J. Bernstein's hash, classic and fast |
| [`hash::djb2a`](hash/djb2a.md) | `hash::djb2a()` | [`hash`](hash.md) | DJB2a (xor variant) — slightly better distribution than djb2 |
| [`hash::equal`](hash/equal.md) | `hash::equal(string1, string2, [algorithm])` | [`hash`](hash.md) | Check if two strings have the same hash (constant-time safe via hash comparison) |
| [`hash::fnv1a32`](hash/fnv1a32.md) | `hash::fnv1a32()` | [`hash`](hash.md) | FNV-1a 32-bit — Fowler-Noll-Vo, excellent avalanche, widely used |
| [`hash::fnv1a64`](hash/fnv1a64.md) | `hash::fnv1a64()` | [`hash`](hash.md) | FNV-1a 64-bit — larger state, better for longer strings |
| [`hash::hmac::md5`](hash/hmac/md5.md) | `hash::hmac::md5(key, message)` | [`hash`](hash.md) | HMAC-MD5 |
| [`hash::hmac::sha256`](hash/hmac/sha256.md) | `hash::hmac::sha256(key, message)` | [`hash`](hash.md) | HMAC-SHA256 |
| [`hash::hmac::sha512`](hash/hmac/sha512.md) | `hash::hmac::sha512(key, message)` | [`hash`](hash.md) | HMAC-SHA512 |
| [`hash::md5`](hash/md5.md) | `hash::md5(string)` | [`hash`](hash.md) | MD5 hash of a string |
| [`hash::murmur2`](hash/murmur2.md) | `hash::murmur2()` | [`hash`](hash.md) | MurmurHash2 — pure bash, good distribution, faster than cryptographic hashes |
| [`hash::sdbm`](hash/sdbm.md) | `hash::sdbm()` | [`hash`](hash.md) | SDBM hash — used in the SDBM database library |
| [`hash::sha1`](hash/sha1.md) | `hash::sha1(arg1)` | [`hash`](hash.md) | SHA1 hash of a string |
| [`hash::sha256`](hash/sha256.md) | `hash::sha256(arg1)` | [`hash`](hash.md) | SHA256 hash of a string |
| [`hash::sha3_256`](hash/sha3_256.md) | `hash::sha3_256()` | [`hash`](hash.md) | SHA3-256 hash of a string |
| [`hash::sha512`](hash/sha512.md) | `hash::sha512(arg1)` | [`hash`](hash.md) | SHA512 hash of a string |
| [`hash::short`](hash/short.md) | `hash::short(string, [length])` | [`hash`](hash.md) | Generate a short hash — first n chars of sha256 |
| [`hash::slot`](hash/slot.md) | `hash::slot(n_buckets, value)` | [`hash`](hash.md) | Consistent hashing — map a value to a bucket (0 to n-1) |
| [`hash::uuid5`](hash/uuid5.md) | `hash::uuid5(namespace, name)` | [`hash`](hash.md) | Generate a hash-based UUID v5 (name-based, SHA1) |
| [`hash::verify`](hash/verify.md) | `hash::verify(string, expected_hash, algorithm)` | [`hash`](hash.md) | Verify a string against a known hash |

## L

| Function | Signature | Module | Description |
|----------|-----------|--------|-------------|
| [`log::debug`](log/debug.md) | `log::debug(message)` | [`log`](log.md) | Log a debug message |
| [`log::error`](log/error.md) | `log::error(message, [exit_code])` | [`log`](log.md) | Log an error message, optionally exiting with a given code |
| [`log::fatal`](log/fatal.md) | `log::fatal(message, [exit_code])` | [`log`](log.md) | Log an error and always exit, defaulting to exit code 1 |
| [`log::info`](log/info.md) | `log::info(message)` | [`log`](log.md) | Log an informational message |
| [`log::init`](log/init.md) | `log::init()` | [`log`](log.md) | Initialise config vars if not already set by the caller |
| [`log::warn`](log/warn.md) | `log::warn(message)` | [`log`](log.md) | Log a warning message |

## M

| Function | Signature | Module | Description |
|----------|-----------|--------|-------------|
| [`math::abs`](math/abs.md) | `math::abs(n)` | [`math`](math.md) | Absolute value (integer) |
| [`math::absf`](math/absf.md) | `math::absf(arg1)` | [`math`](math.md) | Absolute value (float) — Usage: math::absf n [scale] |
| [`math::acos`](math/acos.md) | `math::acos(arg1)` | [`math`](math.md) | _No description available._ |
| [`math::asin`](math/asin.md) | `math::asin(arg1)` | [`math`](math.md) | _No description available._ |
| [`math::atan`](math/atan.md) | `math::atan(arg1)` | [`math`](math.md) | _No description available._ |
| [`math::atan2`](math/atan2.md) | `math::atan2(arg1, arg2)` | [`math`](math.md) | _No description available._ |
| [`math::bc`](math/bc.md) | `math::bc(arg1)` | [`math`](math.md) | _No description available._ |
| [`math::ceil`](math/ceil.md) | `math::ceil(arg1)` | [`math`](math.md) | Ceiling — smallest integer ≥ n |
| [`math::choose`](math/choose.md) | `math::choose(n, k)` | [`math`](math.md) | Binomial coefficient C(n, k) — "n choose k" |
| [`math::clamp`](math/clamp.md) | `math::clamp(n, min, max)` | [`math`](math.md) | Clamp n between min and max inclusive |
| [`math::clampf`](math/clampf.md) | `math::clampf(arg1, arg2, arg3)` | [`math`](math.md) | _No description available._ |
| [`math::cos`](math/cos.md) | `math::cos(arg1)` | [`math`](math.md) | _No description available._ |
| [`math::deg_to_rad`](math/deg_to_rad.md) | `math::deg_to_rad(arg1)` | [`math`](math.md) | Convert degrees to radians |
| [`math::digit_count`](math/digit_count.md) | `math::digit_count()` | [`math`](math.md) | Count number of digits |
| [`math::digit_reverse`](math/digit_reverse.md) | `math::digit_reverse(arg1)` | [`math`](math.md) | Reverse digits of an integer |
| [`math::digit_sum`](math/digit_sum.md) | `math::digit_sum()` | [`math`](math.md) | Sum of digits of an integer |
| [`math::div`](math/div.md) | `math::div(dividend, divisor)` | [`math`](math.md) | Integer division (truncated toward zero) |
| [`math::exp`](math/exp.md) | `math::exp(arg1)` | [`math`](math.md) | Exponential e^n |
| [`math::factorial`](math/factorial.md) | `math::factorial(n)` | [`math`](math.md) | Factorial (integer) |
| [`math::fibonacci`](math/fibonacci.md) | `math::fibonacci(n)` | [`math`](math.md) | Fibonacci (nth term, 0-indexed) |
| [`math::floor`](math/floor.md) | `math::floor(arg1)` | [`math`](math.md) | Floor — largest integer ≤ n |
| [`math::gcd`](math/gcd.md) | `math::gcd(a, b)` | [`math`](math.md) | Greatest common divisor (Euclidean algorithm) |
| [`math::has_bc`](math/has_bc.md) | `math::has_bc()` | [`math`](math.md) | Check if bc is available |
| [`math::int_sqrt`](math/int_sqrt.md) | `math::int_sqrt(math::isqrt, n)` | [`math`](math.md) | Integer square root (floor) |
| [`math::is_even`](math/is_even.md) | `math::is_even(arg1)` | [`math`](math.md) | Check if integer is even |
| [`math::is_int`](math/is_int.md) | `math::is_int(arg1)` | [`math`](math.md) | _No description available._ |
| [`math::is_odd`](math/is_odd.md) | `math::is_odd(arg1)` | [`math`](math.md) | Check if integer is odd |
| [`math::is_palindrome`](math/is_palindrome.md) | `math::is_palindrome()` | [`math`](math.md) | Check if integer is a palindrome |
| [`math::is_prime`](math/is_prime.md) | `math::is_prime(arg1)` | [`math`](math.md) | Check if integer is prime |
| [`math::lcm`](math/lcm.md) | `math::lcm(a, b)` | [`math`](math.md) | Least common multiple |
| [`math::lerp`](math/lerp.md) | `math::lerp(a, b, t, [scale])` | [`math`](math.md) | Linear interpolation between a and b by factor t (0.0 - 1.0) |
| [`math::lerp_unclamped`](math/lerp_unclamped.md) | `math::lerp_unclamped(arg1, arg2, arg3)` | [`math`](math.md) | _No description available._ |
| [`math::log`](math/log.md) | `math::log(arg1)` | [`math`](math.md) | Natural logarithm |
| [`math::log10`](math/log10.md) | `math::log10(arg1)` | [`math`](math.md) | Log base 10 |
| [`math::log2`](math/log2.md) | `math::log2(arg1)` | [`math`](math.md) | Log base 2 |
| [`math::logn`](math/logn.md) | `math::logn(value, base)` | [`math`](math.md) | Log with arbitrary base |
| [`math::map`](math/map.md) | `math::map(value, in_min, in_max, out_min, out_max, [scale])` | [`math`](math.md) | Map a value from one range to another |
| [`math::matrix::add`](math/matrix/add.md) | `math::matrix::add(RxC, a, b)` | [`math`](math.md) | Add two matrices element-wise |
| [`math::matrix::addf`](math/matrix/addf.md) | `math::matrix::addf(scale, RxC, a, b)` | [`math`](math.md) | Add two matrices element-wise with floating point precision |
| [`math::matrix::add::fast`](math/matrix/add/fast.md) | `math::matrix::add::fast(result, RxC, a, b)` | [`math`](math.md) | Add two matrices element-wise, writing result into output array |
| [`math::matrix::addf::fast`](math/matrix/addf/fast.md) | `math::matrix::addf::fast(result, scale, RxC, a, b)` | [`math`](math.md) | Add two matrices element-wise with floating point precision, writing into output array |
| [`math::matrix::adjugate`](math/matrix/adjugate.md) | `math::matrix::adjugate(scale, NxN, a)` | [`math`](math.md) | Compute the adjugate (transpose of cofactor matrix) — requires bc |
| [`math::matrix::cofactor`](math/matrix/cofactor.md) | `math::matrix::cofactor(scale, NxN, a)` | [`math`](math.md) | Compute the cofactor matrix — requires bc |
| [`math::matrix::determinant`](math/matrix/determinant.md) | `math::matrix::determinant(scale, NxN, a)` | [`math`](math.md) | Compute determinant of a square matrix — requires bc |
| [`math::matrix::diagonal`](math/matrix/diagonal.md) | `math::matrix::diagonal(NxN, a)` | [`math`](math.md) | Extract diagonal elements as a flat list |
| [`math::matrix::eq`](math/matrix/eq.md) | `math::matrix::eq(RxC, a, b)` | [`math`](math.md) | Check if two matrices are equal element-wise |
| [`math::matrix::flatten`](math/matrix/flatten.md) | `math::matrix::flatten(RxC, a)` | [`math`](math.md) | Flatten a matrix to a newline-separated list (one element per line) |
| [`math::matrix::hadamard`](math/matrix/hadamard.md) | `math::matrix::hadamard(RxC, a, b)` | [`math`](math.md) | Multiply two matrices element-wise (Hadamard product) |
| [`math::matrix::hadamardf`](math/matrix/hadamardf.md) | `math::matrix::hadamardf(scale, RxC, a, b)` | [`math`](math.md) | Hadamard product with floating point precision |
| [`math::matrix::hadamard::fast`](math/matrix/hadamard/fast.md) | `math::matrix::hadamard::fast(result, RxC, a, b)` | [`math`](math.md) | Hadamard product, writing into output array |
| [`math::matrix::hadamardf::fast`](math/matrix/hadamardf/fast.md) | `math::matrix::hadamardf::fast(result, scale, RxC, a, b)` | [`math`](math.md) | Hadamard product with floating point precision, writing into output array |
| [`math::matrix::identity`](math/matrix/identity.md) | `math::matrix::identity(NxN)` | [`math`](math.md) | Generate an identity matrix of given size |
| [`math::matrix::identity::fast`](math/matrix/identity/fast.md) | `math::matrix::identity::fast(result, NxN)` | [`math`](math.md) | Generate an identity matrix, writing into output array |
| [`math::matrix::inverse`](math/matrix/inverse.md) | `math::matrix::inverse(scale, NxN, a)` | [`math`](math.md) | Compute the inverse of a square matrix — requires bc |
| [`math::matrix::is_square`](math/matrix/is_square.md) | `math::matrix::is_square(RxC)` | [`math`](math.md) | Check if a matrix is square (rows == cols) |
| [`math::matrix::lu`](math/matrix/lu.md) | `math::matrix::lu(scale, NxN, L_out, U_out, a)` | [`math`](math.md) | LU decomposition of a square matrix — requires bc |
| [`math::matrix::minor`](math/matrix/minor.md) | `math::matrix::minor(NxN, row, col, a)` | [`math`](math.md) | Compute the minor of a matrix — submatrix with row i and col j removed |
| [`math::matrix::mul`](math/matrix/mul.md) | `math::matrix::mul(RxC, RxC, a, b)` | [`math`](math.md) | Multiply two matrices — cols of a must equal rows of b |
| [`math::matrix::mulf`](math/matrix/mulf.md) | `math::matrix::mulf(scale, RxC, RxC, a, b)` | [`math`](math.md) | Multiply two matrices with floating point precision |
| [`math::matrix::mul::fast`](math/matrix/mul/fast.md) | `math::matrix::mul::fast(result, RxC, RxC, a, b)` | [`math`](math.md) | Multiply two matrices, writing result into output array |
| [`math::matrix::mulf::fast`](math/matrix/mulf/fast.md) | `math::matrix::mulf::fast(result, scale, RxC, RxC, a, b)` | [`math`](math.md) | Multiply two matrices with floating point precision, writing into output array |
| [`math::matrix::new`](math/matrix/new.md) | `math::matrix::new(arg1)` | [`math`](math.md) | _No description available._ |
| [`math::matrix::new::fast`](math/matrix/new/fast.md) | `math::matrix::new::fast(arg1, arg2)` | [`math`](math.md) | _No description available._ |
| [`math::matrix::pow`](math/matrix/pow.md) | `math::matrix::pow(NxN, exponent, a)` | [`math`](math.md) | Raise a square matrix to an integer power via repeated multiplication |
| [`math::matrix::powf`](math/matrix/powf.md) | `math::matrix::powf(scale, NxN, exponent, a)` | [`math`](math.md) | Raise a square matrix to an integer power with floating point precision |
| [`math::matrix::print`](math/matrix/print.md) | `math::matrix::print(RxC, a)` | [`math`](math.md) | Print a matrix in row-major human-readable format |
| [`math::matrix::rank`](math/matrix/rank.md) | `math::matrix::rank(scale, RxC, a)` | [`math`](math.md) | Compute the rank of a matrix via Gaussian elimination — requires bc |
| [`math::matrix::scale`](math/matrix/scale.md) | `math::matrix::scale(RxC, scalar, a)` | [`math`](math.md) | Multiply every element of a matrix by a scalar |
| [`math::matrix::scalef`](math/matrix/scalef.md) | `math::matrix::scalef(scale, RxC, scalar, a)` | [`math`](math.md) | Multiply every element of a matrix by a scalar with floating point precision |
| [`math::matrix::scale::fast`](math/matrix/scale/fast.md) | `math::matrix::scale::fast(result, RxC, scalar, a)` | [`math`](math.md) | Multiply every element of a matrix by a scalar, writing into output array |
| [`math::matrix::scalef::fast`](math/matrix/scalef/fast.md) | `math::matrix::scalef::fast(result, scale, RxC, scalar, a)` | [`math`](math.md) | Multiply every element of a matrix by a scalar with floating point precision, writing into output array |
| [`math::matrix::sub`](math/matrix/sub.md) | `math::matrix::sub(RxC, a, b)` | [`math`](math.md) | Subtract matrix b from matrix a element-wise |
| [`math::matrix::subf`](math/matrix/subf.md) | `math::matrix::subf(scale, RxC, a, b)` | [`math`](math.md) | Subtract matrix b from matrix a element-wise with floating point precision |
| [`math::matrix::sub::fast`](math/matrix/sub/fast.md) | `math::matrix::sub::fast(result, RxC, a, b)` | [`math`](math.md) | Subtract matrix b from matrix a element-wise, writing into output array |
| [`math::matrix::subf::fast`](math/matrix/subf/fast.md) | `math::matrix::subf::fast(result, scale, RxC, a, b)` | [`math`](math.md) | Subtract matrix b from matrix a element-wise with floating point precision, writing into output array |
| [`math::matrix::trace`](math/matrix/trace.md) | `math::matrix::trace(NxN, a)` | [`math`](math.md) | Sum of diagonal elements — square matrices only |
| [`math::matrix::tracef`](math/matrix/tracef.md) | `math::matrix::tracef(scale, NxN, a)` | [`math`](math.md) | Sum of diagonal elements with floating point precision |
| [`math::matrix::transpose`](math/matrix/transpose.md) | `math::matrix::transpose(RxC, a)` | [`math`](math.md) | Transpose a matrix — rows become columns |
| [`math::matrix::transpose::fast`](math/matrix/transpose/fast.md) | `math::matrix::transpose::fast(result, RxC, a)` | [`math`](math.md) | Transpose a matrix, writing into output array |
| [`math::max`](math/max.md) | `math::max(arg1, arg2)` | [`math`](math.md) | Maximum of two values (integer) |
| [`math::maxf`](math/maxf.md) | `math::maxf(arg1, arg2)` | [`math`](math.md) | Maximum of two values (float) — Usage: math::maxf a b [scale] |
| [`math::min`](math/min.md) | `math::min(arg1, arg2)` | [`math`](math.md) | Minimum of two values (integer) |
| [`math::minf`](math/minf.md) | `math::minf(arg1, arg2)` | [`math`](math.md) | Minimum of two values (float) — Usage: math::minf a b [scale] |
| [`math::mod`](math/mod.md) | `math::mod(arg1, arg2)` | [`math`](math.md) | Modulo |
| [`math::normalize`](math/normalize.md) | `math::normalize(value, min, max, [scale])` | [`math`](math.md) | Normalise a value to 0.0-1.0 range |
| [`math::percent`](math/percent.md) | `math::percent(part, total, [scale])` | [`math`](math.md) | Calculate percentage: (part / total) * 100 |
| [`math::percent_change`](math/percent_change.md) | `math::percent_change(old, new, [scale])` | [`math`](math.md) | Percentage change from old to new |
| [`math::percent_of`](math/percent_of.md) | `math::percent_of(percent, total, [scale])` | [`math`](math.md) | Calculate what value is p% of total |
| [`math::permute`](math/permute.md) | `math::permute(n, k)` | [`math`](math.md) | Number of permutations P(n, k) |
| [`math::pow`](math/pow.md) | `math::pow(base, exponent)` | [`math`](math.md) | Integer exponentiation |
| [`math::powf`](math/powf.md) | `math::powf(base, exponent)` | [`math`](math.md) | Power (floating point) |
| [`math::product`](math/product.md) | `math::product()` | [`math`](math.md) | Product of a sequence of integers |
| [`math::productf`](math/productf.md) | `math::productf(scale, n1, n2, n3, ...)` | [`math`](math.md) | Product of a sequence of floats |
| [`math::rad_to_deg`](math/rad_to_deg.md) | `math::rad_to_deg(arg1)` | [`math`](math.md) | Convert radians to degrees |
| [`math::round`](math/round.md) | `math::round(n, [decimal_places])` | [`math`](math.md) | Round to nearest integer (or to d decimal places) |
| [`math::sigmoid`](math/sigmoid.md) | `math::sigmoid(arr_name, [scale])` | [`math`](math.md) | Sigmoid — array-primary, operates in one awk pass |
| [`math::sigmoid::singleton`](math/sigmoid/singleton.md) | `math::sigmoid::singleton(value, [scale])` | [`math`](math.md) | Sigmoid — single value escape hatch |
| [`math::sin`](math/sin.md) | `math::sin(arg1)` | [`math`](math.md) | _No description available._ |
| [`math::softmax`](math/softmax.md) | `math::softmax(arr_name, [temperature, [scale]])` | [`math`](math.md) | Softmax — array-primary (singleton is degenerate: softmax of one value is always 1.0) |
| [`math::sqrt`](math/sqrt.md) | `math::sqrt(arg1)` | [`math`](math.md) | Square root |
| [`math::sum`](math/sum.md) | `math::sum(n1, n2, n3, ...)` | [`math`](math.md) | Sum of a sequence of integers |
| [`math::sumf`](math/sumf.md) | `math::sumf(scale, n1, n2, n3, ...)` | [`math`](math.md) | Sum of a sequence of floats |
| [`math::tan`](math/tan.md) | `math::tan(arg1)` | [`math`](math.md) | _No description available._ |
| [`math::unitconvert`](math/unitconvert.md) | `math::unitconvert(from, to, value, [scale])` | [`math`](math.md) | math::unitconvert — universal unit conversion dispatcher |
| [`math::vec2::add`](math/vec2/add.md) | `math::vec2::add(x1,y1 x2,y2)` | [`math`](math.md) | Add two vec2 vectors |
| [`math::vec2::addf`](math/vec2/addf.md) | `math::vec2::addf(scale x1,y1 x2,y2)` | [`math`](math.md) | Add two vec2 vectors with floating point precision |
| [`math::vec2::distance`](math/vec2/distance.md) | `math::vec2::distance(x1,y1 x2,y2)` | [`math`](math.md) | Distance between two vec2 points — requires bc |
| [`math::vec2::distancef`](math/vec2/distancef.md) | `math::vec2::distancef(scale x1,y1 x2,y2)` | [`math`](math.md) | Distance between two vec2 points with explicit scale |
| [`math::vec2::dot`](math/vec2/dot.md) | `math::vec2::dot(x1,y1 x2,y2)` | [`math`](math.md) | Dot product of two vec2 vectors |
| [`math::vec2::dotf`](math/vec2/dotf.md) | `math::vec2::dotf(scale x1,y1 x2,y2)` | [`math`](math.md) | Dot product of two vec2 vectors with floating point precision |
| [`math::vec2::eq`](math/vec2/eq.md) | `math::vec2::eq(x1,y1 x2,y2)` | [`math`](math.md) | Check if two vec2 vectors are equal |
| [`math::vec2::magnitude`](math/vec2/magnitude.md) | `math::vec2::magnitude(x,y)` | [`math`](math.md) | Magnitude (length) of a vec2 — requires bc |
| [`math::vec2::magnitudef`](math/vec2/magnitudef.md) | `math::vec2::magnitudef(scale x,y)` | [`math`](math.md) | Magnitude with explicit scale |
| [`math::vec2::normalise`](math/vec2/normalise.md) | `math::vec2::normalise(x,y)` | [`math`](math.md) | Normalise a vec2 to unit length — requires bc |
| [`math::vec2::normalisef`](math/vec2/normalisef.md) | `math::vec2::normalisef(scale x,y)` | [`math`](math.md) | Normalise a vec2 with explicit scale |
| [`math::vec2::scale`](math/vec2/scale.md) | `math::vec2::scale(x,y scalar)` | [`math`](math.md) | Scale a vec2 by a scalar |
| [`math::vec2::scalef`](math/vec2/scalef.md) | `math::vec2::scalef(scale x,y scalar)` | [`math`](math.md) | Scale a vec2 by a scalar with floating point precision |
| [`math::vec2::sub`](math/vec2/sub.md) | `math::vec2::sub(x1,y1 x2,y2)` | [`math`](math.md) | Subtract vec2 b from vec2 a |
| [`math::vec2::subf`](math/vec2/subf.md) | `math::vec2::subf(scale x1,y1 x2,y2)` | [`math`](math.md) | Subtract vec2 b from vec2 a with floating point precision |
| [`math::vec3::add`](math/vec3/add.md) | `math::vec3::add(x1,y1,z1 x2,y2,z2)` | [`math`](math.md) | Add two vec3 vectors |
| [`math::vec3::addf`](math/vec3/addf.md) | `math::vec3::addf(scale x1,y1,z1 x2,y2,z2)` | [`math`](math.md) | Add two vec3 vectors with floating point precision |
| [`math::vec3::cross`](math/vec3/cross.md) | `math::vec3::cross(x1,y1,z1 x2,y2,z2)` | [`math`](math.md) | Cross product of two vec3 vectors |
| [`math::vec3::crossf`](math/vec3/crossf.md) | `math::vec3::crossf(scale x1,y1,z1 x2,y2,z2)` | [`math`](math.md) | Cross product of two vec3 vectors with floating point precision |
| [`math::vec3::distance`](math/vec3/distance.md) | `math::vec3::distance(x1,y1,z1 x2,y2,z2)` | [`math`](math.md) | Distance between two vec3 points — requires bc |
| [`math::vec3::distancef`](math/vec3/distancef.md) | `math::vec3::distancef(scale x1,y1,z1 x2,y2,z2)` | [`math`](math.md) | Distance between two vec3 points with explicit scale |
| [`math::vec3::dot`](math/vec3/dot.md) | `math::vec3::dot(x1,y1,z1 x2,y2,z2)` | [`math`](math.md) | Dot product of two vec3 vectors |
| [`math::vec3::dotf`](math/vec3/dotf.md) | `math::vec3::dotf(scale x1,y1,z1 x2,y2,z2)` | [`math`](math.md) | Dot product of two vec3 vectors with floating point precision |
| [`math::vec3::eq`](math/vec3/eq.md) | `math::vec3::eq(x1,y1,z1 x2,y2,z2)` | [`math`](math.md) | Check if two vec3 vectors are equal |
| [`math::vec3::magnitude`](math/vec3/magnitude.md) | `math::vec3::magnitude(x,y,z)` | [`math`](math.md) | Magnitude (length) of a vec3 — requires bc |
| [`math::vec3::magnitudef`](math/vec3/magnitudef.md) | `math::vec3::magnitudef(scale x,y,z)` | [`math`](math.md) | Magnitude with explicit scale |
| [`math::vec3::new`](math/vec3/new.md) | `math::vec3::new()` | [`math`](math.md) | _No description available._ |
| [`math::vec3::new::fast`](math/vec3/new/fast.md) | `math::vec3::new::fast(arg1)` | [`math`](math.md) | _No description available._ |
| [`math::vec3::normalise`](math/vec3/normalise.md) | `math::vec3::normalise(x,y,z)` | [`math`](math.md) | Normalise a vec3 to unit length — requires bc |
| [`math::vec3::normalisef`](math/vec3/normalisef.md) | `math::vec3::normalisef(scale x,y,z)` | [`math`](math.md) | Normalise a vec3 with explicit scale |
| [`math::vec3::scale`](math/vec3/scale.md) | `math::vec3::scale(x,y,z scalar)` | [`math`](math.md) | Scale a vec3 by a scalar |
| [`math::vec3::scalef`](math/vec3/scalef.md) | `math::vec3::scalef(scale x,y,z scalar)` | [`math`](math.md) | Scale a vec3 by a scalar with floating point precision |
| [`math::vec3::sub`](math/vec3/sub.md) | `math::vec3::sub(x1,y1,z1 x2,y2,z2)` | [`math`](math.md) | Subtract vec3 b from vec3 a |
| [`math::vec3::subf`](math/vec3/subf.md) | `math::vec3::subf(scale x1,y1,z1 x2,y2,z2)` | [`math`](math.md) | Subtract vec3 b from vec3 a with floating point precision |

## N

| Function | Signature | Module | Description |
|----------|-----------|--------|-------------|
| [`net::can_reach`](net/can_reach.md) | `net::can_reach(host, [timeout_seconds])` | [`net`](net.md) | Check if a specific host is reachable |
| [`net::dns::mx`](net/dns/mx.md) | `net::dns::mx(arg1)` | [`net`](net.md) | Get MX records for a domain |
| [`net::dns::ns`](net/dns/ns.md) | `net::dns::ns(arg1)` | [`net`](net.md) | Get nameservers for a domain |
| [`net::dns::propagation`](net/dns/propagation.md) | `net::dns::propagation(hostname)` | [`net`](net.md) | Check DNS propagation — query multiple public resolvers |
| [`net::dns::records`](net/dns/records.md) | `net::dns::records(hostname, [type])` | [`net`](net.md) | Get all DNS records of a type |
| [`net::dns::txt`](net/dns/txt.md) | `net::dns::txt(arg1)` | [`net`](net.md) | Get TXT records (useful for SPF, DKIM etc.) |
| [`net::fetch`](net/fetch.md) | `net::fetch(url, [output_file])` | [`net`](net.md) | Fetch URL contents — curl/wget with fallback |
| [`net::fetch::progress`](net/fetch/progress.md) | `net::fetch::progress(arg1)` | [`net`](net.md) | Fetch with progress bar |
| [`net::fetch::retry`](net/fetch/retry.md) | `net::fetch::retry(url, [output], [retries], [delay])` | [`net`](net.md) | Fetch with retry on failure |
| [`net::gateway`](net/gateway.md) | `net::gateway(arg2, arg3)` | [`net`](net.md) | Get default gateway |
| [`net::hostname`](net/hostname.md) | `net::hostname()` | [`net`](net.md) | Get the system hostname |
| [`net::hostname::fqdn`](net/hostname/fqdn.md) | `net::hostname::fqdn()` | [`net`](net.md) | Get the fully qualified domain name |
| [`net::http::headers`](net/http/headers.md) | `net::http::headers(arg1)` | [`net`](net.md) | Get response headers |
| [`net::http::is_ok`](net/http/is_ok.md) | `net::http::is_ok(arg1)` | [`net`](net.md) | Check if a URL returns 200 OK |
| [`net::http::status`](net/http/status.md) | `net::http::status(url)` | [`net`](net.md) | Check HTTP status code of a URL |
| [`net::interface::is_up`](net/interface/is_up.md) | `net::interface::is_up(arg1)` | [`net`](net.md) | Check if an interface is up |
| [`net::interface::list`](net/interface/list.md) | `net::interface::list(arg2)` | [`net`](net.md) | List all network interfaces |
| [`net::interface::speed`](net/interface/speed.md) | `net::interface::speed()` | [`net`](net.md) | Get interface speed in Mbps |
| [`net::interface::stat`](net/interface/stat.md) | `net::interface::stat(s, interface)` | [`net`](net.md) | Get network interface statistics (rx/tx bytes) |
| [`net::interface::stat::rx`](net/interface/stat/rx.md) | `net::interface::stat::rx()` | [`net`](net.md) | _No description available._ |
| [`net::interface::stat::tx`](net/interface/stat/tx.md) | `net::interface::stat::tx()` | [`net`](net.md) | _No description available._ |
| [`net::ip::all`](net/ip/all.md) | `net::ip::all(arg2)` | [`net`](net.md) | Get all local IP addresses (one per line) |
| [`net::ip::geo`](net/ip/geo.md) | `net::ip::geo([ip], , (omit, for, public, IP))` | [`net`](net.md) | Get geolocation info for an IP (uses ip-api.com free tier) |
| [`net::ip::is_loopback`](net/ip/is_loopback.md) | `net::ip::is_loopback(arg1)` | [`net`](net.md) | Check if IP is loopback |
| [`net::ip::is_private`](net/ip/is_private.md) | `net::ip::is_private(arg1)` | [`net`](net.md) | Check if IP is in private range |
| [`net::ip::is_valid_v4`](net/ip/is_valid_v4.md) | `net::ip::is_valid_v4(arg1)` | [`net`](net.md) | Check if a string is a valid IPv4 address |
| [`net::ip::is_valid_v6`](net/ip/is_valid_v6.md) | `net::ip::is_valid_v6(arg1)` | [`net`](net.md) | Check if a string is a valid IPv6 address (basic check) |
| [`net::ip::local`](net/ip/local.md) | `net::ip::local(arg2)` | [`net`](net.md) | Get local IP address (first non-loopback) |
| [`net::ip::public`](net/ip/public.md) | `net::ip::public()` | [`net`](net.md) | Get public IP address |
| [`net::is_online`](net/is_online.md) | `net::is_online()` | [`net`](net.md) | Check if the system has a working internet connection |
| [`net::mac`](net/mac.md) | `net::mac(interface)` | [`net`](net.md) | Get MAC address of an interface |
| [`net::ping`](net/ping.md) | `net::ping(host, [count])` | [`net`](net.md) | Ping a host and return average round-trip time in ms |
| [`net::port::is_open`](net/port/is_open.md) | `net::port::is_open(host, port, [timeout])` | [`net`](net.md) | Check if a TCP port is open on a host |
| [`net::port::scan`](net/port/scan.md) | `net::port::scan(host, [start_port], [end_port])` | [`net`](net.md) | Scan common ports on a host, print open ones |
| [`net::port::wait`](net/port/wait.md) | `net::port::wait(host, port, [timeout_seconds], [interval])` | [`net`](net.md) | Wait until a port is open (useful for service readiness checks) |
| [`net::resolve`](net/resolve.md) | `net::resolve(hostname)` | [`net`](net.md) | Resolve hostname to IP |
| [`net::resolve::reverse`](net/resolve/reverse.md) | `net::resolve::reverse(ip)` | [`net`](net.md) | Reverse DNS lookup — IP to hostname |
| [`net::whois`](net/whois.md) | `net::whois(arg1)` | [`net`](net.md) | Basic whois lookup |

## P

| Function | Signature | Module | Description |
|----------|-----------|--------|-------------|
| [`pfloat::abs`](pfloat/abs.md) | `pfloat::abs()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::add`](pfloat/add.md) | `pfloat::add()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::avg`](pfloat/avg.md) | `pfloat::avg()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::cbrt`](pfloat/cbrt.md) | `pfloat::cbrt()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::ceil`](pfloat/ceil.md) | `pfloat::ceil()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::clamp`](pfloat/clamp.md) | `pfloat::clamp()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::dist2`](pfloat/dist2.md) | `pfloat::dist2()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::dist3`](pfloat/dist3.md) | `pfloat::dist3()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::div`](pfloat/div.md) | `pfloat::div()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::eq`](pfloat/eq.md) | `pfloat::eq()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::factorial`](pfloat/factorial.md) | `pfloat::factorial()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::abs`](pfloat/fixed/abs.md) | `pfloat::fixed::abs(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::add`](pfloat/fixed/add.md) | `pfloat::fixed::add(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::avg`](pfloat/fixed/avg.md) | `pfloat::fixed::avg()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::cbrt`](pfloat/fixed/cbrt.md) | `pfloat::fixed::cbrt(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::ceil`](pfloat/fixed/ceil.md) | `pfloat::fixed::ceil(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::clamp`](pfloat/fixed/clamp.md) | `pfloat::fixed::clamp(arg1, arg2, arg3)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::dist2`](pfloat/fixed/dist2.md) | `pfloat::fixed::dist2(arg1, arg2, arg3, arg4)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::dist3`](pfloat/fixed/dist3.md) | `pfloat::fixed::dist3(arg1, arg2, arg3, arg4, arg5)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::div`](pfloat/fixed/div.md) | `pfloat::fixed::div(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::eq`](pfloat/fixed/eq.md) | `pfloat::fixed::eq(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::factorial`](pfloat/fixed/factorial.md) | `pfloat::fixed::factorial(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::floor`](pfloat/fixed/floor.md) | `pfloat::fixed::floor(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::ge`](pfloat/fixed/ge.md) | `pfloat::fixed::ge(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::geomean`](pfloat/fixed/geomean.md) | `pfloat::fixed::geomean(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::gt`](pfloat/fixed/gt.md) | `pfloat::fixed::gt(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::harmean`](pfloat/fixed/harmean.md) | `pfloat::fixed::harmean(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::inv_lerp`](pfloat/fixed/inv_lerp.md) | `pfloat::fixed::inv_lerp(arg1, arg2, arg3)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::is_negative`](pfloat/fixed/is_negative.md) | `pfloat::fixed::is_negative(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::is_positive`](pfloat/fixed/is_positive.md) | `pfloat::fixed::is_positive(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::is_zero`](pfloat/fixed/is_zero.md) | `pfloat::fixed::is_zero(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::le`](pfloat/fixed/le.md) | `pfloat::fixed::le(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::lerp`](pfloat/fixed/lerp.md) | `pfloat::fixed::lerp(arg1, arg2, arg3)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::lt`](pfloat/fixed/lt.md) | `pfloat::fixed::lt(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::map`](pfloat/fixed/map.md) | `pfloat::fixed::map(arg1, arg2, arg3, arg4, arg5)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::max`](pfloat/fixed/max.md) | `pfloat::fixed::max(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::mean`](pfloat/fixed/mean.md) | `pfloat::fixed::mean(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::min`](pfloat/fixed/min.md) | `pfloat::fixed::min(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::mod`](pfloat/fixed/mod.md) | `pfloat::fixed::mod(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::mul`](pfloat/fixed/mul.md) | `pfloat::fixed::mul(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::ne`](pfloat/fixed/ne.md) | `pfloat::fixed::ne(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::neg`](pfloat/fixed/neg.md) | `pfloat::fixed::neg(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::normalize`](pfloat/fixed/normalize.md) | `pfloat::fixed::normalize(arg1, arg2, arg3)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::percent`](pfloat/fixed/percent.md) | `pfloat::fixed::percent(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::percent_change`](pfloat/fixed/percent_change.md) | `pfloat::fixed::percent_change(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::percent_of`](pfloat/fixed/percent_of.md) | `pfloat::fixed::percent_of(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::pow`](pfloat/fixed/pow.md) | `pfloat::fixed::pow(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::recip`](pfloat/fixed/recip.md) | `pfloat::fixed::recip(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::round`](pfloat/fixed/round.md) | `pfloat::fixed::round(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::sigmoid`](pfloat/fixed/sigmoid.md) | `pfloat::fixed::sigmoid(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::sign`](pfloat/fixed/sign.md) | `pfloat::fixed::sign(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::softplus`](pfloat/fixed/softplus.md) | `pfloat::fixed::softplus(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::sqr`](pfloat/fixed/sqr.md) | `pfloat::fixed::sqr(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::sqrt`](pfloat/fixed/sqrt.md) | `pfloat::fixed::sqrt(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::sub`](pfloat/fixed/sub.md) | `pfloat::fixed::sub(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::sum`](pfloat/fixed/sum.md) | `pfloat::fixed::sum()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::fixed::trunc`](pfloat/fixed/trunc.md) | `pfloat::fixed::trunc(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::floor`](pfloat/floor.md) | `pfloat::floor()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::ge`](pfloat/ge.md) | `pfloat::ge()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::geomean`](pfloat/geomean.md) | `pfloat::geomean()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::gt`](pfloat/gt.md) | `pfloat::gt()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::harmean`](pfloat/harmean.md) | `pfloat::harmean()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::ieee754::abs`](pfloat/ieee754/abs.md) | `pfloat::ieee754::abs(arg1)` | [`pfloat`](pfloat.md) | IEEE 754: Absolute value |
| [`pfloat::ieee754::add`](pfloat/ieee754/add.md) | `pfloat::ieee754::add(bits_a, bits_b)` | [`pfloat`](pfloat.md) | IEEE 754: Addition |
| [`pfloat::ieee754::div`](pfloat/ieee754/div.md) | `pfloat::ieee754::div(arg1, arg2, ...)` | [`pfloat`](pfloat.md) | IEEE 754: Division |
| [`pfloat::ieee754::dump`](pfloat/ieee754/dump.md) | `pfloat::ieee754::dump(bits)` | [`pfloat`](pfloat.md) | IEEE 754: Dump bit layout for diagnostics |
| [`pfloat::ieee754::eq`](pfloat/ieee754/eq.md) | `pfloat::ieee754::eq(arg1, arg2)` | [`pfloat`](pfloat.md) | IEEE 754: Comparison (returns 0 for true, 1 for false) |
| [`pfloat::ieee754::from_binary`](pfloat/ieee754/from_binary.md) | `pfloat::ieee754::from_binary(0011111111111000..., , , , , , , , , , #, flat, (64, chars))` | [`pfloat`](pfloat.md) | IEEE 754: Convert from binary string |
| [`pfloat::ieee754::from_int`](pfloat/ieee754/from_int.md) | `pfloat::ieee754::from_int(4607182418800017408)` | [`pfloat`](pfloat.md) | IEEE 754: Convert from 64-bit integer (raw bit pattern) |
| [`pfloat::ieee754::from_string`](pfloat/ieee754/from_string.md) | `pfloat::ieee754::from_string(arg1)` | [`pfloat`](pfloat.md) | IEEE 754: Convert from decimal string |
| [`pfloat::ieee754::ge`](pfloat/ieee754/ge.md) | `pfloat::ieee754::ge(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::ieee754::gt`](pfloat/ieee754/gt.md) | `pfloat::ieee754::gt(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::ieee754::is_finite`](pfloat/ieee754/is_finite.md) | `pfloat::ieee754::is_finite(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::ieee754::is_inf`](pfloat/ieee754/is_inf.md) | `pfloat::ieee754::is_inf(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::ieee754::is_nan`](pfloat/ieee754/is_nan.md) | `pfloat::ieee754::is_nan(arg1)` | [`pfloat`](pfloat.md) | IEEE 754: Classification |
| [`pfloat::ieee754::is_negative`](pfloat/ieee754/is_negative.md) | `pfloat::ieee754::is_negative(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::ieee754::is_positive`](pfloat/ieee754/is_positive.md) | `pfloat::ieee754::is_positive(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::ieee754::is_zero`](pfloat/ieee754/is_zero.md) | `pfloat::ieee754::is_zero(arg1)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::ieee754::le`](pfloat/ieee754/le.md) | `pfloat::ieee754::le(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::ieee754::lt`](pfloat/ieee754/lt.md) | `pfloat::ieee754::lt(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::ieee754::mul`](pfloat/ieee754/mul.md) | `pfloat::ieee754::mul(arg1, arg2, ...)` | [`pfloat`](pfloat.md) | IEEE 754: Multiplication |
| [`pfloat::ieee754::ne`](pfloat/ieee754/ne.md) | `pfloat::ieee754::ne(arg1, arg2)` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::ieee754::neg`](pfloat/ieee754/neg.md) | `pfloat::ieee754::neg(arg1)` | [`pfloat`](pfloat.md) | IEEE 754: Negation |
| [`pfloat::ieee754::sign`](pfloat/ieee754/sign.md) | `pfloat::ieee754::sign(arg1)` | [`pfloat`](pfloat.md) | IEEE 754: Sign (-1, 0, or 1) |
| [`pfloat::ieee754::sqrt`](pfloat/ieee754/sqrt.md) | `pfloat::ieee754::sqrt(arg1)` | [`pfloat`](pfloat.md) | IEEE 754: Square root (Newton-Raphson iteration) |
| [`pfloat::ieee754::sub`](pfloat/ieee754/sub.md) | `pfloat::ieee754::sub(arg1, arg2)` | [`pfloat`](pfloat.md) | IEEE 754: Subtraction (uses addition with negated operand) |
| [`pfloat::ieee754::to_binary`](pfloat/ieee754/to_binary.md) | `pfloat::ieee754::to_binary(bits, [separator])` | [`pfloat`](pfloat.md) | IEEE 754: Convert to binary string |
| [`pfloat::ieee754::to_int`](pfloat/ieee754/to_int.md) | `pfloat::ieee754::to_int(bits)` | [`pfloat`](pfloat.md) | IEEE 754: Convert to 64-bit integer (raw bit pattern) |
| [`pfloat::ieee754::to_string`](pfloat/ieee754/to_string.md) | `pfloat::ieee754::to_string(arg1)` | [`pfloat`](pfloat.md) | IEEE 754: Convert to decimal string |
| [`pfloat::inv_lerp`](pfloat/inv_lerp.md) | `pfloat::inv_lerp()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::is_negative`](pfloat/is_negative.md) | `pfloat::is_negative()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::is_positive`](pfloat/is_positive.md) | `pfloat::is_positive()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::is_zero`](pfloat/is_zero.md) | `pfloat::is_zero()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::le`](pfloat/le.md) | `pfloat::le()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::lerp`](pfloat/lerp.md) | `pfloat::lerp()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::lt`](pfloat/lt.md) | `pfloat::lt()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::map`](pfloat/map.md) | `pfloat::map()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::max`](pfloat/max.md) | `pfloat::max()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::mean`](pfloat/mean.md) | `pfloat::mean()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::min`](pfloat/min.md) | `pfloat::min()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::mod`](pfloat/mod.md) | `pfloat::mod()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::mul`](pfloat/mul.md) | `pfloat::mul()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::ne`](pfloat/ne.md) | `pfloat::ne()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::neg`](pfloat/neg.md) | `pfloat::neg()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::normalize`](pfloat/normalize.md) | `pfloat::normalize()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::percent`](pfloat/percent.md) | `pfloat::percent()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::percent_change`](pfloat/percent_change.md) | `pfloat::percent_change()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::percent_of`](pfloat/percent_of.md) | `pfloat::percent_of()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::pow`](pfloat/pow.md) | `pfloat::pow()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::recip`](pfloat/recip.md) | `pfloat::recip()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::round`](pfloat/round.md) | `pfloat::round()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::sigmoid`](pfloat/sigmoid.md) | `pfloat::sigmoid()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::sign`](pfloat/sign.md) | `pfloat::sign()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::softplus`](pfloat/softplus.md) | `pfloat::softplus()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::sqr`](pfloat/sqr.md) | `pfloat::sqr()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::sqrt`](pfloat/sqrt.md) | `pfloat::sqrt()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::sub`](pfloat/sub.md) | `pfloat::sub()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::sum`](pfloat/sum.md) | `pfloat::sum()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pfloat::trunc`](pfloat/trunc.md) | `pfloat::trunc()` | [`pfloat`](pfloat.md) | _No description available._ |
| [`pm::install`](pm/install.md) | `pm::install()` | [`pm`](pm.md) | !/usr/bin/env bash |
| [`pm::search`](pm/search.md) | `pm::search(arg1)` | [`pm`](pm.md) | _No description available._ |
| [`pm::sync`](pm/sync.md) | `pm::sync()` | [`pm`](pm.md) | _No description available._ |
| [`pm::uninstall`](pm/uninstall.md) | `pm::uninstall()` | [`pm`](pm.md) | _No description available._ |
| [`pm::update`](pm/update.md) | `pm::update()` | [`pm`](pm.md) | _No description available._ |
| [`process::cmdline`](process/cmdline.md) | `process::cmdline(pid)` | [`process`](process.md) | Get command line of a process |
| [`process::cpu`](process/cpu.md) | `process::cpu(pid)` | [`process`](process.md) | Get CPU usage percentage for a PID |
| [`process::cwd`](process/cwd.md) | `process::cwd(pid)` | [`process`](process.md) | Get process working directory |
| [`process::env`](process/env.md) | `process::env(pid, varname)` | [`process`](process.md) | Get process environment variable |
| [`process::fd_count`](process/fd_count.md) | `process::fd_count(arg1)` | [`process`](process.md) | Get number of open file descriptors for a PID |
| [`process::find`](process/find.md) | `process::find(pattern)` | [`process`](process.md) | Find processes matching a pattern (name or cmdline) |
| [`process::is_running`](process/is_running.md) | `process::is_running(pid)` | [`process`](process.md) | Check if a process is running by PID |
| [`process::is_running::name`](process/is_running/name.md) | `process::is_running::name(name)` | [`process`](process.md) | Check if a process is running by name |
| [`process::is_zombie`](process/is_zombie.md) | `process::is_zombie(arg1)` | [`process`](process.md) | Check if a process is a zombie |
| [`process::job::list`](process/job/list.md) | `process::job::list()` | [`process`](process.md) | List current shell's background jobs |
| [`process::job::status`](process/job/status.md) | `process::job::status(arg1)` | [`process`](process.md) | Get exit status of last background job |
| [`process::job::wait`](process/job/wait.md) | `process::job::wait(arg1)` | [`process`](process.md) | Wait for a specific background job by PID |
| [`process::job::wait_all`](process/job/wait_all.md) | `process::job::wait_all()` | [`process`](process.md) | Wait for all background jobs to finish |
| [`process::kill`](process/kill.md) | `process::kill(arg1)` | [`process`](process.md) | Terminate a process (SIGTERM) |
| [`process::kill::force`](process/kill/force.md) | `process::kill::force(arg1)` | [`process`](process.md) | Force kill a process (SIGKILL) |
| [`process::kill::graceful`](process/kill/graceful.md) | `process::kill::graceful(pid, [timeout_seconds])` | [`process`](process.md) | Graceful kill — SIGTERM, wait, then SIGKILL if still running |
| [`process::kill::name`](process/kill/name.md) | `process::kill::name(arg1)` | [`process`](process.md) | Kill all processes matching a name |
| [`process::list`](process/list.md) | `process::list()` | [`process`](process.md) | List all running processes (PID and name) |
| [`process::lock::acquire`](process/lock/acquire.md) | `process::lock::acquire(lockname)` | [`process`](process.md) | Acquire a lock — returns 1 if already locked |
| [`process::lock::is_locked`](process/lock/is_locked.md) | `process::lock::is_locked(lockname)` | [`process`](process.md) | Check if a lock is held |
| [`process::lock::release`](process/lock/release.md) | `process::lock::release(lockname)` | [`process`](process.md) | Release a lock |
| [`process::lock::wait`](process/lock/wait.md) | `process::lock::wait(lockname, [timeout])` | [`process`](process.md) | Wait for a lock to become available |
| [`process::memory`](process/memory.md) | `process::memory(pid)` | [`process`](process.md) | Get memory usage in KB for a PID |
| [`process::memory::percent`](process/memory/percent.md) | `process::memory::percent(arg1)` | [`process`](process.md) | Get memory usage as percentage |
| [`process::name`](process/name.md) | `process::name(pid)` | [`process`](process.md) | Get process name from PID |
| [`process::pid`](process/pid.md) | `process::pid(name)` | [`process`](process.md) | Get PID(s) of a named process (one per line) |
| [`process::ppid`](process/ppid.md) | `process::ppid(pid)` | [`process`](process.md) | Get parent PID of a process |
| [`process::reload`](process/reload.md) | `process::reload(arg1)` | [`process`](process.md) | Reload a process config (SIGHUP) |
| [`process::renice`](process/renice.md) | `process::renice(pid, value)` | [`process`](process.md) | Change process priority (nice value, -20 to 19) |
| [`process::resume`](process/resume.md) | `process::resume(arg1)` | [`process`](process.md) | Resume a suspended process (SIGCONT) |
| [`process::retry`](process/retry.md) | `process::retry(times, delay, command, [args...])` | [`process`](process.md) | Retry a command n times with a delay between attempts |
| [`process::run_bg`](process/run_bg.md) | `process::run_bg(command, [args...])` | [`process`](process.md) | Run a command in the background, print its PID |
| [`process::run_bg::log`](process/run_bg/log.md) | `process::run_bg::log(logfile, command, [args...])` | [`process`](process.md) | Run a command in the background, redirect output to a log file |
| [`process::run_bg::timeout`](process/run_bg/timeout.md) | `process::run_bg::timeout(seconds, command, [args...])` | [`process`](process.md) | Run a command in the background with a timeout |
| [`process::self`](process/self.md) | `process::self()` | [`process`](process.md) | Get PID of current shell |
| [`process::service::is_enabled`](process/service/is_enabled.md) | `process::service::is_enabled(arg1)` | [`process`](process.md) | Check if a service is enabled at boot |
| [`process::service::is_running`](process/service/is_running.md) | `process::service::is_running(service_name)` | [`process`](process.md) | Check if a systemd service is running |
| [`process::service::restart`](process/service/restart.md) | `process::service::restart(arg1)` | [`process`](process.md) | Restart a systemd service |
| [`process::service::start`](process/service/start.md) | `process::service::start(arg1)` | [`process`](process.md) | Start a systemd service |
| [`process::service::stop`](process/service/stop.md) | `process::service::stop(arg1)` | [`process`](process.md) | Stop a systemd service |
| [`process::signal`](process/signal.md) | `process::signal(pid, signal)` | [`process`](process.md) | Send a signal to a process |
| [`process::singleton`](process/singleton.md) | `process::singleton(lockname, command, [args...])` | [`process`](process.md) | Run command only if not already running (singleton) |
| [`process::start_time`](process/start_time.md) | `process::start_time(arg1)` | [`process`](process.md) | Get process start time (unix timestamp) |
| [`process::state`](process/state.md) | `process::state(pid)` | [`process`](process.md) | Get process state (R=running, S=sleeping, Z=zombie, etc.) |
| [`process::suspend`](process/suspend.md) | `process::suspend(arg1)` | [`process`](process.md) | Suspend a process (SIGSTOP) |
| [`process::thread_count`](process/thread_count.md) | `process::thread_count(arg1, arg2)` | [`process`](process.md) | Get number of threads for a PID |
| [`process::time`](process/time.md) | `process::time(command, [args...])` | [`process`](process.md) | Run a command and return its execution time in seconds |
| [`process::timeout`](process/timeout.md) | `process::timeout(seconds, command, [args...])` | [`process`](process.md) | Run a command with a timeout, kill it if it exceeds |
| [`process::tree`](process/tree.md) | `process::tree([pid])` | [`process`](process.md) | Get process tree from a PID |
| [`process::uptime`](process/uptime.md) | `process::uptime(arg1, arg2)` | [`process`](process.md) | Get process uptime in seconds |
| [`process::wait`](process/wait.md) | `process::wait(pid, [timeout_seconds])` | [`process`](process.md) | Wait for a process to finish |

## R

| Function | Signature | Module | Description |
|----------|-----------|--------|-------------|
| [`random::isaac`](random/isaac.md) | `random::isaac(a, b, c, s0..s7)` | [`random`](random.md) | Returns: "result new_a new_b new_c s0..s7" |
| [`random::isaac::init`](random/isaac/init.md) | `random::isaac::init(seed)` | [`random`](random.md) | Initialise simplified ISAAC state |
| [`random::lcg`](random/lcg.md) | `random::lcg(state)` | [`random`](random.md) | Returns: next state (also the output value) |
| [`random::lcg::glibc`](random/lcg/glibc.md) | `random::lcg::glibc(arg1)` | [`random`](random.md) | Glibc rand() parameters |
| [`random::middle_square`](random/middle_square.md) | `random::middle_square(seed)` | [`random`](random.md) | Returns: next value (4-digit middle square extract) |
| [`random::mulberry32`](random/mulberry32.md) | `random::mulberry32(state)` | [`random`](random.md) | Returns: "result new_state" |
| [`random::native`](random/native.md) | `random::native()` | [`random`](random.md) | _No description available._ |
| [`random::native::range`](random/native/range.md) | `random::native::range(min, max)` | [`random`](random.md) | Returns a value in [min, max] inclusive |
| [`random::pcg32`](random/pcg32.md) | `random::pcg32(state, inc)` | [`random`](random.md) | Returns: "result new_state" |
| [`random::pcg32::fast`](random/pcg32/fast.md) | `random::pcg32::fast(state)` | [`random`](random.md) | PCG32 fast — hardcoded increment, same quality |
| [`random::seed32`](random/seed32.md) | `random::seed32()` | [`random`](random.md) | Seed from /dev/urandom — returns a 32-bit unsigned integer |
| [`random::seed64`](random/seed64.md) | `random::seed64()` | [`random`](random.md) | Seed from /dev/urandom — returns a 64-bit value (may be negative in bash) |
| [`random::splitmix64`](random/splitmix64.md) | `random::splitmix64(state)` | [`random`](random.md) | Returns: "result new_state" |
| [`random::splitmix64::seed_xoshiro`](random/splitmix64/seed_xoshiro.md) | `random::splitmix64::seed_xoshiro(seed)` | [`random`](random.md) | Expand a single 64-bit seed into four words for xoshiro256 initialisation |
| [`random::well512`](random/well512.md) | `random::well512(index, s0, s1, ..., s15)` | [`random`](random.md) | Returns: "result new_index s0 ... s15" |
| [`random::well512::init`](random/well512/init.md) | `random::well512::init(seed)` | [`random`](random.md) | Initialise WELL512 state from a single seed via splitmix64 |
| [`random::wyrand`](random/wyrand.md) | `random::wyrand(state)` | [`random`](random.md) | Returns: "result new_state" |
| [`random::xorshift32`](random/xorshift32.md) | `random::xorshift32(state)` | [`random`](random.md) | Returns: next state (also the output value) |
| [`random::xorshift64`](random/xorshift64.md) | `random::xorshift64(state)` | [`random`](random.md) | Returns: next state (also the output value) |
| [`random::xorshiftr128plus`](random/xorshiftr128plus.md) | `random::xorshiftr128plus(s0, s1)` | [`random`](random.md) | Returns: "result s0_new s1_new" |
| [`random::xoshiro256p`](random/xoshiro256p.md) | `random::xoshiro256p(same, as, xoshiro256ss)` | [`random`](random.md) | Xoshiro256+ — faster output, slightly weaker low bits |
| [`random::xoshiro256ss`](random/xoshiro256ss.md) | `random::xoshiro256ss(s0, s1, s2, s3)` | [`random`](random.md) | Returns: "result s0_new s1_new s2_new s3_new" |
| [`runtime::arch`](runtime/arch.md) | `runtime::arch()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::bash_version`](runtime/bash_version.md) | `runtime::bash_version()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::bash_version::major`](runtime/bash_version/major.md) | `runtime::bash_version::major()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::braceexpand_enabled`](runtime/braceexpand_enabled.md) | `runtime::braceexpand_enabled()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::de`](runtime/de.md) | `runtime::de()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::debug_trapped`](runtime/debug_trapped.md) | `runtime::debug_trapped()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::distro`](runtime/distro.md) | `runtime::distro()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::errexit_enabled`](runtime/errexit_enabled.md) | `runtime::errexit_enabled()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::exec_root`](runtime/exec_root.md) | `runtime::exec_root()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::has_command`](runtime/has_command.md) | `runtime::has_command(arg1)` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::has_flag`](runtime/has_flag.md) | `runtime::has_flag(arg1)` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::histexpand_enabled`](runtime/histexpand_enabled.md) | `runtime::histexpand_enabled()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_bash`](runtime/is_bash.md) | `runtime::is_bash()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_ci`](runtime/is_ci.md) | `runtime::is_ci()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_container`](runtime/is_container.md) | `runtime::is_container()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_desktop`](runtime/is_desktop.md) | `runtime::is_desktop()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_interactive`](runtime/is_interactive.md) | `runtime::is_interactive()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_login`](runtime/is_login.md) | `runtime::is_login()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_minimum_bash`](runtime/is_minimum_bash.md) | `runtime::is_minimum_bash()` | [`runtime`](runtime.md) | Default to 3, assuming that's what's at least needed for this framework (not final) |
| [`runtime::is_multiplexer`](runtime/is_multiplexer.md) | `runtime::is_multiplexer()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_pipe`](runtime/is_pipe.md) | `runtime::is_pipe()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_pty`](runtime/is_pty.md) | `runtime::is_pty()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_redirected`](runtime/is_redirected.md) | `runtime::is_redirected()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_root`](runtime/is_root.md) | `runtime::is_root()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_sourced`](runtime/is_sourced.md) | `runtime::is_sourced()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_ssh`](runtime/is_ssh.md) | `runtime::is_ssh()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_subshell`](runtime/is_subshell.md) | `runtime::is_subshell()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_sudo`](runtime/is_sudo.md) | `runtime::is_sudo()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_terminal`](runtime/is_terminal.md) | `runtime::is_terminal()` | [`runtime`](runtime.md) | !/usr/bin/env bash |
| [`runtime::is_terminal::stderr`](runtime/is_terminal/stderr.md) | `runtime::is_terminal::stderr()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_terminal::stdin`](runtime/is_terminal/stdin.md) | `runtime::is_terminal::stdin()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_terminal::stdout`](runtime/is_terminal/stdout.md) | `runtime::is_terminal::stdout()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_tmux`](runtime/is_tmux.md) | `runtime::is_tmux()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_traced`](runtime/is_traced.md) | `runtime::is_traced()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_tty`](runtime/is_tty.md) | `runtime::is_tty()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_verbose`](runtime/is_verbose.md) | `runtime::is_verbose()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_virtualized`](runtime/is_virtualized.md) | `runtime::is_virtualized()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_wayland`](runtime/is_wayland.md) | `runtime::is_wayland()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_wsl`](runtime/is_wsl.md) | `runtime::is_wsl()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::is_x11`](runtime/is_x11.md) | `runtime::is_x11()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::job_controlled`](runtime/job_controlled.md) | `runtime::job_controlled()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::kernel_version`](runtime/kernel_version.md) | `runtime::kernel_version()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::noclobber_enabled`](runtime/noclobber_enabled.md) | `runtime::noclobber_enabled()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::nounset_enabled`](runtime/nounset_enabled.md) | `runtime::nounset_enabled()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::os`](runtime/os.md) | `runtime::os()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::physical_cd_enabled`](runtime/physical_cd_enabled.md) | `runtime::physical_cd_enabled()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::pm`](runtime/pm.md) | `runtime::pm()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::screen_session`](runtime/screen_session.md) | `runtime::screen_session()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::ssh_client`](runtime/ssh_client.md) | `runtime::ssh_client()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::supports_color`](runtime/supports_color.md) | `runtime::supports_color()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::supports_truecolor`](runtime/supports_truecolor.md) | `runtime::supports_truecolor()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::sysinit`](runtime/sysinit.md) | `runtime::sysinit()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::tty_name`](runtime/tty_name.md) | `runtime::tty_name()` | [`runtime`](runtime.md) | _No description available._ |
| [`runtime::wm`](runtime/wm.md) | `runtime::wm()` | [`runtime`](runtime.md) | _No description available._ |

## S

| Function | Signature | Module | Description |
|----------|-----------|--------|-------------|
| [`string::after`](string/after.md) | `string::after(str, delimiter)` | [`string`](string.md) | Return everything after the first occurrence of delimiter |
| [`string::after::fast`](string/after/fast.md) | `string::after::fast(result_var, str, delimiter)` | [`string`](string.md) | Fast variant using nameref |
| [`string::after_last`](string/after_last.md) | `string::after_last(str, delimiter)` | [`string`](string.md) | Return everything after the last occurrence of delimiter |
| [`string::after_last::fast`](string/after_last/fast.md) | `string::after_last::fast(result_var, str, delimiter)` | [`string`](string.md) | Fast variant using nameref |
| [`string::base32_decode`](string/base32_decode.md) | `string::base32_decode(arg1)` | [`string`](string.md) | _No description available._ |
| [`string::base32_decode::fast`](string/base32_decode/fast.md) | `string::base32_decode::fast(result_var, str)` | [`string`](string.md) | Fast variant using nameref |
| [`string::base32_decode::pure`](string/base32_decode/pure.md) | `string::base32_decode::pure()` | [`string`](string.md) | _No description available._ |
| [`string::base32_encode`](string/base32_encode.md) | `string::base32_encode(arg1)` | [`string`](string.md) | _No description available._ |
| [`string::base32_encode::fast`](string/base32_encode/fast.md) | `string::base32_encode::fast(result_var, str)` | [`string`](string.md) | Fast variant using nameref |
| [`string::base32_encode::pure`](string/base32_encode/pure.md) | `string::base32_encode::pure()` | [`string`](string.md) | _No description available._ |
| [`string::base64_decode`](string/base64_decode.md) | `string::base64_decode(str)` | [`string`](string.md) | Base64 decode |
| [`string::base64_decode::fast`](string/base64_decode/fast.md) | `string::base64_decode::fast(result_var, str)` | [`string`](string.md) | Fast variant using nameref |
| [`string::base64_decode::pure`](string/base64_decode/pure.md) | `string::base64_decode::pure()` | [`string`](string.md) | _No description available._ |
| [`string::base64_encode`](string/base64_encode.md) | `string::base64_encode(str)` | [`string`](string.md) | Base64 encode |
| [`string::base64_encode::fast`](string/base64_encode/fast.md) | `string::base64_encode::fast(result_var, str)` | [`string`](string.md) | Fast variant using nameref |
| [`string::base64_encode::pure`](string/base64_encode/pure.md) | `string::base64_encode::pure()` | [`string`](string.md) | _No description available._ |
| [`string::before`](string/before.md) | `string::before(str, delimiter)` | [`string`](string.md) | Return everything before the first occurrence of delimiter |
| [`string::before::fast`](string/before/fast.md) | `string::before::fast(result_var, str, delimiter)` | [`string`](string.md) | Fast variant using nameref |
| [`string::before_last`](string/before_last.md) | `string::before_last(str, delimiter)` | [`string`](string.md) | Return everything before the last occurrence of delimiter |
| [`string::before_last::fast`](string/before_last/fast.md) | `string::before_last::fast(result_var, str, delimiter)` | [`string`](string.md) | Fast variant using nameref |
| [`string::camel_to_constant`](string/camel_to_constant.md) | `string::camel_to_constant()` | [`string`](string.md) | camelCase → CONSTANT_CASE |
| [`string::camel_to_constant::fast`](string/camel_to_constant/fast.md) | `string::camel_to_constant::fast(result_var, arg1, arg2)` | [`string`](string.md) | Fast variant using nameref |
| [`string::camel_to_dot`](string/camel_to_dot.md) | `string::camel_to_dot()` | [`string`](string.md) | camelCase → dot.case |
| [`string::camel_to_dot::fast`](string/camel_to_dot/fast.md) | `string::camel_to_dot::fast(result_var, arg1, arg2)` | [`string`](string.md) | Fast variant using nameref |
| [`string::camel_to_kebab`](string/camel_to_kebab.md) | `string::camel_to_kebab()` | [`string`](string.md) | camelCase → kebab-case |
| [`string::camel_to_kebab::fast`](string/camel_to_kebab/fast.md) | `string::camel_to_kebab::fast(result_var, arg1, arg2)` | [`string`](string.md) | Fast variant using nameref |
| [`string::camel_to_pascal`](string/camel_to_pascal.md) | `string::camel_to_pascal()` | [`string`](string.md) | camelCase → PascalCase |
| [`string::camel_to_pascal::fast`](string/camel_to_pascal/fast.md) | `string::camel_to_pascal::fast(result_var, arg1, arg2)` | [`string`](string.md) | Fast variant using nameref |
| [`string::camel_to_path`](string/camel_to_path.md) | `string::camel_to_path()` | [`string`](string.md) | camelCase → path/case |
| [`string::camel_to_path::fast`](string/camel_to_path/fast.md) | `string::camel_to_path::fast(result_var, arg1, arg2)` | [`string`](string.md) | Fast variant using nameref |
| [`string::camel_to_plain`](string/camel_to_plain.md) | `string::camel_to_plain()` | [`string`](string.md) | camelCase → plain |
| [`string::camel_to_plain::fast`](string/camel_to_plain/fast.md) | `string::camel_to_plain::fast(result_var, arg1, arg2)` | [`string`](string.md) | Fast variant using nameref |
| [`string::camel_to_snake`](string/camel_to_snake.md) | `string::camel_to_snake()` | [`string`](string.md) | camelCase → snake_case |
| [`string::camel_to_snake::fast`](string/camel_to_snake/fast.md) | `string::camel_to_snake::fast(result_var, arg1, arg2)` | [`string`](string.md) | Fast variant using nameref |
| [`string::capitalise`](string/capitalise.md) | `string::capitalise(str)` | [`string`](string.md) | Capitalise first character only |
| [`string::capitalise::fast`](string/capitalise/fast.md) | `string::capitalise::fast(result_var, str)` | [`string`](string.md) | Fast variant using nameref |
| [`string::capitalise::legacy`](string/capitalise/legacy.md) | `string::capitalise::legacy()` | [`string`](string.md) | Capitalise first character (Bash 3 compatible) |
| [`string::collapse_spaces`](string/collapse_spaces.md) | `string::collapse_spaces(str)` | [`string`](string.md) | Collapse multiple consecutive spaces into one |
| [`string::collapse_spaces::fast`](string/collapse_spaces/fast.md) | `string::collapse_spaces::fast(result_var, str)` | [`string`](string.md) | Fast variant using nameref (requires tr) |
| [`string::constant_to_camel`](string/constant_to_camel.md) | `string::constant_to_camel()` | [`string`](string.md) | CONSTANT_CASE → camelCase |
| [`string::constant_to_camel::fast`](string/constant_to_camel/fast.md) | `string::constant_to_camel::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::constant_to_dot`](string/constant_to_dot.md) | `string::constant_to_dot()` | [`string`](string.md) | CONSTANT_CASE → dot.case |
| [`string::constant_to_dot::fast`](string/constant_to_dot/fast.md) | `string::constant_to_dot::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::constant_to_kebab`](string/constant_to_kebab.md) | `string::constant_to_kebab()` | [`string`](string.md) | CONSTANT_CASE → kebab-case |
| [`string::constant_to_kebab::fast`](string/constant_to_kebab/fast.md) | `string::constant_to_kebab::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::constant_to_pascal`](string/constant_to_pascal.md) | `string::constant_to_pascal()` | [`string`](string.md) | CONSTANT_CASE → PascalCase |
| [`string::constant_to_pascal::fast`](string/constant_to_pascal/fast.md) | `string::constant_to_pascal::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::constant_to_path`](string/constant_to_path.md) | `string::constant_to_path()` | [`string`](string.md) | CONSTANT_CASE → path/case |
| [`string::constant_to_path::fast`](string/constant_to_path/fast.md) | `string::constant_to_path::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::constant_to_plain`](string/constant_to_plain.md) | `string::constant_to_plain()` | [`string`](string.md) | CONSTANT_CASE → plain |
| [`string::constant_to_plain::fast`](string/constant_to_plain/fast.md) | `string::constant_to_plain::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::constant_to_snake`](string/constant_to_snake.md) | `string::constant_to_snake()` | [`string`](string.md) | CONSTANT_CASE → snake_case |
| [`string::constant_to_snake::fast`](string/constant_to_snake/fast.md) | `string::constant_to_snake::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::contains`](string/contains.md) | `string::contains(haystack, needle)` | [`string`](string.md) | Check if string contains substring |
| [`string::dot_to_camel`](string/dot_to_camel.md) | `string::dot_to_camel()` | [`string`](string.md) | dot.case → camelCase |
| [`string::dot_to_camel::fast`](string/dot_to_camel/fast.md) | `string::dot_to_camel::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::dot_to_constant`](string/dot_to_constant.md) | `string::dot_to_constant()` | [`string`](string.md) | dot.case → CONSTANT_CASE |
| [`string::dot_to_constant::fast`](string/dot_to_constant/fast.md) | `string::dot_to_constant::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::dot_to_kebab`](string/dot_to_kebab.md) | `string::dot_to_kebab()` | [`string`](string.md) | dot.case → kebab-case |
| [`string::dot_to_kebab::fast`](string/dot_to_kebab/fast.md) | `string::dot_to_kebab::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::dot_to_pascal`](string/dot_to_pascal.md) | `string::dot_to_pascal()` | [`string`](string.md) | dot.case → PascalCase |
| [`string::dot_to_pascal::fast`](string/dot_to_pascal/fast.md) | `string::dot_to_pascal::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::dot_to_path`](string/dot_to_path.md) | `string::dot_to_path()` | [`string`](string.md) | dot.case → path/case |
| [`string::dot_to_path::fast`](string/dot_to_path/fast.md) | `string::dot_to_path::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::dot_to_plain`](string/dot_to_plain.md) | `string::dot_to_plain()` | [`string`](string.md) | dot.case → plain |
| [`string::dot_to_plain::fast`](string/dot_to_plain/fast.md) | `string::dot_to_plain::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::dot_to_snake`](string/dot_to_snake.md) | `string::dot_to_snake()` | [`string`](string.md) | dot.case → snake_case |
| [`string::dot_to_snake::fast`](string/dot_to_snake/fast.md) | `string::dot_to_snake::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::ends_with`](string/ends_with.md) | `string::ends_with(str, suffix)` | [`string`](string.md) | Check if string ends with suffix |
| [`string::index_of`](string/index_of.md) | `string::index_of(haystack, needle)` | [`string`](string.md) | Index of first occurrence of substring (-1 if not found) |
| [`string::is_alnum`](string/is_alnum.md) | `string::is_alnum()` | [`string`](string.md) | Check if string is alphanumeric only |
| [`string::is_alpha`](string/is_alpha.md) | `string::is_alpha()` | [`string`](string.md) | Check if string is alphabetic only |
| [`string::is_bin`](string/is_bin.md) | `string::is_bin()` | [`string`](string.md) | _No description available._ |
| [`string::is_empty`](string/is_empty.md) | `string::is_empty()` | [`string`](string.md) | Check if string is empty |
| [`string::is_float`](string/is_float.md) | `string::is_float()` | [`string`](string.md) | Check if string is a valid float |
| [`string::is_hex`](string/is_hex.md) | `string::is_hex()` | [`string`](string.md) | _No description available._ |
| [`string::is_integer`](string/is_integer.md) | `string::is_integer()` | [`string`](string.md) | Check if string is a valid integer |
| [`string::is_not_empty`](string/is_not_empty.md) | `string::is_not_empty()` | [`string`](string.md) | Check if string is non-empty |
| [`string::is_numeric`](string/is_numeric.md) | `string::is_numeric()` | [`string`](string.md) | _No description available._ |
| [`string::is_octal`](string/is_octal.md) | `string::is_octal()` | [`string`](string.md) | _No description available._ |
| [`string::join`](string/join.md) | `string::join(delimiter, arg1, arg2, ...)` | [`string`](string.md) | Join an array of arguments with a delimiter |
| [`string::join::fast`](string/join/fast.md) | `string::join::fast(result_var, delimiter, arg1, arg2, ...)` | [`string`](string.md) | Fast variant using nameref |
| [`string::kebab_to_camel`](string/kebab_to_camel.md) | `string::kebab_to_camel()` | [`string`](string.md) | kebab-case → camelCase |
| [`string::kebab_to_camel::fast`](string/kebab_to_camel/fast.md) | `string::kebab_to_camel::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::kebab_to_constant`](string/kebab_to_constant.md) | `string::kebab_to_constant()` | [`string`](string.md) | kebab-case → CONSTANT_CASE |
| [`string::kebab_to_constant::fast`](string/kebab_to_constant/fast.md) | `string::kebab_to_constant::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::kebab_to_dot`](string/kebab_to_dot.md) | `string::kebab_to_dot()` | [`string`](string.md) | kebab-case → dot.case |
| [`string::kebab_to_dot::fast`](string/kebab_to_dot/fast.md) | `string::kebab_to_dot::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::kebab_to_pascal`](string/kebab_to_pascal.md) | `string::kebab_to_pascal()` | [`string`](string.md) | kebab-case → PascalCase |
| [`string::kebab_to_pascal::fast`](string/kebab_to_pascal/fast.md) | `string::kebab_to_pascal::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::kebab_to_path`](string/kebab_to_path.md) | `string::kebab_to_path()` | [`string`](string.md) | kebab-case → path/case |
| [`string::kebab_to_path::fast`](string/kebab_to_path/fast.md) | `string::kebab_to_path::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::kebab_to_plain`](string/kebab_to_plain.md) | `string::kebab_to_plain()` | [`string`](string.md) | kebab-case → plain |
| [`string::kebab_to_plain::fast`](string/kebab_to_plain/fast.md) | `string::kebab_to_plain::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::kebab_to_snake`](string/kebab_to_snake.md) | `string::kebab_to_snake()` | [`string`](string.md) | kebab-case → snake_case |
| [`string::kebab_to_snake::fast`](string/kebab_to_snake/fast.md) | `string::kebab_to_snake::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::length`](string/length.md) | `string::length(str)` | [`string`](string.md) | Length of a string |
| [`string::lower`](string/lower.md) | `string::lower(str)` | [`string`](string.md) | Convert to lowercase |
| [`string::lower::fast`](string/lower/fast.md) | `string::lower::fast(result_var, str)` | [`string`](string.md) | Fast variant using nameref |
| [`string::lower::legacy`](string/lower/legacy.md) | `string::lower::legacy()` | [`string`](string.md) | Convert to lowercase (Bash 3 compatible) |
| [`string::matches`](string/matches.md) | `string::matches(str, regex)` | [`string`](string.md) | Check if string matches a regex |
| [`string::md5`](string/md5.md) | `string::md5()` | [`string`](string.md) | MD5 hash of a string |
| [`string::pad_center`](string/pad_center.md) | `string::pad_center(str, width, [char])` | [`string`](string.md) | Centre a string within a given width |
| [`string::pad_center::fast`](string/pad_center/fast.md) | `string::pad_center::fast(result_var, str, width, [char])` | [`string`](string.md) | Fast variant using nameref |
| [`string::pad_left`](string/pad_left.md) | `string::pad_left(str, width, [char])` | [`string`](string.md) | Pad string on the left to a given width |
| [`string::pad_left::fast`](string/pad_left/fast.md) | `string::pad_left::fast(result_var, str, width, [char])` | [`string`](string.md) | Fast variant using nameref |
| [`string::pad_right`](string/pad_right.md) | `string::pad_right(str, width, [char])` | [`string`](string.md) | Pad string on the right to a given width |
| [`string::pad_right::fast`](string/pad_right/fast.md) | `string::pad_right::fast(result_var, str, width, [char])` | [`string`](string.md) | Fast variant using nameref |
| [`string::pascal_to_camel`](string/pascal_to_camel.md) | `string::pascal_to_camel()` | [`string`](string.md) | PascalCase → camelCase |
| [`string::pascal_to_camel::fast`](string/pascal_to_camel/fast.md) | `string::pascal_to_camel::fast(result_var, arg1, arg2)` | [`string`](string.md) | Fast variant using nameref |
| [`string::pascal_to_constant`](string/pascal_to_constant.md) | `string::pascal_to_constant()` | [`string`](string.md) | PascalCase → CONSTANT_CASE |
| [`string::pascal_to_constant::fast`](string/pascal_to_constant/fast.md) | `string::pascal_to_constant::fast(result_var, arg1, arg2)` | [`string`](string.md) | Fast variant using nameref |
| [`string::pascal_to_dot`](string/pascal_to_dot.md) | `string::pascal_to_dot()` | [`string`](string.md) | PascalCase → dot.case |
| [`string::pascal_to_dot::fast`](string/pascal_to_dot/fast.md) | `string::pascal_to_dot::fast(result_var, arg1, arg2)` | [`string`](string.md) | Fast variant using nameref |
| [`string::pascal_to_kebab`](string/pascal_to_kebab.md) | `string::pascal_to_kebab()` | [`string`](string.md) | PascalCase → kebab-case |
| [`string::pascal_to_kebab::fast`](string/pascal_to_kebab/fast.md) | `string::pascal_to_kebab::fast(result_var, arg1, arg2)` | [`string`](string.md) | Fast variant using nameref |
| [`string::pascal_to_path`](string/pascal_to_path.md) | `string::pascal_to_path()` | [`string`](string.md) | PascalCase → path/case |
| [`string::pascal_to_path::fast`](string/pascal_to_path/fast.md) | `string::pascal_to_path::fast(result_var, arg1, arg2)` | [`string`](string.md) | Fast variant using nameref |
| [`string::pascal_to_plain`](string/pascal_to_plain.md) | `string::pascal_to_plain()` | [`string`](string.md) | PascalCase → plain |
| [`string::pascal_to_plain::fast`](string/pascal_to_plain/fast.md) | `string::pascal_to_plain::fast(result_var, arg1, arg2)` | [`string`](string.md) | Fast variant using nameref |
| [`string::pascal_to_snake`](string/pascal_to_snake.md) | `string::pascal_to_snake()` | [`string`](string.md) | PascalCase → snake_case |
| [`string::pascal_to_snake::fast`](string/pascal_to_snake/fast.md) | `string::pascal_to_snake::fast(result_var, arg1, arg2)` | [`string`](string.md) | Fast variant using nameref |
| [`string::path_to_camel`](string/path_to_camel.md) | `string::path_to_camel()` | [`string`](string.md) | path/case → camelCase |
| [`string::path_to_camel::fast`](string/path_to_camel/fast.md) | `string::path_to_camel::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::path_to_constant`](string/path_to_constant.md) | `string::path_to_constant()` | [`string`](string.md) | path/case → CONSTANT_CASE |
| [`string::path_to_constant::fast`](string/path_to_constant/fast.md) | `string::path_to_constant::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::path_to_dot`](string/path_to_dot.md) | `string::path_to_dot()` | [`string`](string.md) | path/case → dot.case |
| [`string::path_to_dot::fast`](string/path_to_dot/fast.md) | `string::path_to_dot::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::path_to_kebab`](string/path_to_kebab.md) | `string::path_to_kebab()` | [`string`](string.md) | path/case → kebab-case |
| [`string::path_to_kebab::fast`](string/path_to_kebab/fast.md) | `string::path_to_kebab::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::path_to_pascal`](string/path_to_pascal.md) | `string::path_to_pascal()` | [`string`](string.md) | path/case → PascalCase |
| [`string::path_to_pascal::fast`](string/path_to_pascal/fast.md) | `string::path_to_pascal::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::path_to_plain`](string/path_to_plain.md) | `string::path_to_plain()` | [`string`](string.md) | path/case → plain |
| [`string::path_to_plain::fast`](string/path_to_plain/fast.md) | `string::path_to_plain::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::path_to_snake`](string/path_to_snake.md) | `string::path_to_snake()` | [`string`](string.md) | path/case → snake_case |
| [`string::path_to_snake::fast`](string/path_to_snake/fast.md) | `string::path_to_snake::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::plain_to_camel`](string/plain_to_camel.md) | `string::plain_to_camel()` | [`string`](string.md) | plain → camelCase |
| [`string::plain_to_camel::fast`](string/plain_to_camel/fast.md) | `string::plain_to_camel::fast(result_var, arg1, arg2)` | [`string`](string.md) | Fast variant using nameref |
| [`string::plain_to_constant`](string/plain_to_constant.md) | `string::plain_to_constant()` | [`string`](string.md) | plain → CONSTANT_CASE |
| [`string::plain_to_constant::fast`](string/plain_to_constant/fast.md) | `string::plain_to_constant::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::plain_to_dot`](string/plain_to_dot.md) | `string::plain_to_dot()` | [`string`](string.md) | plain → dot.case |
| [`string::plain_to_dot::fast`](string/plain_to_dot/fast.md) | `string::plain_to_dot::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::plain_to_kebab`](string/plain_to_kebab.md) | `string::plain_to_kebab()` | [`string`](string.md) | plain → kebab-case |
| [`string::plain_to_kebab::fast`](string/plain_to_kebab/fast.md) | `string::plain_to_kebab::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::plain_to_pascal`](string/plain_to_pascal.md) | `string::plain_to_pascal()` | [`string`](string.md) | plain → PascalCase |
| [`string::plain_to_pascal::fast`](string/plain_to_pascal/fast.md) | `string::plain_to_pascal::fast(result_var, arg1, arg2)` | [`string`](string.md) | Fast variant using nameref |
| [`string::plain_to_path`](string/plain_to_path.md) | `string::plain_to_path()` | [`string`](string.md) | plain → path/case |
| [`string::plain_to_path::fast`](string/plain_to_path/fast.md) | `string::plain_to_path::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::plain_to_snake`](string/plain_to_snake.md) | `string::plain_to_snake(hello, world, →, hello_world)` | [`string`](string.md) | plain (space-separated) → snake_case |
| [`string::plain_to_snake::fast`](string/plain_to_snake/fast.md) | `string::plain_to_snake::fast(result_var, hello, world)` | [`string`](string.md) | Fast variant using nameref |
| [`string::random`](string/random.md) | `string::random([length])` | [`string`](string.md) | Generate a random alphanumeric string of given length |
| [`string::remove`](string/remove.md) | `string::remove(str, substring)` | [`string`](string.md) | Remove all occurrences of a substring |
| [`string::remove::fast`](string/remove/fast.md) | `string::remove::fast(result_var, str, substring)` | [`string`](string.md) | Fast variant using nameref |
| [`string::remove_first`](string/remove_first.md) | `string::remove_first(str, substring)` | [`string`](string.md) | Remove first occurrence of a substring |
| [`string::remove_first::fast`](string/remove_first/fast.md) | `string::remove_first::fast(result_var, str, substring)` | [`string`](string.md) | Fast variant using nameref |
| [`string::repeat`](string/repeat.md) | `string::repeat(str, n)` | [`string`](string.md) | Repeat a string n times |
| [`string::repeat::fast`](string/repeat/fast.md) | `string::repeat::fast(result_var, str, n)` | [`string`](string.md) | Fast variant using nameref |
| [`string::replace`](string/replace.md) | `string::replace(str, search, replace)` | [`string`](string.md) | Replace first occurrence of search with replace |
| [`string::replace_all`](string/replace_all.md) | `string::replace_all(str, search, replace)` | [`string`](string.md) | Replace all occurrences of search with replace |
| [`string::replace_all::fast`](string/replace_all/fast.md) | `string::replace_all::fast(result_var, str, search, replace)` | [`string`](string.md) | Fast variant using nameref |
| [`string::replace::fast`](string/replace/fast.md) | `string::replace::fast(result_var, str, search, replace)` | [`string`](string.md) | Fast variant using nameref |
| [`string::reverse`](string/reverse.md) | `string::reverse(str)` | [`string`](string.md) | Reverse a string |
| [`string::reverse::fast`](string/reverse/fast.md) | `string::reverse::fast(result_var, str)` | [`string`](string.md) | Fast variant using nameref (requires rev or awk) |
| [`string::sha256`](string/sha256.md) | `string::sha256()` | [`string`](string.md) | SHA256 hash of a string |
| [`string::snake_to_camel`](string/snake_to_camel.md) | `string::snake_to_camel()` | [`string`](string.md) | snake_case → camelCase |
| [`string::snake_to_camel::fast`](string/snake_to_camel/fast.md) | `string::snake_to_camel::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::snake_to_constant`](string/snake_to_constant.md) | `string::snake_to_constant()` | [`string`](string.md) | snake_case → CONSTANT_CASE |
| [`string::snake_to_constant::fast`](string/snake_to_constant/fast.md) | `string::snake_to_constant::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::snake_to_dot`](string/snake_to_dot.md) | `string::snake_to_dot()` | [`string`](string.md) | snake_case → dot.case |
| [`string::snake_to_dot::fast`](string/snake_to_dot/fast.md) | `string::snake_to_dot::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::snake_to_kebab`](string/snake_to_kebab.md) | `string::snake_to_kebab()` | [`string`](string.md) | snake_case → kebab-case |
| [`string::snake_to_kebab::fast`](string/snake_to_kebab/fast.md) | `string::snake_to_kebab::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::snake_to_pascal`](string/snake_to_pascal.md) | `string::snake_to_pascal()` | [`string`](string.md) | snake_case → PascalCase |
| [`string::snake_to_pascal::fast`](string/snake_to_pascal/fast.md) | `string::snake_to_pascal::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::snake_to_path`](string/snake_to_path.md) | `string::snake_to_path()` | [`string`](string.md) | snake_case → path/case |
| [`string::snake_to_path::fast`](string/snake_to_path/fast.md) | `string::snake_to_path::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::snake_to_plain`](string/snake_to_plain.md) | `string::snake_to_plain()` | [`string`](string.md) | snake_case → plain |
| [`string::snake_to_plain::fast`](string/snake_to_plain/fast.md) | `string::snake_to_plain::fast(result_var, arg1)` | [`string`](string.md) | Fast variant using nameref |
| [`string::split`](string/split.md) | `string::split(str, delimiter)` | [`string`](string.md) | Split a string by delimiter into lines (one element per line) |
| [`string::starts_with`](string/starts_with.md) | `string::starts_with(str, prefix)` | [`string`](string.md) | Check if string starts with prefix |
| [`string::strip_spaces`](string/strip_spaces.md) | `string::strip_spaces(str)` | [`string`](string.md) | Remove all whitespace |
| [`string::strip_spaces::fast`](string/strip_spaces/fast.md) | `string::strip_spaces::fast(result_var, str)` | [`string`](string.md) | Fast variant using nameref |
| [`string::substr`](string/substr.md) | `string::substr(str, start, [length])` | [`string`](string.md) | Extract substring |
| [`string::substr::fast`](string/substr/fast.md) | `string::substr::fast(result_var, str, start, [length])` | [`string`](string.md) | Fast variant using nameref |
| [`string::title`](string/title.md) | `string::title(str)` | [`string`](string.md) | Convert to title case (capitalise first letter of each word) |
| [`string::title::fast`](string/title/fast.md) | `string::title::fast(result_var, str)` | [`string`](string.md) | Fast variant using nameref (requires awk) |
| [`string::trim`](string/trim.md) | `string::trim(str)` | [`string`](string.md) | Trim both leading and trailing whitespace |
| [`string::trim::fast`](string/trim/fast.md) | `string::trim::fast(result_var, str)` | [`string`](string.md) | Fast variant using nameref |
| [`string::trim_left`](string/trim_left.md) | `string::trim_left(str)` | [`string`](string.md) | Trim leading whitespace |
| [`string::trim_left::fast`](string/trim_left/fast.md) | `string::trim_left::fast(result_var, str)` | [`string`](string.md) | Fast variant using nameref |
| [`string::trim_right`](string/trim_right.md) | `string::trim_right(str)` | [`string`](string.md) | Trim trailing whitespace |
| [`string::trim_right::fast`](string/trim_right/fast.md) | `string::trim_right::fast(result_var, str)` | [`string`](string.md) | Fast variant using nameref |
| [`string::truncate`](string/truncate.md) | `string::truncate(str, max, [suffix])` | [`string`](string.md) | Truncate a string to max length, appending suffix if truncated |
| [`string::truncate::fast`](string/truncate/fast.md) | `string::truncate::fast(result_var, str, max, [suffix])` | [`string`](string.md) | Fast variant using nameref |
| [`string::upper`](string/upper.md) | `string::upper(str)` | [`string`](string.md) | Convert to uppercase |
| [`string::upper::fast`](string/upper/fast.md) | `string::upper::fast(result_var, str)` | [`string`](string.md) | Fast variant using nameref |
| [`string::upper::legacy`](string/upper/legacy.md) | `string::upper::legacy()` | [`string`](string.md) | Convert to uppercase (Bash 3 compatible) |
| [`string::url_decode`](string/url_decode.md) | `string::url_decode()` | [`string`](string.md) | _No description available._ |
| [`string::url_decode::fast`](string/url_decode/fast.md) | `string::url_decode::fast(result_var, str)` | [`string`](string.md) | Fast variant using nameref |
| [`string::url_encode`](string/url_encode.md) | `string::url_encode(str)` | [`string`](string.md) | URL-encode a string |
| [`string::url_encode::fast`](string/url_encode/fast.md) | `string::url_encode::fast(result_var, str)` | [`string`](string.md) | Fast variant using nameref |
| [`string::uuid`](string/uuid.md) | `string::uuid()` | [`string`](string.md) | Generate a UUID v4 (random) |

## T

| Function | Signature | Module | Description |
|----------|-----------|--------|-------------|
| [`terminal::bell`](terminal/bell.md) | `terminal::bell()` | [`terminal`](terminal.md) | Ring the terminal bell |
| [`terminal::clear`](terminal/clear.md) | `terminal::clear()` | [`terminal`](terminal.md) | Clear entire screen |
| [`terminal::clear::line`](terminal/clear/line.md) | `terminal::clear::line()` | [`terminal`](terminal.md) | Clear current line |
| [`terminal::clear::line_end`](terminal/clear/line_end.md) | `terminal::clear::line_end()` | [`terminal`](terminal.md) | Clear from cursor to end of line |
| [`terminal::clear::line_start`](terminal/clear/line_start.md) | `terminal::clear::line_start()` | [`terminal`](terminal.md) | Clear from cursor to start of line |
| [`terminal::clear::to_end`](terminal/clear/to_end.md) | `terminal::clear::to_end()` | [`terminal`](terminal.md) | Clear from cursor to end of screen |
| [`terminal::clear::to_start`](terminal/clear/to_start.md) | `terminal::clear::to_start()` | [`terminal`](terminal.md) | Clear from cursor to beginning of screen |
| [`terminal::confirm`](terminal/confirm.md) | `terminal::confirm(Are, you, sure?)` | [`terminal`](terminal.md) | Prompt user for y/n, returns 0 for yes, 1 for no |
| [`terminal::confirm::default`](terminal/confirm/default.md) | `terminal::confirm::default(yes, Proceed?)` | [`terminal`](terminal.md) | Prompt with a default choice shown |
| [`terminal::cursor::col`](terminal/cursor/col.md) | `terminal::cursor::col()` | [`terminal`](terminal.md) | Move cursor to column n on current line |
| [`terminal::cursor::down`](terminal/cursor/down.md) | `terminal::cursor::down()` | [`terminal`](terminal.md) | Move cursor down n rows |
| [`terminal::cursor::hide`](terminal/cursor/hide.md) | `terminal::cursor::hide()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::cursor::home`](terminal/cursor/home.md) | `terminal::cursor::home()` | [`terminal`](terminal.md) | Move cursor to top-left (home) |
| [`terminal::cursor::left`](terminal/cursor/left.md) | `terminal::cursor::left()` | [`terminal`](terminal.md) | Move cursor left n cols |
| [`terminal::cursor::move`](terminal/cursor/move.md) | `terminal::cursor::move(row, col)` | [`terminal`](terminal.md) | Move cursor to row, col (1-indexed) |
| [`terminal::cursor::next_line`](terminal/cursor/next_line.md) | `terminal::cursor::next_line()` | [`terminal`](terminal.md) | Move cursor to start of line n lines down |
| [`terminal::cursor::prev_line`](terminal/cursor/prev_line.md) | `terminal::cursor::prev_line()` | [`terminal`](terminal.md) | Move cursor to start of line n lines up |
| [`terminal::cursor::restore`](terminal/cursor/restore.md) | `terminal::cursor::restore()` | [`terminal`](terminal.md) | Restore cursor to saved position |
| [`terminal::cursor::right`](terminal/cursor/right.md) | `terminal::cursor::right()` | [`terminal`](terminal.md) | Move cursor right n cols |
| [`terminal::cursor::save`](terminal/cursor/save.md) | `terminal::cursor::save()` | [`terminal`](terminal.md) | Save cursor position |
| [`terminal::cursor::show`](terminal/cursor/show.md) | `terminal::cursor::show()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::cursor::toggle`](terminal/cursor/toggle.md) | `terminal::cursor::toggle()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::cursor::up`](terminal/cursor/up.md) | `terminal::cursor::up()` | [`terminal`](terminal.md) | Move cursor up n rows |
| [`terminal::echo::off`](terminal/echo/off.md) | `terminal::echo::off()` | [`terminal`](terminal.md) | Disable terminal echo (e.g. for password input) |
| [`terminal::echo::on`](terminal/echo/on.md) | `terminal::echo::on()` | [`terminal`](terminal.md) | Re-enable terminal echo |
| [`terminal::has_256colour`](terminal/has_256colour.md) | `terminal::has_256colour()` | [`terminal`](terminal.md) | Check if terminal supports 256 colours |
| [`terminal::has_colour`](terminal/has_colour.md) | `terminal::has_colour()` | [`terminal`](terminal.md) | Check if terminal supports colours |
| [`terminal::has_truecolour`](terminal/has_truecolour.md) | `terminal::has_truecolour()` | [`terminal`](terminal.md) | Check if terminal supports true colour |
| [`terminal::height`](terminal/height.md) | `terminal::height()` | [`terminal`](terminal.md) | Get terminal height in rows |
| [`terminal::is_tty`](terminal/is_tty.md) | `terminal::is_tty()` | [`terminal`](terminal.md) | Check if stdout is a terminal |
| [`terminal::is_tty::stderr`](terminal/is_tty/stderr.md) | `terminal::is_tty::stderr()` | [`terminal`](terminal.md) | Check if stderr is a terminal |
| [`terminal::is_tty::stdin`](terminal/is_tty/stdin.md) | `terminal::is_tty::stdin()` | [`terminal`](terminal.md) | Check if stdin is a terminal |
| [`terminal::name`](terminal/name.md) | `terminal::name()` | [`terminal`](terminal.md) | Return the terminal emulator name if detectable |
| [`terminal::read_key`](terminal/read_key.md) | `terminal::read_key(varname)` | [`terminal`](terminal.md) | Read a single keypress without requiring Enter |
| [`terminal::read_key::timeout`](terminal/read_key/timeout.md) | `terminal::read_key::timeout(varname, seconds)` | [`terminal`](terminal.md) | Read a single keypress with a timeout |
| [`terminal::read_password`](terminal/read_password.md) | `terminal::read_password(varname, [prompt])` | [`terminal`](terminal.md) | Read a password (no echo) |
| [`terminal::screen::alternate`](terminal/screen/alternate.md) | `terminal::screen::alternate()` | [`terminal`](terminal.md) | Enter alternate screen buffer (like vim/less do) |
| [`terminal::screen::alternate_enter`](terminal/screen/alternate_enter.md) | `terminal::screen::alternate_enter()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::screen::alternate_exit`](terminal/screen/alternate_exit.md) | `terminal::screen::alternate_exit()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::screen::normal`](terminal/screen/normal.md) | `terminal::screen::normal()` | [`terminal`](terminal.md) | Return to normal screen buffer |
| [`terminal::screen::wrap`](terminal/screen/wrap.md) | `terminal::screen::wrap(command, [args...])` | [`terminal`](terminal.md) | Enter alternate screen, run a command, return to normal screen |
| [`terminal::scroll::down`](terminal/scroll/down.md) | `terminal::scroll::down()` | [`terminal`](terminal.md) | Scroll down n lines |
| [`terminal::scroll::up`](terminal/scroll/up.md) | `terminal::scroll::up()` | [`terminal`](terminal.md) | Scroll up n lines |
| [`terminal::shopt::autocd::disable`](terminal/shopt/autocd/disable.md) | `terminal::shopt::autocd::disable()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::shopt::autocd::enable`](terminal/shopt/autocd/enable.md) | `terminal::shopt::autocd::enable()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::shopt::cdspell::disable`](terminal/shopt/cdspell/disable.md) | `terminal::shopt::cdspell::disable()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::shopt::cdspell::enable`](terminal/shopt/cdspell/enable.md) | `terminal::shopt::cdspell::enable()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::shopt::checkwinsize::disable`](terminal/shopt/checkwinsize/disable.md) | `terminal::shopt::checkwinsize::disable()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::shopt::checkwinsize::enable`](terminal/shopt/checkwinsize/enable.md) | `terminal::shopt::checkwinsize::enable()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::shopt::disable`](terminal/shopt/disable.md) | `terminal::shopt::disable(arg1)` | [`terminal`](terminal.md) | Disable a shopt option |
| [`terminal::shopt::dotglob::disable`](terminal/shopt/dotglob/disable.md) | `terminal::shopt::dotglob::disable()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::shopt::dotglob::enable`](terminal/shopt/dotglob/enable.md) | `terminal::shopt::dotglob::enable()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::shopt::enable`](terminal/shopt/enable.md) | `terminal::shopt::enable(arg1)` | [`terminal`](terminal.md) | Enable a shopt option, return 1 if unsupported |
| [`terminal::shopt::extglob::disable`](terminal/shopt/extglob/disable.md) | `terminal::shopt::extglob::disable()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::shopt::extglob::enable`](terminal/shopt/extglob/enable.md) | `terminal::shopt::extglob::enable()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::shopt::get`](terminal/shopt/get.md) | `terminal::shopt::get(arg1, arg2)` | [`terminal`](terminal.md) | Get current value of a shopt option ("on" or "off") |
| [`terminal::shopt::globstar::disable`](terminal/shopt/globstar/disable.md) | `terminal::shopt::globstar::disable()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::shopt::globstar::enable`](terminal/shopt/globstar/enable.md) | `terminal::shopt::globstar::enable()` | [`terminal`](terminal.md) | Common shopt convenience toggles |
| [`terminal::shopt::histappend::disable`](terminal/shopt/histappend/disable.md) | `terminal::shopt::histappend::disable()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::shopt::histappend::enable`](terminal/shopt/histappend/enable.md) | `terminal::shopt::histappend::enable()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::shopt::is_enabled`](terminal/shopt/is_enabled.md) | `terminal::shopt::is_enabled(arg1)` | [`terminal`](terminal.md) | Check if a shopt option is enabled |
| [`terminal::shopt::list::disabled`](terminal/shopt/list/disabled.md) | `terminal::shopt::list::disabled(arg1, arg2)` | [`terminal`](terminal.md) | List all disabled shopt options |
| [`terminal::shopt::list::enabled`](terminal/shopt/list/enabled.md) | `terminal::shopt::list::enabled(arg1, arg2)` | [`terminal`](terminal.md) | List all enabled shopt options |
| [`terminal::shopt::load`](terminal/shopt/load.md) | `terminal::shopt::load(varname)` | [`terminal`](terminal.md) | Restore state from a variable |
| [`terminal::shopt::nocaseglob::disable`](terminal/shopt/nocaseglob/disable.md) | `terminal::shopt::nocaseglob::disable()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::shopt::nocaseglob::enable`](terminal/shopt/nocaseglob/enable.md) | `terminal::shopt::nocaseglob::enable()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::shopt::nocasematch::disable`](terminal/shopt/nocasematch/disable.md) | `terminal::shopt::nocasematch::disable()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::shopt::nocasematch::enable`](terminal/shopt/nocasematch/enable.md) | `terminal::shopt::nocasematch::enable()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::shopt::nullglob::disable`](terminal/shopt/nullglob/disable.md) | `terminal::shopt::nullglob::disable()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::shopt::nullglob::enable`](terminal/shopt/nullglob/enable.md) | `terminal::shopt::nullglob::enable()` | [`terminal`](terminal.md) | _No description available._ |
| [`terminal::shopt::save`](terminal/shopt/save.md) | `terminal::shopt::save(eval, $(terminal::shopt::save))` | [`terminal`](terminal.md) | Save current shopt state (prints a restore command) |
| [`terminal::size`](terminal/size.md) | `terminal::size()` | [`terminal`](terminal.md) | Get both as "cols rows" |
| [`terminal::title`](terminal/title.md) | `terminal::title(My, Script)` | [`terminal`](terminal.md) | Set terminal title (works in most modern terminal emulators) |
| [`terminal::width`](terminal/width.md) | `terminal::width()` | [`terminal`](terminal.md) | Get terminal width in columns |
| [`timedate::calendar::day_of_year`](timedate/calendar/day_of_year.md) | `timedate::calendar::day_of_year(YYYY-MM-DD)` | [`timedate`](timedate.md) | Get day of year for a date |
| [`timedate::calendar::days_in_year`](timedate/calendar/days_in_year.md) | `timedate::calendar::days_in_year(arg1)` | [`timedate`](timedate.md) | Get number of days in a year |
| [`timedate::calendar::easter`](timedate/calendar/easter.md) | `timedate::calendar::easter(year)` | [`timedate`](timedate.md) | Calculate Easter date for a given year (Meeus/Jones/Butcher algorithm) |
| [`timedate::calendar::is_leap_year`](timedate/calendar/is_leap_year.md) | `timedate::calendar::is_leap_year(year)` | [`timedate`](timedate.md) | Check if a year is a leap year |
| [`timedate::calendar::iso_week`](timedate/calendar/iso_week.md) | `timedate::calendar::iso_week(YYYY-MM-DD)` | [`timedate`](timedate.md) | Get ISO week number for a date |
| [`timedate::calendar::is_weekday`](timedate/calendar/is_weekday.md) | `timedate::calendar::is_weekday(arg1)` | [`timedate`](timedate.md) | Check if a date falls on a weekday |
| [`timedate::calendar::is_weekend`](timedate/calendar/is_weekend.md) | `timedate::calendar::is_weekend(YYYY-MM-DD)` | [`timedate`](timedate.md) | Check if a date falls on a weekend |
| [`timedate::calendar::month`](timedate/calendar/month.md) | `timedate::calendar::month([year], [month])` | [`timedate`](timedate.md) | Get the calendar for a month (like cal command) |
| [`timedate::calendar::quarter`](timedate/calendar/quarter.md) | `timedate::calendar::quarter(YYYY-MM-DD)` | [`timedate`](timedate.md) | Get quarter for a date |
| [`timedate::calendar::weekdays_between`](timedate/calendar/weekdays_between.md) | `timedate::calendar::weekdays_between(YYYY-MM-DD, YYYY-MM-DD)` | [`timedate`](timedate.md) | Number of weekdays between two dates |
| [`timedate::date::add_days`](timedate/date/add_days.md) | `timedate::date::add_days(YYYY-MM-DD, n)` | [`timedate`](timedate.md) | Add n days to a date |
| [`timedate::date::add_months`](timedate/date/add_months.md) | `timedate::date::add_months(arg1, arg2)` | [`timedate`](timedate.md) | Add n months to a date |
| [`timedate::date::add_years`](timedate/date/add_years.md) | `timedate::date::add_years(arg1, arg2)` | [`timedate`](timedate.md) | Add n years to a date |
| [`timedate::date::compare`](timedate/date/compare.md) | `timedate::date::compare(YYYY-MM-DD, YYYY-MM-DD)` | [`timedate`](timedate.md) | Compare two dates — returns -1, 0, or 1 |
| [`timedate::date::day`](timedate/date/day.md) | `timedate::date::day()` | [`timedate`](timedate.md) | Get day of month (01-31) |
| [`timedate::date::day_name`](timedate/date/day_name.md) | `timedate::date::day_name()` | [`timedate`](timedate.md) | Get day of week name |
| [`timedate::date::day_name::short`](timedate/date/day_name/short.md) | `timedate::date::day_name::short()` | [`timedate`](timedate.md) | Get day of week short name |
| [`timedate::date::day_of_week`](timedate/date/day_of_week.md) | `timedate::date::day_of_week()` | [`timedate`](timedate.md) | Get day of week (1=Monday, 7=Sunday, ISO 8601) |
| [`timedate::date::day_of_year`](timedate/date/day_of_year.md) | `timedate::date::day_of_year()` | [`timedate`](timedate.md) | Get day of year (001-366) |
| [`timedate::date::days_between`](timedate/date/days_between.md) | `timedate::date::days_between(YYYY-MM-DD, YYYY-MM-DD)` | [`timedate`](timedate.md) | Number of days between two dates |
| [`timedate::date::days_in_month`](timedate/date/days_in_month.md) | `timedate::date::days_in_month(year, month)` | [`timedate`](timedate.md) | Get last day of a given month |
| [`timedate::date::format`](timedate/date/format.md) | `timedate::date::format([format], [timestamp])` | [`timedate`](timedate.md) | Current date in a custom format |
| [`timedate::date::is_after`](timedate/date/is_after.md) | `timedate::date::is_after(arg1, arg2)` | [`timedate`](timedate.md) | Check if a date is after another |
| [`timedate::date::is_before`](timedate/date/is_before.md) | `timedate::date::is_before(arg1, arg2)` | [`timedate`](timedate.md) | Check if a date is before another |
| [`timedate::date::is_between`](timedate/date/is_between.md) | `timedate::date::is_between(arg1, arg2, arg3)` | [`timedate`](timedate.md) | Check if a date is between two dates (inclusive) |
| [`timedate::date::month`](timedate/date/month.md) | `timedate::date::month()` | [`timedate`](timedate.md) | Get month (01-12) |
| [`timedate::date::month_end`](timedate/date/month_end.md) | `timedate::date::month_end()` | [`timedate`](timedate.md) | Get end of current month |
| [`timedate::date::month_start`](timedate/date/month_start.md) | `timedate::date::month_start()` | [`timedate`](timedate.md) | Get start of current month |
| [`timedate::date::next_weekday`](timedate/date/next_weekday.md) | `timedate::date::next_weekday(weekday_number (1=Mon, 7=Sun))` | [`timedate`](timedate.md) | Next occurrence of a weekday from today |
| [`timedate::date::prev_weekday`](timedate/date/prev_weekday.md) | `timedate::date::prev_weekday(arg1)` | [`timedate`](timedate.md) | Previous occurrence of a weekday |
| [`timedate::date::quarter`](timedate/date/quarter.md) | `timedate::date::quarter()` | [`timedate`](timedate.md) | Get quarter (1-4) |
| [`timedate::date::sub_days`](timedate/date/sub_days.md) | `timedate::date::sub_days(arg1, arg2)` | [`timedate`](timedate.md) | Subtract n days from a date |
| [`timedate::date::today`](timedate/date/today.md) | `timedate::date::today()` | [`timedate`](timedate.md) | Current date in YYYY-MM-DD format |
| [`timedate::date::tomorrow`](timedate/date/tomorrow.md) | `timedate::date::tomorrow()` | [`timedate`](timedate.md) | Get tomorrow's date |
| [`timedate::date::week_end`](timedate/date/week_end.md) | `timedate::date::week_end()` | [`timedate`](timedate.md) | Get end of current week (Sunday) |
| [`timedate::date::week_of_year`](timedate/date/week_of_year.md) | `timedate::date::week_of_year()` | [`timedate`](timedate.md) | Get week of year (ISO 8601, 01-53) |
| [`timedate::date::week_start`](timedate/date/week_start.md) | `timedate::date::week_start()` | [`timedate`](timedate.md) | Get start of current week (Monday) |
| [`timedate::date::year`](timedate/date/year.md) | `timedate::date::year()` | [`timedate`](timedate.md) | Get year |
| [`timedate::date::year_end`](timedate/date/year_end.md) | `timedate::date::year_end()` | [`timedate`](timedate.md) | Get end of current year |
| [`timedate::date::year_start`](timedate/date/year_start.md) | `timedate::date::year_start()` | [`timedate`](timedate.md) | Get start of current year |
| [`timedate::date::yesterday`](timedate/date/yesterday.md) | `timedate::date::yesterday()` | [`timedate`](timedate.md) | Get yesterday's date |
| [`timedate::duration::format`](timedate/duration/format.md) | `timedate::duration::format(seconds)` | [`timedate`](timedate.md) | Format seconds into human-readable duration |
| [`timedate::duration::format_ms`](timedate/duration/format_ms.md) | `timedate::duration::format_ms(arg1)` | [`timedate`](timedate.md) | Format milliseconds into human-readable duration |
| [`timedate::duration::parse`](timedate/duration/parse.md) | `timedate::duration::parse(1d, 2h, 3m, 4s)` | [`timedate`](timedate.md) | Parse a duration string into seconds |
| [`timedate::duration::relative`](timedate/duration/relative.md) | `timedate::duration::relative(timestamp)` | [`timedate`](timedate.md) | Human-readable relative time from a unix timestamp |
| [`timedate::time::format`](timedate/time/format.md) | `timedate::time::format()` | [`timedate`](timedate.md) | Current time in a custom format |
| [`timedate::time::hour`](timedate/time/hour.md) | `timedate::time::hour()` | [`timedate`](timedate.md) | Get hour (00-23) |
| [`timedate::time::is_after`](timedate/time/is_after.md) | `timedate::time::is_after(arg1)` | [`timedate`](timedate.md) | Check if current time is after a given time |
| [`timedate::time::is_afternoon`](timedate/time/is_afternoon.md) | `timedate::time::is_afternoon()` | [`timedate`](timedate.md) | Check if currently afternoon (12:00-17:59) |
| [`timedate::time::is_before`](timedate/time/is_before.md) | `timedate::time::is_before(HH:MM)` | [`timedate`](timedate.md) | Check if current time is before a given time |
| [`timedate::time::is_between`](timedate/time/is_between.md) | `timedate::time::is_between(HH:MM, HH:MM)` | [`timedate`](timedate.md) | Check if current time is between two times (HH:MM) |
| [`timedate::time::is_business_hours`](timedate/time/is_business_hours.md) | `timedate::time::is_business_hours([start_hour], [end_hour])` | [`timedate`](timedate.md) | Check if currently business hours (09:00-17:00 Mon-Fri) |
| [`timedate::time::is_evening`](timedate/time/is_evening.md) | `timedate::time::is_evening()` | [`timedate`](timedate.md) | Check if currently evening (18:00-23:59) |
| [`timedate::time::is_morning`](timedate/time/is_morning.md) | `timedate::time::is_morning()` | [`timedate`](timedate.md) | Check if currently morning (00:00-11:59) |
| [`timedate::time::minute`](timedate/time/minute.md) | `timedate::time::minute()` | [`timedate`](timedate.md) | Get minute (00-59) |
| [`timedate::time::now`](timedate/time/now.md) | `timedate::time::now()` | [`timedate`](timedate.md) | Current time in HH:MM:SS |
| [`timedate::time::second`](timedate/time/second.md) | `timedate::time::second()` | [`timedate`](timedate.md) | Get second (00-59) |
| [`timedate::time::sleep`](timedate/time/sleep.md) | `timedate::time::sleep(seconds, [message])` | [`timedate`](timedate.md) | Sleep with a progress indicator |
| [`timedate::timestamp::from_human`](timedate/timestamp/from_human.md) | `timedate::timestamp::from_human(2024-01-15, 12:00:00)` | [`timedate`](timedate.md) | Convert human-readable date to unix timestamp |
| [`timedate::timestamp::to_human`](timedate/timestamp/to_human.md) | `timedate::timestamp::to_human(timestamp, [format])` | [`timedate`](timedate.md) | Convert unix timestamp to human-readable |
| [`timedate::timestamp::unix`](timedate/timestamp/unix.md) | `timedate::timestamp::unix()` | [`timedate`](timedate.md) | Current unix timestamp (seconds since epoch) |
| [`timedate::timestamp::unix_ms`](timedate/timestamp/unix_ms.md) | `timedate::timestamp::unix_ms()` | [`timedate`](timedate.md) | Current unix timestamp in milliseconds |
| [`timedate::timestamp::unix_ns`](timedate/timestamp/unix_ns.md) | `timedate::timestamp::unix_ns()` | [`timedate`](timedate.md) | Current unix timestamp in nanoseconds |
| [`timedate::time::stopwatch::start`](timedate/time/stopwatch/start.md) | `timedate::time::stopwatch::start(token=$(timedate::time::stopwatch::start))` | [`timedate`](timedate.md) | Stopwatch — start, returns a token |
| [`timedate::time::stopwatch::stop`](timedate/time/stopwatch/stop.md) | `timedate::time::stopwatch::stop(token)` | [`timedate`](timedate.md) | Stopwatch — stop, returns elapsed ms |
| [`timedate::time::timezone`](timedate/time/timezone.md) | `timedate::time::timezone()` | [`timedate`](timedate.md) | Get timezone abbreviation |
| [`timedate::time::timezone_offset`](timedate/time/timezone_offset.md) | `timedate::time::timezone_offset()` | [`timedate`](timedate.md) | Get timezone offset from UTC (e.g. +0800) |
| [`timedate::tz::convert`](timedate/tz/convert.md) | `timedate::tz::convert(timestamp, timezone)` | [`timedate`](timedate.md) | Convert a timestamp to a different timezone |
| [`timedate::tz::current`](timedate/tz/current.md) | `timedate::tz::current()` | [`timedate`](timedate.md) | Get current timezone name |
| [`timedate::tz::is_dst`](timedate/tz/is_dst.md) | `timedate::tz::is_dst()` | [`timedate`](timedate.md) | Check if currently in daylight saving time |
| [`timedate::tz::list`](timedate/tz/list.md) | `timedate::tz::list()` | [`timedate`](timedate.md) | List all available timezones |
| [`timedate::tz::list::region`](timedate/tz/list/region.md) | `timedate::tz::list::region(America)` | [`timedate`](timedate.md) | List timezones filtered by region |
| [`timedate::tz::now`](timedate/tz/now.md) | `timedate::tz::now(timezone)` | [`timedate`](timedate.md) | Get current time in a specific timezone |
| [`timedate::tz::offset_seconds`](timedate/tz/offset_seconds.md) | `timedate::tz::offset_seconds()` | [`timedate`](timedate.md) | Get UTC offset in seconds |

---
*Generated by tools/api-gen.sh — 2026-05-21*
