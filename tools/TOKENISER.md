# `tokeniser.sh` — Architecture & Consumer Guide

How to build source-transforming tools (prettifier, obfuscator, minifier,
linter, …) on top of `tools/tokeniser.sh`.

---

## 1. What it is

A **pure lexer** for Bash source. It crawls the input character-by-character
with lookaheads and emits a **flat, ordered token stream**. It does *not* build
an AST, resolve nesting into a tree, expand anything, or remove anything.

Two invariants make it useful as a transformation substrate:

1. **Every byte of the source is represented.** Concatenating the faithful
   re-emission of every token reproduces the original input. Nothing is dropped.
2. **It is a lexer, not a parser.** There is no command/redirect/list tree —
   just a sequence of typed lexical chunks. Consumers that need structure build
   it themselves from the token stream.

It is verified against the Parable bash corpus by `tools/parable-verify.sh`
(see §8): tokenise → re-emit → real `bash` agrees on the AST. Currently
**294/295 corpus files round-trip exactly.**

---

## 2. The API

```bash
source tools/tokeniser.sh

local -a toks_type toks_val toks_pos   # parallel output arrays (auto-bound)
local    toks_count=0

tokenise "$source" toks toks_count
#          │        │    └─ name of an int var: receives the token count
#          │        └────── BASE NAME. The lexer binds <base>_type, <base>_val,
#          │                and <base>_pos by nameref. You declare those arrays.
#          └─────────────── the source string (may contain newlines)
```

After the call, for `0 <= N < toks_count`:

| Array | Holds |
|-------|-------|
| `toks_type[N]` | the token's type (see §3) |
| `toks_val[N]`  | the token's value (encoding/convention per type, §4–5) |
| `toks_pos[N]`  | start **byte offset** of the token in the logical source |

> **Naming:** you pass the *base* `toks`; the lexer binds `toks_type`,
> `toks_val`, `toks_pos`. Declare them with the exact `<base>_type` etc. names,
> or the namerefs won't resolve. Requires **bash 4.3+** (namerefs).

### Optional: parameter-expansion sub-parsing

```bash
local -A pe_table
PARSE_PE=1 tokenise "$source" toks toks_count pe_table
```
With `PARSE_PE=1` and a 4th associative-array argument, `${…}` interiors are
further decomposed into `pe_table`. Leave it off unless you specifically need
structured parameter expansions.

### Logging

The lexer honours `_minify_log_mode` (set it before calling):

| Value | Effect |
|-------|--------|
| unset / `""` | silent |
| `"progress"` | TTY progress bar on stderr |
| `"verbose"`  | per-token log lines on stderr |
| `"quiet"`    | suppress everything |

---

## 3. Token types

```
WORD          bare word: identifiers, keywords, numbers, unquoted globs
OP            shell operators: ; ;; ;;& ;& && || | & \ and a literal newline
REDIRECT      redirection operators: > >> < 2>&1 &> …   (NOT << or <<<)
HEREDOC_HEAD  << <<- or <<< (here-string)
HEREDOC_TAG   the delimiter word following HEREDOC_HEAD (quotes removed)
HEREDOC_BODY  opaque here-doc body (embedded newlines stored encoded)
HEREDOC_TAIL  the closing delimiter line
COMMENT       # … through end of line (the # is included)
STRING_SQ     '…'   interior only, no surrounding quotes
STRING_DQ     "…"   interior only, encoded
ARITH         $(( … ))   FULL verbatim incl. delimiters, encoded   ← see note
ARITH_STMT    (( … ))     FULL verbatim incl. delimiters, encoded   ← see note
ARITH_DEPRECATED  $[ … ]  full verbatim incl. delimiters
CMD_SUB       $( … )   interior only, encoded
PROC_SUB      <( … ) or >( … )   "dir|interior", encoded
PARAM_EXP     ${ … }   interior only, encoded
VAR_LITERAL   $var $1 $# $@ …   unbraced expansion, verbatim
BACKTICK      ` … `   verbatim
EXTGLOB       *( ) +( ) ?( ) @( ) !( )   verbatim
LOCALE_STRING $"…"   verbatim
```

