# `timedate::tz::list`

List all available timezones

## Source

```bash
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
```

## Module

[`timedate`](../timedate.md)
