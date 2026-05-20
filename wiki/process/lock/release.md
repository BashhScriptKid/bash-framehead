# `process::lock::release`

Release a lock

## Usage

```bash
process::lock::release lockname
```

## Source

```bash
process::lock::release() {
    rm -f "/tmp/fsbshf_${1}.lock"
}
```

## Module

[`process`](../process.md)
