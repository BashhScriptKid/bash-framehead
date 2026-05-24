#!/usr/bin/env bash
# ext/http-server/http-server.sh -- Bash HTTP server
#
# Dependencies:
#   core: runtime string fs log
#   external: nc|socat|tcpserver

# --- guard ---

declare -f 'runtime::bash_version' &>/dev/null || {
    echo "${BASH_SOURCE[0]}: runtime not found -- source bash-framehead.sh first" >&2
    return 1
}

_guard_core_deps=(string::url_decode string::random string::trim string::split::fast
                  string::after string::lower string::base64_encode fs::mime_type
                  fs::exists fs::is_file fs::read fs::size)
_guard_ext_deps=()

for _guard_dep in "${_guard_core_deps[@]}"; do
    declare -f "$_guard_dep" &>/dev/null || {
        echo "${BASH_SOURCE[0]}: missing core function '$_guard_dep'" >&2
        return 1
    }
done

# Check for at least one TCP listener tool
_http_has_listener=0
for _guard_dep in tcpserver socat nc; do
    command -v "$_guard_dep" &>/dev/null && { _http_has_listener=1; break; }
done
if (( ! _http_has_listener )); then
    echo "${BASH_SOURCE[0]}: requires at least one of: tcpserver, socat, nc" >&2
    return 1
fi
unset _http_has_listener

for _guard_dep in "${_guard_ext_deps[@]}"; do
    command -v "$_guard_dep" &>/dev/null || {
        echo "${BASH_SOURCE[0]}: missing external tool '$_guard_dep'" >&2
        return 1
    }
done

unset _guard_core_deps _guard_ext_deps _guard_dep
# --- end guard ---

# ==============================================================================
# STATUS CODES
# ==============================================================================

declare -A _HTTP_STATUS_CODES
_http_status_init_done=0

# Initialise the HTTP status code → reason phrase map (lazy, once).
_http::init_status_codes() {
    (( _http_status_init_done )) && return
    _http_status_init_done=1

    _HTTP_STATUS_CODES[100]="Continue"
    _HTTP_STATUS_CODES[101]="Switching Protocols"
    _HTTP_STATUS_CODES[200]="OK"
    _HTTP_STATUS_CODES[201]="Created"
    _HTTP_STATUS_CODES[204]="No Content"
    _HTTP_STATUS_CODES[301]="Moved Permanently"
    _HTTP_STATUS_CODES[302]="Found"
    _HTTP_STATUS_CODES[303]="See Other"
    _HTTP_STATUS_CODES[304]="Not Modified"
    _HTTP_STATUS_CODES[307]="Temporary Redirect"
    _HTTP_STATUS_CODES[308]="Permanent Redirect"
    _HTTP_STATUS_CODES[400]="Bad Request"
    _HTTP_STATUS_CODES[401]="Unauthorized"
    _HTTP_STATUS_CODES[403]="Forbidden"
    _HTTP_STATUS_CODES[404]="Not Found"
    _HTTP_STATUS_CODES[405]="Method Not Allowed"
    _HTTP_STATUS_CODES[409]="Conflict"
    _HTTP_STATUS_CODES[410]="Gone"
    _HTTP_STATUS_CODES[411]="Length Required"
    _HTTP_STATUS_CODES[413]="Payload Too Large"
    _HTTP_STATUS_CODES[414]="URI Too Long"
    _HTTP_STATUS_CODES[415]="Unsupported Media Type"
    _HTTP_STATUS_CODES[418]="I'm a teapot"
    _HTTP_STATUS_CODES[422]="Unprocessable Entity"
    _HTTP_STATUS_CODES[429]="Too Many Requests"
    _HTTP_STATUS_CODES[500]="Internal Server Error"
    _HTTP_STATUS_CODES[501]="Not Implemented"
    _HTTP_STATUS_CODES[502]="Bad Gateway"
    _HTTP_STATUS_CODES[503]="Service Unavailable"
}

# ==============================================================================
# SERVER STATE
# ==============================================================================

