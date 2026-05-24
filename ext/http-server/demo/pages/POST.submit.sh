# POST /submit — handle URL-encoded form
name="${_HTTP_FORM_DATA[name]:-Anonymous}"
email="${_HTTP_FORM_DATA[email]:-N/A}"
message="${_HTTP_FORM_DATA[message]:-No message}"

# Basic XSS prevention
name="${name//</&lt;}"
name="${name//>/&gt;}"
email="${email//</&lt;}"
email="${email//>/&gt;}"
message="${message//</&lt;}"
message="${message//>/&gt;}"

body=$(cat <<BODY
<h1>Form Submitted</h1>
<p>The handler received the form data via <code>_HTTP_FORM_DATA[]</code>, populated automatically by <code>http::parse_request</code> for <code>application/x-www-form-urlencoded</code> bodies.</p>

<section>
<h2>Parsed Fields</h2>
<table>
  <tr><th>Field</th><th>Value</th></tr>
  <tr><td>name</td><td><code>${name}</code></td></tr>
  <tr><td>email</td><td><code>${email}</code></td></tr>
  <tr><td>message</td><td><code>${message}</code></td></tr>
</table>
</section>

<p><a href="/form">&#8592; Back to form</a></p>
BODY
)

http::respond 200 "$(_demo::page "Submitted" "$body")"
