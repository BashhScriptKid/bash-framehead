#!/usr/bin/env bash
# ext/wav/wav.sh — WAV audio read/write
#
# Pure-Bash WAV (RIFF/PCM) file generation and parsing. Adapted from the
# BMP extension pattern — uses core binary::* primitives for byte packing.
#
# Dependencies:
#   core: runtime binary pfloat

# --- guard ---

declare -f 'runtime::bash_version' &>/dev/null || {
    echo "${BASH_SOURCE[0]}: runtime not found -- source bash-framehead.sh first" >&2
    return 1
}

_guard_core_deps=(binary::u16le binary::u32le binary::u64le pfloat::ieee754::from_string)
_guard_ext_deps=()

for _guard_dep in "${_guard_core_deps[@]}"; do
    declare -f "$_guard_dep" &>/dev/null || {
        echo "${BASH_SOURCE[0]}: missing core function '$_guard_dep'" >&2
        return 1
    }
done

for _guard_dep in "${_guard_ext_deps[@]}"; do
    command -v "$_guard_dep" &>/dev/null || {
        echo "${BASH_SOURCE[0]}: missing external tool '$_guard_dep'" >&2
        return 1
    }
done

unset _guard_core_deps _guard_ext_deps _guard_dep
# --- end guard ---

# ==============================================================================
# ENCODING TABLE (internal)
# ==============================================================================

# Map encoding name → bytes_per_sample:format_tag:signed
# format_tag: 1=PCM integer, 3=IEEE float
declare -A _WAV_ENCODINGS=(
    [u8]="1:1:0"
    [s16le]="2:1:1"
    [s24le]="3:1:1"
    [s32le]="4:1:1"
    [f32le]="4:3:0"
    [f64le]="8:3:0"
)

# Look up an encoding property.
# Usage: _wav::encoding_info <encoding> <field>
#   field: bytes, format, signed
_wav::encoding_info() {
    local enc=$1 field=$2
    local IFS=':' bits fmt signed
    read -r bits fmt signed <<< "${_WAV_ENCODINGS[$enc]:-}"
    if [[ -z "$bits" ]]; then
        echo "wav: unknown encoding '$enc'" >&2
        return 1
    fi
    case "$field" in
        bytes)  echo "$bits" ;;
        format) echo "$fmt" ;;
        signed) echo "$signed" ;;
    esac
}

# Default amplitude for an encoding (half of max for PCM, 1.0 for float).
_wav::default_amp() {
    local enc=$1
    case "$enc" in
        u8)   echo "128" ;;
        s16le) echo "32767" ;;
        s24le) echo "8388607" ;;
        s32le) echo "1073741823" ;;
        *)     echo "1" ;;  # float: caller uses pfloat
    esac
}

# ==============================================================================
# HEADER
# ==============================================================================

# Emit a 44-byte WAV header (RIFF + fmt + data chunk headers).
# Usage: wav::header <sample_rate> <channels> <bits_per_sample> <num_samples>
wav::header() {
    local rate=$1 channels=$2 bits=$3 num_samples=$4
    local bytes_per_sample=$((bits / 8))
    local block_align=$((channels * bytes_per_sample))
    local data_size=$((num_samples * block_align))
    local fmt_tag=1  # PCM
    # Detect float encodings by bit depth convention (32 or 64 with float tag)
    # Caller sets bits=32 for f32le, bits=64 for f64le — we infer float from
    # context; override via _WAV_FORMAT_TAG if needed.

    local byte_rate=$((rate * block_align))
    local file_size=$((data_size + 36))  # 44 - 8

    printf 'RIFF'
    binary::u32le "$file_size"
    printf 'WAVE'
    printf 'fmt '
    binary::u32le 16                        # fmt chunk size
    binary::u16le "${_WAV_FORMAT_TAG:-1}"   # audio format (1=PCM)
    binary::u16le "$channels"
    binary::u32le "$rate"
    binary::u32le "$byte_rate"
    binary::u16le "$block_align"
    binary::u16le "$bits"
    printf 'data'
    binary::u32le "$data_size"
}