declare -A _HTTP_HEADERS=()
declare -A _HTTP_QUERY_PARAMS=()
declare -A _HTTP_COOKIES=()
declare -A _HTTP_FORM_DATA=()
declare -A _HTTP_FILE_UPLOADS=()
declare -A _HTTP_FILE_UPLOAD_NAMES=()
declare -A _HTTP_FILE_UPLOAD_TYPES=()
declare -A PATH_VARS=()
_HTTP_METHOD=""
_HTTP_PATH=""
_HTTP_VERSION=""
_HTTP_BODY=""

_HTTP_SESSION_ID=""
declare -A _HTTP_SESSION=()

declare -A _HTTP_ROUTES=()
_HTTP_SERVER_LISTENER_PID=""

# ==============================================================================
# PUBLIC: STATUS CODES
# ==============================================================================

# Look up the reason phrase for an HTTP status code.
# Usage: http::statuscode::what 404  →  "Not Found"
http::statuscode::what() {
    local code="${1:-200}"
    _http::init_status_codes
    echo "${_HTTP_STATUS_CODES[$code]:-Unknown}"
}

# ==============================================================================
# INTERNAL: request parsing helpers
# ==============================================================================

# Parse a query string (?key=val&...) into _HTTP_QUERY_PARAMS[].
_http::parse_query() {
    local query="$1" pair key val
    _HTTP_QUERY_PARAMS=()
    if [[ -z "$query" ]]; then
        return 0
    fi
    while IFS='&' read -r -d '&' pair; do
        [[ -z "$pair" ]] && continue
        key="${pair%%=*}"
        val="${pair#*=}"
        [[ "$key" == "$pair" ]] && val=""
        _HTTP_QUERY_PARAMS["$(string::url_decode "$key")"]="$(string::url_decode "$val")"
    done <<< "${query}&"
}

# Parse a Cookie header value into _HTTP_COOKIES[].
_http::parse_cookie_header() {
    local raw="$1" pair key val
    _HTTP_COOKIES=()
    if [[ -z "$raw" ]]; then
        return 0
    fi
    while IFS=';' read -r -d ';' pair; do
        pair="$(string::trim "$pair")"
        [[ -z "$pair" ]] && continue
        key="${pair%%=*}"
        val="${pair#*=}"
        [[ "$key" == "$pair" ]] && val=""
        key="$(string::trim "$key")"
        _HTTP_COOKIES["$key"]="$(string::url_decode "$val")"
    done <<< "${raw};"
}

# Parse application/x-www-form-urlencoded body into _HTTP_FORM_DATA[].
_http::parse_form_urlencoded() {
    local body="$1" pair key val
    _HTTP_FORM_DATA=()
    while IFS='&' read -r -d '&' pair; do
        [[ -z "$pair" ]] && continue
        key="${pair%%=*}"
        val="${pair#*=}"
        [[ "$key" == "$pair" ]] && val=""
        _HTTP_FORM_DATA["$(string::url_decode "$key")"]="$(string::url_decode "$val")"
    done <<< "${body}&"
}

# ==============================================================================
# PUBLIC: request parsing
# ==============================================================================

# Parse a raw HTTP request from stdin. Populates global variables:
#   _HTTP_METHOD  _HTTP_PATH  _HTTP_VERSION
#   _HTTP_HEADERS[]  _HTTP_QUERY_PARAMS[]  _HTTP_COOKIES[]
#   _HTTP_FORM_DATA[]  _HTTP_BODY
http::parse_request() {
    local line key val content_length content_type boundary

    # Reset state
    _HTTP_HEADERS=()
    _HTTP_QUERY_PARAMS=()
    _HTTP_COOKIES=()
    _HTTP_FORM_DATA=()
    _HTTP_FILE_UPLOADS=()
    _HTTP_FILE_UPLOAD_NAMES=()
    _HTTP_FILE_UPLOAD_TYPES=()
    _HTTP_BODY=""

    # Request line
    IFS= read -r line
    line="${line%%$'\r'}"
    read -r _HTTP_METHOD _HTTP_PATH _HTTP_VERSION <<< "$line"

    # Parse query string from path
    if [[ "$_HTTP_PATH" == *"?"* ]]; then
        local raw_query="${_HTTP_PATH#*\?}"
        _HTTP_PATH="${_HTTP_PATH%%\?*}"
        _http::parse_query "$raw_query"
    fi

    # Read headers
    while IFS= read -r line; do
        line="${line%%$'\r'}"
        [[ -z "$line" ]] && break
        key="${line%%:*}"
        val="${line#*: }"
        [[ "$key" == "$line" ]] && val=""
        _HTTP_HEADERS["$(string::lower "$key")"]="$val"
    done

    # Parse cookies
    if [[ -n "${_HTTP_HEADERS[cookie]:-}" ]]; then
        _http::parse_cookie_header "${_HTTP_HEADERS[cookie]}"
    fi

    # Read body
    content_length="${_HTTP_HEADERS[content-length]:-0}"
    content_type="${_HTTP_HEADERS[content-type]:-}"

    if [[ "$content_length" =~ ^[0-9]+$ ]] && (( content_length > 0 )); then
        read -r -N "$content_length" _HTTP_BODY 2>/dev/null || true
        if [[ "$content_type" == "application/x-www-form-urlencoded"* ]]; then
            _http::parse_form_urlencoded "$_HTTP_BODY"
        fi
    fi
}

