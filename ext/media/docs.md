# media — Pure Bash Media Metadata Extension

Read image and audio metadata using `od` (coreutils) + bash arithmetic. No external media tools required.

## Dependencies

- **Required:** runtime.sh
- **Tool:** `od` (GNU coreutils, always available)

## Usage

```bash
source bash-framehead.sh
source ext/media/media.sh

# Detect type and format
media::type photo.jpg        # image
media::format photo.jpg      # JPEG

# Image metadata
media::image::width photo.jpg    # 1920
media::image::height photo.jpg   # 1080
media::image::depth photo.jpg    # 8
media::image::channels photo.jpg # 3
media::image::info photo.jpg     # format=PNG width=1920 ...

# Audio metadata
media::audio::duration song.mp3  # 245
media::audio::bitrate song.mp3   # 320
media::audio::sample_rate song.mp3 # 44100
media::audio::channels song.mp3  # 2
media::audio::bits song.mp3      # 16
media::audio::tags song.mp3      # title=Song artist=Artist ...
media::audio::tag::get song.mp3 title  # Song
media::audio::info song.mp3      # format=MP3 duration=245 ...

# Generic
media::info photo.jpg  # Dispatches to format-specific info
```

## Supported Formats

### Images
| Format | Readable |
|---|---|
| PNG | width, height, depth, channels |
| BMP | width, height, depth, channels |
| JPEG | format detection only (EXIF not implemented) |

### Audio
| Format | Readable |
|---|---|
| WAV | duration, bitrate, sample rate, channels, bits |
| FLAC | sample rate, channels, bits, duration (estimated) |
| MP3 | ID3v1 tags (title, artist, album, year), format detection |
| OGG | format detection only |

## Constants

All format constants are readonly globals prefixed with `_MEDIA_`:

- `_MEDIA_MAGIC_PNG`, `_MEDIA_MAGIC_JPEG`, `_MEDIA_MAGIC_BMP`, etc.
- `_PNG_WIDTH_OFFSET`, `_PNG_HEIGHT_OFFSET`, etc.
- `_WAV_CHANNELS_OFFSET`, `_WAV_SAMPLE_RATE_OFFSET`, etc.
- `_ID3V1_SIZE`, `_ID3V1_TITLE_OFFSET`, etc.

## Notes

- Pure Bash — no ffmpeg, ffprobe, or exiftool required
- Uses `od` for binary reading (part of GNU coreutils)
- ID3v2 tag parsing not yet implemented (only ID3v1)
- JPEG EXIF parsing not implemented (too complex for pure Bash)
- Video parsing stub only
- Duration for FLAC is estimated (lossless, size varies)
