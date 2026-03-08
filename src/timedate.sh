#!/usr/bin/env bash
# timedate.sh — bash-frameheader time and date lib
#
# PORTABILITY NOTE: GNU date and BSD date (macOS) have different syntax.
# date arithmetic uses GNU date where available, falls back to pure bash.
# Pure bash calendar math works on Bash 3+.

# ==============================================================================
# INTERNAL HELPERS
# ==============================================================================

# Detect if GNU date is available
_timedate::has_gnu_date() {
    date --version >/dev/null 2>&1
}

# Portable date formatting
# Usage: _timedate::format format [timestamp]
_timedate::format() {
    if [[ -n "${2:-}" ]]; then
        if _timedate::has_gnu_date; then
            date -d "@$2" +"$1" 2>/dev/null
        else
            date -r "$2" +"$1" 2>/dev/null
        fi
    else
        date +"$1"
    fi
}

# ==============================================================================
# TIMESTAMP
# ==============================================================================

# Current unix timestamp (seconds since epoch)
timedate::timestamp::unix() {
    date +%s
}

# Current unix timestamp in milliseconds
timedate::timestamp::unix_ms() {
    if _timedate::has_gnu_date; then
        date +%s%3N
    else
        # macOS fallback — python if available
        if runtime::has_command python3; then
            python3 -c "import time; print(int(time.time() * 1000))"
        else
            echo "$(date +%s)000"
        fi
    fi
}

# Current unix timestamp in nanoseconds
timedate::timestamp::unix_ns() {
    if _timedate::has_gnu_date; then
        date +%s%N
    elif runtime::has_command python3; then
        python3 -c "import time; print(int(time.time() * 1e9))"
    else
        echo "$(date +%s)000000000"
    fi
}

# Convert unix timestamp to human-readable
# Usage: timedate::timestamp::to_human timestamp [format]
timedate::timestamp::to_human() {
    _timedate::format "${2:-%Y-%m-%d %H:%M:%S}" "$1"
}

# Convert human-readable date to unix timestamp
# Usage: timedate::timestamp::from_human "2024-01-15 12:00:00"
timedate::timestamp::from_human() {
    if _timedate::has_gnu_date; then
        date -d "$1" +%s 2>/dev/null
    else
        date -j -f "%Y-%m-%d %H:%M:%S" "$1" +%s 2>/dev/null
    fi
}

# ==============================================================================
# DATE
# ==============================================================================

# Current date in YYYY-MM-DD format
timedate::date::today() {
    date +%Y-%m-%d
}

# Current date in a custom format
# Usage: timedate::date::format [format] [timestamp]
timedate::date::format() {
    _timedate::format "${1:-%Y-%m-%d}" "${2:-}"
}

# Get year
timedate::date::year()  { date +%Y; }

# Get month (01-12)
timedate::date::month() { date +%m; }

# Get day of month (01-31)
timedate::date::day()   { date +%d; }

# Get day of week (1=Monday, 7=Sunday, ISO 8601)
timedate::date::day_of_week() {
    date +%u
}

# Get day of week name
timedate::date::day_name() {
    date +%A
}

# Get day of week short name
timedate::date::day_name::short() {
    date +%a
}

# Get day of year (001-366)
timedate::date::day_of_year() {
    date +%j
}

# Get week of year (ISO 8601, 01-53)
timedate::date::week_of_year() {
    date +%V
}

