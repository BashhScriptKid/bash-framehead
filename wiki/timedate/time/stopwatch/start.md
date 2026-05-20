# `timedate::time::stopwatch::start`

Stopwatch — start, returns a token

## Usage

```bash
token=$(timedate::time::stopwatch::start)
```

## Source

```bash
timedate::time::stopwatch::start() {
    timedate::timestamp::unix_ms
}
```

## Module

[`timedate`](../timedate.md)
