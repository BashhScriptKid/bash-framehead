# `terminal`

Terminal manipulation — capability detection, cursor control, screen buffer management, input handling, and `shopt` wrappers. **74 functions.** No `::fast` variants.

---

## Capability Detection

| Function | Description |
|----------|-------------|
| `terminal::is_tty` | Check if stdout is a terminal |
| `terminal::is_tty::stdin` | Check if stdin is a terminal |
| `terminal::is_tty::stderr` | Check if stderr is a terminal |
| `terminal::width` | Get terminal width in columns |
| `terminal::height` | Get terminal height in rows |
| `terminal::size` | Get both as `"cols rows"` |
| `terminal::has_colour` | Check if terminal supports colours |
| `terminal::has_256colour` | Check if terminal supports 256 colours |
| `terminal::has_truecolour` | Check if terminal supports true colour |
| `terminal::name` | Return the terminal emulator name if detectable |

```bash
terminal::width               # → 120
read cols rows < <(terminal::size)
terminal::has_truecolour && echo "24-bit colour available"
```

---

## Cursor Control

All cursor positions are 1-indexed (row, col).

| Function | Description |
|----------|-------------|
| `terminal::cursor::show` | Show cursor |
| `terminal::cursor::hide` | Hide cursor |
| `terminal::cursor::toggle` | Toggle cursor visibility (tracks state via global flag) |
| `terminal::cursor::save` | Save cursor position |
| `terminal::cursor::restore` | Restore cursor to saved position |
| `terminal::cursor::move` | Move cursor to row, col |
| `terminal::cursor::up` | Move cursor up n rows |
| `terminal::cursor::down` | Move cursor down n rows |
| `terminal::cursor::right` | Move cursor right n columns |
| `terminal::cursor::left` | Move cursor left n columns |
| `terminal::cursor::next_line` | Move to start of line n lines down |
| `terminal::cursor::prev_line` | Move to start of line n lines up |
| `terminal::cursor::col` | Move cursor to column n on current line |
| `terminal::cursor::home` | Move cursor to top-left (home) |

```bash
terminal::cursor::hide
terminal::cursor::move 5 10
echo -n "hello at (5,10)"
terminal::cursor::show
```

---

## Screen Buffer

| Function | Description |
|----------|-------------|
| `terminal::clear` | Clear entire screen |
| `terminal::clear::to_end` | Clear from cursor to end of screen |
| `terminal::clear::to_start` | Clear from cursor to beginning of screen |
| `terminal::clear::line` | Clear current line |
| `terminal::clear::line_end` | Clear from cursor to end of line |
| `terminal::clear::line_start` | Clear from cursor to start of line |
| `terminal::screen::alternate` | Enter alternate screen buffer (like vim/less do) |
| `terminal::screen::normal` | Return to normal screen buffer |
| `terminal::screen::wrap` | Enter alternate screen, run a command, return to normal |
| `terminal::screen::alternate_enter` | Enter alternate screen, home cursor, clear, auto-restore on EXIT |
| `terminal::screen::alternate_exit` | Return to normal screen and clear the trap |
| `terminal::scroll::up` | Scroll up n lines |
| `terminal::scroll::down` | Scroll down n lines |

```bash
# Run a command in the alternate screen buffer
terminal::screen::wrap "less /etc/hosts"

# Build a TUI: enter alt screen, draw, wait, restore
terminal::screen::alternate_enter
echo "Press any key to exit..."
terminal::read_key key
terminal::screen::alternate_exit
```

## Titles & Alerts

| Function | Description |
|----------|-------------|
| `terminal::title` | Set terminal title (works in most modern terminal emulators) |
| `terminal::bell` | Ring the terminal bell |

```bash
terminal::title "My Script — Processing..."
terminal::bell  # alert the user
```

---

## Input Handling

| Function | Description |
|----------|-------------|
| `terminal::read_key` | Read a single keypress without requiring Enter |
| `terminal::read_key::timeout` | Read a single keypress with a timeout |
| `terminal::confirm` | Prompt user for y/n, returns 0 for yes, 1 for no (defaults to no) |
| `terminal::confirm::default` | Prompt with a default choice shown |
| `terminal::echo::off` | Disable terminal echo (for password input) |
| `terminal::echo::on` | Re-enable terminal echo |
| `terminal::read_password` | Read a password with no echo |

```bash
# Single keypress
terminal::read_key key
echo "You pressed: $key"

# Confirmation
if terminal::confirm "Proceed with installation?"; then
    echo "Proceeding..."
fi

# With default
terminal::confirm::default yes "Continue?" && echo "User said yes"

# Password input
terminal::read_password pass "Enter password: "
echo "Password entered"
```

---

## Shopt Wrappers

Programmatic control over bash shell options.

### Core

| Function | Description |
|----------|-------------|
| `terminal::shopt::enable` | Enable a shopt option, return 1 if unsupported |
| `terminal::shopt::disable` | Disable a shopt option |
| `terminal::shopt::is_enabled` | Check if a shopt option is enabled |
| `terminal::shopt::get` | Get current value ("on" or "off") |
| `terminal::shopt::list::enabled` | List all enabled shopt options |
| `terminal::shopt::list::disabled` | List all disabled shopt options |
| `terminal::shopt::save` | Save current shopt state (prints a restore command) |
| `terminal::shopt::load` | Restore state from a variable |

```bash
# Save and restore shell options
state=$(terminal::shopt::save)
terminal::shopt::enable globstar
# ... do work with globstar enabled ...
eval "$state"  # restore original state
```

### Convenience Toggles

| Option | Description | enable/disable |
|--------|-------------|----------------|
| `globstar` | `**` recursive glob | `::enable` / `::disable` |
| `nullglob` | Failed globs expand to empty | `::enable` / `::disable` |
| `dotglob` | Globs match dotfiles | `::enable` / `::disable` |
| `extglob` | Extended pattern matching | `::enable` / `::disable` |
| `nocaseglob` | Case-insensitive glob | `::enable` / `::disable` |
| `autocd` | cd by typing directory name | `::enable` / `::disable` |
| `checkwinsize` | Auto-update LINES/COLUMNS | `::enable` / `::disable` |
| `histappend` | Append to history | `::enable` / `::disable` |
| `cdspell` | Autocorrect cd typos | `::enable` / `::disable` |
| `nocasematch` | Case-insensitive `[[ =~` | `::enable` / `::disable` |

```bash
terminal::shopt::globstar::enable
terminal::shopt::extglob::enable
```

## Dependencies

- **Requires**: `runtime`
- **Pure Bash** — all escape sequences and control codes are ANSI standard
