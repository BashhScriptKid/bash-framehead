# ext/wav — WAV Audio Read/Write

Pure-Bash WAV (RIFF/PCM) file generation and parsing. Uses core `binary::*`
primitives for byte packing and `pfloat::ieee754` for float samples.

## Dependencies

- **bash-framehead core**: `binary::u16le`, `binary::u32le`, `binary::u64le`, `pfloat::ieee754::from_string`
- **External**: `bc` (sine tone only)

## Usage

### Writing tones

```bash
source ./bash-framehead.sh
source ./ext/wav/wav.sh

# 440 Hz square wave, 2 seconds, 16-bit
wav::write::tone square s16le 440 2 > a440.wav

# 1 kHz sawtooth, 0.5 sec, 48 kHz, 8-bit, stereo
wav::write::tone sawtooth u8 1000 0.5 48000 64 2 > sweep.wav

# Triangle wave, 16-bit
wav::write::tone triangle s16le 523 1 > c5.wav

# Sine wave (requires bc)
wav::write::tone sine s16le 440 1.5 > sine.wav
```

### Low-level writing

```bash
wav::header 44100 1 16 100 > noise.wav
for ((i = 0; i < 100; i++)); do
    wav::write::sample s16le $(( (RANDOM % 65536) - 32768 ))
done >> noise.wav
```

### Reading

```bash
wav::parse_header < input.wav
echo "$_WAV_RATE Hz, $_WAV_CHANNELS ch, $_WAV_BITS-bit"

# Read 10 samples
for ((i = 0; i < 10; i++)); do
    wav::read s16le
done < input.wav

# Skip 100 samples, read the 101st
wav::read s16le 100 < input.wav
```

## API Reference

### Header

#### `wav::header <rate> <channels> <bits> <num_samples>`
Emit a 44-byte WAV header (RIFF + fmt + data chunks). The audio format tag
defaults to 1 (PCM); set `_WAV_FORMAT_TAG=3` before calling for IEEE float.

### Parsing

#### `wav::parse_header`
Read a 44-byte WAV header from stdin, populate globals:

| Variable | Content |
|---|---|
| `_WAV_RATE` | Sample rate (Hz) |
| `_WAV_CHANNELS` | Channel count |
| `_WAV_BITS` | Bits per sample |
| `_WAV_FORMAT` | Audio format (1=PCM, 3=IEEE float) |
| `_WAV_DATA_SIZE` | Size of sample data in bytes |
| `_WAV_NUM_SAMPLES` | Total sample frames |
| `_WAV_BYTES_PER_SAMPLE` | Bytes per sample frame |

### Reading samples

#### `wav::read <encoding> [skip_n]`
Read one sample from stdin in the given encoding. If `skip_n` > 0, discards
that many samples first.

### Writing samples

#### `wav::write::sample <encoding> <value>`
Emit one sample in the given encoding to stdout.

### Tone generation

#### `wav::write::tone <type> <encoding> <freq> <duration> [rate=44100] [amp] [channels=1]`
Emit a complete WAV file with a generated waveform to stdout.

| Type | Description | Needs bc? |
|---|---|---|
| `square` | Alternating high/low | No |
| `sawtooth` | Linear ramp per period | No |
| `triangle` | Linear up-down per period | No |
| `sine` | `amp * sin(2π · freq · i / rate)` | Yes |

Amplitude defaults: half of maximum for PCM encodings (e.g. 32767 for s16le),
1.0 for float encodings.

### Encodings

| Encoding | Bytes | Domain |
|---|---|---|
| `u8` | 1 | 0–255 (unsigned, silence=128) |
| `s16le` | 2 | -32768–32767 |
| `s24le` | 3 | -8388608–8388607 |
| `s32le` | 4 | -2147483648–2147483647 |
| `f32le` | 4 | IEEE 754 single (raw 32-bit pattern) |
| `f64le` | 8 | IEEE 754 double (raw 64-bit pattern) |

### Float helpers

#### `_wav::f64_to_f32 <double_bits>`
Internal: convert a 64-bit IEEE 754 bit pattern to 32-bit single precision.

## Limitations

- **bc is slow for sine**: each sample requires a `sin()` call; practical for
  short tones only (~1000 samples)
- **No streaming read**: `wav::parse_header` assumes a complete 44-byte header
  on stdin; chunked/streaming reads are not supported
- **PCM and IEEE float only**: no A-law, μ-law, ADPCM, or extensible formats
- **No metadata chunks**: only RIFF + fmt + data; no LIST, INFO, or cue chunks