# ==============================================================================
# INTERNAL: response helpers
# ==============================================================================

_http::emit_status_line() {
    local code="$1" reason
    reason="$(http::statuscode::what "$code")"
    printf '%s\r\n' "HTTP/1.1 $code $reason"
}

_http::emit_header() {
    printf '%s: %s\r\n' "$1" "$2"
}

# ==============================================================================
# PUBLIC: response
# ==============================================================================

# Emit HTTP status line with Server header, optional body.
# Usage: http::respond 200 "Hello"
http::respond() {
    local code="${1:-200}" body="${2:-}"
    _http::emit_status_line "$code"
    _http::emit_header "Server" "bash-framehead"
    if [[ -n "$body" ]]; then
        _http::emit_header "Content-Length" "${#body}"
        printf '\r\n%s' "$body"
    else
        _http::emit_header "Content-Length" "0"
        printf '\r\n'
    fi
}

# Emit a single HTTP header line. Use between http::respond (without body)
# and http::end_headers for custom multi-header responses.
# Usage: http::header "Content-Type" "text/html"
http::header() {
    _http::emit_header "$1" "$2"
}

# Terminate the header block (sends the blank line).
# Usage: http::end_headers
http::end_headers() {
    printf '\r\n'
}

# Emit a redirect response.
# Usage: http::redirect "/new-location" [code]
http::redirect() {
    local url="$1" code="${2:-302}"
    _http::emit_status_line "$code"
    _http::emit_header "Location" "$url"
    _http::emit_header "Server" "bash-framehead"
    _http::emit_header "Content-Length" "0"
    printf '\r\n'
}

# Emit an error response with optional custom message.
# Usage: http::error 404 "Page not found"
http::error() {
    local code="${1:-500}" msg="${2:-}"
    [[ -z "$msg" ]] && msg="$(http::statuscode::what "$code")"
    _http::emit_status_line "$code"
    _http::emit_header "Server" "bash-framehead"
    _http::emit_header "Content-Type" "text/plain"
    _http::emit_header "Content-Length" "${#msg}"
    printf '\r\n%s' "$msg"
}

# ==============================================================================
# ROUTING
# ==============================================================================

# Register a GET route.
# Usage: http::route::get "/path" handler_function
http::route::get()     { _HTTP_ROUTES["GET:$1"]="$2"; }

# Register a POST route.
# Usage: http::route::post "/path" handler_function
http::route::post()    { _HTTP_ROUTES["POST:$1"]="$2"; }

# Register a PUT route.
# Usage: http::route::put "/path" handler_function
http::route::put()     { _HTTP_ROUTES["PUT:$1"]="$2"; }

# Register a DELETE route.
# Usage: http::route::delete "/path" handler_function
http::route::delete()  { _HTTP_ROUTES["DELETE:$1"]="$2"; }

