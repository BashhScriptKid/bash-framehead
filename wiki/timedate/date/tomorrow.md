# `timedate::date::tomorrow`

Get tomorrow's date

## Source

```bash
timedate::date::tomorrow() {
    timedate::date::add_days "$(timedate::date::today)" 1
}
```

## Module

[`timedate`](../timedate.md)
