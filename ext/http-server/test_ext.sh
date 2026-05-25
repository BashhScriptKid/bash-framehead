#!/usr/bin/env bash
# test_ext.sh — ext/http-server test suite
#
# Sourced by the test runner after tester.sh and the extension are loaded.
# _pass / _fail / _assert / _assert_contains / _sub_done / _skip are in scope.

# ==============================================================================
# http::statuscode::what
# ==============================================================================

test::http::statuscode::what() {
		_assert "200 OK"            "OK"               "$(http::statuscode::what 200)"
		_assert "404 Not Found"     "Not Found"        "$(http::statuscode::what 404)"
		_assert "500 Server Error"  "Internal Server Error" "$(http::statuscode::what 500)"
		_assert "418 Teapot"        "I'm a teapot"     "$(http::statuscode::what 418)"
		_assert "unknown code"      "Unknown"          "$(http::statuscode::what 999)"
		_assert "default 200"       "OK"               "$(http::statuscode::what)"
		_sub_done
}

# ==============================================================================
# http::parse_request — GET with query
# ==============================================================================

test::http::parse_request() {
		http::parse_request <<< $'GET /hello?foo=bar&baz=qux HTTP/1.1\r\nHost: localhost\r\n\r\n'

		_assert "GET method"    "GET"       "$_HTTP_METHOD"
		_assert "path /hello"   "/hello"    "$_HTTP_PATH"
		_assert "HTTP version"  "HTTP/1.1"  "$_HTTP_VERSION"
		_assert "query foo"     "bar"       "${_HTTP_QUERY_PARAMS[foo]:-}"
		_assert "query baz"     "qux"       "${_HTTP_QUERY_PARAMS[baz]:-}"
		_assert "host header"   "localhost" "${_HTTP_HEADERS[host]:-}"
		_sub_done
}

# ==============================================================================
# http::respond
# ==============================================================================

test::http::respond() {
		local result
		result=$(http::respond 200 "Hello World")

		_assert_contains "status line"     "HTTP/1.1 200 OK"        "$result"
		_assert_contains "server header"   "Server: bash-framehead" "$result"
		_assert_contains "content-length"  "Content-Length: 11"     "$result"
		_assert_contains "body"            "Hello World"            "$result"
		_sub_done
}

# ==============================================================================
# http::header
# ==============================================================================

test::http::header() {
		local result
		result=$(http::header "X-Custom" "testval")
		# HTTP headers end with CRLF
		_assert_contains "header name:value" "X-Custom: testval" "$result"
		_sub_done
}

# ==============================================================================
# http::end_headers
# ==============================================================================

test::http::end_headers() {
		local result
		result=$(http::end_headers)
		# HTTP end-of-headers is \r\n, but $() strips trailing \n
		_assert "blank line" $'\r' "$result"
		_sub_done
}

# ==============================================================================
# http::redirect
# ==============================================================================

test::http::redirect() {
		local result
		result=$(http::redirect "/new-location")
		_assert_contains "302 status"  "HTTP/1.1 302"            "$result"
		_assert_contains "location"    "Location: /new-location"  "$result"
		_sub_done
}

# ==============================================================================
# http::error
# ==============================================================================

test::http::error() {
		local result
		result=$(http::error 404)
		_assert_contains "404 status"       "HTTP/1.1 404"              "$result"
		_assert_contains "reason phrase"    "Not Found"                 "$result"
		_assert_contains "content-type"     "Content-Type: text/plain"  "$result"
		_sub_done
}

# ==============================================================================
# http::route::get
# ==============================================================================

test::http::route::get() {
		http::route::get "/testroute" _tr_test_handler
		_assert "route registered" "_tr_test_handler" "${_HTTP_ROUTES[GET:/testroute]:-}"
		unset '_HTTP_ROUTES[GET:/testroute]'
		_sub_done
}

# ==============================================================================
# http::route::post
# ==============================================================================

test::http::route::post() {
		http::route::post "/submit" _tr_post_handler
		_assert "post route" "_tr_post_handler" "${_HTTP_ROUTES[POST:/submit]:-}"
		unset '_HTTP_ROUTES[POST:/submit]'
		_sub_done
}

# ==============================================================================
# http::route::put
# ==============================================================================

test::http::route::put() {
		http::route::put "/update" _tr_put_handler
		_assert "put route" "_tr_put_handler" "${_HTTP_ROUTES[PUT:/update]:-}"
		unset '_HTTP_ROUTES[PUT:/update]'
		_sub_done
}

