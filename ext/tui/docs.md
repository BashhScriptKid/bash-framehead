# tui — TUI Primitives Extension

High-level wrappers for dialog boxes, menus, progress bars, and input forms. Uses caller-owned context pattern with associative arrays.

## Dependencies

- **Required:** runtime.sh
- **Backend:** `dialog` (ncurses) or `whiptail` (newt)
- **Fallback:** plain bash I/O if neither available

## Quick Start

```bash
source bash-framehead.sh
source ext/tui/tui.sh

# Simple message box
local -A _ctx
_ctx[title]="Hello"
tui::msgbox _ctx "World"

# Yes/No dialog
if tui::yesno _ctx "Continue?"; then
    echo "yes"
fi

# Menu selection
local -a _items=("event0" "Power Button" "event2" "Keyboard" "event7" "Mouse")
_ctx[listheight]=3
local _choice
_choice=$(tui::menu _ctx _items)
echo "Selected: $_choice"
```

## Context Pattern

All functions take a caller-owned `_ctx` associative array as the first argument. Set options directly:

```bash
local -A _ctx
_ctx[title]="My Dialog"
_ctx[backtitle]="App Name"
_ctx[height]=15
_ctx[width]=60
_ctx[clear_on_exit]=1
_ctx[listheight]=5
_ctx[ok_txt]="Go"
_ctx[cancel_txt]="Stop"
```

### Context Keys

| Key | Type | Applies to | Description |
|---|---|---|---|
| `title` | string | all | Dialog title |
| `backtitle` | string | all | Background title |
| `height` | int | all | Widget height |
| `width` | int | all | Widget width |
| `clear_on_exit` | bool | all | Clear screen on exit |
| `defaultno` | bool | yesno | Default to No |
| `nocancel` | bool | menu/checklist | Hide Cancel button |
| `ok_txt` | string | all | OK button text |
| `cancel_txt` | string | all | Cancel button text |
| `yes_txt` | string | yesno | Yes button text |
| `no_txt` | string | yesno | No button text |
| `scroll` | bool | menu/checklist | Force scrollbars |
| `topleft` | bool | all | Position at top-left |
| `output_fd` | int | all | Output file descriptor |
| `separate` | bool | checklist | One line per selected item |
| `listheight` | int | menu/checklist | Visible items |
| `default_item` | string | menu | Pre-selected item |
| `storage` | string | arbitrary | KV store with `\0` separators |

## Item Arrays

List widgets take a separate nameref array for items:

```bash
# Menu: tag, item pairs
local -a _items=("tag1" "Item 1" "tag2" "Item 2")

# Checklist/Radiolist: tag, item, status triples
local -a _items=("tag1" "Item 1" "on" "tag2" "Item 2" "off")
```

## Form Arrays

Form widgets take three parallel arrays:

```bash
local -a _labels=("Name" "Email" "Phone")
local -a _types=("input" "input" "input")
local -a _inits=("John" "john@example.com" "555-1234")
```

## Storage

Arbitrary key-value store in context:

```bash
tui::storage::set _ctx "key" "value"
tui::storage::get _ctx "key"
tui::storage::unset _ctx "key"
tui::storage::keys _ctx
tui::storage::dump _ctx
```

Format: `key1=val1|key2=val2|key3=val3` (pipe-separated)

## Functions

### Common (dialog/whiptail)

| Function | Args | Returns |
|---|---|---|
| `tui::msgbox` | `_ctx "text"` | 0 (OK) |
| `tui::yesno` | `_ctx "text"` | 0=yes 1=no |
| `tui::inputbox` | `_ctx "text" ["init"]` | text |
| `tui::passwordbox` | `_ctx "text"` | text (hidden) |
| `tui::infobox` | `_ctx "text"` | 0 (no wait) |
| `tui::textbox` | `_ctx "file.txt"` | 0 |
| `tui::menu` | `_ctx _items` | selected tag |
| `tui::checklist` | `_ctx _items` | selected tags |
| `tui::radiolist` | `_ctx _items` | selected tag |
| `tui::gauge` | `_ctx "text" pct` | 0 |

### Dialog-only

| Function | Args |
|---|---|
| `tui::dialog::calendar` | `_ctx "day" "month" "year"` |
| `tui::dialog::fselect` | `_ctx "/path"` |
| `tui::dialog::timebox` | `_ctx "hour" "min" "sec"` |
| `tui::dialog::form` | `_ctx _labels _types _inits` |
| `tui::dialog::mixedform` | `_ctx _labels _types _inits _statuses` |
| `tui::dialog::editbox` | `_ctx "file.txt"` |
| `tui::dialog::treeview` | `_ctx _items` |
| `tui::dialog::buildlist` | `_ctx _items` |
| `tui::dialog::rangebox` | `_ctx "min" "max" "init"` |
| `tui::dialog::mixedgauge` | `_ctx "text" pct _tasks` |
| `tui::dialog::tailbox` | `_ctx "file.txt"` |

### Storage

| Function | Args |
|---|---|
| `tui::storage::set` | `_ctx "key" "value"` |
| `tui::storage::get` | `_ctx "key"` |
| `tui::storage::unset` | `_ctx "key"` |
| `tui::storage::keys` | `_ctx` |
| `tui::storage::dump` | `_ctx` |

### Utility

| Function | Description |
|---|---|
| `tui::is_available` | Check backend exists |
| `tui::backend` | Return backend name |
| `tui::clear` | Clear terminal |
| `tui::set_size` | Set LINES/COLUMNS |

## Fallback Behavior

When no backend is available:
- `tui::yesno` → `[y/N]` prompt
- `tui::inputbox` → text prompt with default
- `tui::passwordbox` → hidden prompt
- `tui::menu` → numbered list
- `tui::checklist` → `[x]`/`[ ]` list with comma selection
- `tui::radiolist` → numbered list with single selection
- `tui::gauge` → `[percent%] text`

## Notes

- All functions fall back to plain bash if dialog/whiptail isn't installed
- Exit code 0 = user confirmed, 1 = user cancelled
- `tui::dialog::*` functions require dialog specifically, return 1 if unavailable
- Storage uses `\0` (null byte) as key-value separator
