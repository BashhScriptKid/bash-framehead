# `timedate::date::is_after`

Check if a date is after another

## Source

```bash
timedate::date::is_after() {
    [[ "$(timedate::date::compare "$1" "$2")" == "1" ]]
}
```

## Module

[`timedate`](../timedate.md)