# ==============================================================================
# PARSING
# ==============================================================================

# Read a WAV header from stdin (44 bytes), populate _WAV_* globals.
# Usage: wav::parse_header
wav::parse_header() {
    local tmp
    tmp=$(mktemp "/tmp/fsbshf-wav-parse.XXXXXX")
    head -c 44 > "$tmp" 2>/dev/null

    local hdr_size
    hdr_size=$(wc -c < "$tmp")

    if (( hdr_size < 44 )); then
        echo "wav::parse_header: short read ($hdr_size bytes), expected 44" >&2
        rm -f "$tmp"
        return 1
    fi

    # RIFF signature
    local sig; sig=$(head -c 4 "$tmp")
    if [[ "$sig" != "RIFF" ]]; then
        echo "wav::parse_header: not a RIFF file" >&2
        rm -f "$tmp"
        return 1
    fi

    # WAVE signature at offset 8
    sig=$(tail -c +9 "$tmp" | head -c 4)
    if [[ "$sig" != "WAVE" ]]; then
        echo "wav::parse_header: not a WAVE file" >&2
        rm -f "$tmp"
        return 1
    fi

    # Helper: read u16le from tmp at byte offset (0-indexed)
    _wav_ru16() {
        local off=$1
        local lo hi
        lo=$(tail -c +$((off + 1)) "$tmp" | head -c 1 | od -An -tu1 | tr -d ' ')
        hi=$(tail -c +$((off + 2)) "$tmp" | head -c 1 | od -An -tu1 | tr -d ' ')
        echo $((lo | (hi << 8)))
    }

    # Helper: read u32le from tmp at byte offset
    _wav_ru32() {
        local off=$1 i b val=0
        for ((i = 0; i < 4; i++)); do
            b=$(tail -c +$((off + i + 1)) "$tmp" | head -c 1 | od -An -tu1 | tr -d ' ')
            (( val |= (b << (8 * i)) ))
        done
        echo "$val"
    }

    _WAV_FORMAT=$(_wav_ru16 20)
    _WAV_CHANNELS=$(_wav_ru16 22)
    _WAV_RATE=$(_wav_ru32 24)
    _WAV_BITS=$(_wav_ru16 34)
    _WAV_DATA_SIZE=$(_wav_ru32 40)

    local block_align; block_align=$(_wav_ru16 32)
    _WAV_BYTES_PER_SAMPLE=$block_align
    _WAV_NUM_SAMPLES=$(( _WAV_DATA_SIZE / block_align ))

    rm -f "$tmp"
    return 0
}

# ==============================================================================
# READ
# ==============================================================================

# Read one sample from stdin, optionally skipping n samples first.
# Usage: wav::read <encoding> [skip_n]
wav::read() {
    local enc=$1 skip=${2:-0}
    local bytes; bytes=$(_wav::encoding_info "$enc" bytes) || return 1

    if (( skip > 0 )); then
        head -c $((skip * bytes)) > /dev/null 2>/dev/null
    fi

    local raw i b val=0
    raw=$(head -c "$bytes" 2>/dev/null)

    case "$enc" in
        u8)
            printf '%d' "'$raw"
            ;;
        s16le|s24le|s32le)
            local fmt; fmt=$(_wav::encoding_info "$enc" signed) || return 1
            for ((i = 0; i < bytes; i++)); do
                b=$(printf '%d' "'${raw:i:1}")
                (( val |= (b << (8 * i)) ))
            done
            # Sign-extend if signed and MSB is set
            if [[ "$fmt" == "1" ]] && (( (val >> (bytes * 8 - 1)) & 1 )); then
                local sign_ext=$(( (~0) << (bytes * 8) ))
                (( val |= sign_ext ))
            fi
            echo "$val"
            ;;
        f32le|f64le)
            # Reassemble raw bytes to integer (IEEE 754 bit pattern)
            for ((i = 0; i < bytes; i++)); do
                b=$(printf '%d' "'${raw:i:1}")
                (( val |= (b << (8 * i)) ))
            done
            echo "$val"
            ;;
    esac
}

