# `timedate::tz::list::region`

List timezones filtered by region

## Usage

```bash
timedate::tz::list::region America
```

## Source

```bash
timedate::tz::list::region() {
    timedate::tz::list | grep "^${1}/"
}
```

## Module

[`timedate`](../timedate.md)
