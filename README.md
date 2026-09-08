# Phishing URL Detection and Security Intelligence System

A practical cybersecurity application that accepts a URL, runs multi-layer local analysis (URL heuristics, DNS/IP, HTTP/TLS, WHOIS/RDAP, and optional open-source scanners), correlates evidence, and produces an **explainable phishing-risk score**.

This is a personal college / final-year / interview / resume project intended for **authorized testing, demonstrations, learning, and portfolio use**.

> This is a heuristic security analyzer. It does **not** guarantee that a URL is safe or malicious.

---

## Problem Statement

Phishing remains a common cyber threat. Users and analysts often need a transparent way to inspect a suspicious link using free/local tooling—without depending on commercial threat-intelligence APIs.

## Objectives

- Accept a URL and validate it safely
- Collect multi-layer technical and security evidence using local/open-source tools
- Correlate findings into normalized security indicators
- Produce an explainable 0–100 risk score and a clear verdict
- Remain functional even when optional tools are missing

## Verdict Labels

| Verdict | Meaning |
|---------|---------|
| **LIKELY SAFE** | Few or no strong risk indicators |
| **SUSPICIOUS** | Multiple moderate indicators |
| **HIGHLY SUSPICIOUS** | Strong combined evidence |

Never interpret these as “100% safe” or “100% phishing”.

---

## Features

- URL validation & structure analysis
- Domain / DNS / IP intelligence (`socket`, `ipaddress`, `dnspython`, optional `dnsx`)
- HTTP analysis (`requests`) + optional ProjectDiscovery `httpx`
- TLS/certificate analysis (`ssl`) + optional `tlsx`
- WHOIS + public RDAP
- Conservative Nmap service discovery (optional)
- WAF detection via WAFW00F (optional, informational)
- Technology detection via WhatWeb (optional)
- Explainable risk engine with scored indicators
- SSRF protections (localhost / private / metadata blocked)
- Parallel analyzer execution with per-tool error isolation
- React dashboard with tool availability status

---

## Architecture

```text
URL
 ↓
URL Validation
 ↓
URL Structure Analysis
 ↓
Domain Analysis
 ↓
DNS Analysis (+ dnsx)
 ↓
IP Analysis
 ↓
HTTP Analysis (+ httpx)
 ↓
TLS/Certificate Analysis (+ tlsx)
 ↓
WHOIS / RDAP
 ↓
Nmap / WhatWeb / WAFW00F
 ↓
Security Indicator Correlation
 ↓
Risk Scoring Engine
 ↓
Explainable Verdict → Frontend Dashboard
```

### Stack

| Layer | Technology |
|-------|------------|
| Frontend | React, Vite, modern CSS |
| Backend | Python, FastAPI, Uvicorn |
| Core libs | `urllib.parse`, `socket`, `ssl`, `ipaddress`, `requests`, `dnspython`, `python-whois` |
| Optional tools | Nmap, httpx, dnsx, tlsx, WAFW00F, WhatWeb, whois CLI |

The previous Node/Express backend is preserved under `backend-node/` for reference. The active API is Python FastAPI.

---

## Security Tools (purpose)

| Tool | Purpose |
|------|---------|
| **Nmap** | Basic authorized service/port discovery on the resolved host |
| **httpx** | HTTP probing: status, title, server, tech hints |
| **dnsx** | Enriched DNS record collection |
| **tlsx** | TLS metadata, cert subject/issuer/SAN/fingerprint |
| **WAFW00F** | Detect presence/vendor of a WAF (informational only) |
| **WhatWeb** | Web technology / CMS / framework fingerprinting |
| **WHOIS** | Registrar and registration timeline context |
| **RDAP** | Structured public registration data complementary to WHOIS |

Missing tools never crash the app; they return `status: unavailable`.

---

## Risk Scoring Methodology

Score range: **0–100**

| Score | Level | Verdict |
|------:|-------|---------|
| 0–24 | LOW | LIKELY SAFE |
| 25–49 | MODERATE | SUSPICIOUS |
| 50–74 | HIGH | SUSPICIOUS |
| 75–100 | HIGHLY SUSPICIOUS | HIGHLY SUSPICIOUS |