# ==============================================================================
# WRITE — SAMPLE
# ==============================================================================

# Emit one sample in the given encoding.
# Usage: wav::write::sample <encoding> <value>
wav::write::sample() {
    local enc=$1 val=$2
    local bytes fmt
    bytes=$(_wav::encoding_info "$enc" bytes) || return 1
    fmt=$(_wav::encoding_info "$enc" format) || return 1

    case "$enc" in
        u8)
            printf -v _ws_byte '\\x%02x' "$((val & 0xFF))"
            printf '%b' "$_ws_byte"
            ;;
        s16le)
            binary::u16le $((val & 0xFFFF))
            ;;
        s24le)
            printf -v _ws_byte '\\x%02x\\x%02x\\x%02x' \
                "$((val & 0xFF))" \
                "$(((val >> 8) & 0xFF))" \
                "$(((val >> 16) & 0xFF))"
            printf '%b' "$_ws_byte"
            ;;
        s32le)
            binary::u32le $((val & 0xFFFFFFFF))
            ;;
        f32le)
            binary::u32le "$val"
            ;;
        f64le)
            binary::u64le "$val"
            ;;
    esac
    unset -v _ws_byte
}

# ==============================================================================
# WRITE — TONE
# ==============================================================================

# Emit a complete WAV file with a generated tone to stdout.
# Usage: wav::write::tone <type> <encoding> <freq> <duration> [rate=44100] [amp] [channels=1]
wav::write::tone() {
    local type=$1 enc=$2 freq=$3 duration=$4 rate=${5:-44100} amp=${6} channels=${7:-1}
    local bytes fmt bits
    bytes=$(_wav::encoding_info "$enc" bytes) || return 1
    fmt=$(_wav::encoding_info "$enc" format) || return 1

    case "$enc" in
        u8) bits=8 ;;
        s16le) bits=16 ;;
        s24le) bits=24 ;;
        s32le) bits=32 ;;
        f32le) bits=32 ;;
        f64le) bits=64 ;;
    esac

    [[ -z "$amp" ]] && amp=$(_wav::default_amp "$enc")

    local num_samples
    if [[ "$duration" == *.* ]]; then
        num_samples=$(echo "$rate * $duration" | bc | cut -d. -f1)
    else
        num_samples=$((rate * duration))
    fi
    local samples_per_period=$((rate / freq))
    (( samples_per_period < 2 )) && samples_per_period=2

    _WAV_FORMAT_TAG="$fmt" wav::header "$rate" "$channels" "$bits" "$num_samples"

    local i ch phase half sample
    half=$((samples_per_period / 2))

    for ((i = 0; i < num_samples; i++)); do
        case "$type" in
            square)
                phase=$((i % samples_per_period))
                sample=$((phase < half ? amp : -amp))
                ;;
            sawtooth)
                phase=$((i % samples_per_period))
                sample=$((phase * 2 * amp / samples_per_period - amp))
                ;;
            triangle)
                phase=$((i % samples_per_period))
                if ((phase < half)); then
                    sample=$((phase * 4 * amp / samples_per_period - amp))
                else
                    sample=$((3 * amp - phase * 4 * amp / samples_per_period))
                fi
                ;;
            sine)
                if ! command -v bc &>/dev/null; then
                    echo "wav::write::tone: sine requires bc" >&2
                    _WAV_FORMAT_TAG=1
                    return 1
                fi
                # Use bc for sin(), but write raw sample bytes directly for
                # performance — piping bc per-sample through wav::write::sample
                # would fork on every sample.  Build a single bc script instead.
                ;;
            *)
                echo "wav::write::tone: unknown type '$type'" >&2
                _WAV_FORMAT_TAG=1
                return 1
                ;;
        esac

        # Integer PCM output
        if [[ "$type" != "sine" ]]; then
            for ((ch = 0; ch < channels; ch++)); do
                wav::write::sample "$enc" "$sample"
            done
        fi
    done

    # Sine wave: use single bc invocation for all samples
    if [[ "$type" == "sine" ]]; then
        local bc_script is_float=0
        [[ "$enc" == f32le || "$enc" == f64le ]] && is_float=1
        bc_script=$(mktemp "/tmp/fsbshf-wav-sine.XXXXXX")
        echo "scale=10" > "$bc_script"
        for ((i = 0; i < num_samples; i++)); do
            # bc: scale=10; amp * s(2*pi*freq*i/rate)
            echo "$amp * s(2 * 3.141592653589793 * $freq * $i / $rate)" >> "$bc_script"
        done
        bc -l "$bc_script" | {
            while IFS= read -r _ws_float; do
                if (( is_float )); then
                    # Normalise bc output: "-.5" → "-0.5", ".5" → "0.5"
                    [[ "$_ws_float" == .* ]] && _ws_float="0$_ws_float"
                    [[ "$_ws_float" == -* ]] && _ws_float="-0${_ws_float#-}"
                    local _ws_bits
                    _ws_bits=$(pfloat::ieee754::from_string "$_ws_float")
                    if [[ "$enc" == "f32le" ]]; then
                        _ws_bits=$(_wav::f64_to_f32 "$_ws_bits")
                    fi
                    for ((ch = 0; ch < channels; ch++)); do
                        wav::write::sample "$enc" "$_ws_bits"
                    done
                else
                    local _ws_int; _ws_int=$(printf '%.0f' "$_ws_float")
                    for ((ch = 0; ch < channels; ch++)); do
                        wav::write::sample "$enc" "$_ws_int"
                    done
                fi
            done
        }
        rm -f "$bc_script"
    fi

    _WAV_FORMAT_TAG=1
    return 0
}

