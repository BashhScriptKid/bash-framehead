# `math::clamp`

**Signature:** `math::clamp(n, min, max)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Clamp n between min and max inclusive

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `n` | integer | Yes | |
| `min` | string | Yes | |
| `max` | string | Yes | |

## Source

```bash
math::clamp() {
    local n="$1" lo="$2" hi="$3"
    _math::is_float "$n" || _math::is_float "$lo" || _math::is_float "$hi" && { echo "math::clamp: float input — use math::clampf" >&2; return 1; }
    echo $(( n < lo ? lo : (n > hi ? hi : n) ))
}
```