# Get quarter (1-4)
timedate::date::quarter() {
    local month
    month=$(date +%m)
    echo $(( (10#$month - 1) / 3 + 1 ))
}

# Get last day of a given month
# Usage: timedate::date::days_in_month year month
timedate::date::days_in_month() {
    # Remove leading zero to avoid octal interpretation
    local month=$(( 10#$2 ))
    case "$month" in
    1|3|5|7|8|10|12) echo 31 ;;
    4|6|9|11)         echo 30 ;;
    2)
        if timedate::calendar::is_leap_year "$1"; then
            echo 29
        else
            echo 28
        fi
        ;;
    esac
}

# Add n days to a date
# Usage: timedate::date::add_days YYYY-MM-DD n
timedate::date::add_days() {
    if _timedate::has_gnu_date; then
        date -d "$1 + $2 days" +%Y-%m-%d 2>/dev/null
    else
        date -v+"${2}d" -j -f "%Y-%m-%d" "$1" +%Y-%m-%d 2>/dev/null
    fi
}

# Subtract n days from a date
timedate::date::sub_days() {
    timedate::date::add_days "$1" "$(( -$2 ))"
}

# Add n months to a date
timedate::date::add_months() {
    if _timedate::has_gnu_date; then
        date -d "$1 + $2 months" +%Y-%m-%d 2>/dev/null
    else
        date -v+"${2}m" -j -f "%Y-%m-%d" "$1" +%Y-%m-%d 2>/dev/null
    fi
}

# Add n years to a date
timedate::date::add_years() {
    if _timedate::has_gnu_date; then
        date -d "$1 + $2 years" +%Y-%m-%d 2>/dev/null
    else
        date -v+"${2}y" -j -f "%Y-%m-%d" "$1" +%Y-%m-%d 2>/dev/null
    fi
}

# Number of days between two dates
# Usage: timedate::date::days_between YYYY-MM-DD YYYY-MM-DD
timedate::date::days_between() {
    local ts1 ts2
    ts1=$(timedate::timestamp::from_human "$1 00:00:00")
    ts2=$(timedate::timestamp::from_human "$2 00:00:00")
    echo $(( (ts2 - ts1) / 86400 ))
}

# Get yesterday's date
timedate::date::yesterday() {
    timedate::date::add_days "$(timedate::date::today)" -1
}

# Get tomorrow's date
timedate::date::tomorrow() {
    timedate::date::add_days "$(timedate::date::today)" 1
}

# Get start of current week (Monday)
timedate::date::week_start() {
    local dow
    dow=$(timedate::date::day_of_week)
    timedate::date::add_days "$(timedate::date::today)" "$(( -(dow - 1) ))"
}

# Get end of current week (Sunday)
timedate::date::week_end() {
    local dow
    dow=$(timedate::date::day_of_week)
    timedate::date::add_days "$(timedate::date::today)" "$(( 7 - dow ))"
}

# Get start of current month
timedate::date::month_start() {
    date +%Y-%m-01
}

# Get end of current month
timedate::date::month_end() {
    local year month days
    year=$(date +%Y)
    month=$(date +%m)
    days=$(timedate::date::days_in_month "$year" "$month")
    printf '%s-%s-%02d\n' "$year" "$month" "$days"
}

# Get start of current year
timedate::date::year_start() {
    date +%Y-01-01
}

# Get end of current year
timedate::date::year_end() {
    date +%Y-12-31
}

# Next occurrence of a weekday from today
# Usage: timedate::date::next_weekday weekday_number (1=Mon, 7=Sun)
timedate::date::next_weekday() {
    local dow
    dow=$(timedate::date::day_of_week)
    local diff=$(( ($1 - dow + 7) % 7 ))
    (( diff == 0 )) && diff=7
    timedate::date::add_days "$(timedate::date::today)" "$diff"
}

# Previous occurrence of a weekday
timedate::date::prev_weekday() {
    local dow
    dow=$(timedate::date::day_of_week)
    local diff=$(( (dow - $1 + 7) % 7 ))
    (( diff == 0 )) && diff=7
    timedate::date::add_days "$(timedate::date::today)" "$(( -diff ))"
}

# Compare two dates — returns -1, 0, or 1
# Usage: timedate::date::compare YYYY-MM-DD YYYY-MM-DD
timedate::date::compare() {
    local ts1 ts2
    ts1=$(timedate::timestamp::from_human "$1 00:00:00")
    ts2=$(timedate::timestamp::from_human "$2 00:00:00")
    if (( ts1 < ts2 ));   then echo -1
    elif (( ts1 > ts2 )); then echo 1
    else                       echo 0
    fi
}

# Check if a date is before another
timedate::date::is_before() {
    [[ "$(timedate::date::compare "$1" "$2")" == "-1" ]]
}

# Check if a date is after another
timedate::date::is_after() {
    [[ "$(timedate::date::compare "$1" "$2")" == "1" ]]
}

# Check if a date is between two dates (inclusive)
timedate::date::is_between() {
    ! timedate::date::is_before "$1" "$2" && \
    ! timedate::date::is_after  "$1" "$3"
}

# ==============================================================================
# TIME
# ==============================================================================

# Current time in HH:MM:SS
timedate::time::now() {
    date +%H:%M:%S
}

# Current time in a custom format
timedate::time::format() {
    date +"${1:-%H:%M:%S}"
}

# Get hour (00-23)
timedate::time::hour()   { date +%H; }

# Get minute (00-59)
timedate::time::minute() { date +%M; }

# Get second (00-59)
timedate::time::second() { date +%S; }

# Get timezone abbreviation
timedate::time::timezone() {
    date +%Z
}

# Get timezone offset from UTC (e.g. +0800)
timedate::time::timezone_offset() {
    date +%z
}

# Check if current time is before a given time
# Usage: timedate::time::is_before HH:MM
timedate::time::is_before() {
    [[ "$(date +%H:%M)" < "$1" ]]
}

# Check if current time is after a given time
timedate::time::is_after() {
    [[ "$(date +%H:%M)" > "$1" ]]
}

# Check if current time is between two times (HH:MM)
# Usage: timedate::time::is_between HH:MM HH:MM
timedate::time::is_between() {
    local current
    current=$(date +%H:%M)
    [[ "$current" > "$1" && "$current" < "$2" ]]
}

# Check if currently business hours (09:00-17:00 Mon-Fri)
# Usage: timedate::time::is_business_hours [start_hour] [end_hour]
timedate::time::is_business_hours() {
    local dow
    dow=$(timedate::date::day_of_week)
    (( dow >= 1 && dow <= 5 )) || return 1
    timedate::time::is_between "${1:-09:00}" "${2:-17:00}"
}

# Check if currently morning (00:00-11:59)
timedate::time::is_morning() {
    local hour
    hour=$(( 10#$(date +%H) ))
    (( hour < 12 ))
}

# Check if currently afternoon (12:00-17:59)
timedate::time::is_afternoon() {
    local hour
    hour=$(( 10#$(date +%H) ))
    (( hour >= 12 && hour < 18 ))
}

# Check if currently evening (18:00-23:59)
timedate::time::is_evening() {
    local hour
    hour=$(( 10#$(date +%H) ))
    (( hour >= 18 ))
}

# Sleep with a progress indicator
# Usage: timedate::time::sleep seconds [message]
timedate::time::sleep() {
    local i
    for (( i=$1; i>0; i-- )); do
        printf '\r%s... %ds ' "${2:-Waiting}" "$i"
        sleep 1
    done
    printf '\r%s... done\n' "${2:-Waiting}"
}

# Stopwatch — start, returns a token
# Usage: token=$(timedate::time::stopwatch::start)
timedate::time::stopwatch::start() {
    timedate::timestamp::unix_ms
}

# Stopwatch — stop, returns elapsed ms
# Usage: timedate::time::stopwatch::stop token
timedate::time::stopwatch::stop() {
    local now
    now=$(timedate::timestamp::unix_ms)
    echo $(( now - $1 ))
}

# ==============================================================================
# DURATION
# ==============================================================================

# Format seconds into human-readable duration
# Usage: timedate::duration::format seconds
# Output: 1d 2h 3m 4s
timedate::duration::format() {
    local neg=""
    (( $1 < 0 )) && neg="-" && $1=$(( -$1 ))

    local days=$(( $1 / 86400 ))
    local hours=$(( ($1 % 86400) / 3600 ))
    local mins=$(( ($1 % 3600) / 60 ))
    local secs=$(( $1 % 60 ))

    local result=""
    (( days  > 0 )) && result+="${days}d "
    (( hours > 0 )) && result+="${hours}h "
    (( mins  > 0 )) && result+="${mins}m "
    (( secs  > 0 || $1 == 0 )) && result+="${secs}s"

    echo "${neg}${result% }"
}

# Format milliseconds into human-readable duration
timedate::duration::format_ms() {
    if (( $1 < 1000 )); then
        echo "${1}ms"
    elif (( $1 < 60000 )); then
        echo "$(( $1 / 1000 ))s $(( $1 % 1000 ))ms"
    else
        timedate::duration::format "$(( $1 / 1000 ))"
    fi
}

# Parse a duration string into seconds
# Usage: timedate::duration::parse "1d 2h 3m 4s"
timedate::duration::parse() {
    local total=0
    local -a tokens=($1)
    for token in "${tokens[@]}"; do
        local val unit
        val="${token%[dhms]*}"
        unit="${token##*[0-9]}"
        case "$unit" in
        d) (( total += val * 86400 )) ;;
        h) (( total += val * 3600  )) ;;
        m) (( total += val * 60    )) ;;
        s) (( total += val         )) ;;
        esac
    done
    echo "$total"
}

# Human-readable relative time from a unix timestamp
# Usage: timedate::duration::relative timestamp
# Output: "3 hours ago", "in 2 days"
timedate::duration::relative() {
    local now
    now=$(timedate::timestamp::unix)
    local diff=$(( now - $1 ))
    local abs_diff=$(( diff < 0 ? -diff : diff ))
    local future=false
    (( diff < 0 )) && future=true

    local result
    if   (( abs_diff < 60 ));     then result="${abs_diff} second$( (( abs_diff != 1 )) && echo s)"
    elif (( abs_diff < 3600 ));   then
        local m=$(( abs_diff / 60 ))
        result="$m minute$( (( m != 1 )) && echo s)"
    elif (( abs_diff < 86400 ));  then
        local h=$(( abs_diff / 3600 ))
        result="$h hour$( (( h != 1 )) && echo s)"
    elif (( abs_diff < 2592000 )); then
        local d=$(( abs_diff / 86400 ))
        result="$d day$( (( d != 1 )) && echo s)"
    elif (( abs_diff < 31536000 )); then
        local mo=$(( abs_diff / 2592000 ))
        result="$mo month$( (( mo != 1 )) && echo s)"
    else
        local y=$(( abs_diff / 31536000 ))
        result="$y year$( (( y != 1 )) && echo s)"
    fi

    $future && echo "in $result" || echo "$result ago"
}

# ==============================================================================
# CALENDAR
# ==============================================================================

# Check if a year is a leap year
# Usage: timedate::calendar::is_leap_year year
timedate::calendar::is_leap_year() {
    (( $1 % 4 == 0 && ($1 % 100 != 0 || $1 % 400 == 0) ))
}

# Get number of days in a year
timedate::calendar::days_in_year() {
    timedate::calendar::is_leap_year "$1" && echo 366 || echo 365
}

# Check if a date falls on a weekend
# Usage: timedate::calendar::is_weekend YYYY-MM-DD
timedate::calendar::is_weekend() {
    local dow
    if _timedate::has_gnu_date; then
        dow=$(date -d "$1" +%u 2>/dev/null)
    else
        dow=$(date -j -f "%Y-%m-%d" "$1" +%u 2>/dev/null)
    fi
    (( dow >= 6 ))
}

# Check if a date falls on a weekday
timedate::calendar::is_weekday() {
    ! timedate::calendar::is_weekend "$1"
}

# Get ISO week number for a date
# Usage: timedate::calendar::iso_week YYYY-MM-DD
timedate::calendar::iso_week() {
    if _timedate::has_gnu_date; then
        date -d "$1" +%V 2>/dev/null
    else
        date -j -f "%Y-%m-%d" "$1" +%V 2>/dev/null
    fi
}

# Get day of year for a date
# Usage: timedate::calendar::day_of_year YYYY-MM-DD
timedate::calendar::day_of_year() {
    if _timedate::has_gnu_date; then
        date -d "$1" +%j 2>/dev/null
    else
        date -j -f "%Y-%m-%d" "$1" +%j 2>/dev/null
    fi
}

# Get quarter for a date
# Usage: timedate::calendar::quarter YYYY-MM-DD
timedate::calendar::quarter() {
    local month
    if _timedate::has_gnu_date; then
        month=$(date -d "$1" +%m 2>/dev/null)
    else
        month=$(date -j -f "%Y-%m-%d" "$1" +%m 2>/dev/null)
    fi
    echo $(( (10#$month - 1) / 3 + 1 ))
}

# Calculate Easter date for a given year (Meeus/Jones/Butcher algorithm)
# Usage: timedate::calendar::easter year
# Output: YYYY-MM-DD
timedate::calendar::easter() {
    local a b c d e f g h i k l m n p

    a=$(( $1 % 19 ))
    b=$(( $1 / 100 ))
    c=$(( $1 % 100 ))
    d=$(( b / 4 ))
    e=$(( b % 4 ))
    f=$(( (b + 8) / 25 ))
    g=$(( (b - f + 1) / 3 ))
    h=$(( (19 * a + b - d - g + 15) % 30 ))
    i=$(( c / 4 ))
    k=$(( c % 4 ))
    l=$(( (32 + 2 * e + 2 * i - h - k) % 7 ))
    m=$(( (a + 11 * h + 22 * l) / 451 ))
    n=$(( (h + l - 7 * m + 114) / 31 ))
    p=$(( (h + l - 7 * m + 114) % 31 + 1 ))

    printf '%d-%02d-%02d\n' "$1" "$n" "$p"
}

# Number of weekdays between two dates
# Usage: timedate::calendar::weekdays_between YYYY-MM-DD YYYY-MM-DD
timedate::calendar::weekdays_between() {
    local count=0 current="$1"
    while ! timedate::date::is_after "$current" "$2"; do
        timedate::calendar::is_weekday "$current" && (( count++ ))
        current=$(timedate::date::add_days "$current" 1)
    done
    echo "$count"
}

# Get the calendar for a month (like cal command)
# Usage: timedate::calendar::month [year] [month]
timedate::calendar::month() {
    local year="${1:-$(date +%Y)}" month="${2:-$(date +%m)}"
    if runtime::has_command cal; then
        cal "$month" "$year"
    else
        # Pure bash fallback — basic grid
        local days
        days=$(timedate::date::days_in_month "$year" "$month")
        local first_dow
        if _timedate::has_gnu_date; then
            first_dow=$(date -d "${year}-${month}-01" +%u 2>/dev/null)
        else
            first_dow=$(date -j -f "%Y-%m-%d" "${year}-${month}-01" +%u 2>/dev/null)
        fi
        printf '%s %s\n' "$(date -d "${year}-${month}-01" +"%B %Y" 2>/dev/null || echo "$year-$month")" ""
        printf 'Mo Tu We Th Fr Sa Su\n'
        local pad=$(( first_dow - 1 ))
        local i col=1
        printf '%s' "$(printf '   %.0s' $(seq 1 $pad))"
        col=$(( pad + 1 ))
        for (( i=1; i<=days; i++ )); do
            printf '%2d ' "$i"
            (( col % 7 == 0 )) && printf '\n'
            (( col++ ))
        done
        printf '\n'
    fi
}

# ==============================================================================
# TIMEZONE
# ==============================================================================

# Convert a timestamp to a different timezone
# Usage: timedate::tz::convert timestamp timezone
# Example: timedate::tz::convert 1700000000 "America/New_York"
timedate::tz::convert() {
    if _timedate::has_gnu_date; then
        TZ="$2" date -d "@$1" "+%Y-%m-%d %H:%M:%S %Z" 2>/dev/null
    else
        TZ="$2" date -r "$1" "+%Y-%m-%d %H:%M:%S %Z" 2>/dev/null
    fi
}

# Get current time in a specific timezone
# Usage: timedate::tz::now timezone
timedate::tz::now() {
    TZ="$1" date "+%Y-%m-%d %H:%M:%S %Z" 2>/dev/null
}

# Get current timezone name
timedate::tz::current() {
    date +%Z
}

# Get UTC offset in seconds
timedate::tz::offset_seconds() {
    local offset
    offset=$(date +%z)
    local sign="${offset:0:1}"
    local hours=$(( 10#${offset:1:2} ))
    local mins=$(( 10#${offset:3:2} ))
    local total=$(( hours * 3600 + mins * 60 ))
    [[ "$sign" == "-" ]] && total=$(( -total ))
    echo "$total"
}

# Check if currently in daylight saving time
timedate::tz::is_dst() {
    local dst
    dst=$(date +%Z)
    # Most DST zones have a different abbreviation (EDT vs EST, BST vs GMT, etc.)
    # This is a heuristic — not universally reliable
    [[ "$dst" =~ DT$|BST|CEST|IST|NZDT|AEDT|AEST ]]
}

# List all available timezones
timedate::tz::list() {
    if [[ -d /usr/share/zoneinfo ]]; then
        find /usr/share/zoneinfo -type f -o -type l | \
            sed 's|/usr/share/zoneinfo/||' | \
            grep -v '^\.' | \
            sort
    elif runtime::has_command timedatectl; then
        timedatectl list-timezones 2>/dev/null
    else
        echo "timedate::tz::list: no timezone database found" >&2
        return 1
    fi
}

# List timezones filtered by region
# Usage: timedate::tz::list::region America
timedate::tz::list::region() {
    timedate::tz::list | grep "^${1}/"
}