# ==============================================================================
# FLOAT HELPERS
# ==============================================================================

# Convert a 64-bit IEEE 754 bit pattern to 32-bit (single precision).
# Uses pfloat's internal _ieee754:: helpers.
# Usage: _wav::f64_to_f32 <double_bits>  →  single_bits
_wav::f64_to_f32() {
    local bits=$1
    local sign exp64 mant64 exp32 mant32

    sign=$(_ieee754::get_sign "$bits")
    exp64=$(_ieee754::get_exp "$bits")
    mant64=$(_ieee754::get_mant "$bits")

    # NaN / Inf: preserve with single-precision field widths
    if (( exp64 == 2047 )); then
        exp32=255
        mant32=$((mant64 >> 29))
        echo $(( (sign << 31) | (exp32 << 23) | mant32 ))
        return
    fi

    # Zero / subnormal
    if (( exp64 == 0 )); then
        echo $(( sign << 31 ))
        return
    fi

    # Normal: rebias exponent, truncate mantissa with round-to-nearest
    exp32=$((exp64 - 1023 + 127))

    # Overflow → Inf
    if (( exp32 >= 255 )); then
        echo $(( (sign << 31) | (255 << 23) ))
        return
    fi

    # Underflow → zero (subnormals not worth the complexity here)
    if (( exp32 <= 0 )); then
        echo $(( sign << 31 ))
        return
    fi

    # Round to nearest (add 0.5 LSB at bit 28 of the 52-bit mantissa)
    mant32=$(((mant64 + (1 << 28)) >> 29))

    # Carry into exponent
    if (( mant32 >= (1 << 23) )); then
        mant32=0
        (( exp32++ ))
        if (( exp32 >= 255 )); then
            echo $(( (sign << 31) | (255 << 23) ))
            return
        fi
    fi

    echo $(( (sign << 31) | (exp32 << 23) | mant32 ))
}
