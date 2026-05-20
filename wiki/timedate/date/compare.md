# `timedate::date::compare`

Compare two dates — returns -1, 0, or 1

## Usage

```bash
timedate::date::compare YYYY-MM-DD YYYY-MM-DD
```

## Source

```bash
timedate::date::compare() {
    local ts1 ts2
    ts1=$(timedate::timestamp::from_human "$1 00:00:00")
    ts2=$(timedate::timestamp::from_human "$2 00:00:00")
    if (( ts1 < ts2 ));   then echo -1
    elif (( ts1 > ts2 )); then echo 1
    else                       echo 0
    fi
}
```

## Module

[`timedate`](../timedate.md)
