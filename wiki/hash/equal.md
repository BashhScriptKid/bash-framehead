# `hash::equal`

Check if two strings have the same hash (constant-time safe via hash comparison)

## Usage

```bash
hash::equal string1 string2 [algorithm]
```

## Source

```bash
hash::equal() {
    local h1 h2 algo="${3:-sha256}"
    h1=$(hash::"$algo" "$1" 2>/dev/null) || return 1
    h2=$(hash::"$algo" "$2" 2>/dev/null) || return 1
    [[ "$h1" == "$h2" ]]
}
```

## Module

[`hash`](../hash.md)
