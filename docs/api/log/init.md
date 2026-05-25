# `log::init`

**Signature:** `log::init()`

**Module:** [`log`](../log.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- DEFAULTS ---


## Source

```bash
log::init() {
		LOG_FMT="${LOG_FMT:-%datetime% [%severity%] %message%}"
		LOG_FILE="${LOG_FILE:-}"
		LOG_TO_STDOUT="${LOG_TO_STDOUT:-2#0011}"
		if [[ -z "${LOG_COLOUR+x}" ]]; then
				# Auto-detect: enable if terminal supports colour
				if [[ -t 1 && "${TERM:-}" != "dumb" && ( -n "${COLORTERM:-}" || "${TERM:-}" == *color* || "${TERM:-}" == *256* ) ]]; then
						LOG_COLOUR=1
				else
						LOG_COLOUR=0
				fi
		fi
}
```

