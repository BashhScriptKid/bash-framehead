# `timedate::time::stopwatch::stop`

Stopwatch — stop, returns elapsed ms

## Usage

```bash
timedate::time::stopwatch::stop token
```

## Source

```bash
timedate::time::stopwatch::stop() {
    local start="$1"
    local now
    now=$(timedate::timestamp::unix_ms)
    echo $(( now - start ))
}
```

## Module

[`timedate`](../timedate.md)
