# GET / — Home page
body=$(cat <<'BODY'
<h1>Bash::Framehead HTTP Server</h1>
<p>A lightweight HTTP server built entirely in Bash, powered by the <strong>Bash::Framehead</strong> standard library framework.</p>

<section>
<h2>Features</h2>
<div class="grid">
	<div class="card">
		<h3>Dynamic Routing</h3>
		<p>Exact, parameterized <code>[param]</code>, and catch-all <code>[...]</code> route patterns with automatic PATH_VARS extraction.</p>
		<a href="/hello/world">Try it &#8594;</a>
	</div>
	<div class="card">
		<h3>Form Handling</h3>
		<p>Parse URL-encoded and multipart form data with automatic field extraction.</p>
		<a href="/form">Try it &#8594;</a>
	</div>
	<div class="card">
		<h3>Server-Sent Events</h3>
		<p>Real-time streaming with native SSE support and keepalive heartbeats.</p>
		<a href="/sse">Try it &#8594;</a>
	</div>
	<div class="card">
		<h3>Session Management</h3>
		<p>File-based sessions with cookie handling, persistence, and automatic cleanup.</p>
		<a href="/api/counter">Try it &#8594;</a>
	</div>
	<div class="card">
		<h3>File Uploads</h3>
		<p>Multipart file upload parsing with filename and content-type extraction.</p>
		<a href="/upload">Try it &#8594;</a>
	</div>
	<div class="card">
		<h3>Static Files</h3>
		<p>Serve assets with automatic MIME detection and path traversal protection.</p>
		<a href="/static/style.css">View CSS &#8594;</a>
	</div>
</div>
</section>
BODY
)

http::respond 200 "$(_demo::page "Home" "$body")"
