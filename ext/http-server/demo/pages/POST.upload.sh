# POST /upload — handle multipart file upload
http::upload::parse

description="${_HTTP_FILE_UPLOADS[description]:-N/A}"
filename="${_HTTP_FILE_UPLOAD_NAMES[file]:-N/A}"
filetype="${_HTTP_FILE_UPLOAD_TYPES[file]:-N/A}"
file_content="${_HTTP_FILE_UPLOADS[file]:-}"
filesize="${#file_content}"

# Escape for HTML
description="${description//</&lt;}"
description="${description//>/&gt;}"
filename="${filename//</&lt;}"
filename="${filename//>/&gt;}"
filetype="${filetype//</&lt;}"
filetype="${filetype//>/&gt;}"

body=$(cat <<BODY
<h1>File Uploaded</h1>
<p>The handler called <code>http::upload::parse</code> to decode the multipart body. Results are in <code>_HTTP_FILE_UPLOADS[]</code>, <code>_HTTP_FILE_UPLOAD_NAMES[]</code>, and <code>_HTTP_FILE_UPLOAD_TYPES[]</code>.</p>

<section>
<h2>Upload Details</h2>
<table>
  <tr><th>Field</th><th>Value</th></tr>
  <tr><td>description</td><td><code>${description}</code></td></tr>
  <tr><td>filename</td><td><code>${filename}</code></td></tr>
  <tr><td>content-type</td><td><code>${filetype}</code></td></tr>
  <tr><td>size</td><td><code>${filesize} bytes</code></td></tr>
</table>
</section>

<p><a href="/upload">&#8592; Back to upload</a></p>
BODY
)

http::respond 200 "$(_demo::page "Uploaded" "$body")"
