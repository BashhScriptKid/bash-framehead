# `timedate::date::is_before`

Check if a date is before another

## Source

```bash
timedate::date::is_before() {
    [[ "$(timedate::date::compare "$1" "$2")" == "-1" ]]
}
```

## Module

[`timedate`](../timedate.md)
