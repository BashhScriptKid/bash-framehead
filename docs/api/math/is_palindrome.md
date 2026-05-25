# `math::is_palindrome`

**Signature:** `math::is_palindrome()`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if integer is a palindrome


## Source

```bash
math::is_palindrome() {
		local n="${1#-}"
		local rev
		rev=$(math::digit_reverse "$n")
		(( n == rev ))
}
```

