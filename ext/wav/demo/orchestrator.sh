#!/usr/bin/env bash
# ---------------------------------------------------------------
# Bytebeat orchestrator
#
# Forks N workers (one per CPU core), each running a chunk of the
# time domain. Workers call runner's sample() function, encode
# the output, and write PCM to temp files. Master assembles the
# final WAV from the chunks.
#
# Env vars (precedence: TARGET_SAMPLES > TARGET_SECONDS > TIMEOUT > batch-derived):
#   TARGET_SECONDS  — render this many seconds
#   TARGET_SAMPLES  — alternative: render this many samples
#   TIMEOUT         — render duration in seconds (also safety-net kill for workers)
#   START_OFFSET    — start t from this value (default: 0)
#   SAMPLE_RATE     — sample rate (default: 44000)
#   SPEED           — batch speed multiplier, 1=realtime (default: 1)
#   ENCODING        — u8 or u16le (default: u8)
#   NUM_WORKERS     — parallel workers (default: nproc)
#   MAX_BATCH       — samples per worker before flushing to disk (default: 4096)
#   NO_BATCH        — set to 1 to disable batch mode, use single-sample fallback
#
# When no target is defined, the orchestrator benchmarks sample() 10 times
# to measure velocity, then computes an optimal batch size:
#   batch = max( (SAMPLE_RATE / velocity) * SPEED, 1 )
#
# Usage:
#   ./orchestrator.sh [runner.sh] [output.wav]
# ---------------------------------------------------------------

set -euo pipefail

# ---------------------------------------------------------------
# Waveform LUTs — hardcoded constants, not computed at launch.
# 256 entries each, values 0-255. Index by phase & 0xFF.
# ---------------------------------------------------------------
_SIN=(128 131 134 137 140 143 146 149 152 155 158 161 164 167 170 173 176 179 182 185 187 190 193 195 198 201 203 206 208 210 213 215 217 219 222 224 226 228 230 231 233 235 236 238 240 241 242 244 245 246 247 248 249 250 251 251 252 253 253 254 254 254 254 254 255 254 254 254 254 254 253 253 252 251 251 250 249 248 247 246 245 244 242 241 240 238 236 235 233 231 230 228 226 224 222 219 217 215 213 210 208 206 203 201 198 195 193 190 187 185 182 179 176 173 170 167 164 161 158 155 152 149 146 143 140 137 134 131 128 124 121 118 115 112 109 106 103 100 97 94 91 88 85 82 79 76 73 70 68 65 62 60 57 54 52 49 47 45 42 40 38 36 33 31 29 27 25 24 22 20 19 17 15 14 13 11 10 9 8 7 6 5 4 4 3 2 2 1 1 1 1 1 1 1 1 1 1 1 2 2 3 4 4 5 6 7 8 9 10 11 13 14 15 17 19 20 22 24 25 27 29 31 33 36 38 40 42 45 47 49 52 54 57 60 62 65 68 70 73 76 79 82 85 88 91 94 97 100 103 106 109 112 115 118 121 124)
_TRI=(0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 64 66 68 70 72 74 76 78 80 82 84 86 88 90 92 94 96 98 100 102 104 106 108 110 112 114 116 118 120 122 124 126 128 130 132 134 136 138 140 142 144 146 148 150 152 154 156 158 160 162 164 166 168 170 172 174 176 178 180 182 184 186 188 190 192 194 196 198 200 202 204 206 208 210 212 214 216 218 220 222 224 226 228 230 232 234 236 238 240 242 244 246 248 250 252 254 255 253 251 249 247 245 243 241 239 237 235 233 231 229 227 225 223 221 219 217 215 213 211 209 207 205 203 201 199 197 195 193 191 189 187 185 183 181 179 177 175 173 171 169 167 165 163 161 159 157 155 153 151 149 147 145 143 141 139 137 135 133 131 129 127 125 123 121 119 117 115 113 111 109 107 105 103 101 99 97 95 93 91 89 87 85 83 81 79 77 75 73 71 69 67 65 63 61 59 57 55 53 51 49 47 45 43 41 39 37 35 33 31 29 27 25 23 21 19 17 15 13 11 9 7 5 3 1)
_SAW=(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255)

