import json
import os
import signal
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

TOKEN_FILE = "/etc/web/token"


def token_loaded():
    try:
        with open(TOKEN_FILE) as f:
            return len(f.read().strip()) > 0
    except OSError:
        return False


class Handler(BaseHTTPRequestHandler):
    def _send(self, code, body):
        payload = json.dumps(body).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self):
        if self.path == "/healthz":
            self._send(200, {"status": "alive"})
        elif self.path == "/ready":
            self._send(200, {"status": "ready"})
        elif self.path == "/":
            self._send(200, {
                "app": "web",
                "color": os.getenv("APP_COLOR"),
                "token_loaded": token_loaded(),
                "uid": os.getuid(),
                "pod": os.uname().nodename,
            })
        else:
            self._send(404, {"error": "not found"})


signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
print("ouvindo em :8000", flush=True)
ThreadingHTTPServer(("0.0.0.0", 8000), Handler).serve_forever()
