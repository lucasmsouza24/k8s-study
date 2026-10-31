import json
import os
import signal
import sys
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

ALLOC_MB = int(os.getenv("ALLOC_MB", "100"))
STARTUP_SECONDS = int(os.getenv("STARTUP_SECONDS", "20"))

signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))

print(f"[boot] carregando cache em memória ({ALLOC_MB} MB)...", flush=True)
cache = b"x" * (ALLOC_MB * 1024 * 1024)

print(f"[boot] aquecendo conexões ({STARTUP_SECONDS}s)...", flush=True)
time.sleep(STARTUP_SECONDS)


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
            self._send(200, {"status": "ready", "cache_mb": len(cache) // (1024 * 1024)})
        elif self.path == "/":
            self._send(200, {"app": "k4", "pod": os.uname().nodename})
        else:
            self._send(404, {"error": "not found"})


print("[boot] pronto, ouvindo em :8000", flush=True)
ThreadingHTTPServer(("0.0.0.0", 8000), Handler).serve_forever()
