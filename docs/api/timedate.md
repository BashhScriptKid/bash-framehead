# `timedate`

74 functions. [Guide](../guide/index.md) — [Dictionary](index.md)

| Function | Signature | Description |
|----------|-----------|-------------|
| [`timedate::calendar::day_of_year`](timedate/calendar/day_of_year.md) | `timedate::calendar::day_of_year(YYYY-MM-DD)` |  |
| [`timedate::calendar::days_in_year`](timedate/calendar/days_in_year.md) | `timedate::calendar::days_in_year(arg1)` |  |
| [`timedate::calendar::easter`](timedate/calendar/easter.md) | `timedate::calendar::easter(year)` |  |
| [`timedate::calendar::is_leap_year`](timedate/calendar/is_leap_year.md) | `timedate::calendar::is_leap_year(year)` |  |
| [`timedate::calendar::iso_week`](timedate/calendar/iso_week.md) | `timedate::calendar::iso_week(YYYY-MM-DD)` |  |
| [`timedate::calendar::is_weekday`](timedate/calendar/is_weekday.md) | `timedate::calendar::is_weekday(arg1)` |  |
| [`timedate::calendar::is_weekend`](timedate/calendar/is_weekend.md) | `timedate::calendar::is_weekend(YYYY-MM-DD)` |  |
| [`timedate::calendar::month`](timedate/calendar/month.md) | `timedate::calendar::month([year], [month])` |  |
| [`timedate::calendar::quarter`](timedate/calendar/quarter.md) | `timedate::calendar::quarter(YYYY-MM-DD)` |  |
| [`timedate::calendar::weekdays_between`](timedate/calendar/weekdays_between.md) | `timedate::calendar::weekdays_between(YYYY-MM-DD, YYYY-MM-DD)` |  |
| [`timedate::date::add_days`](timedate/date/add_days.md) | `timedate::date::add_days(YYYY-MM-DD, n)` |  |
| [`timedate::date::add_months`](timedate/date/add_months.md) | `timedate::date::add_months(arg1, arg2)` |  |
| [`timedate::date::add_years`](timedate/date/add_years.md) | `timedate::date::add_years(arg1, arg2)` |  |
| [`timedate::date::compare`](timedate/date/compare.md) | `timedate::date::compare(YYYY-MM-DD, YYYY-MM-DD)` |  |
| [`timedate::date::day`](timedate/date/day.md) | `timedate::date::day()` |  |
| [`timedate::date::day_name`](timedate/date/day_name.md) | `timedate::date::day_name()` |  |
| [`timedate::date::day_name::short`](timedate/date/day_name/short.md) | `timedate::date::day_name::short()` |  |
| [`timedate::date::day_of_week`](timedate/date/day_of_week.md) | `timedate::date::day_of_week()` |  |
| [`timedate::date::day_of_year`](timedate/date/day_of_year.md) | `timedate::date::day_of_year()` |  |
| [`timedate::date::days_between`](timedate/date/days_between.md) | `timedate::date::days_between(YYYY-MM-DD, YYYY-MM-DD)` |  |
| [`timedate::date::days_in_month`](timedate/date/days_in_month.md) | `timedate::date::days_in_month(year, month)` |  |
| [`timedate::date::format`](timedate/date/format.md) | `timedate::date::format([format], [timestamp])` |  |
| [`timedate::date::is_after`](timedate/date/is_after.md) | `timedate::date::is_after(arg1, arg2)` |  |
| [`timedate::date::is_before`](timedate/date/is_before.md) | `timedate::date::is_before(arg1, arg2)` |  |
| [`timedate::date::is_between`](timedate/date/is_between.md) | `timedate::date::is_between(arg1, arg2, arg3)` |  |
| [`timedate::date::month_end`](timedate/date/month_end.md) | `timedate::date::month_end()` |  |
| [`timedate::date::month`](timedate/date/month.md) | `timedate::date::month()` |  |
| [`timedate::date::month_start`](timedate/date/month_start.md) | `timedate::date::month_start()` |  |
| [`timedate::date::next_weekday`](timedate/date/next_weekday.md) | `timedate::date::next_weekday(weekday_number (1=Mon, 7=Sun))` |  |
| [`timedate::date::prev_weekday`](timedate/date/prev_weekday.md) | `timedate::date::prev_weekday(arg1)` |  |
| [`timedate::date::quarter`](timedate/date/quarter.md) | `timedate::date::quarter()` |  |
| [`timedate::date::sub_days`](timedate/date/sub_days.md) | `timedate::date::sub_days(arg1, arg2)` |  |
| [`timedate::date::today`](timedate/date/today.md) | `timedate::date::today()` |  |
| [`timedate::date::tomorrow`](timedate/date/tomorrow.md) | `timedate::date::tomorrow()` |  |
| [`timedate::date::week_end`](timedate/date/week_end.md) | `timedate::date::week_end()` |  |
| [`timedate::date::week_of_year`](timedate/date/week_of_year.md) | `timedate::date::week_of_year()` |  |
| [`timedate::date::week_start`](timedate/date/week_start.md) | `timedate::date::week_start()` |  |
| [`timedate::date::year_end`](timedate/date/year_end.md) | `timedate::date::year_end()` |  |
| [`timedate::date::year`](timedate/date/year.md) | `timedate::date::year()` |  |
| [`timedate::date::year_start`](timedate/date/year_start.md) | `timedate::date::year_start()` |  |
| [`timedate::date::yesterday`](timedate/date/yesterday.md) | `timedate::date::yesterday()` |  |
| [`timedate::duration::format`](timedate/duration/format.md) | `timedate::duration::format(seconds)` |  |
| [`timedate::duration::format_ms`](timedate/duration/format_ms.md) | `timedate::duration::format_ms(arg1)` |  |
| [`timedate::duration::parse`](timedate/duration/parse.md) | `timedate::duration::parse(1d, 2h, 3m, 4s)` |  |
| [`timedate::duration::relative`](timedate/duration/relative.md) | `timedate::duration::relative(timestamp)` |  |
| [`timedate::time::format`](timedate/time/format.md) | `timedate::time::format()` |  |
| [`timedate::time::hour`](timedate/time/hour.md) | `timedate::time::hour()` |  |
| [`timedate::time::is_after`](timedate/time/is_after.md) | `timedate::time::is_after(arg1)` |  |
| [`timedate::time::is_afternoon`](timedate/time/is_afternoon.md) | `timedate::time::is_afternoon()` |  |
| [`timedate::time::is_before`](timedate/time/is_before.md) | `timedate::time::is_before(HH:MM)` |  |
| [`timedate::time::is_between`](timedate/time/is_between.md) | `timedate::time::is_between(HH:MM, HH:MM)` |  |
| [`timedate::time::is_business_hours`](timedate/time/is_business_hours.md) | `timedate::time::is_business_hours([start_hour], [end_hour])` |  |
| [`timedate::time::is_evening`](timedate/time/is_evening.md) | `timedate::time::is_evening()` |  |
| [`timedate::time::is_morning`](timedate/time/is_morning.md) | `timedate::time::is_morning()` |  |
| [`timedate::time::minute`](timedate/time/minute.md) | `timedate::time::minute()` |  |
| [`timedate::time::now`](timedate/time/now.md) | `timedate::time::now()` |  |
| [`timedate::time::second`](timedate/time/second.md) | `timedate::time::second()` |  |
| [`timedate::time::sleep`](timedate/time/sleep.md) | `timedate::time::sleep(seconds, [message])` |  |
| [`timedate::timestamp::from_human`](timedate/timestamp/from_human.md) | `timedate::timestamp::from_human(2024-01-15, 12:00:00)` |  |
| [`timedate::timestamp::to_human`](timedate/timestamp/to_human.md) | `timedate::timestamp::to_human(timestamp, [format])` |  |
| [`timedate::timestamp::unix`](timedate/timestamp/unix.md) | `timedate::timestamp::unix()` |  |
| [`timedate::timestamp::unix_ms`](timedate/timestamp/unix_ms.md) | `timedate::timestamp::unix_ms()` |  |
| [`timedate::timestamp::unix_ns`](timedate/timestamp/unix_ns.md) | `timedate::timestamp::unix_ns()` |  |
| [`timedate::time::stopwatch::start`](timedate/time/stopwatch/start.md) | `timedate::time::stopwatch::start(token=$(timedate::time::stopwatch::start))` |  |
| [`timedate::time::stopwatch::stop`](timedate/time/stopwatch/stop.md) | `timedate::time::stopwatch::stop(token)` |  |
| [`timedate::time::timezone`](timedate/time/timezone.md) | `timedate::time::timezone()` |  |
| [`timedate::time::timezone_offset`](timedate/time/timezone_offset.md) | `timedate::time::timezone_offset()` |  |
| [`timedate::tz::convert`](timedate/tz/convert.md) | `timedate::tz::convert(timestamp, timezone)` |  |
| [`timedate::tz::current`](timedate/tz/current.md) | `timedate::tz::current()` |  |
| [`timedate::tz::is_dst`](timedate/tz/is_dst.md) | `timedate::tz::is_dst()` |  |
| [`timedate::tz::list`](timedate/tz/list.md) | `timedate::tz::list()` |  |
| [`timedate::tz::list::region`](timedate/tz/list/region.md) | `timedate::tz::list::region(America)` |  |
| [`timedate::tz::now`](timedate/tz/now.md) | `timedate::tz::now(timezone)` |  |
| [`timedate::tz::offset_seconds`](timedate/tz/offset_seconds.md) | `timedate::tz::offset_seconds()` |  |