### Example weight guidance

- **HIGH**: IP-as-hostname, severe obfuscation, `@` userinfo, long redirect abuse, cert mismatch/expiry
- **MEDIUM**: HTTP (not HTTPS), suspicious keywords, excessive subdomains, odd ports, punycode, very new domains
- **LOW**: long URL, many parameters, many hyphens
- **INFO (no score)**: WAF detected

Keywords alone never classify a URL as phishing. A TLD alone never determines the verdict.

---

## API

### `POST /api/analyze`

```json
{ "url": "https://example.com" }
```

Response sections include: `url`, `domain`, `ip`, `dns`, `http`, `tls`, `whois`, `rdap`, `nmap`, `httpx`, `dnsx`, `tlsx`, `waf`, `technology`, `indicators`, `risk`, `tools`.

### `GET /api/tools`

Returns local tool availability.

### `GET /health`

Health check.

---

## Installation

### Prerequisites

- Python 3.10+
- Node.js 18+
- Optional security tools listed below

### Backend setup

```bash
cd backend
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 5000
```

### Frontend setup

```bash
cd frontend
npm install
npm run dev
```

Open **http://localhost:3000**

The Vite dev server proxies `/api` and `/health` to the backend on port 5000.

---

## Optional tool installation

### Linux (Arch / Debian-style examples)

```bash
# Nmap + whois
sudo pacman -S nmap whois          # Arch
# sudo apt install nmap whois      # Debian/Ubuntu

# ProjectDiscovery tools (requires Go)
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install -v github.com/projectdiscovery/tlsx/cmd/tlsx@latest
# Ensure ~/go/bin is on PATH

# WAFW00F
pipx install wafw00f
# or: pip install wafw00f

# WhatWeb (Ruby)
# Arch: sudo pacman -S whatweb
# Debian: sudo apt install whatweb
```

### Windows (practical notes)

- Install Python + Node from official installers
- Nmap: https://nmap.org/download.html
- ProjectDiscovery tools via Go (`go install ...`) and add `%USERPROFILE%\go\bin` to PATH
- WHOIS: use `python-whois` (already in requirements); CLI whois optional
- WhatWeb/WAFW00F are easiest under WSL

---

## Example output (abbreviated)

```json
{
  "risk": {
    "score": 35,
    "level": "MODERATE",
    "verdict": "SUSPICIOUS",
    "explanation": "Heuristic score based on correlated local analysis signals..."
  },
  "indicators": [
    {
      "id": "url_http",
      "severity": "MEDIUM",
      "category": "URL",
      "title": "HTTP Instead of HTTPS",
      "score_contribution": 10
    }
  ]
}
```

---

## SSRF / safety controls

The analyzer blocks:

- localhost / loopback
- private IPv4/IPv6
- link-local
- cloud metadata endpoints (e.g. `169.254.169.254`)

Also enforced:

- request timeouts
- response size limits
- limited redirects
- tool execution timeouts
- no brute force, exploitation, credential submission, or destructive scans

Only the host associated with the submitted URL is analyzed.

---

## Limitations

- Heuristic only — false positives/negatives are possible
- Optional scanners may be absent on a given machine
- WHOIS/RDAP privacy redaction is common and not treated as malicious
- Nmap coverage is intentionally conservative
- No commercial threat intel (VirusTotal, URLScan, Shodan, etc.) by design

## Future improvements

- Historical analysis cache
- Optional passive DNS sources that remain free/local
- Exportable PDF/JSON reports
- Browser extension wrapper for authorized demos

---

## Project layout

```text
phishing-url-detector/
├── frontend/                 # React + Vite dashboard
├── backend/                  # FastAPI app
│   ├── app/
│   │   ├── main.py
│   │   ├── api/
│   │   ├── analyzers/
│   │   ├── scoring/
│   │   ├── models/
│   │   ├── services/
│   │   └── utils/
│   └── requirements.txt
├── backend-node/             # Previous Express backend (archived)
└── README.md
```

## License

MIT — for educational and authorized security research use.
