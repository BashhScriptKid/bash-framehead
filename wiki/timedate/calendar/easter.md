# `timedate::calendar::easter`

Calculate Easter date for a given year (Meeus/Jones/Butcher algorithm)

## Usage

```bash
timedate::calendar::easter year
```

**Output:** YYYY-MM-DD

## Source

```bash
timedate::calendar::easter() {
    local year="$1"
    local a b c d e f g h i k l m n p

    a=$(( year % 19 ))
    b=$(( year / 100 ))
    c=$(( year % 100 ))
    d=$(( b / 4 ))
    e=$(( b % 4 ))
    f=$(( (b + 8) / 25 ))
    g=$(( (b - f + 1) / 3 ))
    h=$(( (19 * a + b - d - g + 15) % 30 ))
    i=$(( c / 4 ))
    k=$(( c % 4 ))
    l=$(( (32 + 2 * e + 2 * i - h - k) % 7 ))
    m=$(( (a + 11 * h + 22 * l) / 451 ))
    n=$(( (h + l - 7 * m + 114) / 31 ))
    p=$(( (h + l - 7 * m + 114) % 31 + 1 ))

    printf '%d-%02d-%02d\n' "$year" "$n" "$p"
}
```

## Module

[`timedate`](../timedate.md)