# ==============================================================================
# http::route::delete
# ==============================================================================

test::http::route::delete() {
		http::route::delete "/remove" _tr_delete_handler
		_assert "delete route" "_tr_delete_handler" "${_HTTP_ROUTES[DELETE:/remove]:-}"
		unset '_HTTP_ROUTES[DELETE:/remove]'
		_sub_done
}

# ==============================================================================
# http::route::dispatch — exact match
# ==============================================================================

test::http::route::dispatch() {
		_tr_called=0
		_tr_exact_handler() { _tr_called=1; }

		http::route::get "/exact" _tr_exact_handler
		_HTTP_METHOD="GET"
		_HTTP_PATH="/exact"
		http::route::dispatch >/dev/null

		_assert "handler called" "1" "$_tr_called"
		unset _tr_called _tr_exact_handler
		unset '_HTTP_ROUTES[GET:/exact]'
		_sub_done
}

# ==============================================================================
# http::route::scan
# ==============================================================================

test::http::route::scan() {
		local tmpdir
		tmpdir=$(mktemp -d "/tmp/fsbshf-http-test-routes.XXXXXX")
		echo '#!/usr/bin/env bash' > "$tmpdir/index.sh"
		echo '#!/usr/bin/env bash' > "$tmpdir/hello.sh"

		http::route::scan "$tmpdir"
		_assert "index route" "source $tmpdir/index.sh" "${_HTTP_ROUTES[GET:/]:-}"
		_assert "hello route" "source $tmpdir/hello.sh" "${_HTTP_ROUTES[GET:/hello]:-}"
		rm -rf "$tmpdir"
		unset '_HTTP_ROUTES[GET:/]' '_HTTP_ROUTES[GET:/hello]'
		_sub_done
}

# ==============================================================================
# http::serve_file
# ==============================================================================

test::http::serve_file() {
		local result tmpfile
		tmpfile=$(mktemp "/tmp/fsbshf-http-test.XXXXXX")
		echo "hello static" > "$tmpfile"

		result=$(HTTP_DOCROOT="/tmp" http::serve_file "$tmpfile" 2>/dev/null)
		_assert_contains "serves content" "hello static" "$result"

		rm -f "$tmpfile"
		_sub_done
}

# ==============================================================================
# http::cookie::set
# ==============================================================================

test::http::cookie::set() {
		local result
		result=$(http::cookie::set "name" "value")
		_assert_contains "basic cookie"     "Set-Cookie"  "$result"
		_assert_contains "name=value"       "name=value"  "$result"
		_assert_contains "default path"     "Path=/"      "$result"
		_sub_done
}

# ==============================================================================
# http::cookie::parse
# ==============================================================================

test::http::cookie::parse() {
		http::cookie::parse "a=1; b=2"
		_assert "cookie a"  "1"  "${_HTTP_COOKIES[a]:-}"
		_assert "cookie b"  "2"  "${_HTTP_COOKIES[b]:-}"
		_sub_done
}

# ==============================================================================
# http::cookie::delete
# ==============================================================================

test::http::cookie::delete() {
		local result
		result=$(http::cookie::delete "sid")
		_assert_contains "max-age 0"     "Max-Age=0"        "$result"
		_assert_contains "deleted"       "sid=deleted"       "$result"
		_sub_done
}

# ==============================================================================
# http::session::start
# ==============================================================================

test::http::session::start() {
		_HTTP_COOKIES=()
		_HTTP_SESSION_ID=""
		http::session::start

		_assert_nonempty "session id set"     "${_HTTP_SESSION_ID:-}"
		_assert "session id length"           "32"  "${#_HTTP_SESSION_ID}"
		_sub_done
}

# ==============================================================================
# http::session::save
# ==============================================================================

test::http::session::save() {
		_HTTP_SESSION_ID="test-save-id"
		_HTTP_SESSION=([k1]="v1" [k2]="v2")
		http::session::save

		local sess_dir="${HTTP_SESSION_DIR:-/tmp/fsbshf-http-sessions}"
		_assert "session file exists" "0" "$([[ -f "$sess_dir/test-save-id.session" ]]; echo $?)"
		rm -f "$sess_dir/test-save-id.session"
		_sub_done
}

# ==============================================================================
# http::session::destroy
# ==============================================================================

