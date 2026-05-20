# `timedate::date::yesterday`

Get yesterday's date

## Source

```bash
timedate::date::yesterday() {
    timedate::date::add_days "$(timedate::date::today)" -1
}
```

## Module

[`timedate`](../timedate.md)
