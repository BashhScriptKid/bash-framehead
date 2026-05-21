# `string::base64_decode::pure`

**Signature:** `string::base64_decode::pure()`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
string::base64_decode::pure() {
    local input; _string::read_input input "$@"
    local s="$input" i
    local -i a b c d byte1 byte2 byte3
    local _B64="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    # strip padding
    s="${s//=}"

    for (( i=0; i<${#s}; i+=4 )); do
        local c0="${s:$i:1}" c1="${s:$((i+1)):1}" c2="${s:$((i+2)):1}" c3="${s:$((i+3)):1}"
        # Use case for reliable index lookup (avoids issues with +/ in patterns)
        case "$c0" in A) a=0;; B) a=1;; C) a=2;; D) a=3;; E) a=4;; F) a=5;; G) a=6;; H) a=7;; I) a=8;; J) a=9;; K) a=10;; L) a=11;; M) a=12;; N) a=13;; O) a=14;; P) a=15;; Q) a=16;; R) a=17;; S) a=18;; T) a=19;; U) a=20;; V) a=21;; W) a=22;; X) a=23;; Y) a=24;; Z) a=25;; a) a=26;; b) a=27;; c) a=28;; d) a=29;; e) a=30;; f) a=31;; g) a=32;; h) a=33;; i) a=34;; j) a=35;; k) a=36;; l) a=37;; m) a=38;; n) a=39;; o) a=40;; p) a=41;; q) a=42;; r) a=43;; s) a=44;; t) a=45;; u) a=46;; v) a=47;; w) a=48;; x) a=49;; y) a=50;; z) a=51;; 0) a=52;; 1) a=53;; 2) a=54;; 3) a=55;; 4) a=56;; 5) a=57;; 6) a=58;; 7) a=59;; 8) a=60;; 9) a=61;; +) a=62;; /) a=63;; *) a=0;; esac
        case "$c1" in A) b=0;; B) b=1;; C) b=2;; D) b=3;; E) b=4;; F) b=5;; G) b=6;; H) b=7;; I) b=8;; J) b=9;; K) b=10;; L) b=11;; M) b=12;; N) b=13;; O) b=14;; P) b=15;; Q) b=16;; R) b=17;; S) b=18;; T) b=19;; U) b=20;; V) b=21;; W) b=22;; X) b=23;; Y) b=24;; Z) b=25;; a) b=26;; b) b=27;; c) b=28;; d) b=29;; e) b=30;; f) b=31;; g) b=32;; h) b=33;; i) b=34;; j) b=35;; k) b=36;; l) b=37;; m) b=38;; n) b=39;; o) b=40;; p) b=41;; q) b=42;; r) b=43;; s) b=44;; t) b=45;; u) b=46;; v) b=47;; w) b=48;; x) b=49;; y) b=50;; z) b=51;; 0) b=52;; 1) b=53;; 2) b=54;; 3) b=55;; 4) b=56;; 5) b=57;; 6) b=58;; 7) b=59;; 8) b=60;; 9) b=61;; +) b=62;; /) b=63;; *) b=0;; esac
        case "$c2" in A) c=0;; B) c=1;; C) c=2;; D) c=3;; E) c=4;; F) c=5;; G) c=6;; H) c=7;; I) c=8;; J) c=9;; K) c=10;; L) c=11;; M) c=12;; N) c=13;; O) c=14;; P) c=15;; Q) c=16;; R) c=17;; S) c=18;; T) c=19;; U) c=20;; V) c=21;; W) c=22;; X) c=23;; Y) c=24;; Z) c=25;; a) c=26;; b) c=27;; c) c=28;; d) c=29;; e) c=30;; f) c=31;; g) c=32;; h) c=33;; i) c=34;; j) c=35;; k) c=36;; l) c=37;; m) c=38;; n) c=39;; o) c=40;; p) c=41;; q) c=42;; r) c=43;; s) c=44;; t) c=45;; u) c=46;; v) c=47;; w) c=48;; x) c=49;; y) c=50;; z) c=51;; 0) c=52;; 1) c=53;; 2) c=54;; 3) c=55;; 4) c=56;; 5) c=57;; 6) c=58;; 7) c=59;; 8) c=60;; 9) c=61;; +) c=62;; /) c=63;; *) c=0;; esac
        case "$c3" in A) d=0;; B) d=1;; C) d=2;; D) d=3;; E) d=4;; F) d=5;; G) d=6;; H) d=7;; I) d=8;; J) d=9;; K) d=10;; L) d=11;; M) d=12;; N) d=13;; O) d=14;; P) d=15;; Q) d=16;; R) d=17;; S) d=18;; T) d=19;; U) d=20;; V) d=21;; W) d=22;; X) d=23;; Y) d=24;; Z) d=25;; a) d=26;; b) d=27;; c) d=28;; d) d=29;; e) d=30;; f) d=31;; g) d=32;; h) d=33;; i) d=34;; j) d=35;; k) d=36;; l) d=37;; m) d=38;; n) d=39;; o) d=40;; p) d=41;; q) d=42;; r) d=43;; s) d=44;; t) d=45;; u) d=46;; v) d=47;; w) d=48;; x) d=49;; y) d=50;; z) d=51;; 0) d=52;; 1) d=53;; 2) d=54;; 3) d=55;; 4) d=56;; 5) d=57;; 6) d=58;; 7) d=59;; 8) d=60;; 9) d=61;; +) d=62;; /) d=63;; *) d=0;; esac

        byte1=$(( (a << 2) | (b >> 4) ))
        byte2=$(( ((b & 15) << 4) | (c >> 2) ))
        byte3=$(( ((c & 3) << 6) | d ))

        printf "\\$(printf '%03o' $byte1)"
        (( i+2 < ${#s} )) && printf "\\$(printf '%03o' $byte2)"
        (( i+3 < ${#s}  )) && printf "\\$(printf '%03o' $byte3)"
    done
    echo
}
```

