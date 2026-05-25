# `string::base32_decode::pure`

**Signature:** `string::base32_decode::pure()`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
string::base32_decode::pure() {
		local input; _string::read_input input "$@"
		local _str="${input//=}" i
		local -i a b c d e f g h

		# uppercase input since base32 alphabet is uppercase only
		_str="${s^^}"

		for (( i=0; i<${#s}; i+=8 )); do
				local c0="${_str:$i:1}" c1="${_str:$((i+1)):1}" c2="${_str:$((i+2)):1}" c3="${_str:$((i+3)):1}"
				local c4="${_str:$((i+4)):1}" c5="${_str:$((i+5)):1}" c6="${_str:$((i+6)):1}" c7="${_str:$((i+7)):1}"
				# Use case for reliable index lookup (base32 alphabet: A-Z, 2-7)
				case "$c0" in A) a=0;; B) a=1;; C) a=2;; D) a=3;; E) a=4;; F) a=5;; G) a=6;; H) a=7;; I) a=8;; J) a=9;; K) a=10;; L) a=11;; M) a=12;; N) a=13;; O) a=14;; P) a=15;; Q) a=16;; R) a=17;; S) a=18;; T) a=19;; U) a=20;; V) a=21;; W) a=22;; X) a=23;; Y) a=24;; Z) a=25;; 2) a=26;; 3) a=27;; 4) a=28;; 5) a=29;; 6) a=30;; 7) a=31;; *) a=0;; esac
				case "$c1" in A) b=0;; B) b=1;; C) b=2;; D) b=3;; E) b=4;; F) b=5;; G) b=6;; H) b=7;; I) b=8;; J) b=9;; K) b=10;; L) b=11;; M) b=12;; N) b=13;; O) b=14;; P) b=15;; Q) b=16;; R) b=17;; S) b=18;; T) b=19;; U) b=20;; V) b=21;; W) b=22;; X) b=23;; Y) b=24;; Z) b=25;; 2) b=26;; 3) b=27;; 4) b=28;; 5) b=29;; 6) b=30;; 7) b=31;; *) b=0;; esac
				case "$c2" in A) c=0;; B) c=1;; C) c=2;; D) c=3;; E) c=4;; F) c=5;; G) c=6;; H) c=7;; I) c=8;; J) c=9;; K) c=10;; L) c=11;; M) c=12;; N) c=13;; O) c=14;; P) c=15;; Q) c=16;; R) c=17;; S) c=18;; T) c=19;; U) c=20;; V) c=21;; W) c=22;; X) c=23;; Y) c=24;; Z) c=25;; 2) c=26;; 3) c=27;; 4) c=28;; 5) c=29;; 6) c=30;; 7) c=31;; *) c=0;; esac
				case "$c3" in A) d=0;; B) d=1;; C) d=2;; D) d=3;; E) d=4;; F) d=5;; G) d=6;; H) d=7;; I) d=8;; J) d=9;; K) d=10;; L) d=11;; M) d=12;; N) d=13;; O) d=14;; P) d=15;; Q) d=16;; R) d=17;; S) d=18;; T) d=19;; U) d=20;; V) d=21;; W) d=22;; X) d=23;; Y) d=24;; Z) d=25;; 2) d=26;; 3) d=27;; 4) d=28;; 5) d=29;; 6) d=30;; 7) d=31;; *) d=0;; esac
				case "$c4" in A) e=0;; B) e=1;; C) e=2;; D) e=3;; E) e=4;; F) e=5;; G) e=6;; H) e=7;; I) e=8;; J) e=9;; K) e=10;; L) e=11;; M) e=12;; N) e=13;; O) e=14;; P) e=15;; Q) e=16;; R) e=17;; S) e=18;; T) e=19;; U) e=20;; V) e=21;; W) e=22;; X) e=23;; Y) e=24;; Z) e=25;; 2) e=26;; 3) e=27;; 4) e=28;; 5) e=29;; 6) e=30;; 7) e=31;; *) e=0;; esac
				case "$c5" in A) f=0;; B) f=1;; C) f=2;; D) f=3;; E) f=4;; F) f=5;; G) f=6;; H) f=7;; I) f=8;; J) f=9;; K) f=10;; L) f=11;; M) f=12;; N) f=13;; O) f=14;; P) f=15;; Q) f=16;; R) f=17;; S) f=18;; T) f=19;; U) f=20;; V) f=21;; W) f=22;; X) f=23;; Y) f=24;; Z) f=25;; 2) f=26;; 3) f=27;; 4) f=28;; 5) f=29;; 6) f=30;; 7) f=31;; *) f=0;; esac
				case "$c6" in A) g=0;; B) g=1;; C) g=2;; D) g=3;; E) g=4;; F) g=5;; G) g=6;; H) g=7;; I) g=8;; J) g=9;; K) g=10;; L) g=11;; M) g=12;; N) g=13;; O) g=14;; P) g=15;; Q) g=16;; R) g=17;; S) g=18;; T) g=19;; U) g=20;; V) g=21;; W) g=22;; X) g=23;; Y) g=24;; Z) g=25;; 2) g=26;; 3) g=27;; 4) g=28;; 5) g=29;; 6) g=30;; 7) g=31;; *) g=0;; esac
				case "$c7" in A) h=0;; B) h=1;; C) h=2;; D) h=3;; E) h=4;; F) h=5;; G) h=6;; H) h=7;; I) h=8;; J) h=9;; K) h=10;; L) h=11;; M) h=12;; N) h=13;; O) h=14;; P) h=15;; Q) h=16;; R) h=17;; S) h=18;; T) h=19;; U) h=20;; V) h=21;; W) h=22;; X) h=23;; Y) h=24;; Z) h=25;; 2) h=26;; 3) h=27;; 4) h=28;; 5) h=29;; 6) h=30;; 7) h=31;; *) h=0;; esac

				printf "\\$(printf '%03o' $(( (a << 3) | (b >> 2) )))"
				(( i+2 < ${#s} )) && printf "\\$(printf '%03o' $(( ((b & 3) << 6) | (c << 1) | (d >> 4) )))"
				(( i+4 < ${#s} )) && printf "\\$(printf '%03o' $(( ((d & 15) << 4) | (e >> 1) )))"
				(( i+5 < ${#s} )) && printf "\\$(printf '%03o' $(( ((e & 1) << 7) | (f << 2) | (g >> 3) )))"
				(( i+7 < ${#s} )) && printf "\\$(printf '%03o' $(( ((g & 7) << 5) | h )))"
		done
		echo
}
```