# Float-scale LUTs — values 0..10000 (fixed-point 0.0..1.0). Index by phase & 0xFF.
_FSIN=(5000 5122 5245 5367 5490 5612 5733 5854 5975 6095 6214 6333 6451 6568 6684 6799 6913 7026 7137 7248 7356 7464 7570 7674 7777 7879 7978 8076 8171 8265 8357 8447 8535 8621 8704 8786 8865 8941 9016 9087 9157 9224 9288 9350 9409 9466 9519 9571 9619 9664 9707 9747 9784 9818 9850 9878 9903 9926 9945 9962 9975 9986 9993 9998 10000 9998 9993 9986 9975 9962 9945 9926 9903 9878 9850 9818 9784 9747 9707 9664 9619 9571 9519 9466 9409 9350 9288 9224 9157 9087 9016 8941 8865 8786 8704 8621 8535 8447 8357 8265 8171 8076 7978 7879 7777 7674 7570 7464 7356 7248 7137 7026 6913 6799 6684 6568 6451 6333 6214 6095 5975 5854 5733 5612 5490 5367 5245 5122 5000 4877 4754 4632 4509 4387 4266 4145 4024 3904 3785 3666 3548 3431 3315 3200 3086 2973 2862 2751 2643 2535 2429 2325 2222 2120 2021 1923 1828 1734 1642 1552 1464 1378 1295 1213 1134 1058 983 912 842 775 711 649 590 533 480 428 380 335 292 252 215 181 149 121 96 73 54 37 24 13 6 1 0 1 6 13 24 37 54 73 96 121 149 181 215 252 292 335 380 428 480 533 590 649 711 775 842 912 983 1058 1134 1213 1295 1378 1464 1552 1642 1734 1828 1923 2021 2120 2222 2325 2429 2535 2643 2751 2862 2973 3086 3200 3315 3431 3548 3666 3785 3904 4024 4145 4266 4387 4509 4632 4754 4877)
_FTRI=(0 78 156 235 313 392 470 549 627 705 784 862 941 1019 1098 1176 1254 1333 1411 1490 1568 1647 1725 1803 1882 1960 2039 2117 2196 2274 2352 2431 2509 2588 2666 2745 2823 2901 2980 3058 3137 3215 3294 3372 3450 3529 3607 3686 3764 3843 3921 4000 4078 4156 4235 4313 4392 4470 4549 4627 4705 4784 4862 4941 5019 5098 5176 5254 5333 5411 5490 5568 5647 5725 5803 5882 5960 6039 6117 6196 6274 6352 6431 6509 6588 6666 6745 6823 6901 6980 7058 7137 7215 7294 7372 7450 7529 7607 7686 7764 7843 7921 8000 8078 8156 8235 8313 8392 8470 8549 8627 8705 8784 8862 8941 9019 9098 9176 9254 9333 9411 9490 9568 9647 9725 9803 9882 9960 10000 9921 9843 9764 9686 9607 9529 9450 9372 9294 9215 9137 9058 8980 8901 8823 8745 8666 8588 8509 8431 8352 8274 8196 8117 8039 7960 7882 7803 7725 7647 7568 7490 7411 7333 7254 7176 7098 7019 6941 6862 6784 6705 6627 6549 6470 6392 6313 6235 6156 6078 6000 5921 5843 5764 5686 5607 5529 5450 5372 5294 5215 5137 5058 4980 4901 4823 4745 4666 4588 4509 4431 4352 4274 4196 4117 4039 3960 3882 3803 3725 3647 3568 3490 3411 3333 3254 3176 3098 3019 2941 2862 2784 2705 2627 2549 2470 2392 2313 2235 2156 2078 2000 1921 1843 1764 1686 1607 1529 1450 1372 1294 1215 1137 1058 980 901 823 745 666 588 509 431 352 274 196 117 39)
_FSAW=(0 39 78 117 156 196 235 274 313 352 392 431 470 509 549 588 627 666 705 745 784 823 862 901 941 980 1019 1058 1098 1137 1176 1215 1254 1294 1333 1372 1411 1450 1490 1529 1568 1607 1647 1686 1725 1764 1803 1843 1882 1921 1960 2000 2039 2078 2117 2156 2196 2235 2274 2313 2352 2392 2431 2470 2509 2549 2588 2627 2666 2705 2745 2784 2823 2862 2901 2941 2980 3019 3058 3098 3137 3176 3215 3254 3294 3333 3372 3411 3450 3490 3529 3568 3607 3647 3686 3725 3764 3803 3843 3882 3921 3960 4000 4039 4078 4117 4156 4196 4235 4274 4313 4352 4392 4431 4470 4509 4549 4588 4627 4666 4705 4745 4784 4823 4862 4901 4941 4980 5019 5058 5098 5137 5176 5215 5254 5294 5333 5372 5411 5450 5490 5529 5568 5607 5647 5686 5725 5764 5803 5843 5882 5921 5960 6000 6039 6078 6117 6156 6196 6235 6274 6313 6352 6392 6431 6470 6509 6549 6588 6627 6666 6705 6745 6784 6823 6862 6901 6941 6980 7019 7058 7098 7137 7176 7215 7254 7294 7333 7372 7411 7450 7490 7529 7568 7607 7647 7686 7725 7764 7803 7843 7882 7921 7960 8000 8039 8078 8117 8156 8196 8235 8274 8313 8352 8392 8431 8470 8509 8549 8588 8627 8666 8705 8745 8784 8823 8862 8901 8941 8980 9019 9058 9098 9137 9176 9215 9254 9294 9333 9372 9411 9450 9490 9529 9568 9607 9647 9686 9725 9764 9803 9843 9882 9921 9960 10000)
_FNOISE=(2463 3961 9550 1713 5984 9380 9649 7493 949 6187 1836 3045 8836 200 1698 8093 469 8857 6960 2070 4547 7696 3127 4133 2517 7538 8956 1066 3925 3260 5314 5364 8055 8458 4416 5355 6462 911 427 5450 1961 8725 308 822 591 4231 696 6029 3782 2991 6010 5754 503 3426 277 8050 1959 5721 8084 9157 763 8874 5797 1487 5830 8882 4635 4575 4541 7646 4049 3100 6542 6460 8284 9265 9006 582 8950 5454 1835 1798 1733 3241 6843 3766 293 3230 4407 3337 9322 6691 8864 187 4210 2298 6148 2556 2657 3978 4169 9564 4184 3127 7441 6613 3805 7882 573 5683 2072 3381 8158 4274 5387 7792 8745 5758 6854 8378 8604 4735 9115 1914 1192 2433 63 4238 1463 3272 2840 4333 5134 242 6751 8268 3014 8433 9418 2326 3379 2170 241 3564 3637 4223 7298 2299 2580 5472 4837 3736 9338 1311 9783 6583 2692 926 7910 9319 4770 5751 46 9545 4812 5988 1053 3956 9911 1781 4164 3577 2478 2445 8203 9104 4177 2753 4068 8611 1664 4065 519 703 881 759 9660 6950 5344 8044 9607 9302 4907 9823 5199 404 6438 7439 3769 4390 3362 6230 9151 4882 1542 2846 4907 6050 5360 1862 5607 5164 8334 3694 1213 8625 1319 590 7425 5066 8501 8025 4337 7317 5731 7016 4278 5247 6908 7280 4109 3295 9593 4303 1567 9727 7022 7657 423 9053 2803 1038 8507 2724 4811 7691 3028 3034 9675 5237 5509 7965 8882 8998 2789 9872)

# Math constants — fixed-point (_S = 10000)
_S=10000
_PI=31416     # 3.1416
_2PI=62832    # 6.2832
_SQRT2=14142  # 1.4142
_LN2=6931     # 0.6931
_E=27183      # 2.7183

