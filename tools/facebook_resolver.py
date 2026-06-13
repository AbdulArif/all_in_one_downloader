import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

import yt_dlp


HOST = "127.0.0.1"
PORT = 9000


class ResolverHandler(BaseHTTPRequestHandler):
    def _headers(self, status=200):
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.end_headers()

    def do_OPTIONS(self):
        self._headers(204)

    def do_GET(self):
        self._headers()
        self.wfile.write(json.dumps({"status": "ok"}).encode())

    def do_POST(self):
        try:
            length = int(self.headers.get("Content-Length", "0"))
            payload = json.loads(self.rfile.read(length) or b"{}")
            source_url = str(payload.get("url", "")).strip()
            if not source_url:
                raise ValueError("missing url")

            options = {
                "quiet": True,
                "no_warnings": True,
                "format": "best[ext=mp4]/best",
                "noplaylist": True,
            }
            with yt_dlp.YoutubeDL(options) as downloader:
                info = downloader.extract_info(source_url, download=False)

            media_url = info.get("url")
            if not media_url:
                raise ValueError("no downloadable media was found")

            self._headers()
            self.wfile.write(
                json.dumps({"status": "redirect", "url": media_url}).encode()
            )
        except Exception as error:
            self._headers(400)
            self.wfile.write(
                json.dumps({"error": {"code": str(error)}}).encode()
            )

    def log_message(self, message, *args):
        print(f"[facebook-resolver] {message % args}")


if __name__ == "__main__":
    server = ThreadingHTTPServer((HOST, PORT), ResolverHandler)
    print(f"Facebook resolver listening on http://{HOST}:{PORT}/")
    server.serve_forever()
