# GET /upload — file upload form
body=$(cat <<'BODY'
<h1>File Upload Demo</h1>
<p>Upload a file to test <strong>multipart/form-data</strong> parsing via <code>http::upload::parse</code>. The handler extracts the filename, content type, and file size from the parsed upload.</p>

<form method="POST" action="/upload" enctype="multipart/form-data">
	<label for="description">Description</label>
	<input type="text" id="description" name="description" placeholder="What is this file?">

	<label for="file">File</label>
	<input type="file" id="file" name="file" required>

	<button type="submit">Upload</button>
</form>
BODY
)

http::respond 200 "$(_demo::page "Upload" "$body")"
