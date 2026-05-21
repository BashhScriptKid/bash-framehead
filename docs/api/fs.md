# `fs`

79 functions. [Guide](../guide/index.md) — [Dictionary](index.md)

| Function | Signature | Description |
|----------|-----------|-------------|
| [`fs::appendln`](fs/appendln.md) | `fs::appendln(arg1, arg2)` |  |
| [`fs::append`](fs/append.md) | `fs::append(arg1, arg2)` |  |
| [`fs::char_count`](fs/char_count.md) | `fs::char_count(arg1)` |  |
| [`fs::checksum::md5`](fs/checksum/md5.md) | `fs::checksum::md5(arg1)` |  |
| [`fs::checksum::sha1`](fs/checksum/sha1.md) | `fs::checksum::sha1(arg1)` |  |
| [`fs::checksum::sha256`](fs/checksum/sha256.md) | `fs::checksum::sha256(arg1)` |  |
| [`fs::contains`](fs/contains.md) | `fs::contains(path, string)` |  |
| [`fs::copy`](fs/copy.md) | `fs::copy(src, dst)` |  |
| [`fs::created`](fs/created.md) | `fs::created(arg1)` |  |
| [`fs::delete`](fs/delete.md) | `fs::delete(arg1)` |  |
| [`fs::dir::count`](fs/dir/count.md) | `fs::dir::count()` |  |
| [`fs::dir::is_empty`](fs/dir/is_empty.md) | `fs::dir::is_empty()` |  |
| [`fs::dir::size::human`](fs/dir/size/human.md) | `fs::dir::size::human(arg1)` |  |
| [`fs::dir::size`](fs/dir/size.md) | `fs::dir::size(arg1)` |  |
| [`fs::exists`](fs/exists.md) | `fs::exists(arg1)` |  |
| [`fs::find::larger_than`](fs/find/larger_than.md) | `fs::find::larger_than()` |  |
| [`fs::find`](fs/find.md) | `fs::find(path, pattern)` |  |
| [`fs::find::recent`](fs/find/recent.md) | `fs::find::recent()` |  |
| [`fs::find::smaller_than`](fs/find/smaller_than.md) | `fs::find::smaller_than()` |  |
| [`fs::find::type`](fs/find/type.md) | `fs::find::type(arg2)` |  |
| [`fs::hardlink`](fs/hardlink.md) | `fs::hardlink(arg1, arg2)` |  |
| [`fs::inode`](fs/inode.md) | `fs::inode(arg1)` |  |
| [`fs::is_dir`](fs/is_dir.md) | `fs::is_dir(arg1)` |  |
| [`fs::is_empty`](fs/is_empty.md) | `fs::is_empty(arg1)` |  |
| [`fs::is_executable`](fs/is_executable.md) | `fs::is_executable(arg1)` |  |
| [`fs::is_file`](fs/is_file.md) | `fs::is_file(arg1)` |  |
| [`fs::is_identical`](fs/is_identical.md) | `fs::is_identical(arg1, arg2)` |  |
| [`fs::is_readable`](fs/is_readable.md) | `fs::is_readable(arg1)` |  |
| [`fs::is_same`](fs/is_same.md) | `fs::is_same(arg1, arg2)` |  |
| [`fs::is_symlink`](fs/is_symlink.md) | `fs::is_symlink(arg1)` |  |
| [`fs::is_writable`](fs/is_writable.md) | `fs::is_writable(arg1)` |  |
| [`fs::line_count`](fs/line_count.md) | `fs::line_count(arg1)` |  |
| [`fs::line`](fs/line.md) | `fs::line(path, line_number)` |  |
| [`fs::lines`](fs/lines.md) | `fs::lines(path, start, end)` |  |
| [`fs::link_count`](fs/link_count.md) | `fs::link_count(arg1)` |  |
| [`fs::ls::all`](fs/ls/all.md) | `fs::ls::all()` |  |
| [`fs::ls::dirs`](fs/ls/dirs.md) | `fs::ls::dirs()` |  |
| [`fs::ls::files`](fs/ls/files.md) | `fs::ls::files()` |  |
| [`fs::ls`](fs/ls.md) | `fs::ls()` |  |
| [`fs::matches`](fs/matches.md) | `fs::matches(arg1, arg2)` |  |
| [`fs::mime_type`](fs/mime_type.md) | `fs::mime_type(arg1)` |  |
| [`fs::mkdir`](fs/mkdir.md) | `fs::mkdir(arg1)` |  |
| [`fs::modified::human`](fs/modified/human.md) | `fs::modified::human(arg1)` |  |
| [`fs::modified`](fs/modified.md) | `fs::modified(arg1)` |  |
| [`fs::move`](fs/move.md) | `fs::move(arg1, arg2)` |  |
| [`fs::owner::group`](fs/owner/group.md) | `fs::owner::group(arg1)` |  |
| [`fs::owner`](fs/owner.md) | `fs::owner(arg1)` |  |
| [`fs::path::absolute`](fs/path/absolute.md) | `fs::path::absolute(arg1)` |  |
| [`fs::path::basename`](fs/path/basename.md) | `fs::path::basename()` |  |
| [`fs::path::dirname`](fs/path/dirname.md) | `fs::path::dirname(arg1)` |  |
| [`fs::path::extension`](fs/path/extension.md) | `fs::path::extension(file.tar.gz, →, gz)` |  |
| [`fs::path::extensions`](fs/path/extensions.md) | `fs::path::extensions(file.tar.gz, →, tar.gz)` |  |
| [`fs::path::is_absolute`](fs/path/is_absolute.md) | `fs::path::is_absolute(arg1)` |  |
| [`fs::path::is_relative`](fs/path/is_relative.md) | `fs::path::is_relative(arg1)` |  |
| [`fs::path::join`](fs/path/join.md) | `fs::path::join(part1, part2, ...)` |  |
| [`fs::path::relative`](fs/path/relative.md) | `fs::path::relative(/a/b/c, /a, →, b/c)` |  |
| [`fs::path::stem`](fs/path/stem.md) | `fs::path::stem()` |  |
| [`fs::permissions`](fs/permissions.md) | `fs::permissions(arg1)` |  |
| [`fs::permissions::symbolic`](fs/permissions/symbolic.md) | `fs::permissions::symbolic(arg1)` |  |
| [`fs::prepend`](fs/prepend.md) | `fs::prepend(arg1, arg2)` |  |
| [`fs::read`](fs/read.md) | `fs::read(arg1)` |  |
| [`fs::rename`](fs/rename.md) | `fs::rename(old_path, new_name)` |  |
| [`fs::replace`](fs/replace.md) | `fs::replace(path, old, new)` |  |
| [`fs::size::human`](fs/size/human.md) | `fs::size::human(arg1)` |  |
| [`fs::size`](fs/size.md) | `fs::size(arg1)` |  |
| [`fs::symlink`](fs/symlink.md) | `fs::symlink(target, link_name)` |  |
| [`fs::symlink::resolve`](fs/symlink/resolve.md) | `fs::symlink::resolve(arg1)` |  |
| [`fs::symlink::target`](fs/symlink/target.md) | `fs::symlink::target(arg1)` |  |
| [`fs::temp::dir::auto`](fs/temp/dir/auto.md) | `fs::temp::dir::auto(arg1)` |  |
| [`fs::temp::dir`](fs/temp/dir.md) | `fs::temp::dir(tmpdir=$(fs::temp::dir, [prefix]))` |  |
| [`fs::temp::file::auto`](fs/temp/file/auto.md) | `fs::temp::file::auto([prefix])` |  |
| [`fs::temp::file`](fs/temp/file.md) | `fs::temp::file(tmpfile=$(fs::temp::file, [prefix]))` |  |
| [`fs::touch`](fs/touch.md) | `fs::touch(arg1)` |  |
| [`fs::trash`](fs/trash.md) | `fs::trash(path)` |  |
| [`fs::watch`](fs/watch.md) | `fs::watch(path, callback, [interval_seconds])` |  |
| [`fs::watch::timeout`](fs/watch/timeout.md) | `fs::watch::timeout(path, callback, timeout, [interval])` |  |
| [`fs::word_count`](fs/word_count.md) | `fs::word_count(arg1)` |  |
| [`fs::writeln`](fs/writeln.md) | `fs::writeln(arg1, arg2)` |  |
| [`fs::write`](fs/write.md) | `fs::write(path, content)` |  |

