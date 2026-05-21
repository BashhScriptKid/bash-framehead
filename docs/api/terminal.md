# `terminal`

74 functions. [Guide](../guide/index.md) — [Dictionary](index.md)

| Function | Signature | Description |
|----------|-----------|-------------|
| [`terminal::bell`](terminal/bell.md) | `terminal::bell()` |  |
| [`terminal::clear::line_end`](terminal/clear/line_end.md) | `terminal::clear::line_end()` |  |
| [`terminal::clear::line`](terminal/clear/line.md) | `terminal::clear::line()` |  |
| [`terminal::clear::line_start`](terminal/clear/line_start.md) | `terminal::clear::line_start()` |  |
| [`terminal::clear`](terminal/clear.md) | `terminal::clear()` |  |
| [`terminal::clear::to_end`](terminal/clear/to_end.md) | `terminal::clear::to_end()` |  |
| [`terminal::clear::to_start`](terminal/clear/to_start.md) | `terminal::clear::to_start()` |  |
| [`terminal::confirm::default`](terminal/confirm/default.md) | `terminal::confirm::default(yes, Proceed?)` |  |
| [`terminal::confirm`](terminal/confirm.md) | `terminal::confirm(Are, you, sure?)` |  |
| [`terminal::cursor::col`](terminal/cursor/col.md) | `terminal::cursor::col()` |  |
| [`terminal::cursor::down`](terminal/cursor/down.md) | `terminal::cursor::down()` |  |
| [`terminal::cursor::hide`](terminal/cursor/hide.md) | `terminal::cursor::hide()` |  |
| [`terminal::cursor::home`](terminal/cursor/home.md) | `terminal::cursor::home()` |  |
| [`terminal::cursor::left`](terminal/cursor/left.md) | `terminal::cursor::left()` |  |
| [`terminal::cursor::move`](terminal/cursor/move.md) | `terminal::cursor::move(row, col)` |  |
| [`terminal::cursor::next_line`](terminal/cursor/next_line.md) | `terminal::cursor::next_line()` |  |
| [`terminal::cursor::prev_line`](terminal/cursor/prev_line.md) | `terminal::cursor::prev_line()` |  |
| [`terminal::cursor::restore`](terminal/cursor/restore.md) | `terminal::cursor::restore()` |  |
| [`terminal::cursor::right`](terminal/cursor/right.md) | `terminal::cursor::right()` |  |
| [`terminal::cursor::save`](terminal/cursor/save.md) | `terminal::cursor::save()` |  |
| [`terminal::cursor::show`](terminal/cursor/show.md) | `terminal::cursor::show()` |  |
| [`terminal::cursor::toggle`](terminal/cursor/toggle.md) | `terminal::cursor::toggle()` |  |
| [`terminal::cursor::up`](terminal/cursor/up.md) | `terminal::cursor::up()` |  |
| [`terminal::echo::off`](terminal/echo/off.md) | `terminal::echo::off()` |  |
| [`terminal::echo::on`](terminal/echo/on.md) | `terminal::echo::on()` |  |
| [`terminal::has_256colour`](terminal/has_256colour.md) | `terminal::has_256colour()` |  |
| [`terminal::has_colour`](terminal/has_colour.md) | `terminal::has_colour()` |  |
| [`terminal::has_truecolour`](terminal/has_truecolour.md) | `terminal::has_truecolour()` |  |
| [`terminal::height`](terminal/height.md) | `terminal::height()` |  |
| [`terminal::is_tty`](terminal/is_tty.md) | `terminal::is_tty()` |  |
| [`terminal::is_tty::stderr`](terminal/is_tty/stderr.md) | `terminal::is_tty::stderr()` |  |
| [`terminal::is_tty::stdin`](terminal/is_tty/stdin.md) | `terminal::is_tty::stdin()` |  |
| [`terminal::name`](terminal/name.md) | `terminal::name()` |  |
| [`terminal::read_key`](terminal/read_key.md) | `terminal::read_key(varname)` |  |
| [`terminal::read_key::timeout`](terminal/read_key/timeout.md) | `terminal::read_key::timeout(varname, seconds)` |  |
| [`terminal::read_password`](terminal/read_password.md) | `terminal::read_password(varname, [prompt])` |  |
| [`terminal::screen::alternate_enter`](terminal/screen/alternate_enter.md) | `terminal::screen::alternate_enter()` |  |
| [`terminal::screen::alternate_exit`](terminal/screen/alternate_exit.md) | `terminal::screen::alternate_exit()` |  |
| [`terminal::screen::alternate`](terminal/screen/alternate.md) | `terminal::screen::alternate()` |  |
| [`terminal::screen::normal`](terminal/screen/normal.md) | `terminal::screen::normal()` |  |
| [`terminal::screen::wrap`](terminal/screen/wrap.md) | `terminal::screen::wrap(command, [args...])` |  |
| [`terminal::scroll::down`](terminal/scroll/down.md) | `terminal::scroll::down()` |  |
| [`terminal::scroll::up`](terminal/scroll/up.md) | `terminal::scroll::up()` |  |
| [`terminal::shopt::autocd::disable`](terminal/shopt/autocd/disable.md) | `terminal::shopt::autocd::disable()` |  |
| [`terminal::shopt::autocd::enable`](terminal/shopt/autocd/enable.md) | `terminal::shopt::autocd::enable()` |  |
| [`terminal::shopt::cdspell::disable`](terminal/shopt/cdspell/disable.md) | `terminal::shopt::cdspell::disable()` |  |
| [`terminal::shopt::cdspell::enable`](terminal/shopt/cdspell/enable.md) | `terminal::shopt::cdspell::enable()` |  |
| [`terminal::shopt::checkwinsize::disable`](terminal/shopt/checkwinsize/disable.md) | `terminal::shopt::checkwinsize::disable()` |  |
| [`terminal::shopt::checkwinsize::enable`](terminal/shopt/checkwinsize/enable.md) | `terminal::shopt::checkwinsize::enable()` |  |
| [`terminal::shopt::disable`](terminal/shopt/disable.md) | `terminal::shopt::disable(arg1)` |  |
| [`terminal::shopt::dotglob::disable`](terminal/shopt/dotglob/disable.md) | `terminal::shopt::dotglob::disable()` |  |
| [`terminal::shopt::dotglob::enable`](terminal/shopt/dotglob/enable.md) | `terminal::shopt::dotglob::enable()` |  |
| [`terminal::shopt::enable`](terminal/shopt/enable.md) | `terminal::shopt::enable(arg1)` |  |
| [`terminal::shopt::extglob::disable`](terminal/shopt/extglob/disable.md) | `terminal::shopt::extglob::disable()` |  |
| [`terminal::shopt::extglob::enable`](terminal/shopt/extglob/enable.md) | `terminal::shopt::extglob::enable()` |  |
| [`terminal::shopt::get`](terminal/shopt/get.md) | `terminal::shopt::get(arg1, arg2)` |  |
| [`terminal::shopt::globstar::disable`](terminal/shopt/globstar/disable.md) | `terminal::shopt::globstar::disable()` |  |
| [`terminal::shopt::globstar::enable`](terminal/shopt/globstar/enable.md) | `terminal::shopt::globstar::enable()` |  |
| [`terminal::shopt::histappend::disable`](terminal/shopt/histappend/disable.md) | `terminal::shopt::histappend::disable()` |  |
| [`terminal::shopt::histappend::enable`](terminal/shopt/histappend/enable.md) | `terminal::shopt::histappend::enable()` |  |
| [`terminal::shopt::is_enabled`](terminal/shopt/is_enabled.md) | `terminal::shopt::is_enabled(arg1)` |  |
| [`terminal::shopt::list::disabled`](terminal/shopt/list/disabled.md) | `terminal::shopt::list::disabled(arg1, arg2)` |  |
| [`terminal::shopt::list::enabled`](terminal/shopt/list/enabled.md) | `terminal::shopt::list::enabled(arg1, arg2)` |  |
| [`terminal::shopt::load`](terminal/shopt/load.md) | `terminal::shopt::load(varname)` |  |
| [`terminal::shopt::nocaseglob::disable`](terminal/shopt/nocaseglob/disable.md) | `terminal::shopt::nocaseglob::disable()` |  |
| [`terminal::shopt::nocaseglob::enable`](terminal/shopt/nocaseglob/enable.md) | `terminal::shopt::nocaseglob::enable()` |  |
| [`terminal::shopt::nocasematch::disable`](terminal/shopt/nocasematch/disable.md) | `terminal::shopt::nocasematch::disable()` |  |
| [`terminal::shopt::nocasematch::enable`](terminal/shopt/nocasematch/enable.md) | `terminal::shopt::nocasematch::enable()` |  |
| [`terminal::shopt::nullglob::disable`](terminal/shopt/nullglob/disable.md) | `terminal::shopt::nullglob::disable()` |  |
| [`terminal::shopt::nullglob::enable`](terminal/shopt/nullglob/enable.md) | `terminal::shopt::nullglob::enable()` |  |
| [`terminal::shopt::save`](terminal/shopt/save.md) | `terminal::shopt::save(eval, $(terminal::shopt::save))` |  |
| [`terminal::size`](terminal/size.md) | `terminal::size()` |  |
| [`terminal::title`](terminal/title.md) | `terminal::title(My, Script)` |  |
| [`terminal::width`](terminal/width.md) | `terminal::width()` |  |

