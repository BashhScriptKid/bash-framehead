# `fs::checksum::sha1`

_No description available._

## Source

```bash
fs::checksum::sha1() {
    if runtime::has_command sha1sum; then
        sha1sum "$1" | awk '{print $1}'
    elif runtime::has_command shasum; then
        shasum -a 1 "$1" | awk '{print $1}'
    fi
}
```

## Module

[`fs`](../fs.md)
