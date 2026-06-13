FROM ghcr.io/cirruslabs/flutter:stable AS flutter-build

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

FROM python:3.12-slim

ENV HOST=0.0.0.0 \
    PORT=10000 \
    STATIC_DIR=/app/static \
    PYTHONUNBUFFERED=1

WORKDIR /app
RUN pip install --no-cache-dir yt-dlp
COPY --from=flutter-build /app/build/web /app/static
COPY tools/facebook_resolver.py /app/server.py

EXPOSE 10000
CMD ["python", "/app/server.py"]
