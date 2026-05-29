# uinput — Virtual Input Device Extension

Create and control virtual input devices (keyboard, mouse, touchscreen) via Linux uinput.

## Dependencies

- **Build:** C compiler (gcc/cc)
- **Runtime:** compiled `uinput_helper` binary, root access

## Build

```bash
cd ext/uinput && make
```

## Functions

| Function | Description |
|---|---|
| `uinput::is_ready` | Check if helper binary is compiled |
| `uinput::create <name>` | Create virtual device, prints fd path |
| `uinput::destroy <fd_path>` | Destroy virtual device |
| `uinput::key <fd_path> <code> <value>` | Emit key event (1=press, 0=release) |
| `uinput::mouse <fd_path> <dx> <dy>` | Emit relative mouse movement |
| `uinput::abs <fd_path> <code> <value>` | Emit absolute axis event |
| `uinput::event <fd_path> <type> <code> <value>` | Emit raw input event |

## Example

```bash
source bash-framehead.sh
source ext/uinput/uinput.sh

uinput::is_ready || { echo "Build first: cd ext/uinput && make"; exit 1; }

# Create virtual keyboard
fd=$(uinput::create "my-keyboard")

# Press and release 'A' (key code 30)
uinput::key "$fd" 30 1   # press
uinput::key "$fd" 30 0   # release

# Mouse movement
uinput::mouse "$fd" 100 50   # move right 100, down 50

# Cleanup
uinput::destroy "$fd"
```

## Key Codes

Common key codes (from `linux/input-event-codes.h`):

| Key | Code |
|---|---|
| A | 30 |
| B | 48 |
| Enter | 28 |
| Space | 57 |
| Escape | 1 |
| Left Shift | 42 |
| Left Ctrl | 29 |

## Notes

- All write operations require root
- Virtual devices persist until `uinput::destroy` or process exit
- The helper binary is ~150 lines of C, no external dependencies
