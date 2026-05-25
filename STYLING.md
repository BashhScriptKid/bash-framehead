# bash-framehead Style Guide

## Philosophy

Practical performance over theoretical purity. We target Bash 4.3+ and optimise
for speed and clarity. Portability matters only when it does not hurt
performance.

The ysap Bash Style Guide (style.ysap.sh) is useful for practical portability,
but we deviate where it conflicts with framehead's values (performance,
readability, or aesthetic choice).

### Implementation Reference

framehead is designed as an **implementation reference**. No one should feel
forced to use the entire framework. Every function follows "do one thing and do
it well" so developers can copy a single function or module into their own
scripts and inherit framehead's robustness without framework lock-in.

To support this:

- Public functions include a `# Usage:` comment when their parameters, return
  values, or behaviour are non-obvious.  Functions whose name alone fully
  describes their purpose (e.g. `runtime::is_root`, `colour::fg::red`,
  `git::is_dirty`) are exempt — the name *is* the documentation.
- Functions depend only on `runtime.sh` where possible — no horizontal
  cross-module coupling.
- Functions are self-contained; a reader can understand a single function by
  reading it in isolation.
- The codebase serves as a reference for idiomatic Bash 4.3+ patterns:
  parameter expansion, arrays, `printf -v`, namerefs, and `[[ ]]` / `(( ))`.

### Extensions & `compile_bare` (planned)

Extensions in `ext/` are self-contained units that depend on one or more
`src/` modules.  They document their required modules via a `# Requires:`
header comment (e.g. `# Requires: runtime.sh string.sh`).

A planned compilation mode — `compile_bare` — will perform a cascading
symbol query to resolve the full dependency chain:

```
json → string → runtime
```

It will emit a minimal, self-contained script that includes only the
functions actually used by the extension and its transitive dependencies.
This gives users a copyable, zero-framework-lock-in artifact that inherits
framehead's robustness.

## 1. Aesthetics

### 1.1 Indentation
- **Tabs only**. Never spaces.
- Tab display width does not matter.

### 1.2 Column Limit
- **Soft 80-column limit**.
- Break with a backslash (\) **unless** that would ruin surrounding alignment.

### 1.3 Semicolons
- Allowed for aesthetic grouping:
  ```bash
  colour::fg::red; echo "error"
  [[ $ok ]] && { colour::bold; echo "pass"; }
  ```
- Never chain unrelated statements:
  ```bash
  local a=1; local b=2   # BAD
  ```

### 1.4 Blank Lines (Maximum 4 Blank)

| Context | Blank Lines |
|---------|-------------|
| Between related statements in a function | 0 |
| Between local declarations and first logic | 1 |
| Between logical sections within a module | 1 |
| Between functions in the same family | 1 |
| Between feature families (e.g. vec2 vs vec3) | 2 |
| Between major subsystems (e.g. vectors vs tensors) | 4 |
| **Never more than 4** | — |

Example:
```bash
math::vec2::add() { … }
math::vec2::sub() { … }


math::vec3::add() { … }
math::vec3::sub() { … }


math::tensor::rank() { … }
```

## 2. Function Definitions

```bash
module::function() {
	local var=value
	…
}
```

- **No** `function` keyword.
- **All** variables must be `local`.
- Public API: `module::function`
- Private helpers: `_module::helper`
- Fast nameref variants: `module::function::fast`
- Exported constants: `UPPER_SNAKE_CASE` (readonly permitted for intent)
- Local variables: `lower_snake_case`

### 2.1 Variable Naming

Variable names must be self-documenting. Single-letter or abbreviated names
harm readability and are forbidden unless they fall into one of these
exceptions:

| Allowed | Example | Reason |
|---------|---------|--------|
| Loop counters | `i`, `j`, `k` | Universal convention |
| Cartesian coords | `x`, `y`, `z` | Domain convention (math, geometry) |
| Color channels | `r`, `g`, `b` | Domain convention (graphics) |
| PRNG state registers | `s0`, `s1`, `s2` | Domain convention (XorShift, ISAAC, etc.) |
| Scalar helpers in math | `dx`, `dy`, `sum`, `val` | Short but unambiguous |
| Standard Unix abbrevs | `_fd` (file descriptor), `_pid` | Ubiquitous in the shell ecosystem |
| **Algebraic leeway** | `_W_weights`, `_cof_cofactor`, `_lr_rate` | Short form preserved for formula readability; suffix disambiguates |

