# `timedate`

Date, time, and timezone operations — timestamps, calendar calculations, duration formatting, stopwatches, and timezone conversion. **76 functions.** No `::fast` variants. Uses `date` with portable GNU/BSD detection.

---

## Timestamps

| Function | Description |
|----------|-------------|
| `timedate::timestamp::unix` | Current unix timestamp (seconds since epoch) |
| `timedate::timestamp::unix_ms` | Current unix timestamp in milliseconds |
| `timedate::timestamp::unix_ns` | Current unix timestamp in nanoseconds |
| `timedate::timestamp::to_human` | Convert unix timestamp to human-readable format |
| `timedate::timestamp::from_human` | Convert human-readable date to unix timestamp |

```bash
timedate::timestamp::unix          # → 1716300000
timedate::timestamp::to_human 1716300000 "%Y-%m-%d %H:%M:%S"  # → "2024-05-21 14:00:00"
timedate::timestamp::from_human "2024-01-15 12:00:00"
```

---

## Date

### Current Date Components

| Function | Description |
|----------|-------------|
| `timedate::date::today` | Current date in `YYYY-MM-DD` format |
| `timedate::date::format` | Current date in a custom format |
| `timedate::date::year` | Current year |
| `timedate::date::month` | Current month (01–12) |
| `timedate::date::day` | Current day of month (01–31) |
| `timedate::date::day_of_week` | Day of week (1=Monday, 7=Sunday, ISO 8601) |
| `timedate::date::day_name` | Day of week full name (Monday–Sunday) |
| `timedate::date::day_name::short` | Day of week short name (Mon–Sun) |
| `timedate::date::day_of_year` | Day of year (001–366) |
| `timedate::date::week_of_year` | ISO 8601 week number (01–53) |
| `timedate::date::quarter` | Quarter (1–4) |

### Date Arithmetic

| Function | Description |
|----------|-------------|
| `timedate::date::add_days` | Add n days to a date |
| `timedate::date::sub_days` | Subtract n days from a date |
| `timedate::date::add_months` | Add n months to a date |
| `timedate::date::add_years` | Add n years to a date |
| `timedate::date::days_between` | Number of days between two dates |
| `timedate::date::days_in_month` | Last day of a given month |

### Date Boundaries

| Function | Description |
|----------|-------------|
| `timedate::date::yesterday` | Yesterday's date |
| `timedate::date::tomorrow` | Tomorrow's date |
| `timedate::date::week_start` | Start of current week (Monday) |
| `timedate::date::week_end` | End of current week (Sunday) |
| `timedate::date::month_start` | Start of current month |
| `timedate::date::month_end` | End of current month |
| `timedate::date::year_start` | Start of current year |
| `timedate::date::year_end` | End of current year |
| `timedate::date::next_weekday` | Next occurrence of a weekday from today |
| `timedate::date::prev_weekday` | Previous occurrence of a weekday |

### Comparison

| Function | Description |
|----------|-------------|
| `timedate::date::compare` | Compare two dates — returns -1, 0, or 1 |
| `timedate::date::is_before` | Check if date A is before date B |
| `timedate::date::is_after` | Check if date A is after date B |
| `timedate::date::is_between` | Check if date is between two dates (inclusive) |

```bash
timedate::date::today             # → 2026-05-21
timedate::date::tomorrow          # → 2026-05-22
timedate::date::days_between "2026-01-01" "2026-01-15"  # → 14
timedate::date::next_weekday 5    # Next Friday
timedate::date::days_in_month 2026 2  # → 28
```

---

## Time

| Function | Description |
|----------|-------------|
| `timedate::time::now` | Current time in `HH:MM:SS` |
| `timedate::time::format` | Current time in a custom format |
| `timedate::time::hour` | Current hour (00–23) |
| `timedate::time::minute` | Current minute (00–59) |
| `timedate::time::second` | Current second (00–59) |
| `timedate::time::timezone` | Current timezone abbreviation |
| `timedate::time::timezone_offset` | Current UTC offset (e.g., `+0800`) |

### Time Checks

