#!/usr/bin/env bash
# Demo routes — sourced by the dispatcher on every request.
# Defines helper functions, scans file-based pages, and registers dynamic routes.

if [[ -z "${_DEMO_DIR:-}" ]]; then
		_DEMO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

source "$_DEMO_DIR/../http-server.sh"

# ── Route scan for file-based pages ──

http::route::scan "$_DEMO_DIR/pages"

# ── HTML shell helpers ──

_DEMO_TITLE="Bash::Framehead HTTP Server"

_demo::html_top() {
		local title="$1"
		cat <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>$title — $_DEMO_TITLE</title>
<link rel="stylesheet" href="/static/style.css">
</head>
<body>
<nav>
	<a href="/">Home</a>
	<a href="/about">About</a>
	<a href="/form">Form</a>
	<a href="/sse">SSE</a>
	<a href="/upload">Upload</a>
	<a href="/redirect">Redirect</a>
	<a href="/api/status">API</a>
</nav>
<main>
HTML
}

_demo::html_bottom() {
		cat <<HTML
</main>
<footer>
	<p>Powered by <strong>Bash::Framehead</strong> &mdash; a Bash standard library</p>
</footer>
</body>
</html>
HTML
}

_demo::page() {
		local title="$1" body="$2"
		_demo::html_top "$title"
		printf '%s\n' "$body"
		_demo::html_bottom
}

# ── Static file serving ──

http::route::get "/static/[...]" _demo::serve_static
_demo::serve_static() {
		HTTP_DOCROOT="$_DEMO_DIR/static" http::serve_file "$_DEMO_DIR/static${PATH_VARS[splat]}"
}

# ── Dynamic route: hello/[name] ──

http::route::get "/hello/[name]" _demo::hello
_demo::hello() {
		local name="${PATH_VARS[name]}"
		name="${name//</&lt;}"
		name="${name//>/&gt;}"
		local body
		body=$(cat <<HTML
<h1>Hello, ${name}!</h1>
<p>This page demonstrates <strong>dynamic routing</strong> with path parameters.</p>
<pre><code>PATH_VARS[name] = ${name}</code></pre>
<p><a href="/hello/world">Try /hello/world</a> &bull; <a href="/hello/bash">Try /hello/bash</a></p>
HTML
)
		http::respond 200 "$(_demo::page "Hello" "$body")"
}

# ── JSON API status ──

http::route::get "/api/status" _demo::api_status
_demo::api_status() {
		local body
		body='{"server":"Bash::Framehead","version":"1.0","status":"ok"}'
		http::header "Content-Type" "application/json"
		http::respond 200 "$body"
}

# ── Session counter ──

http::route::get "/api/counter" _demo::counter
_demo::counter() {
		http::session::start
		local count="${_HTTP_SESSION[visits]:-0}"
		count=$((count + 1))
		_HTTP_SESSION[visits]="$count"
		http::session::save
		http::header "Content-Type" "application/json"
		http::respond 200 "{\"visits\":$count,\"session_id\":\"$_HTTP_SESSION_ID\"}"
}

# ── SSE stream ──

http::route::get "/api/sse-stream" _demo::sse_stream
_demo::sse_stream() {
		http::sse::start

		local i=1
		while (( i <= 20 )); do
				printf 'event: tick\ndata: {"count":%d,"time":"%s"}\n\n' \
						"$i" "$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S%z')"
				sleep 1
				((i++))
		done

		printf 'event: done\ndata: {"message":"stream complete"}\n\n'
}
