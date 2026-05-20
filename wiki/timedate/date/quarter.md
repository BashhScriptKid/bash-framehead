# `timedate::date::quarter`

Get quarter (1-4)

## Source

```bash
timedate::date::quarter() {
    local month
    month=$(date +%m)
    echo $(( (10#$month - 1) / 3 + 1 ))
}
```

## Module

[`timedate`](../timedate.md)
