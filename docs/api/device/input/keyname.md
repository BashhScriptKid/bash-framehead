# `device::input::keyname`

**Signature:** `device::input::keyname(arg1, ...)`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Convert key code to name

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `...` | any | — | |

## Source

```bash
device::input::keyname() {
		local _code="$1"
		case "$_code" in
				1) echo "escape" ;;
				2) echo "1" ;; 3) echo "2" ;; 4) echo "3" ;; 5) echo "4" ;;
				6) echo "5" ;; 7) echo "6" ;; 8) echo "7" ;; 9) echo "8" ;;
				10) echo "9" ;; 11) echo "0" ;;
				12) echo "minus" ;; 13) echo "equal" ;; 14) echo "backspace" ;;
				15) echo "tab" ;;
				16) echo "q" ;; 17) echo "w" ;; 18) echo "e" ;; 19) echo "r" ;;
				20) echo "t" ;; 21) echo "y" ;; 22) echo "u" ;; 23) echo "i" ;;
				24) echo "o" ;; 25) echo "p" ;;
				26) echo "leftbrace" ;; 27) echo "rightbrace" ;; 28) echo "enter" ;;
				29) echo "leftctrl" ;;
				30) echo "a" ;; 31) echo "s" ;; 32) echo "d" ;; 33) echo "f" ;;
				34) echo "g" ;; 35) echo "h" ;; 36) echo "j" ;; 37) echo "k" ;;
				38) echo "l" ;;
				39) echo "semicolon" ;; 40) echo "apostrophe" ;; 41) echo "grave" ;;
				42) echo "leftshift" ;; 43) echo "backslash" ;;
				44) echo "z" ;; 45) echo "x" ;; 46) echo "c" ;; 47) echo "v" ;;
				48) echo "b" ;; 49) echo "n" ;; 50) echo "m" ;;
				51) echo "comma" ;; 52) echo "dot" ;; 53) echo "slash" ;;
				54) echo "rightshift" ;;
				55) echo "kpasterisk" ;; 56) echo "leftalt" ;; 57) echo "space" ;;
				58) echo "capslock" ;;
				59) echo "f1" ;; 60) echo "f2" ;; 61) echo "f3" ;; 62) echo "f4" ;;
				63) echo "f5" ;; 64) echo "f6" ;; 65) echo "f7" ;; 66) echo "f8" ;;
				67) echo "f9" ;; 68) echo "f10" ;; 69) echo "numlock" ;; 70) echo "scrolllock" ;;
				71) echo "kp7" ;; 72) echo "kp8" ;; 73) echo "kp9" ;; 74) echo "kpminus" ;;
				75) echo "kp4" ;; 76) echo "kp5" ;; 77) echo "kp6" ;; 78) echo "kpplus" ;;
				79) echo "kp1" ;; 80) echo "kp2" ;; 81) echo "kp3" ;; 82) echo "kp0" ;;
				83) echo "kpdot" ;;
				87) echo "f11" ;; 88) echo "f12" ;;
				96) echo "kpenter" ;; 97) echo "rightctrl" ;; 98) echo "kpslash" ;;
				99) echo "sysrq" ;;
				100) echo "rightalt" ;;
				102) echo "home" ;; 103) echo "up" ;; 104) echo "pageup" ;;
				105) echo "left" ;; 106) echo "right" ;; 107) echo "end" ;;
				108) echo "down" ;; 109) echo "pagedown" ;; 110) echo "insert" ;;
				111) echo "delete" ;;
				119) echo "pause" ;;
				125) echo "leftmeta" ;; 126) echo "rightmeta" ;; 127) echo "compose" ;;
				*) echo "key_$_code" ;;
		esac
}
```