# Auto-register routes from a directory (bash-stack compatible file-based routing).
# Files named like "index.sh" or "api/hello.sh" map to GET / and GET /api/hello.
# Files prefixed with METHOD. (e.g. "POST.create.sh") register that method.
# Usage: http::route::scan ./pages
http::route::scan() {
    local dir="${1:-.}" file route method ext
    [[ -d "$dir" ]] || { echo "http::route::scan: not a directory: $dir" >&2; return 1; }
    while IFS= read -r file; do
        file="${file#$dir/}"
        ext="${file##*.}"
        [[ "$ext" != "sh" ]] && continue
        route="/${file%.sh}"
        method="GET"
        # Check for METHOD. prefix convention (e.g. POST.create.sh)
        if [[ "$(basename "$route")" =~ ^[A-Z]+\. ]]; then
            method="${BASH_REMATCH[0]%.}"
            route="${route%/*}/${file#*.}"
            route="/${route%.sh}"
        fi
        [[ "$route" == "/index" ]] && route="/"
        _HTTP_ROUTES["$method:$route"]="source $dir/$file"
    done < <(find "$dir" -type f -name '*.sh' | sort)
}

# Dispatch the current request to a registered route handler.
# Matches in order: exact → [param] dynamic → [...] catch-all.
# Populates PATH_VARS[] with extracted path parameters.
# Usage: http::route::dispatch
http::route::dispatch() {
    PATH_VARS=()
    local method="${_HTTP_METHOD:-GET}"
    local path="${_HTTP_PATH:-/}"
    local route_key handler

    # 1. Exact match
    route_key="$method:$path"
    handler="${_HTTP_ROUTES[$route_key]:-}"
    if [[ -n "$handler" ]]; then
        eval "$handler"
        return $?
    fi

    # 2. Dynamic match — [param] patterns
    local req_parts pat_parts key pat val
    local -a req_parts_arr pat_parts_arr
    IFS='/' read -ra req_parts_arr <<< "$path"

    for route_key in "${!_HTTP_ROUTES[@]}"; do
        [[ "$route_key" == "$method:"* ]] || continue
        local pattern="${route_key#$method:}"
        IFS='/' read -ra pat_parts_arr <<< "$pattern"

        if (( ${#req_parts_arr[@]} != ${#pat_parts_arr[@]} )); then
            continue
        fi

        local match=1
        local -A temp_vars=()
        for (( i=0; i < ${#pat_parts_arr[@]}; i++ )); do
            pat="${pat_parts_arr[$i]}"
            val="${req_parts_arr[$i]}"

            if [[ "$pat" == '['*']' ]]; then
                # Named parameter: [param]
                key="${pat:1:-1}"
                temp_vars["$key"]="$val"
            elif [[ "$pat" == "$val" ]]; then
                :
            else
                match=0; break
            fi
        done

        if (( match )); then
            for key in "${!temp_vars[@]}"; do
                PATH_VARS["$key"]="${temp_vars[$key]}"
            done
            eval "${_HTTP_ROUTES[$route_key]}"
            return $?
        fi
    done

    # 3. Catch-all match — [...] patterns (variable length)
    for route_key in "${!_HTTP_ROUTES[@]}"; do
        [[ "$route_key" == "$method:"* ]] || continue
        local pattern="${route_key#$method:}"
        [[ "$pattern" == *"[...]"* ]] || continue

        IFS='/' read -ra pat_parts_arr <<< "$pattern"
        if (( ${#req_parts_arr} < ${#pat_parts_arr[@]} - 1 )); then
            continue
        fi

        local match=1
        local -A temp_vars=()
        for (( i=0; i < ${#pat_parts_arr[@]}; i++ )); do
            pat="${pat_parts_arr[$i]}"
            val="${req_parts_arr[$i]:-}"

            if [[ "$pat" == '[...]' ]]; then
                # Splat: capture remaining segments
                key="${pat:1:-4}"
                [[ -z "$key" ]] && key="splat"
                local remaining=""
                for (( j=i; j < ${#req_parts_arr[@]}; j++ )); do
                    remaining+="/${req_parts_arr[$j]}"
                done
                temp_vars["$key"]="$remaining"
                break
            elif [[ "$pat" == '['*']' ]]; then
                key="${pat:1:-1}"
                temp_vars["$key"]="$val"
            elif [[ "$pat" != "$val" ]]; then
                match=0; break
            fi
        done

        if (( match )); then
            for key in "${!temp_vars[@]}"; do
                PATH_VARS["$key"]="${temp_vars[$key]}"
            done
            eval "${_HTTP_ROUTES[$route_key]}"
            return $?
        fi
    done

    # No match
    http::error 404
    return 1
}

# ==============================================================================
# COOKIES
# ==============================================================================

# Emit a Set-Cookie header.
# Usage: http::cookie::set "name" "value" [max-age] [path] [domain] [secure] [httponly] [samesite]
http::cookie::set() {
    local name="$1" val="$2" max_age="${3:-}" path="${4:-/}" domain="${5:-}"
    local secure="${6:-}" httponly="${7:-}" samesite="${8:-}"
    local encoded
    encoded=$(string::url_encode "$val")
    local header="Set-Cookie: $name=$encoded"
    [[ -n "$max_age" ]] && header+="; Max-Age=$max_age"
    [[ -n "$path" ]]     && header+="; Path=$path"
    [[ -n "$domain" ]]   && header+="; Domain=$domain"
    [[ -n "$secure" ]]   && header+="; Secure"
    [[ -n "$httponly" ]]  && header+="; HttpOnly"
    [[ -n "$samesite" ]] && header+="; SameSite=$samesite"
    _http::emit_header "Set-Cookie" "${header#Set-Cookie: }"
}

# Parse a Cookie header value into _HTTP_COOKIES[] (public wrapper).
# Usage: http::cookie::parse "$raw_cookie_header"
http::cookie::parse() {
    _http::parse_cookie_header "$1"
}

# Send a deletion cookie (Max-Age=0).
# Usage: http::cookie::delete "session_id"
http::cookie::delete() {
    http::cookie::set "$1" "deleted" "0" "/" "" "" "" ""
}

# ==============================================================================
# SESSIONS
# ==============================================================================

# Create or resume a session. Populates _HTTP_SESSION[] and _HTTP_SESSION_ID.
# Sends Set-Cookie for new sessions. Reads tab-delimited session file for resume.
# Usage: http::session::start
http::session::start() {
    local session_dir="${HTTP_SESSION_DIR:-/tmp/fsbshf-http-sessions}"
    mkdir -p "$session_dir" 2>/dev/null

    local cookie_id="${_HTTP_COOKIES[session_id]:-}"

    # Trim non-alphanumeric for safety
    cookie_id="$(echo "$cookie_id" | tr -dc 'a-zA-Z0-9')"

    local session_file="$session_dir/$cookie_id.session"

    if [[ -n "$cookie_id" ]] && [[ -f "$session_file" ]]; then
        _HTTP_SESSION_ID="$cookie_id"
        _HTTP_SESSION=()
        local k v
        while IFS=$'\t' read -r k v; do
            [[ -n "$k" ]] && _HTTP_SESSION["$k"]="$v"
        done < "$session_file"
    else
        _HTTP_SESSION_ID="$(string::random 32)"
        _HTTP_SESSION=()
        http::cookie::set "session_id" "$_HTTP_SESSION_ID" "3600" "/" "" "1" "1" "Lax"
    fi
}

# Persist _HTTP_SESSION[] to disk (tab-delimited).
# Usage: http::session::save
http::session::save() {
    local session_dir="${HTTP_SESSION_DIR:-/tmp/fsbshf-http-sessions}"
    local session_file="$session_dir/${_HTTP_SESSION_ID}.session"
    local k
    > "$session_file"
    for k in "${!_HTTP_SESSION[@]}"; do
        printf '%s\t%s\n' "$k" "${_HTTP_SESSION[$k]}" >> "$session_file"
    done
}

# Destroy the current session: remove file, clear state, send deletion cookie.
# Usage: http::session::destroy
http::session::destroy() {
    local session_dir="${HTTP_SESSION_DIR:-/tmp/fsbshf-http-sessions}"
    [[ -n "${_HTTP_SESSION_ID:-}" ]] || return 0
    rm -f "$session_dir/${_HTTP_SESSION_ID}.session"
    _HTTP_SESSION_ID=""
    _HTTP_SESSION=()
    http::cookie::delete "session_id"
}

# ==============================================================================
# STATIC FILES
# ==============================================================================

# Serve a static file with appropriate MIME type and path traversal guard.
# Usage: http::serve_file <path>
http::serve_file() {
    local path="$1" docroot resolved
    docroot="${HTTP_DOCROOT:-.}"

    # Resolve to absolute to prevent path traversal
    resolved=$(readlink -f "$path" 2>/dev/null) || resolved=$(realpath "$path" 2>/dev/null) || {
        http::error 500 "Cannot resolve path"
        return 1
    }

    local docroot_resolved
    docroot_resolved=$(readlink -f "$docroot" 2>/dev/null) || docroot_resolved=$(realpath "$docroot" 2>/dev/null) || docroot_resolved="$docroot"

    [[ "$resolved" == "$docroot_resolved"* ]] || {
        http::error 403 "Forbidden"
        return 1
    }

    [[ -f "$path" ]] && [[ -r "$path" ]] || {
        http::error 404 "File not found"
        return 1
    }

    local mime size
    mime=$(fs::mime_type "$path")
    size=$(fs::size "$path")

    _http::emit_status_line "200"
    _http::emit_header "Server" "bash-framehead"
    _http::emit_header "Content-Type" "$mime"
    _http::emit_header "Content-Length" "$size"
    printf '\r\n'
    cat "$path"
}

# ==============================================================================
# SSE (Server-Sent Events)
# ==============================================================================

# Start an SSE response (emits headers and flushes).
# Usage: http::sse::start
http::sse::start() {
    _http::emit_status_line "200"
    _http::emit_header "Server" "bash-framehead"
    _http::emit_header "Content-Type" "text/event-stream"
    _http::emit_header "Cache-Control" "no-cache"
    _http::emit_header "Connection" "keep-alive"
    _http::emit_header "X-Accel-Buffering" "no"
    printf '\r\n'
}

# Emit a Server-Sent Event.
# Usage: http::sse::event <type> <data>
http::sse::event() {
    local type="$1" data="$2"
    printf 'event: %s\ndata: %s\n\n' "$type" "$data"
}

# Start a background heartbeat (SSE comment) to keep the connection alive.
# Usage: http::sse::heartbeat [interval_seconds]
http::sse::heartbeat() {
    local interval="${1:-15}"
    ( while true; do
        sleep "$interval"
        printf ': heartbeat\n\n'
    done ) &
}

# ==============================================================================
# FILE UPLOADS
# ==============================================================================

# Parse multipart/form-data from _HTTP_BODY. Populates _HTTP_FILE_UPLOADS[]
# (field → content), _HTTP_FILE_UPLOAD_NAMES[] (field → filename),
# and _HTTP_FILE_UPLOAD_TYPES[] (field → content-type).
# Usage: http::upload::parse
http::upload::parse() {
    _HTTP_FILE_UPLOADS=()
    _HTTP_FILE_UPLOAD_NAMES=()
    _HTTP_FILE_UPLOAD_TYPES=()

    local content_type="${_HTTP_HEADERS[content-type]:-}"
    [[ "$content_type" == "multipart/form-data;"* ]] || return 1

    local boundary="${content_type#*boundary=}"
    boundary="${boundary%%;*}"
    [[ -z "$boundary" ]] && return 1

    local body="$_HTTP_BODY"
    local delim=$'\r\n'"--$boundary"
    local end_delim=$'\r\n'"--$boundary--"

    local part part_headers part_body fieldname filename part_ct
    local line key val

    # Split on boundary + CRLF (not the end boundary)
    local remaining="$body"
    # Strip leading boundary line (with or without leading \r\n)
    remaining="${remaining#*--$boundary$'\r\n'}"
    # Strip trailing end boundary (with optional -- and optional trailing \r\n)
    remaining="${remaining%"$end_delim"}"
    remaining="${remaining%"$end_delim"$'\r\n'}"
    remaining="${remaining%$'\r\n'--$boundary}"
    remaining="${remaining%$'\r\n'--$boundary$'\r\n'}"

    while [[ -n "$remaining" ]]; do
        # Extract next part
        if [[ "$remaining" == *"$delim"* ]]; then
            part="${remaining%%"$delim"}"
            remaining="${remaining#*"$delim"}"
            remaining="${remaining#$'\r\n'}"
        else
            part="$remaining"
            remaining=""
        fi

        [[ -z "$part" ]] && continue

        # Split part into headers and body
        if [[ "$part" == *$'\r\n\r\n'* ]]; then
            part_headers="${part%%$'\r\n\r\n'*}"
            part_body="${part#*$'\r\n\r\n'}"
        elif [[ "$part" == *$'\n\n'* ]]; then
            part_headers="${part%%$'\n\n'*}"
            part_body="${part#*$'\n\n'}"
        else
            continue
        fi

        # Parse Content-Disposition
        fieldname=""
        filename=""
        if [[ "$part_headers" =~ Content-Disposition:[[:space:]]*form-data[^$'\r\n']* ]]; then
            local disp="${BASH_REMATCH[0]}"
            if [[ "$disp" =~ name=\"([^\"]+)\" ]]; then
                fieldname="${BASH_REMATCH[1]}"
            fi
            if [[ "$disp" =~ filename=\"([^\"]+)\" ]]; then
                filename="${BASH_REMATCH[1]}"
            fi
        fi

        [[ -z "$fieldname" ]] && continue

        # Parse Content-Type for this part
        part_ct=""
        if [[ "$part_headers" =~ Content-Type:[[:space:]]*([^$'\r\n']+) ]]; then
            part_ct="${BASH_REMATCH[1]}"
            part_ct="${part_ct%%$'\r'}"
        fi

        _HTTP_FILE_UPLOADS["$fieldname"]="$part_body"
        _HTTP_FILE_UPLOAD_NAMES["$fieldname"]="$filename"
        _HTTP_FILE_UPLOAD_TYPES["$fieldname"]="$part_ct"
    done
}

# ==============================================================================
# SERVER
# ==============================================================================

# Start the HTTP server accept loop. Detects available listener:
# tcpserver (ucspi-tcp) > socat > nc.
# Usage: http::server::start [port]
http::server::start() {
    local port="${1:-8080}" script_path listener_cmd

    # Re-exec ourselves as the per-connection handler
    script_path="$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || realpath "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")"

    # Create a small dispatch script that sources framehead + routes then dispatches
    local dispatcher
    dispatcher=$(mktemp "/tmp/fsbshf-http-dispatcher.XXXXXX")
    cat > "$dispatcher" << 'DISPATCHER_EOF'
#!/usr/bin/env bash
# Auto-generated HTTP dispatcher — do not edit
source "${BASH_FRAMEHEAD_PATH:-./bash-framehead.sh}" 2>/dev/null || true
source "${HTTP_EXT_PATH}" 2>/dev/null || source "${0%/*}/http-server.sh" 2>/dev/null || true
http::parse_request
http::route::dispatch
DISPATCHER_EOF
    chmod +x "$dispatcher"

    if command -v tcpserver &>/dev/null; then
        listener_cmd="tcpserver -1 -o -l 0 -H -R -c 1000 0 $port $dispatcher"
    elif command -v socat &>/dev/null; then
        listener_cmd="socat TCP-LISTEN:$port,reuseaddr,fork EXEC:$dispatcher"
    elif command -v nc &>/dev/null; then
        echo "http::server::start: using nc — performance degraded, install tcpserver or socat" >&2
        listener_cmd="while true; do nc -l -p $port -e $dispatcher; done"
    else
        echo "http::server::start: no listener available" >&2
        rm -f "$dispatcher"
        return 1
    fi

    echo "HTTP server starting on port $port (listener: ${listener_cmd%% *})"
    eval "$listener_cmd" &
    _HTTP_SERVER_LISTENER_PID=$!

    # Register cleanup
    trap 'http::server::stop' EXIT
}

# Stop the server and clean up.
# Usage: http::server::stop
http::server::stop() {
    if [[ -n "${_HTTP_SERVER_LISTENER_PID:-}" ]]; then
        kill "$_HTTP_SERVER_LISTENER_PID" 2>/dev/null || true
        wait "$_HTTP_SERVER_LISTENER_PID" 2>/dev/null || true
        _HTTP_SERVER_LISTENER_PID=""
    fi
    rm -f /tmp/fsbshf-http-dispatcher.* 2>/dev/null || true
}
