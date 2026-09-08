# START HERE

Phishing URL Detection and Security Intelligence System (FastAPI + React).

## Run in 2 terminals

```bash
# Terminal 1 — backend
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 5000

# Terminal 2 — frontend
cd frontend
npm install
npm run dev
```

Open http://localhost:3000

Full docs: [README.md](README.md) · Quick start: [QUICKSTART.md](QUICKSTART.md)

Note: `backend-node/` is the archived Express backend from an earlier version.
