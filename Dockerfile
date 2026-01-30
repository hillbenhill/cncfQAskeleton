FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1     PYTHONUNBUFFERED=1

# Create non-root user
RUN useradd -m -u 10001 appuser
WORKDIR /app

# Copy demo app (static site). Replace with your real app code.
COPY app/ /app

EXPOSE 8000

# Healthcheck (simple TCP test). Adjust for your app.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3   CMD python -c "import socket; s=socket.socket(); s.settimeout(2); s.connect(('127.0.0.1',8000)); s.close()" || exit 1

USER appuser

# Simple static server
CMD ["python", "-c", "import http.server, socketserver; socketserver.TCPServer.allow_reuse_address=True; http.server.ThreadingHTTPServer(('',8000), http.server.SimpleHTTPRequestHandler).serve_forever()"]