# Additional float-scale LUTs for transcendental functions
# _FEXP: exp(x) for x in [-2.0, 0.0], 256 entries, scaled by _S (10000)
# Index: i -> x = -2 + i*2/255, value = exp(x) * _S
_FEXP=(1353 1364 1375 1386 1396 1407 1419 1430 1441 1452 1464 1475 1487 1499 1510 1522 1534 1546 1559 1571 1583 1596 1608 1621 1634 1647 1659 1673 1686 1699 1712 1726 1739 1753 1767 1781 1795 1809 1823 1838 1852 1867 1881 1896 1911 1926 1941 1957 1972 1988 2003 2019 2035 2051 2067 2083 2100 2116 2133 2150 2167 2184 2201 2218 2236 2253 2271 2289 2307 2325 2343 2362 2380 2399 2418 2437 2456 2476 2495 2515 2535 2555 2575 2595 2615 2636 2657 2678 2699 2720 2741 2763 2785 2807 2829 2851 2873 2896 2919 2942 2965 2988 3012 3036 3060 3084 3108 3132 3157 3182 3207 3232 3258 3283 3309 3335 3362 3388 3415 3442 3469 3496 3523 3551 3579 3607 3636 3664 3693 3722 3752 3781 3811 3841 3871 3902 3932 3963 3995 4026 4058 4090 4122 4154 4187 4220 4253 4287 4320 4355 4389 4423 4458 4493 4529 4564 4600 4636 4673 4710 4747 4784 4822 4860 4898 4937 4976 5015 5054 5094 5134 5175 5215 5256 5298 5340 5382 5424 5467 5510 5553 5597 5641 5685 5730 5775 5821 5866 5913 5959 6006 6053 6101 6149 6198 6246 6296 6345 6395 6445 6496 6547 6599 6651 6703 6756 6809 6863 6917 6971 7026 7082 7137 7193 7250 7307 7365 7423 7481 7540 7599 7659 7720 7780 7842 7903 7966 8028 8092 8155 8219 8284 8349 8415 8481 8548 8616 8683 8752 8821 8890 8960 9031 9102 9173 9246 9318 9392 9466 9540 9615 9691 9767 9844 9922 10000)

# _FLOG: log(x) for x in [1.0, 2.0), 256 entries, scaled by _S (10000)
# Mantissa part — use with frexp-style decomposition:
#   log(x) = _FLOG[mantissa_idx] + exp * _LN2
#   where x = mantissa * 2^exp, mantissa in [1,2)
_FLOG=(0 39 78 117 156 194 233 271 309 347 385 422 460 497 534 572 609 645 682 719 755 791 828 864 899 935 971 1006 1042 1077 1112 1147 1182 1217 1252 1286 1321 1355 1389 1423 1457 1491 1525 1558 1592 1625 1658 1692 1725 1758 1790 1823 1856 1888 1921 1953 1985 2017 2049 2081 2113 2145 2176 2208 2239 2271 2302 2333 2364 2395 2426 2456 2487 2518 2548 2578 2609 2639 2669 2699 2729 2758 2788 2818 2847 2877 2906 2935 2965 2994 3023 3052 3081 3109 3138 3167 3195 3224 3252 3280 3309 3337 3365 3393 3421 3448 3476 3504 3531 3559 3586 3614 3641 3668 3695 3722 3749 3776 3803 3830 3857 3883 3910 3936 3963 3989 4015 4042 4068 4094 4120 4146 4172 4197 4223 4249 4274 4300 4325 4351 4376 4402 4427 4452 4477 4502 4527 4552 4577 4602 4626 4651 4675 4700 4725 4749 4773 4798 4822 4846 4870 4894 4918 4942 4966 4990 5014 5037 5061 5085 5108 5132 5155 5179 5202 5225 5248 5272 5295 5318 5341 5364 5387 5410 5432 5455 5478 5500 5523 5546 5568 5591 5613 5635 5658 5680 5702 5724 5746 5768 5790 5812 5834 5856 5878 5900 5921 5943 5965 5986 6008 6029 6051 6072 6093 6115 6136 6157 6178 6199 6221 6242 6263 6283 6304 6325 6346 6367 6388 6408 6429 6449 6470 6491 6511 6531 6552 6572 6592 6613 6633 6653 6673 6693 6713 6733 6753 6773 6793 6813 6833 6853 6872 6892 6912 6931)

# ---------------------------------------------------------------
# Integer arithmetic primitives — zero overhead, direct $(( )) ops
# ---------------------------------------------------------------

# 2^n via bit-shift (n in 0..62 safe for 64-bit)
_pow2() { _r=$(( 1 << $1 )); }

# x % 2^n via bitmask (n in 0..62)
_mod_pow2() { _r=$(( $1 & ((1 << $2) - 1) )); }

# x * 2^n via bit-shift
_shift_left() { _r=$(( $1 << $2 )); }

# x / 2^n via bit-shift
_shift_right() { _r=$(( $1 >> $2 )); }

# Integer log2 (bit-length - 1)
_log2() {
    local x=$1 n=0
    (( x <= 0 )) && { _r=0; return; }
    while (( x > 1 )); do x=$(( x >> 1 )); n=$(( n + 1 )); done
    _r=$n
}

# Integer square root (Newton's method)
_isqrt() {
    local x=$1
    (( x <= 0 )) && { _r=0; return; }
    local guess=$(( x / 2 + 1 ))
    local prev
    while true; do
        prev=$guess
        guess=$(( (guess + x / guess) / 2 ))
        (( guess >= prev )) && break
    done
    _r=$guess
}

# Fixed-point multiply-shift: (a * b) >> shift
# Avoids scaling overhead for intermediate fixed-point math
_mul_shift() { _r=$(( ($1 * $2) >> $3 )); }

# Branchless clamp
_clamp() {
    local x=$1 lo=$2 hi=$3
    _r=$x
    (( x < lo )) && _r=$lo
    (( x > hi )) && _r=$hi
}

# Branchless min/max
_min() { _r=$(( $1 < $2 ? $1 : $2 )); }
_max() { _r=$(( $1 > $2 ? $1 : $2 )); }

# ---------------------------------------------------------------
# LUT helpers — transcendental functions via lookup tables
# ---------------------------------------------------------------

# sin(x) where x is radians * _S -> result * _S
# Uses _FSIN LUT (phase 0-255, values 0-10000, centered at 5000)
_lut_sin() {
    local phase=$(( ($1 * 256 / _2PI) & 0xFF ))
    _r=$(( (${_FSIN[$phase]} - 5000) * _S / 5000 ))
}

# exp(x) where x in [-2*_S, 0] -> result * _S
# Uses _FEXP LUT (256 entries, x from -2 to 0)
_lut_exp() {
    local idx=$(( ($1 + 2 * _S) * 255 / (2 * _S) ))
    _clamp $idx 0 255; idx=$_r
    _r=${_FEXP[$idx]}
}