| Function | Description |
|----------|-------------|
| `timedate::time::is_before` | Check if current time is before `HH:MM` |
| `timedate::time::is_after` | Check if current time is after `HH:MM` |
| `timedate::time::is_between` | Check if current time is between two `HH:MM` times |
| `timedate::time::is_business_hours` | Check if during business hours (09:00–17:00 Mon–Fri, configurable) |
| `timedate::time::is_morning` | 00:00–11:59 |
| `timedate::time::is_afternoon` | 12:00–17:59 |
| `timedate::time::is_evening` | 18:00–23:59 |

```bash
timedate::time::is_business_hours && echo "Business hours"
timedate::time::is_between "09:00" "17:00" && echo "Working hours"
```

---

## Duration

| Function | Description |
|----------|-------------|
| `timedate::duration::format` | Format seconds as `"1d 2h 3m 4s"` |
| `timedate::duration::format_ms` | Format milliseconds as human-readable |
| `timedate::duration::parse` | Parse a duration string (`"1d 2h 3m 4s"`) back into seconds |
| `timedate::duration::relative` | Human-readable relative time from a timestamp (`"3 hours ago"`, `"in 2 days"`) |

```bash
timedate::duration::format 90061           # → "1d 1h 1m 1s"
timedate::duration::parse "2h 30m"          # → 9000
timedate::duration::relative 1716300000     # → "3 hours ago"
```

## Stopwatch

| Function | Description |
|----------|-------------|
| `timedate::time::stopwatch::start` | Start stopwatch, returns a token |
| `timedate::time::stopwatch::stop` | Stop stopwatch, returns elapsed milliseconds |

```bash
token=$(timedate::time::stopwatch::start)
# ... do work ...
elapsed=$(timedate::time::stopwatch::stop "$token")
echo "Took ${elapsed}ms"
```

## Sleep

| Function | Description |
|----------|-------------|
| `timedate::time::sleep` | Sleep with an optional progress message |

```bash
timedate::time::sleep 5 "Waiting for service..."
```

---

## Calendar

| Function | Description |
|----------|-------------|
| `timedate::calendar::is_leap_year` | Check if year is a leap year |
| `timedate::calendar::days_in_year` | Get number of days in a year |
| `timedate::calendar::is_weekend` | Check if a date falls on a weekend |
| `timedate::calendar::is_weekday` | Check if a date falls on a weekday |
| `timedate::calendar::iso_week` | Get ISO week number for a date |
| `timedate::calendar::day_of_year` | Get day of year for a date |
| `timedate::calendar::quarter` | Get quarter for a date |
| `timedate::calendar::easter` | Calculate Easter date (Meeus/Jones/Butcher algorithm) |
| `timedate::calendar::weekdays_between` | Number of weekdays between two dates |
| `timedate::calendar::month` | Print calendar for a month (like `cal`) |

```bash
timedate::calendar::is_leap_year 2026      # → false (exit 1)
timedate::calendar::easter 2026            # → 2026-04-05
timedate::calendar::weekdays_between "2026-05-01" "2026-05-15"
timedate::calendar::month 2026 5           # Prints May 2026 calendar
```

---

## Timezone

| Function | Description |
|----------|-------------|
| `timedate::tz::convert` | Convert a timestamp to a different timezone |
| `timedate::tz::now` | Get current time in a specific timezone |
| `timedate::tz::current` | Get current timezone name |
| `timedate::tz::offset_seconds` | Get UTC offset in seconds |
| `timedate::tz::is_dst` | Check if currently in daylight saving time |
| `timedate::tz::list` | List all available timezones |
| `timedate::tz::list::region` | List timezones filtered by region |

```bash
timedate::tz::convert 1716300000 "America/New_York"
timedate::tz::now "Asia/Tokyo"             # → Current time in Tokyo
timedate::tz::current                      # → "Asia/Manila"
timedate::tz::offset_seconds               # → 28800
timedate::tz::is_dst && echo "DST active"
timedate::tz::list::region "Europe"
```

## Dependencies

- **Requires**: `runtime`
- **External tools**: `date` (GNU or BSD, detected automatically), `/usr/share/zoneinfo` (for timezone listing)
