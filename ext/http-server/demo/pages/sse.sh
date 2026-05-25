# GET /sse — SSE demo page
body=$(cat <<'BODY'
<h1>SSE Demo</h1>
<p>Real-time <strong>Server-Sent Events</strong> streamed from a Bash handler. The page connects to <code>/api/sse-stream</code> which emits 20 tick events at 1-second intervals, plus a keepalive heartbeat every 10 seconds.</p>

<div id="sse-output" class="sse-box">
	<p>Connecting to /api/sse-stream...</p>
</div>

<script>
const output = document.getElementById("sse-output");
const evtSource = new EventSource("/api/sse-stream");
let count = 0;

evtSource.addEventListener("tick", function(e) {
	const data = JSON.parse(e.data);
	count = data.count;
	const p = document.createElement("p");
	p.textContent = "Tick #" + data.count + " — " + data.time;
	output.appendChild(p);
	output.scrollTop = output.scrollHeight;
});

evtSource.addEventListener("done", function(e) {
	const p = document.createElement("p");
	p.className = "done";
	p.textContent = "Stream complete after " + count + " events.";
	output.appendChild(p);
	evtSource.close();
});

evtSource.onerror = function() {
	if (evtSource.readyState === EventSource.CLOSED) {
		const p = document.createElement("p");
		p.className = "error";
		p.textContent = "Connection closed.";
		output.appendChild(p);
	}
};
</script>
BODY
)

http::respond 200 "$(_demo::page "SSE" "$body")"
