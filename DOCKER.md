# Docker deployment

This project uses a two-container Docker Compose setup.

## Runtime stack

- Frontend build: Node.js 24 Alpine
- Frontend runtime: Nginx 1.29 Alpine
- Backend runtime: Python 3.14 slim Bookworm
- ProjectDiscovery build toolchain: Go 1.26 Bookworm
- Security tools: Nmap, httpx, dnsx, tlsx, WAFW00F, WhatWeb, WHOIS

`httpx`, `dnsx`, and `tlsx` are compiled in a separate Go build stage and
only their binaries are copied into the final backend image. Go itself is
not required at runtime.

## Build

```bash
docker compose build --no-cache
```

## Start

```bash
docker compose up
```

Open:

```text
http://localhost:3000
```

## Verify all security tools

```bash
docker compose exec backend /app/docker/verify-tools.sh
```

The verification command checks:

```text
nmap
httpx
dnsx
tlsx
wafw00f
whatweb
whois
```

## Stop

```bash
docker compose down
```

The host only needs Docker with Compose support. The application runtime and
security tools are installed inside the containers.
