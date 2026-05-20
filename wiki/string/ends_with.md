# `string::ends_with`

Check if string ends with suffix

## Usage

```bash
string::ends_with str suffix
```

## Source

```bash
string::ends_with() {
  [[ "$1" == *"$2" ]]
}
```

## Module

[`string`](../string.md)
