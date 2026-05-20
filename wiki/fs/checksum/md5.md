# `fs::checksum::md5`

_No description available._

## Source

```bash
fs::checksum::md5() {
    if runtime::has_command md5sum; then
        md5sum "$1" | awk '{print $1}'
    elif runtime::has_command md5; then
        md5 -q "$1"
    fi
}
```

## Module

[`fs`](../fs.md)
