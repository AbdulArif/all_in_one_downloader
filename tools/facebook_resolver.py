import json
import mimetypes
import os
import base64
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote, urlparse

import yt_dlp


HOST = os.environ.get("HOST", "127.0.0.1")
PORT = int(os.environ.get("PORT", "9000"))
STATIC_DIR = Path(
    os.environ.get(
        "STATIC_DIR",
        str(Path(__file__).resolve().parent.parent / "build" / "web"),
    )
).resolve()
YOUTUBE_COOKIES_FILE = Path("/tmp/youtube-cookies.txt")


def prepare_youtube_cookies():
    encoded = os.environ.get("YOUTUBE_COOKIES_B64", "").strip()
    if not encoded:
        return None
    YOUTUBE_COOKIES_FILE.write_bytes(base64.b64decode(encoded))
    return str(YOUTUBE_COOKIES_FILE)


YOUTUBE_COOKIES = prepare_youtube_cookies()


class ResolverHandler(BaseHTTPRequestHandler):
    def _headers(self, status=200, content_type="application/json"):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.end_headers()

    def _json(self, payload, status=200):
        self._headers(status)
        self.wfile.write(json.dumps(payload).encode())

    def do_OPTIONS(self):
        self._headers(204)

    def do_GET(self):
        path = urlparse(self.path).path
        if path == "/health":
            self._json({"status": "ok"})
            return
        self._serve_static(path)

    def do_POST(self):
        if urlparse(self.path).path not in ("/", "/api/resolve"):
            self._json({"error": {"code": "not found"}}, 404)
            return

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
            if "youtu.be" in source_url or "youtube.com" in source_url:
                options["extractor_args"] = {
                    "youtube": {
                        "player_client": ["android_vr"],
                        "player_skip": ["webpage", "configs"],
                    }
                }
                if YOUTUBE_COOKIES:
                    options["cookiefile"] = YOUTUBE_COOKIES
            with yt_dlp.YoutubeDL(options) as downloader:
                info = downloader.extract_info(source_url, download=False)

            media_url = info.get("url")
            if not media_url:
                raise ValueError("no downloadable media was found")
            self._json({"status": "redirect", "url": media_url})
        except Exception as error:
            self._json({"error": {"code": str(error)}}, 400)

    def _serve_static(self, request_path):
        relative_path = unquote(request_path).lstrip("/") or "index.html"
        candidate = (STATIC_DIR / relative_path).resolve()
        if STATIC_DIR not in candidate.parents and candidate != STATIC_DIR:
            self._headers(403, "text/plain")
            return
        if not candidate.is_file():
            candidate = STATIC_DIR / "index.html"
        if not candidate.is_file():
            self._json({"status": "ok", "message": "Flutter build not found"})
            return

        content_type = mimetypes.guess_type(candidate.name)[0] or "application/octet-stream"
        self._headers(200, content_type)
        self.wfile.write(candidate.read_bytes())

    def log_message(self, message, *args):
        print(f"[downloader] {message % args}")


if __name__ == "__main__":
    server = ThreadingHTTPServer((HOST, PORT), ResolverHandler)
    print(f"Downloader listening on http://{HOST}:{PORT}/")
    server.serve_forever()
