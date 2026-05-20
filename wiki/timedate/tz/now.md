# `timedate::tz::now`

Get current time in a specific timezone

## Usage

```bash
timedate::tz::now timezone
```

## Source

```bash
timedate::tz::now() {
    TZ="$1" date "+%Y-%m-%d %H:%M:%S %Z" 2>/dev/null
}
```

## Module

[`timedate`](../timedate.md)
