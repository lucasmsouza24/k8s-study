import json
import os
import signal
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

import redis

r = redis.Redis(host=os.getenv("REDIS_HOST", "localhost"), port=6379, socket_timeout=2)


class Handler(BaseHTTPRequestHandler):
    def _send(self, code, body):
        payload = json.dumps(body).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self):
        try:
            if self.path == "/hit":
                self._send(200, {"hits": r.incr("hits")})
            elif self.path == "/hits":
                self._send(200, {"hits": int(r.get("hits") or 0)})
            elif self.path == "/health":
                r.ping()
                self._send(200, {"status": "ok"})
            elif self.path == "/crash":
                print("crash solicitado, encerrando com exit code 1", flush=True)
                os._exit(1)
            else:
                self._send(404, {"error": "not found"})
        except redis.RedisError as e:
            self._send(503, {"error": f"redis indisponível: {e}"})


signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
print(f"ouvindo em :8080, redis em {r.connection_pool.connection_kwargs['host']}", flush=True)
ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
