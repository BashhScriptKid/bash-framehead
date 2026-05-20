# `timedate::date::month_end`

Get end of current month

## Source

```bash
timedate::date::month_end() {
    local year month days
    year=$(date +%Y)
    month=$(date +%m)
    days=$(timedate::date::days_in_month "$year" "$month")
    printf '%s-%s-%02d\n' "$year" "$month" "$days"
}
```

## Module

[`timedate`](../timedate.md)
