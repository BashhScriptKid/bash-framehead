# GET /about
body=$(cat <<'BODY'
<h1>About</h1>
<p>This demo showcases the <code>ext/http-server</code> extension of Bash::Framehead, a comprehensive Bash standard library with ~785 functions across 16 modules.</p>

<section>
<h2>How It Works</h2>
<pre><code># Define a handler function
handle_hello() {
		http::respond 200 "Hello, ${PATH_VARS[name]}!"
}

# Register the route with a dynamic parameter
http::route::get "/hello/[name]" handle_hello

# Scan a directory for file-based route handlers
http::route::scan ./pages

# Start the server on port 8080
http::server::start 8080</code></pre>
</section>

<section>
<h2>Architecture</h2>
<ul>
	<li><strong>Request parsing</strong> via <code>http::parse_request</code> — method, path, headers, query params, cookies, form data, and body</li>
	<li><strong>Route dispatch</strong> via <code>http::route::dispatch</code> — exact, dynamic <code>[param]</code>, and catch-all <code>[...]</code> patterns</li>
	<li><strong>File-based routing</strong> via <code>http::route::scan</code> — directory of .sh files with METHOD.name.sh convention</li>
	<li><strong>Concurrent connections</strong> via <code>tcpserver</code> (ucspi-tcp) or <code>socat</code> fork model</li>
	<li><strong>Stateful singletons</strong> — cookies, sessions, and upload data in associative arrays</li>
</ul>
</section>

<section>
<h2>Requirements</h2>
<ul>
	<li>Bash 4.3+</li>
	<li>Bash::Framehead core (runtime, string, fs, log modules)</li>
	<li>At least one of: <code>tcpserver</code>, <code>socat</code>, or <code>nc</code></li>
</ul>
</section>
BODY
)

http::respond 200 "$(_demo::page "About" "$body")"
