# ext/csv — Pure Bash CSV Parser (RFC 4180)

A zero-dependency CSV parser written entirely in Bash. No `csvkit`, no `python`, no
external binaries at all. Handles RFC 4180 quoting rules so you don't have to
write your own `IFS=,` parser that breaks on `"Smith, John"`.

## Dependencies

- **bash-framehead core**: `runtime`
- **External**: `grep` (GNU), `tr` — used for the C-speed row index on CSVs > 4 KB.
  Without them the parser falls back to a pure-Bash sequential scanner that is
  correct but slower on large files.

## Usage

```bash
source ./bash-framehead.sh
source ./ext/csv/csv.sh
```

## Global Configuration

| Variable | Default | Effect |
|----------|---------|--------|
| `CSV_NOHEADER` | unset | Treat first row as data, not headers |
| `CSV_DELIMITER` | `,` | Field delimiter character |

```bash
# Semicolon-delimited European CSV
CSV_DELIMITER=';' csv::get "$data" 0 2

# CSV without a header row
CSV_NOHEADER=1 csv::get "$data" 0 0
```

## API Reference

All functions read the full CSV into memory — no streaming. For files over ~10 MB
Bash string handling becomes the bottleneck.

### `csv::get <csv> <row> <col>`

Return a single cell. `<row>` is 0-based, counting from the first **data** row
(i.e. after the header row when `CSV_NOHEADER` is not set). `<col>` is either
a 0-based index or a header name.

```bash
data=$'name,age,city\nAlice,30,NYC\nBob,25,LA'

csv::get "$data" 0 name   # → Alice
csv::get "$data" 0 1      # → 30
csv::get "$data" 1 city   # → LA
```

### `csv::get_file <file> <row> <col>`

Same as `csv::get` but reads the CSV from a file.

```bash
csv::get_file /path/to/data.csv 5 email
```

### `csv::row <csv> <row>`

Print all fields of a single row, tab-separated. Designed for `read`:

```bash
while IFS=$'\t' read -r name age city; do
    echo "Name: $name, Age: $age"
done < <(csv::row "$data" 0)
```

### `csv::headers <csv>`

Print header field names, one per line. Always reads the first row regardless
of `CSV_NOHEADER`.

```bash
csv::headers "$data"
# → name
# → age
# → city
```

### `csv::numrows <csv>`

Count data rows (excludes the header when `CSV_NOHEADER` is not set).

```bash
csv::numrows "$data"   # → 2 (Alice + Bob, header excluded)
```

### `csv::numcols <csv>`

Count columns from the first row.

```bash
csv::numcols "$data"   # → 3
```

## RFC 4180 Support

- Fields containing commas, double-quotes, or newlines must be quoted
- Double-quotes inside quoted fields are escaped by doubling (`""`)
- CRLF and LF line endings are both accepted
- Trailing newline is optional on the last row

## Limitations

- **No streaming**: the entire CSV must fit in a Bash string
- **Column count from first row only**: `numcols` returns the column count of
  the first row — it does not detect jagged rows
- **Bash 4.3+** required (associative arrays, namerefs in guard)
- **No type inference**: all values are strings
- **GNU grep required for large CSV performance**: the row-index optimisation
  uses `grep -z` (null-data mode) which is GNU-specific. On systems without
  GNU grep, the parser falls back to a pure-Bash sequential scanner that is
  correct but proportionally slower on deep files.
