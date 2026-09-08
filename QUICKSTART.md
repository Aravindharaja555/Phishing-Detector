# Quick Start

## Backend (FastAPI)

```bash
cd backend
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 5000
```

## Frontend (React + Vite)

```bash
cd frontend
npm install
npm run dev
```

Open http://localhost:3000

## Smoke test

```bash
chmod +x test-api.sh
./test-api.sh
```

Optional scanners (Nmap, httpx, dnsx, tlsx, WAFW00F, WhatWeb) are detected automatically. See README.md for install notes.

The archived Node/Express backend lives in `backend-node/` and is not required to run the app.
