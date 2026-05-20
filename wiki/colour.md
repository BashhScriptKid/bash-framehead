# `colour`

ANSI escape code generation — 4/8/24-bit colour support, text styling attributes, and higher-level helpers for coloured output. **65 functions.** No `::fast` variants.

---

## Capability Detection

| Function | Description |
|----------|-------------|
| `colour::supports` | Check if the terminal supports any colour |
| `colour::depth` | Return the number of colours the terminal supports (0, 8, 256, or 16777216) |
| `colour::supports_256` | Check if terminal supports 256 colours |
| `colour::supports_truecolor` | Check if terminal supports true colour (24-bit) |

```bash
if colour::supports_truecolor; then
    echo "24-bit colour available"
fi
colour::depth  # → 256
```

## Index Lookup

| Function | Description |
|----------|-------------|
| `colour::index::4bit` | Get 4-bit ANSI colour code index (30–37, 40–47, 90–97, 100–107) |
| `colour::index::8bit` | Get 8-bit colour index (0–255); accepts named colours, `rgbR,G,B`, `greyN` |

```bash
colour::index::4bit red fg     # → 31
colour::index::8bit "rgb5,2,3" # → 127
colour::index::8bit grey10     # → 242
```

## Escape Code Generation

| Function | Description |
|----------|-------------|
| `colour::esc` | Generate a raw ANSI escape sequence for a given bit depth and colour |
| `colour::safe_esc` | Like `colour::esc` but degrades gracefully — returns empty string if terminal doesn't support the requested depth |

```bash
colour::esc 4 fg red          # → \033[31m
colour::esc 8 bg blue         # → \033[48;5;12m
colour::safe_esc 24 fg "255,128,0"  # empty if no truecolor support
```

---

## Text Attributes

Styling independent of colour depth.

| Function | Description |
|----------|-------------|
| `colour::reset` | Reset all attributes |
| `colour::bold` | Bold text |
| `colour::dim` | Dim/faint text |
| `colour::italic` | Italic text |
| `colour::underline` | Underline text |
| `colour::blink` | Blinking text |
| `colour::reverse` | Reverse video (swap fg/bg) |
| `colour::hidden` | Hidden text |
| `colour::strike` | Strikethrough text |

### Attribute Reset

| Function | Description |
|----------|-------------|
| `colour::reset::bold` | Reset bold |
| `colour::reset::dim` | Reset dim |
| `colour::reset::italic` | Reset italic |
| `colour::reset::underline` | Reset underline |
| `colour::reset::blink` | Reset blink |
| `colour::reset::reverse` | Reset reverse |
| `colour::reset::hidden` | Reset hidden |
| `colour::reset::strike` | Reset strike |
| `colour::reset::fg` | Reset foreground colour |
| `colour::reset::bg` | Reset background colour |

---

## 4-Bit Named Shortcuts

Convenience functions that directly output the escape sequence — no need to call `colour::esc` with bit depth.

### Foreground (16 colours)

| Standard | Bright |
|----------|--------|
| `colour::fg::black` | `colour::fg::bright_black` |
| `colour::fg::red` | `colour::fg::bright_red` |
| `colour::fg::green` | `colour::fg::bright_green` |
| `colour::fg::yellow` | `colour::fg::bright_yellow` |
| `colour::fg::blue` | `colour::fg::bright_blue` |
| `colour::fg::magenta` | `colour::fg::bright_magenta` |
| `colour::fg::cyan` | `colour::fg::bright_cyan` |
| `colour::fg::white` | `colour::fg::bright_white` |

### Background (16 colours)

| Standard | Bright |
|----------|--------|
| `colour::bg::black` | `colour::bg::bright_black` |
| `colour::bg::red` | `colour::bg::bright_red` |
| `colour::bg::green` | `colour::bg::bright_green` |
| `colour::bg::yellow` | `colour::bg::bright_yellow` |
| `colour::bg::blue` | `colour::bg::bright_blue` |
| `colour::bg::magenta` | `colour::bg::bright_magenta` |
| `colour::bg::cyan` | `colour::bg::bright_cyan` |
| `colour::bg::white` | `colour::bg::bright_white` |

```bash
echo "$(colour::fg::red)Error:$(colour::reset) something went wrong"
echo "$(colour::bg::green)$(colour::fg::white) SUCCESS $(colour::reset)"
```

---

## Higher-Level Helpers

| Function | Description |
|----------|-------------|
| `colour::print` | Print text wrapped in colour, auto-reset after |
| `colour::println` | Like `colour::print` but appends a newline |
| `colour::wrap` | Wrap text in escape codes and return as string (no direct print) |
| `colour::strip` | Strip all ANSI escape codes from a string |
| `colour::visible_length` | Return the visible length of a string (excluding escape codes) |
| `colour::has_colour` | Check if a string contains any ANSI escape codes |

```bash
colour::println 4 fg red "This is red text"

# Pipe input
echo "hello" | colour::print 4 fg green

# Wrap and store
coloured=$(colour::wrap 4 fg blue "blue text")

# Strip for logging
plain=$(echo "$coloured" | colour::strip)

# Alignment with coloured strings
colour::visible_length "$coloured"  # → 9 (ignoring escape codes)
```

## Dependencies

- **Requires**: `runtime`
- **Pure Bash** — no external tools needed for escape code generation