When a variable name is derived from mathematical notation (matrix
coefficients, neural-net weights, formula parameters), use the pattern
`{letter}_{word}` — the letter keeps formulas readable, the word tells
non-experts what it means:

```bash
# BAD
local W dW              # weights? width? window?
local lr                # learning rate? left-right?

# GOOD
local _W_weights _dW_weight_gradient
local _lr_learning_rate
```

Exemptions are **stricter the more niche the context**.  Short names like `i`
or `tmp` survive anywhere because they're universally understood.  But `_cp`
in a unicode decoder confuses everyone who doesn't already know it means
"code point" — so in narrow domains you must spell it out precisely *because*
fewer readers share the context:  `_codepoint` over `_cp`, `_delimiter` over
`_d`.  When in doubt, expand.

Otherwise, spell it out:

```bash
# BAD
local s="$1"        # string? sum? scale?
local n="$2"        # number? name? count?
local _a            # what is _a?

# GOOD
local str="$1"
local count="$2"
local _name
```

## 3. Bashisms (Use Freely)

- `[[ … ]]` for conditionals (never `[ ]`)
- `(( … ))` for arithmetic (never `let`)
- `$( … )` for command substitution (never backticks)
- Parameter expansion: `${var//pat/rep}`, `${var@Q}`, etc.
- Arrays for lists (never space-separated strings)

## 4. External Commands (Pragmatic)

Use external tools when they provide measurable speed or clarity
benefits over pure Bash.

Use:
- `awk` for fast field extraction or CSV parsing
- `sed` for complex multi-line regex
- `tput` for terminal capability detection
- `bc` for high-precision floating-point
- `seq` only for large ranges where `{1..N}` is slower

Prefer builtins for simple cases:

```bash
${var%/*}   # instead of dirname
${var##*/}  # instead of basename
${var//-/}  # instead of sed/tr
```

## 5. Conditional Breaking

When a conditional exceeds 80 columns:

a. Keep comparison operators together (`-lt`, `-gt`, `-eq`, `&&`, `||`)
b. Break before command substitution (`$( )`, `$(( ))`) or mixed logic
c. Never split a comparison group just to fit the line

```bash
# GOOD
if [[ $a -lt $b && $c -gt $d ]] &&
   [[ $(get_limit) -gt 0 ]]; then

# BAD
if [[ $a -lt $b && $c -gt $d &&
      $e -eq $f ]]; then
```

## 6. Variable Declaration

- Every variable in a function must be `local`.
- Do not use `declare -i` (use `(( … ))` instead).
- Do not use `let`.
- `readonly` is **permitted** for constants where intent matters (e.g. IEEE754 masks).
- Avoid uppercase names unless they are constants or exported.

## 7. Error Handling

- Guard commands that may fail: `cd /path || return`
- Do not use `set -e`
- Return meaningful exit codes

## 8. Quoting

- Quote variables undergoing word-splitting: `echo "$var"`
- Inside `[[ … ]]` quoting is optional
- Controlled variables (flags, counters) may remain unquoted

## 9. Comments

### 9.1 File Header

```bash
#!/usr/bin/env bash
# <module>.sh - bash-framehead <category> module
# Requires: runtime.sh [other deps…]
#
# One-sentence description.
#
# --- Section Name ---
```

### 9.2 Section Separators

```bash
# --- Section Name ---
```

### 9.3 Function Comments

```bash
# Trim leading whitespace
# Usage: string::trim_left str
string::trim_left() { … }
```

- One line for simple functions; two for non-obvious parameters.
- No JSDoc / verbose blocks.

### 9.4 Explain *Why*, Not *What*

```bash
# BAD
i=$((i + 1))  # increment i

# GOOD
i=$((i + 1))  # skip the sentinel delimiter
```

### 9.5 No Trailing Comments for Multi-Line Logic

Put the comment above the code, not at the end of a line.

### 9.6 ASCII Only

No Unicode or emoji in comments.

### 9.7 TODO / FIXME / NOTE

```bash
# TODO: add overflow guard for scale > 8
# FIXME: breaks on Bash 4.2, requires 4.3+
# NOTE: keeping readonly for constant clarity (see STYLING.md)
```

### 9.8 Historical / Human Comments

Permitted if they carry historical significance. Do not sanitise, reformat, or
attribute.

```bash
# i actually dont want to kms anymore i think
```

## 10. Module Structure

- One module per concern
- No horizontal dependencies except via `runtime.sh`
- Leave 1 blank line above a section separator, 1 below
