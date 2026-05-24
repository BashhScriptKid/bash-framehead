# GET /form
body=$(cat <<'BODY'
<h1>Form Demo</h1>
<p>Submit this form to see <strong>URL-encoded form parsing</strong> in action. The handler reads <code>_HTTP_FORM_DATA[]</code> populated by <code>http::parse_request</code>.</p>

<form method="POST" action="/submit">
  <label for="name">Name</label>
  <input type="text" id="name" name="name" placeholder="Enter your name" required>

  <label for="email">Email</label>
  <input type="email" id="email" name="email" placeholder="you@example.com">

  <label for="message">Message</label>
  <textarea id="message" name="message" rows="4" placeholder="Your message..."></textarea>

  <button type="submit">Submit</button>
</form>
BODY
)

http::respond 200 "$(_demo::page "Form" "$body")"
