# ext/http-server — Bash HTTP Server

A lightweight HTTP server built on top of bash-framehead. Provides request
parsing, response generation, routing (function registration with file-based
fallback), cookie management, session support, SSE, and file upload handling.

## Dependencies

- **bash-framehead core**: runtime, string, fs, log
- **External**: at least one of `tcpserver` (ucspi-tcp), `socat`, or `nc` (netcat)

## Usage

```bash
source ./bash-framehead.sh
source ./ext/http-server/http-server.sh

# Define handlers
handle_home() { http::respond 200 "Welcome to bash-framehead HTTP server"; }
handle_api() { http::respond 200 "Hello, ${PATH_VARS[name]}!"; }

# Register routes
http::route::get "/" handle_home
http::route::get "/api/hello/[name]" handle_api

# Start server
http::server::start 8080
```

## API Reference

### Status Codes

#### `http::statuscode::what <code>`
Look up the reason phrase for an HTTP status code.
```bash
http::statuscode::what 404    # "Not Found"
http::statuscode::what 200    # "OK"
http::statuscode::what 999    # "Unknown"
```

### Request Parsing

#### `http::parse_request`
Parse a raw HTTP request from stdin. Populates these globals:

| Variable | Description |
|---|---|
| `_HTTP_METHOD` | GET, POST, PUT, DELETE, etc. |
| `_HTTP_PATH` | Request path (query string stripped) |
| `_HTTP_VERSION` | HTTP/1.1 |
| `_HTTP_HEADERS[]` | Associative array, lowercase keys |
| `_HTTP_QUERY_PARAMS[]` | Query string key/value pairs (URL-decoded) |
| `_HTTP_COOKIES[]` | Cookie key/value pairs |
| `_HTTP_FORM_DATA[]` | URL-encoded form body (POST) |
| `_HTTP_BODY` | Raw request body |

### Response

#### `http::respond <code> [body]`
Emit a complete HTTP response with status line, Server header, and optional body.
```bash
http::respond 200 "Hello"            # 200 with body
http::respond 204                    # 204 no content
```

#### `http::header <name> <value>`
Emit a single header line. Use between a body-less `http::respond` and
`http::end_headers` for custom responses.

#### `http::end_headers`
Terminate the header block (emits blank line).

#### `http::redirect <url> [code]`
Emit a redirect response (default 302).
```bash
http::redirect "/new-location"
http::redirect "/permanent" 301
```

#### `http::error <code> [msg]`
Emit an error response with text/plain body.
```bash
http::error 404 "Page not found"
http::error 500
```

### Routing

#### `http::route::get <path> <function>`
Register a GET route handler. Function receives the request (globals populated)
and can access `PATH_VARS[]` for dynamic segments.
```bash
http::route::get "/users/[id]" handle_user
```

#### `http::route::post <path> <function>`
Register a POST route handler.

#### `http::route::put <path> <function>`
Register a PUT route handler.

#### `http::route::delete <path> <function>`
Register a DELETE route handler.

#### Route patterns
- **Literal**: `/` or `/api/status` — exact match
- **Dynamic**: `/users/[id]` — captures `id` into `PATH_VARS[id]`
- **Catch-all**: `/files/[...]` — captures remainder into `PATH_VARS[splat]`

#### `http::route::scan <dir>`
Auto-register routes from `.sh` files in a directory (bash-stack compatible).
Files named `index.sh` map to `GET /`, `api/hello.sh` to `GET /api/hello`.
Files prefixed with `METHOD.` (e.g., `POST.create.sh`) register that method.
```bash
http::route::scan ./pages
```

#### `http::route::dispatch`
Match and dispatch the current request to the registered handler. Called
automatically by the server accept loop.

### Static Files

#### `http::serve_file <path>`
Serve a file with appropriate MIME type. Includes path traversal protection
(via `HTTP_DOCROOT`). Rejects paths that escape the document root.
```bash
http::serve_file ./static/index.html
```

### Cookies

#### `http::cookie::set <name> <value> [max-age] [path] [domain] [secure] [httponly] [samesite]`
Emit a `Set-Cookie` header.
```bash
http::cookie::set "token" "abc123"
http::cookie::set "token" "abc123" "3600" "/" "" "1" "1" "Lax"
```

#### `http::cookie::parse <raw_cookie_header>`
Parse a Cookie header value into `_HTTP_COOKIES[]`.

#### `http::cookie::delete <name>`
Send a deletion cookie (Max-Age=0).

### Sessions

Session files stored as tab-delimited key/value pairs under
`HTTP_SESSION_DIR` (default: `/tmp/fsbshf-http-sessions`).

#### `http::session::start`
Create or resume a session. Populates `_HTTP_SESSION[]` and `_HTTP_SESSION_ID`.
Sends a `Set-Cookie` for new sessions.

#### `http::session::save`
Persist `_HTTP_SESSION[]` to disk.

#### `http::session::destroy`
Remove session file, clear state, send deletion cookie.

### SSE (Server-Sent Events)

#### `http::sse::start`
Emit SSE response headers (Content-Type: text/event-stream).

#### `http::sse::event <type> <data>`
Emit an SSE event in wire format.
```bash
http::sse::event "update" "{\"status\": \"done\"}"
```

#### `http::sse::heartbeat [interval]`
Start a background keepalive (SSE comment every N seconds, default 15).

### File Uploads

#### `http::upload::parse`
Parse multipart/form-data body. Populates `_HTTP_FILE_UPLOADS[]` (field → content),
`_HTTP_FILE_UPLOAD_NAMES[]` (field → filename), and `_HTTP_FILE_UPLOAD_TYPES[]`
(field → content-type).

### Server

#### `http::server::start [port]`
Start the HTTP accept loop. Detects available listener (tcpserver > socat > nc).
```bash
http::server::start 8080
```

#### `http::server::stop`
Graceful shutdown. Registered automatically on EXIT.

## Limitations

- **Single-threaded per process**: concurrency via `tcpserver`/`socat fork` model
- **No HTTPS**: TLS termination should be handled by a reverse proxy (nginx, caddy)
- **Request body limit**: practical limit ~10 MB (Bash string capacity)
- **No WebSocket support**: use SSE for server-pushed events
- **Session storage is plaintext**: file-based, no encryption — not suitable for secrets
- **`nc` listener is serial**: only one connection at a time; use tcpserver or socat
  for concurrent connections