# log(x) where x > 0 -> result * _S
# Decomposes x = mantissa * 2^n, mantissa in [1,2)
# Uses _FLOG LUT for mantissa, adds n * _LN2 for exponent
_lut_log() {
    local x=$1 n=0
    # Normalize to [1*_S, 2*_S) range
    while (( x >= 2 * _S )); do
        x=$(( x / 2 ))
        n=$(( n + 1 ))
    done
    while (( x < _S )); do
        x=$(( x * 2 ))
        n=$(( n - 1 ))
    done
    # x now in [_S, 2*_S), index = (x - _S) * 255 / _S
    local idx=$(( (x - _S) * 255 / _S ))
    _clamp $idx 0 255; idx=$_r
    _r=$(( _FLOG[idx] + n * _LN2 ))
}

# ---------------------------------------------------------------
# Binary encoding helpers — little-endian WAV header fields
# ---------------------------------------------------------------
_le16() { printf -v _v '\\x%02x\\x%02x' $(( $1 & 0xFF )) $(( ($1 >> 8) & 0xFF )); }
_le32() {
    printf -v _v '\\x%02x\\x%02x\\x%02x\\x%02x' \
        $(( $1 & 0xFF )) $(( ($1 >> 8) & 0xFF )) \
        $(( ($1 >> 16) & 0xFF )) $(( ($1 >> 24) & 0xFF ))
}

# ---------------------------------------------------------------
# prefer — composition API for declaring recommended render settings.
# Usage: prefer VARIABLE value
# The composer calls prefer to set how the song is best played:
#   prefer SAMPLE_RATE 48000
#   prefer ENCODING u16le
# If the user overrides via env, the user's choice wins.
# Precedence: caller env > composition prefer > orchestrator default.
# ---------------------------------------------------------------
declare -A _CALLER_SET=()
declare -A _PREFER_SET=()

prefer() {
    local _var=$1 _val=$2
    # Only set if caller hasn't explicitly provided this value
    if [[ -z "${_CALLER_SET[$_var]:-}" ]]; then
        declare -g "$_var=$_val"
        _PREFER_SET[$_var]=1
    fi
}

