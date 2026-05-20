# `string::starts_with`

Check if string starts with prefix

## Usage

```bash
string::starts_with str prefix
```

## Source

```bash
string::starts_with() {
  [[ "$1" == "$2"* ]]
}
```

## Module

[`string`](../string.md)