> **Note (ARITH/ARITH_STMT):** the value stores the **whole construct including
> the `$((`/`((` and `))` delimiters**, not just the interior. This is the only
> faithful representation when the closing parens are non-adjacent
> (e.g. `$(($())#)`) or the body holds quotes/escapes/newlines. The re-emit is
> therefore byte-verbatim. (Older header comments calling it "interior" are
> stale.)

---

## 4. Value encoding (`_lit`)

Token values must survive in a flat array (one logical entry each), so types
whose interiors can contain newlines/tabs/backslashes are **`_lit`-encoded**:

| Raw byte | Stored as |
|----------|-----------|
| `\` (backslash) | `\\` |
| newline | `\n` (two chars) |
| tab | `\t` (two chars) |

To recover the raw text, reverse it **in exactly this order** (protect escaped
backslashes first):

```bash
unlit() {                       # writes decoded text into var named $2
    local s="$1"
    s="${s//\\\\/$'\x01'}"      # protect \\  → sentinel
    s="${s//\\n/$'\n'}"         # \n → newline
    s="${s//\\t/$'\t'}"         # \t → tab
    s="${s//$'\x01'/\\}"        # sentinel → single backslash
    printf -v "$2" '%s' "$s"
}
```

> **Gotcha — trailing newlines:** decode via `printf -v` (nameref), **not**
> `decoded=$(unlit "$v")`. Command substitution strips trailing newlines, which
> silently corrupts here-doc bodies and constructs like `$(cmd\n)`.

Which types are encoded: `STRING_DQ`, `CMD_SUB`, `PROC_SUB`, `PARAM_EXP`,
`ARITH`, `ARITH_STMT`, `HEREDOC_BODY`. Everything else is stored verbatim.
(`STRING_SQ` is interior-only but **raw** — single quotes preserve bytes
literally, including newlines.)

---

## 5. Re-emitting a token (tokens → source)

To reconstruct source from one token (the canonical reference is
`_pv_reemit_token` in `tools/parable-verify.sh`):

| Type | Reconstruction |
|------|----------------|
| `WORD` `OP` `REDIRECT` `HEREDOC_HEAD` `VAR_LITERAL` `BACKTICK` `EXTGLOB` `LOCALE_STRING` `ARITH_DEPRECATED` | `val` verbatim |
| `ARITH` `ARITH_STMT` | `unlit(val)` (already includes delimiters) |
| `STRING_SQ` | `'` + `val` + `'` |
| `STRING_DQ` | `"` + `unlit(val)` + `"` |
| `CMD_SUB`   | `$(` + `unlit(val)` + `)` |
| `PARAM_EXP` | `${` + `unlit(val)` + `}` |
| `PROC_SUB`  | `dir` + `(` + `unlit(val_after_pipe)` + `)`, where `dir=${val%%\|*}` |
| `COMMENT`   | `#` + `val` |
| `HEREDOC_TAG`  | `val`; re-quote as `'val'` if it is empty or contains a newline |
| `HEREDOC_BODY` | `\n` + decoded body + `\n` |
| `HEREDOC_TAIL` | `val` + `\n` |

### Spacing / adjacency

The lexer's **merge pass fuses adjacent word pieces into a single `WORD`** — e.g.
`a"b"$x` comes out as one `WORD`, not three tokens — so most intra-word
adjacency is already handled for you. When you do emit tokens back-to-back, two
tokens were adjacent in the source (no whitespace between) iff
`toks_pos[N] == toks_pos[N-1] + len(rendered token N-1)`; use `toks_pos` to
decide whether to insert a separator. A naïve "join with a space between
word-like tokens" works for most reformatting; for **byte-faithful** round-trip,
mirror `_pv_reemit`'s position-aware gap logic.

---

## 6. Worked example — identity re-emitter

The skeleton every transforming tool starts from. Tokenise, optionally rewrite
`type`/`val`, then re-emit.