test::http::session::destroy() {
		_HTTP_SESSION_ID="test-destroy-id"
		_HTTP_SESSION=([k]="v")
		local sess_dir="${HTTP_SESSION_DIR:-/tmp/fsbshf-http-sessions}"
		mkdir -p "$sess_dir"
		touch "$sess_dir/test-destroy-id.session"

		http::session::destroy
		_assert "session id cleared" "" "${_HTTP_SESSION_ID:-}"
		_sub_done
}

# ==============================================================================
# http::sse::start
# ==============================================================================

test::http::sse::start() {
		local result
		result=$(http::sse::start)
		_assert_contains "sse content-type"  "text/event-stream"   "$result"
		_assert_contains "no-cache"          "Cache-Control: no-cache" "$result"
		_sub_done
}

# ==============================================================================
# http::sse::event
# ==============================================================================

test::http::sse::event() {
		local result
		result=$(http::sse::event "update" "hello sse")
		_assert_contains "event type"  "event: update"   "$result"
		_assert_contains "event data"  "data: hello sse" "$result"
		_sub_done
}

# ==============================================================================
# http::sse::heartbeat
# ==============================================================================

test::http::sse::heartbeat() {
		http::sse::heartbeat 1
		local hb_pid=$!
		sleep 2
		kill "$hb_pid" 2>/dev/null || true
		wait "$hb_pid" 2>/dev/null || true
		_pass "heartbeat started and stopped"
		_sub_done
}

# ==============================================================================
# http::upload::parse
# ==============================================================================

test::http::upload::parse() {
		local boundary="----TestBoundary123"
		local body=$'------TestBoundary123\r\nContent-Disposition: form-data; name="file"; filename="test.txt"\r\nContent-Type: text/plain\r\n\r\nhello upload\r\n------TestBoundary123--\r\n'
		_HTTP_BODY="$body"
		_HTTP_HEADERS[content-type]="multipart/form-data; boundary=$boundary"

		http::upload::parse
		_assert "upload field"       "hello upload"  "${_HTTP_FILE_UPLOADS[file]:-}"
		_assert "upload filename"    "test.txt"      "${_HTTP_FILE_UPLOAD_NAMES[file]:-}"
		_assert "upload content-type" "text/plain"   "${_HTTP_FILE_UPLOAD_TYPES[file]:-}"
		_sub_done
}

# ==============================================================================
# http::server::start
# ==============================================================================

test::http::server::start() {
		_skip "requires tcpserver/socat/nc listener"
}

# ==============================================================================
# http::server::stop
# ==============================================================================

test::http::server::stop() {
		_HTTP_SERVER_LISTENER_PID=""
		http::server::stop
		_pass "stop with no pid is safe"
		_sub_done
}

# ==============================================================================
# http::global — edge cases
# ==============================================================================

test::http::global() {
		# Malformed request method survives
		http::parse_request <<< $'INVALID\r\n\r\n' 2>/dev/null
		if [[ "$_HTTP_METHOD" == "INVALID" ]]; then
				_sub_pass "malformed request method survived"
		else
				_sub_fail "malformed request method"
		fi

		# Empty cookie
		http::cookie::parse ""
		if [[ ${#_HTTP_COOKIES[@]} -eq 0 ]]; then
				_sub_pass "empty cookie yields no cookies"
		else
				_sub_fail "empty cookie should yield no cookies"
		fi

		# Path traversal rejection
		local result
		result=$(http::serve_file "/etc/passwd" 2>/dev/null || true)
		if [[ "$result" == *"Forbidden"* ]] || [[ "$result" == *"403"* ]]; then
				_sub_pass "path traversal rejected"
		else
				_sub_fail "path traversal should be rejected"
		fi

		# 500 with custom message
		result=$(http::error 500 "boom")
		if [[ "$result" == *"boom"* ]]; then
				_sub_pass "error 500 with custom message"
		else
				_sub_fail "error 500 custom message"
		fi

		_sub_done
}

test::http::header::get() {
		http::parse_request <<< $'GET / HTTP/1.1\r\nHost: localhost\r\nX-Custom: testval\r\n\r\n'
		local v; v=$(http::header::get "host")
		_assert "host header" "localhost" "$v"
		local v2; v2=$(http::header::get "x-custom")
		_assert "custom header" "testval" "$v2"
		local v3; v3=$(http::header::get "missing-header")
		_assert "missing header" "" "$v3"
		_sub_done
}

test::http::html_encode() {
		local out; out=$(http::html_encode '<script>alert("xss")</script>')
		_assert "html encode" '&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;' "$out"
		_sub_done
}
