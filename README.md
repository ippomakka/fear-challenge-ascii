# Break The Glass — 7 Day Fear Challenge

A self-contained red/black/white ASCII tracker for a 7-day fear challenge.

## Run locally

```bash
cd /Users/ippo/projects/fear-challenge-ascii
python3 -m http.server 8788 --bind 127.0.0.1
```

Open: http://127.0.0.1:8788/index.html

## What it does

- User enters their main fear.
- Seven daily check-ins save in browser localStorage.
- ASCII glass barrier cracks more each completed day.
- Final report calculates days logged, words written, longest streak, action/emotion signals.
- Freedom animation plays at the end with flying ASCII shards.

No backend, login, database, or external dependencies.