```bash
source tools/tokeniser.sh

reemit_one() {                    # echoes reconstructed source for token i
    local t="$1" v="$2"
    local d
    case "$t" in
        ARITH|ARITH_STMT)        unlit "$v" d; printf '%s' "$d" ;;
        STRING_SQ)               printf "'%s'" "$v" ;;
        STRING_DQ)               unlit "$v" d; printf '"%s"' "$d" ;;
        CMD_SUB)                 unlit "$v" d; printf '$(%s)' "$d" ;;
        PARAM_EXP)               unlit "$v" d; printf '${%s}' "$d" ;;
        PROC_SUB)                unlit "${v#*|}" d; printf '%s(%s)' "${v%%|*}" "$d" ;;
        COMMENT)                 printf '#%s' "$v" ;;
        *)                       printf '%s' "$v" ;;   # WORD/OP/VAR_LITERAL/…
    esac
}

prettify() {
    local -a tk_type tk_val tk_pos
    local tk_count=0 i
    tokenise "$1" tk tk_count
    for (( i=0; i<tk_count; i++ )); do
        # … inspect/rewrite tk_type[i] / tk_val[i] here …
        reemit_one "${tk_type[i]}" "${tk_val[i]}"
    done
}
```

---

## 7. Worked example — sketches for real tools

**Prettifier** — re-flow whitespace using token boundaries:
- Insert a newline after `OP` tokens whose value is `;` or a literal newline.
- Track indent on `{`, `do`, `then`, `case`/`in`, `(` and dedent on the
  matching closers (you maintain the nesting; the lexer won't).
- Leave every other token's `val` untouched and re-emit per §5 — correctness is
  preserved because each token round-trips byte-for-byte.

**Obfuscator** — rename and encode without breaking semantics:
- Only rewrite `WORD` tokens that are *identifiers you own* (skip reserved words
  `if/then/while/…`, builtins, and `WORD`s in command position you don't
  control). The flat stream means you decide what's renameable.
- Re-encode `STRING_SQ`/`STRING_DQ` values through the bundled `_b32d` base32
  runtime helper (`$_B32D_HELPER`, exported by the tokeniser for exactly this) —
  emit `$(_b32d …)` in place and prepend the helper once.
- Never touch `HEREDOC_*`, `CMD_SUB`, or `ARITH` internals unless you re-tokenise
  their (decoded) interiors recursively.

**Minifier** — drop `COMMENT` tokens, collapse runs of whitespace-only `OP`
newlines, and join lines with `;`. Because comments are *tokens* (not stripped
text), removal is just "skip tokens of type `COMMENT`".

---

## 8. Verifying your consumer

`tools/parable-verify.sh` is the reference harness and is itself the only
in-tree consumer — read its `_pv_reemit_token` for the authoritative re-emit.
It runs four stages against a real `bash` oracle:

| Stage | Checks |
|-------|--------|
| **S1 LEX**       | the input tokenises without error |
| **S2 ROUNDTRIP** | re-emitted source parses to the *same AST* as the original (whitespace-normalised) |
| **S3 VOLUME**    | token-count / AST-group-count ratio is sane (catches under-tokenisation that S2 can mask) |
| **S4 VECTOR**    | the AST shape implies the expected token types are present |

Point it at an alternate tokeniser copy with the `TOKENISER` env var — useful
for testing a change in isolation before promoting it:

```bash
TOKENISER=/path/to/your/tokeniser.sh \
BASH_ORACLE=/path/to/bash-oracle \
  ./tools/parable-verify.sh [file.tests | dir]    # VERBOSE=1 dumps divergences
```

The S2 round-trip is the contract your transform must preserve: if you only
rewrite token *values* in ways that remain valid bash, re-emission stays sound.

---

## 9. Invariants & gotchas

- **Lexer, not parser.** No nesting tree. Track structure yourself from the
  stream (brace/paren/keyword depth).
- **Every byte is represented** — re-emission is lossless. A token you don't
  understand should be passed through verbatim, never dropped.
- **Decode before inspecting** encoded values (§4); re-encode (or re-wrap with
  delimiters) before re-emitting.
- **Use `printf -v`, not `$( )`,** to decode anything that may end in a newline.
- **Here-doc bodies are deferred tokens** (`HEREDOC_HEAD` → `HEREDOC_TAG` …
  later `HEREDOC_BODY`/`HEREDOC_TAIL`), mirroring bash. Preserve their order.
- **`STRING_SQ` is raw** (literal newlines included); everything `_lit`-encoded
  is listed in §4.
- **Adjacent word pieces are pre-fused** into one `WORD`; rely on `toks_pos` for
  any remaining gap decisions.
```
