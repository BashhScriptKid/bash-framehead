# `timedate::calendar::month`

Get the calendar for a month (like cal command)

## Usage

```bash
timedate::calendar::month [year] [month]
```

## Source

```bash
timedate::calendar::month() {
    local year="${1:-$(date +%Y)}" month="${2:-$(date +%m)}"
    if runtime::has_command cal; then
        cal "$month" "$year"
    else
        # Pure bash fallback — basic grid
        local days
        days=$(timedate::date::days_in_month "$year" "$month")
        local first_dow
        if _timedate::has_gnu_date; then
            first_dow=$(date -d "${year}-${month}-01" +%u 2>/dev/null)
        else
            first_dow=$(date -j -f "%Y-%m-%d" "${year}-${month}-01" +%u 2>/dev/null)
        fi
        printf '%s %s\n' "$(date -d "${year}-${month}-01" +"%B %Y" 2>/dev/null || echo "$year-$month")" ""
        printf 'Mo Tu We Th Fr Sa Su\n'
        local pad=$(( first_dow - 1 ))
        local i col=1
        printf '%s' "$(printf '   %.0s' $(seq 1 $pad))"
        col=$(( pad + 1 ))
        for (( i=1; i<=days; i++ )); do
            printf '%2d ' "$i"
            (( col % 7 == 0 )) && printf '\n'
            (( col++ ))
        done
        printf '\n'
    fi
}
```

## Module

[`timedate`](../timedate.md)