# ---------------------------------------------------------------
# Master orchestrator — fork workers and assemble WAV
# ---------------------------------------------------------------
if [[ "${1:-}" != "_worker" && "${1:-}" != "_lead" ]]; then

    DIR="$(dirname "${BASH_SOURCE[0]}")"
    RUNNER="${1:-${DIR}/runner.sh}"
    OUTPUT="${2:-bytebeat.wav}"

    # Track which config vars the caller set via env
    for _v in SAMPLE_RATE ENCODING NUM_WORKERS MAX_BATCH SPEED \
              TARGET_SECONDS TARGET_SAMPLES TIMEOUT NO_BATCH; do
        [[ -n "${!_v:-}" ]] && _CALLER_SET[$_v]=1
    done

    # Resolve runner path
    [[ "$RUNNER" != /* && ! -f "$RUNNER" ]] && RUNNER="${DIR}/${RUNNER}"

    if [[ ! -f "$RUNNER" ]]; then
        echo "runner not found: $RUNNER" >&2
        exit 1
    fi

    # Load runner. Bash runners are sourced directly; a compiled binary
    # runner (ELF) emits its own glue (prefer/sample/sample_batch) via the
    # `shim` subcommand, so it can be used with no separate .sh file.
    if [[ -x "$RUNNER" && "$(head -c 4 "$RUNNER" 2>/dev/null)" == $'\x7fELF' ]]; then
        eval "$("$RUNNER" shim)" || {
            echo "failed to load binary runner shim: $RUNNER" >&2; exit 1; }
    else
        source "$RUNNER"
    fi
    if ! declare -f sample >/dev/null 2>&1; then
        echo "runner $RUNNER does not define sample()" >&2
        exit 1
    fi

    # Apply orchestrator defaults for anything still unset
    SAMPLE_RATE="${SAMPLE_RATE:-44000}"
    ENCODING="${ENCODING:-u8}"
    NUM_WORKERS="${NUM_WORKERS:-$(nproc 2>/dev/null || echo 4)}"
    MAX_BATCH="${MAX_BATCH:-4096}"
    SPEED="${SPEED:-1}"
    TARGET_SECONDS="${TARGET_SECONDS:-}"
    TARGET_SAMPLES="${TARGET_SAMPLES:-}"
    TIMEOUT="${TIMEOUT:-}"
    START_OFFSET="${START_OFFSET:-0}"
    NO_BATCH="${NO_BATCH:-0}"

    t=$START_OFFSET

    # Benchmark runner — always runs, cheap (10 calls)
    _bench_start=${EPOCHREALTIME}
    for ((i = 0; i < 10; i++)); do
        sample "$i"
    done
    _bench_end=${EPOCHREALTIME}
    _bench_dt=$(awk "BEGIN{printf \"%.6f\", $_bench_end - $_bench_start}")
    VELOCITY=$(awk "BEGIN{printf \"%.0f\", 10 / $_bench_dt}")

    # Benchmark fork overhead (3 forks, measure average)
    _fork_start=${EPOCHREALTIME}
    for ((i = 0; i < 3; i++)); do
        bash -c 'exit' &
        wait
    done
    _fork_end=${EPOCHREALTIME}
    _fork_dt=$(awk "BEGIN{printf \"%.6f\", $_fork_end - $_fork_start}")
    FORK_OVERHEAD=$(awk "BEGIN{printf \"%.6f\", $_fork_dt / 3}")

    # Compute total samples
    if [[ -n "$TARGET_SAMPLES" ]]; then
        TOTAL_SAMPLES="$TARGET_SAMPLES"
    elif [[ -n "$TARGET_SECONDS" ]]; then
        TOTAL_SAMPLES=$(( TARGET_SECONDS * SAMPLE_RATE ))
    elif [[ -n "$TIMEOUT" ]]; then
        TOTAL_SAMPLES=$(( TIMEOUT * SAMPLE_RATE ))
    else
        # No target — derive from velocity (tiny benchmark-sized render).
        # Check what would actually be produced and warn, like a dry-run.
        OPTIMAL_BATCH=$(awk "BEGIN{v=$SAMPLE_RATE / $VELOCITY * $SPEED; b=int(v); if(b<1)b=1; print b}")
        TOTAL_SAMPLES=$(( OPTIMAL_BATCH * NUM_WORKERS ))
        _auto_sec=$(awk "BEGIN{printf \"%.3f\", $TOTAL_SAMPLES / $SAMPLE_RATE}")
        echo "[orch] WARNING: no TARGET_SECONDS/TARGET_SAMPLES/TIMEOUT set; output would be" >&2
        echo "[orch] WARNING: ~${_auto_sec}s (${TOTAL_SAMPLES} samples) — effectively inaudible." >&2
        echo "[orch] WARNING: set TARGET_SECONDS/TARGET_SAMPLES/TIMEOUT for real audio." >&2
    fi

    # Optimal worker count: minimize total_samples/(velocity*N) + N*fork_overhead
    # At optimum: d/dN = -total/(v*N^2) + fork = 0 → N = sqrt(total / (v * fork))
    MAX_CPUS=$(nproc 2>/dev/null || echo 4)
    OPTIMAL_WORKERS=$(awk "BEGIN{
        n = sqrt($TOTAL_SAMPLES / ($VELOCITY * $FORK_OVERHEAD))
        n = int(n + 0.5)
        if (n < 1) n = 1
        if (n > $MAX_CPUS) n = $MAX_CPUS
        print n
    }")

    # Use optimal unless user explicitly set NUM_WORKERS (env/arg) OR the
    # runner's `prefer NUM_WORKERS` declared it (stateful runners need this).
    if [[ -z "${_CALLER_SET[NUM_WORKERS]:-}" && -z "${_PREFER_SET[NUM_WORKERS]:-}" ]]; then
        NUM_WORKERS=$OPTIMAL_WORKERS
    fi

    # TIMEOUT-aware scaling: if ETA exceeds TIMEOUT, ramp up workers
    if [[ -n "$TIMEOUT" ]]; then
        _eta_sec=$(awk "BEGIN{printf \"%.0f\", $TOTAL_SAMPLES / $VELOCITY / $NUM_WORKERS + $NUM_WORKERS * $FORK_OVERHEAD}")
        while (( _eta_sec > TIMEOUT && NUM_WORKERS < MAX_CPUS )); do
            (( NUM_WORKERS++ )) || true
            _eta_sec=$(awk "BEGIN{printf \"%.0f\", $TOTAL_SAMPLES / $VELOCITY / $NUM_WORKERS + $NUM_WORKERS * $FORK_OVERHEAD}")
        done
        # If still over TIMEOUT with max workers, cap total_samples
        if (( _eta_sec > TIMEOUT )); then
            _max_samples=$(awk "BEGIN{printf \"%.0f\", ($TIMEOUT - $MAX_CPUS * $FORK_OVERHEAD) * $VELOCITY * $MAX_CPUS}")
            if (( _max_samples < TOTAL_SAMPLES )); then
                echo "[orch] TIMEOUT=${TIMEOUT}s caps render: $(( TOTAL_SAMPLES / SAMPLE_RATE ))s -> $(( _max_samples / SAMPLE_RATE ))s (${_max_samples} samples)" >&2
                TOTAL_SAMPLES=$_max_samples
                TOTAL_SECONDS=$(( TOTAL_SAMPLES / SAMPLE_RATE ))
            fi
        fi
    fi

    # ETA and resource estimates
    TOTAL_SECONDS=$(( TOTAL_SAMPLES / SAMPLE_RATE ))
    _eta_sec=$(awk "BEGIN{printf \"%.0f\", $TOTAL_SAMPLES / $VELOCITY / $NUM_WORKERS + $NUM_WORKERS * $FORK_OVERHEAD}")
    _realtime_ratio=$(awk "BEGIN{printf \"%.1f\", $VELOCITY / $SAMPLE_RATE}")
    _samples_per_worker=$(( (TOTAL_SAMPLES + NUM_WORKERS - 1) / NUM_WORKERS ))

    echo "[orch] sample_rate=$SAMPLE_RATE encoding=$ENCODING"
    echo "[orch] total_samples=$TOTAL_SAMPLES (${TOTAL_SECONDS}s)"
    echo "[orch] velocity=${VELOCITY} samples/s (${_realtime_ratio}x realtime)"
    echo "[orch] fork_overhead=${FORK_OVERHEAD}s optimal_workers=${OPTIMAL_WORKERS} (using ${NUM_WORKERS})"
    echo "[orch] planned_batch=${_samples_per_worker} samples/worker"
    echo "[orch] estimated render: ~${_eta_sec}s wall time"
    [[ -n "${OPTIMAL_BATCH:-}" ]] && echo "[orch] optimal_batch=$OPTIMAL_BATCH speed=$SPEED"

    # Warn if render will be slow
    if (( _eta_sec > 300 )); then
        echo "[orch] WARNING: estimated render >5 minutes." >&2
    fi

    echo "[orch] runner=$RUNNER"

    # Split samples across workers
    SAMPLES_PER_WORKER=$_samples_per_worker

    # Encoding params
    case "$ENCODING" in
        u8)    BPS=1 ; MASK=0xFF   ;;
        u16le) BPS=2 ; MASK=0xFFFF ;;
        *) echo "unsupported encoding: $ENCODING" >&2; exit 1 ;;
    esac
    FRAME_BYTES=$(( BPS * 2 ))  # stereo

    # ---- Progress tracking via per-worker files ----
    _PROGRESS_DIR=$(mktemp -d "/tmp/bborch-progress-XXXXXX")
    _WORKER_DONE=()
    _WORKERS_COMPLETE=0
    _render_start=$(date +%s)

    # ---- Fork lead worker (process group leader) ----
    CHUNKS_DIR=$(mktemp -d "/tmp/bborch-chunks-XXXXXX")

    if [[ -n "$TIMEOUT" ]]; then
        setsid timeout "$TIMEOUT" \
            bash "${BASH_SOURCE[0]}" _lead \
            "$NUM_WORKERS" "$TOTAL_SAMPLES" "$SAMPLES_PER_WORKER" \
            "$ENCODING" "$MASK" "$BPS" "$MAX_BATCH" \
            "$RUNNER" "$_PROGRESS_DIR" "$CHUNKS_DIR" &
    else
        setsid bash "${BASH_SOURCE[0]}" _lead \
            "$NUM_WORKERS" "$TOTAL_SAMPLES" "$SAMPLES_PER_WORKER" \
            "$ENCODING" "$MASK" "$BPS" "$MAX_BATCH" \
            "$RUNNER" "$_PROGRESS_DIR" "$CHUNKS_DIR" &
    fi
    LEAD_PID=$!
    # setsid makes lead the process group leader, so pgid == pid
    echo "[orch] lead worker launched: pid=$LEAD_PID pgid=$LEAD_PID"

    # Kill all workers on interrupt
    _INT_COUNT=0
    _cleanup_master() {
        (( _INT_COUNT++ )) || true

        echo "" >&2
        if (( _INT_COUNT == 1 )); then
            echo "[orch] interrupted, signaling lead worker to stop..." >&2
            # SIGTERM to lead — workers should clean up their children
            kill -TERM "$LEAD_PID" 2>/dev/null
            # Wait for lead to exit (with timeout)
            local _waited=0
            while kill -0 "$LEAD_PID" 2>/dev/null; do
                sleep 0.1
                _waited=$(( _waited + 1 ))
                if (( _waited > 100 )); then
                    echo "[orch] lead didn't exit in 10s, force killing..." >&2
                    kill -9 -- -"$LEAD_PID" 2>/dev/null
                    kill -9 "$LEAD_PID" 2>/dev/null
                    break
                fi
            done
        else
            echo "[orch] force killing lead process group..." >&2
            # Kill lead's entire process group (lead + all workers + awk children)
            kill -9 -- -"$LEAD_PID" 2>/dev/null
            kill -9 "$LEAD_PID" 2>/dev/null
        fi

        # Final sweep for any orphaned processes from this render session
        [[ -n "$CHUNKS_DIR" ]] && rm -rf "$CHUNKS_DIR"

        rm -f "${CHUNKS[@]}"
        rm -rf "$_PROGRESS_DIR"
        exit 130
    }
    trap _cleanup_master INT TERM

    # Wait for lead worker — poll progress files for display
    _last_total=0
    _last_time=$_render_start
    while kill -0 "$LEAD_PID" 2>/dev/null; do
        _total=0
        _done_count=0
        _generating_count=0
        _active_count=0
        for ((w=0; w<NUM_WORKERS; w++)); do
            if [[ -f "$_PROGRESS_DIR/$w.done" ]]; then
                _done_count=$(( _done_count + 1 ))
            elif [[ -f "$_PROGRESS_DIR/$w" ]]; then
                _active_count=$(( _active_count + 1 ))
                _wsamples=$(< "$_PROGRESS_DIR/$w" 2>/dev/null) || _wsamples=0
                if (( _wsamples < 0 )); then
                    # Negative = batch generation in progress, -(N+1) means N%
                    _generating_count=$(( _generating_count + 1 ))
                else
                    _total=$(( _total + _wsamples ))
                fi
            fi
        done
        # Show something if any workers are active (generating, encoding, or started)
        if (( _total > 0 || _generating_count > 0 || _active_count > 0 )); then
            _now=$(date +%s)
            _pct=$(( _total * 100 / TOTAL_SAMPLES ))
            _elapsed=$(( _now - _render_start ))

            # Progress bar (20 chars) — built with printf, no per-char loops
            _bar_len=20
            _filled=$(( _pct * _bar_len / 100 ))
            _empty=$(( _bar_len - _filled ))
            if (( _pct < 100 && _filled < _bar_len )); then
                printf -v _bar '%0.s=' $(seq 1 "$_filled" 2>/dev/null) 2>/dev/null
                _bar="${_bar}>"
                _empty=$(( _empty - 1 ))
            else
                printf -v _bar '%0.s=' $(seq 1 "$_filled" 2>/dev/null) 2>/dev/null
            fi
            printf -v _dots '%0.s.' $(seq 1 "$_empty" 2>/dev/null) 2>/dev/null
            _bar="${_bar}${_dots}"

            # Rate and ETA
            _dt=$(( _now - _last_time ))
            if (( _dt > 0 )); then
                _rate=$(( (_total - _last_total) / _dt ))
                _last_total=$_total
                _last_time=$_now
            fi
            if (( ${_rate:-0} > 0 )); then
                _eta=$(( (TOTAL_SAMPLES - _total) / _rate ))
                _eta_str=$(printf '%dm%02ds' $(( _eta / 60 )) $(( _eta % 60 )))
            else
                _eta_str="?"
            fi
            _rate_k=$(( ${_rate:-0} / 1000 ))

            # Worker dots: # = done, G = generating batch, + = encoding, . = queued
            _wdots=""
            for ((w=0; w<NUM_WORKERS; w++)); do
                if [[ -f "$_PROGRESS_DIR/$w.done" ]]; then
                    _wdots="${_wdots}#"
                elif [[ -f "$_PROGRESS_DIR/$w" ]]; then
                    _wval=$(< "$_PROGRESS_DIR/$w" 2>/dev/null) || _wval=0
                    if (( _wval < 0 )); then
                        _wdots="${_wdots}G"
                    else
                        _wdots="${_wdots}+"
                    fi
                else
                    _wdots="${_wdots}."
                fi
            done

            printf "\r[${_bar}] %3d%% %'d/%'d  %dk/s ETA %s  [%s] %d/%d %ds   " \
                "$_pct" "$_total" "$TOTAL_SAMPLES" \
                "$_rate_k" "$_eta_str" \
                "$_wdots" "$_done_count" "$NUM_WORKERS" "$_elapsed" >&2
        fi
        sleep 0.5
    done

    wait "$LEAD_PID" 2>/dev/null
    # Clear progress line completely
    printf '\r%0.s ' {1..80}
    printf '\r' >&2
    rm -rf "$_PROGRESS_DIR"

    # Collect chunk files — numeric sort by worker ID (handles ≥10 workers)
    CHUNKS=()
    for c in "$CHUNKS_DIR"/chunk-*; do
        [[ -f "$c" ]] || continue
        _csize=$(stat -c%s "$c" 2>/dev/null || echo 0)
        if (( _csize == 0 )); then
            echo "[orch] WARNING: empty chunk ${c##*/}, skipping" >&2
            continue
        fi
        # Extract worker ID from filename for numeric sort
        _wid="${c##*-}"
        CHUNKS+=("$_wid:$_csize:$c")
    done
    # Sort by worker ID, extract paths
    IFS=$'\n' CHUNKS_SORTED=($(printf '%s\n' "${CHUNKS[@]}" | sort -t: -k1,1n))
    unset IFS
    CHUNKS=()
    for _entry in "${CHUNKS_SORTED[@]}"; do
        CHUNKS+=("${_entry##*:}")  # path is last field
    done

    echo "[orch] workers done, assembling WAV..."

    # Validate chunks before assembly
    PCM_BYTES=0
    _bad_chunks=0
    for c in "${CHUNKS[@]}"; do
        _csize=$(stat -c%s "$c")
        # Frame alignment check — truncated chunk will fail this
        if (( _csize % FRAME_BYTES != 0 )); then
            echo "[orch] ERROR: chunk $(basename "$c") has $_csize bytes, not aligned to frame size $FRAME_BYTES" >&2
            echo "[orch] ERROR: possible truncation — worker may have crashed" >&2
            _bad_chunks=1
        fi
        PCM_BYTES=$(( PCM_BYTES + _csize ))
    done

    if (( _bad_chunks )); then
        echo "[orch] ERROR: chunk validation failed, WAV may be corrupted" >&2
    fi

    # Warn if chunk count doesn't match expected workers
    if (( ${#CHUNKS[@]} != NUM_WORKERS )); then
        echo "[orch] WARNING: expected $NUM_WORKERS chunks, got ${#CHUNKS[@]}" >&2
    fi

    NUM_SAMPLES=$(( PCM_BYTES / FRAME_BYTES ))
    echo "[orch] pcm_bytes=$PCM_BYTES num_samples=$NUM_SAMPLES"

    # Write WAV
    BYTE_RATE=$(( SAMPLE_RATE * FRAME_BYTES ))
    {
        printf 'RIFF'
        _le32 $(( PCM_BYTES + 36 )); printf '%b' "$_v"
        printf 'WAVEfmt '
        _le32 16; printf '%b' "$_v"
        _le16 1; printf '%b' "$_v"     # PCM format
        _le16 2; printf '%b' "$_v"     # channels
        _le32 $SAMPLE_RATE; printf '%b' "$_v"
        _le32 $BYTE_RATE; printf '%b' "$_v"
        _le16 $FRAME_BYTES; printf '%b' "$_v"  # block align
        _le16 $(( BPS * 8 )); printf '%b' "$_v"  # bits per sample
        printf 'data'
        _le32 $PCM_BYTES; printf '%b' "$_v"

        # Concatenate PCM chunks in order
        for c in "${CHUNKS[@]}"; do
            [[ -f "$c" ]] && cat "$c"
        done
    } > "$OUTPUT"

    # Cleanup temp files
    rm -f "${CHUNKS[@]}"
    rmdir "$CHUNKS_DIR" 2>/dev/null

    echo "[orch] done: $OUTPUT ($NUM_SAMPLES samples, $(( NUM_SAMPLES / SAMPLE_RATE ))s)"
    exit 0
fi

# ---------------------------------------------------------------
# Lead worker — called by master via: bash orchestrator.sh _lead ...
# Process group leader. Forks actual workers, waits for them.
# ---------------------------------------------------------------
if [[ "${1:-}" == "_lead" ]]; then
    shift  # consume _lead sentinel
    NUM_WORKERS=$1 TOTAL_SAMPLES=$2 SAMPLES_PER_WORKER=$3
    ENCODING=$4 MASK=$5 BPS=$6 MAX_BATCH=$7
    RUNNER=$8 _PROGRESS_DIR=$9 CHUNKS_DIR=${10}

    # Kill all child workers on exit — ensures no orphans
    _WORKER_PIDS=()
    _lead_cleanup() {
        # Send TERM to each worker — workers clean up their own children (awk)
        for pid in "${_WORKER_PIDS[@]}"; do
            kill -TERM "$pid" 2>/dev/null
        done
        # Wait for workers to exit cleanly
        local _waited=0
        for pid in "${_WORKER_PIDS[@]}"; do
            while kill -0 "$pid" 2>/dev/null; do
                sleep 0.1
                _waited=$(( _waited + 1 ))
                if (( _waited > 50 )); then
                    # 5 seconds timeout — force kill worker and its process group
                    kill -9 "$pid" 2>/dev/null
                    break
                fi
            done
            _waited=0
        done
        # Final sweep: kill anything still in our process group (orphaned awk, etc)
        kill -9 -- -"$$" 2>/dev/null
        exit 0
    }
    trap _lead_cleanup INT TERM

    # Fork actual workers
    for ((w = 0; w < NUM_WORKERS; w++)); do
        START=$(( w * SAMPLES_PER_WORKER ))
        LENGTH=$SAMPLES_PER_WORKER
        (( START >= TOTAL_SAMPLES )) && break
        if (( START + LENGTH > TOTAL_SAMPLES )); then
            LENGTH=$(( TOTAL_SAMPLES - START ))
        fi

        CHUNK_FILE="$CHUNKS_DIR/chunk-${w}"

        bash "${BASH_SOURCE[0]}" _worker \
            "$START" "$LENGTH" "$CHUNK_FILE" \
            "$ENCODING" "$MASK" "$BPS" "$MAX_BATCH" \
            "$RUNNER" "$_PROGRESS_DIR" "$w" &
        _WORKER_PIDS+=($!)
        echo "[lead] forked worker $w: t=$START length=$LENGTH pid=${_WORKER_PIDS[-1]}"
    done

    echo "[lead] all ${#_WORKER_PIDS[@]} workers launched, waiting..."

    # Wait for all workers
    FAIL=0
    for pid in "${_WORKER_PIDS[@]}"; do
        wait "$pid" 2>/dev/null || FAIL=1
    done

    (( FAIL )) && echo "[lead] WARNING: some workers exited with errors" >&2
    # Clear progress line (80 spaces) before printing
    printf '\r%0.s ' {1..80}
    printf '\r'
    echo "[lead] all workers done" >&2
    exit $FAIL
fi

# ---------------------------------------------------------------
# Worker — called by master via: bash orchestrator.sh _worker ...
# ---------------------------------------------------------------
shift  # consume _worker sentinel
START=$1 LENGTH=$2 CHUNK_FILE=$3
ENCODING=$4 MASK=$5 BPS=$6 MAX_BATCH=$7
RUNNER=$8
_PROGRESS_DIR="${9:-}"
_WORKER_ID="${10:-0}"

# Composition has no caller overrides — prefer always applies
declare -A _CALLER_SET=()
prefer() {
    local _var=$1 _val=$2
    if [[ -z "${_CALLER_SET[$_var]:-}" ]]; then
        declare -g "$_var=$_val"
    fi
}

# Load runner: source bash runners, or eval the `shim` glue for ELF binaries.
if [[ -x "$RUNNER" && "$(head -c 4 "$RUNNER" 2>/dev/null)" == $'\x7fELF' ]]; then
    eval "$("$RUNNER" shim)" || {
        echo "failed to load binary runner shim: $RUNNER" >&2; exit 1; }
else
    source "$RUNNER"
fi

START_OFFSET="${START_OFFSET:-0}"
NO_BATCH="${NO_BATCH:-0}"
declare -a _hex_chunks=()
_chunk_idx=0
_count=0
_batch_pid=0

cleanup_child() {
    if (( _chunk_idx > 0 )); then
        printf '%b' "${_hex_chunks[@]}" >> "$CHUNK_FILE"
    fi
    # Kill orphaned awk/batch subprocess — MUST wait for it to fully exit
    if (( _batch_pid > 0 )); then
        kill -TERM -- -$_batch_pid 2>/dev/null
        kill -TERM "$_batch_pid" 2>/dev/null
        # Wait for awk to fully exit before proceeding
        local _wait=0
        while kill -0 "$_batch_pid" 2>/dev/null && (( _wait < 100 )); do
            sleep 0.1
            _wait=$(( _wait + 1 ))
        done
        # Force kill if still alive, then wait again
        if kill -0 "$_batch_pid" 2>/dev/null; then
            kill -9 -- -$_batch_pid 2>/dev/null
            kill -9 "$_batch_pid" 2>/dev/null
            # Give it a moment to die
            _wait=0
            while kill -0 "$_batch_pid" 2>/dev/null && (( _wait < 10 )); do
                sleep 0.1
                _wait=$(( _wait + 1 ))
            done
        fi
        # Wait on PID to reap it — this is critical
        wait "$_batch_pid" 2>/dev/null
    fi
    # Report interrupted status
    if [[ -n "$_PROGRESS_DIR" && -d "$_PROGRESS_DIR" ]]; then
        echo "interrupted" > "$_PROGRESS_DIR/$_WORKER_ID.done" 2>/dev/null
    fi
    exit 1
}
trap cleanup_child INT TERM

declare -a _HEX
for ((i = 0; i < 256; i++)); do
    printf -v "_HEX[i]" '\\x%02x' "$i"
done

run_sample_gen() {
    local _start=$(( START + START_OFFSET ))
    local _end=$(( _start + LENGTH ))
    local _progress_interval=$(( LENGTH / 20 ))  # report ~20 times
    (( _progress_interval < 1000 )) && _progress_interval=1000
    local _last_reported=0
    local _total_processed=0

    # Signal that we're alive (so master shows progress immediately)
    echo "0" > "$_PROGRESS_DIR/$_WORKER_ID" 2>/dev/null

    # Batch mode: runner provides sample_batch — one awk process for all samples
    # Skipped if NO_BATCH=1
    if [[ "$NO_BATCH" != "1" ]] && declare -f sample_batch >/dev/null 2>&1; then
        # Expected PCM bytes for this worker
        local _expected_pcm=$(( LENGTH * BPS * 2 ))

        # Report "generating" phase
        echo "-1" > "$_PROGRESS_DIR/$_WORKER_ID" 2>/dev/null

        # Run batch: pipe input to sample_batch, write raw PCM to chunk file
        printf '%d %d %d\n' "$_start" "$LENGTH" "$SAMPLE_RATE" \
            | sample_batch "$ENCODING" "$MASK" "$BPS" \
            > "$CHUNK_FILE" &
        _batch_pid=$!

        # Poll chunk file size during generation
        while kill -0 "$_batch_pid" 2>/dev/null; do
            sleep 0.5
            if [[ -f "$CHUNK_FILE" ]]; then
                _batch_size=$(stat -c%s "$CHUNK_FILE" 2>/dev/null || echo 0)
                if (( _expected_pcm > 0 && _batch_size > 0 )); then
                    _gen_pct=$(( _batch_size * 100 / _expected_pcm ))
                    (( _gen_pct > 99 )) && _gen_pct=99
                    echo "-$(( _gen_pct + 1 ))" > "$_PROGRESS_DIR/$_WORKER_ID" 2>/dev/null
                fi
            fi
        done
        wait "$_batch_pid" 2>/dev/null
        _batch_pid=0

        # PCM already written to CHUNK_FILE — just count samples
        _total_processed=$LENGTH
        _count=0
        _chunk_idx=0
        echo "$_total_processed" > "$_PROGRESS_DIR/$_WORKER_ID" 2>/dev/null
    else
        # Fallback: single-sample mode (forks per call)
        t=$_start
        while (( t < _end )); do
            sample "$t"

            case "$ENCODING" in
                u8)
                    _hex_chunks[_chunk_idx]="${_HEX[SAMPLE_L & MASK]}${_HEX[SAMPLE_R & MASK]}"
                    ;;
                u16le)
                    _hex_chunks[_chunk_idx]="${_HEX[SAMPLE_L & 0xFF]}${_HEX[(SAMPLE_L >> 8) & 0xFF]}${_HEX[SAMPLE_R & 0xFF]}${_HEX[(SAMPLE_R >> 8) & 0xFF]}"
                    ;;
            esac

            (( _chunk_idx++ )) || true
            (( _count++ )) || true
            (( _total_processed++ )) || true
            if (( _count >= MAX_BATCH )); then
                printf '%b' "${_hex_chunks[@]}" >> "$CHUNK_FILE"
                _hex_chunks=()
                _chunk_idx=0
                _count=0
            fi
            # Periodic progress report (cumulative, not per-batch)
            if (( _total_processed - _last_reported >= _progress_interval )); then
                echo "$_total_processed" > "$_PROGRESS_DIR/$_WORKER_ID" 2>/dev/null
                _last_reported=$_total_processed
            fi
            (( t++ )) || true
        done
    fi

    # Flush remaining
    (( _chunk_idx > 0 )) && printf '%b' "${_hex_chunks[@]}" >> "$CHUNK_FILE"

    # Report completion via progress file
    if [[ -n "$_PROGRESS_DIR" && -d "$_PROGRESS_DIR" ]]; then
        echo "$_total_processed" > "$_PROGRESS_DIR/$_WORKER_ID.done" 2>/dev/null
    fi
}

run_sample_gen
