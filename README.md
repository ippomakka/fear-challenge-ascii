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
- Seven daily check-ins save in browser localStorage for guest mode.
- Supabase magic-link sign-in can sync challenge/check-in data across devices.
- ASCII glass barrier cracks more each completed day.
- Final report calculates days logged, words written, longest streak, action/emotion signals.
- Freedom animation plays at the end with flying ASCII shards.

## Supabase setup

Project URL configured in `index.html`:

```txt
https://cvjuqwmdlrwirxztjgwo.supabase.co
```

Run `supabase/schema.sql` once in the Supabase SQL Editor. It creates:

- `challenges`
- `checkins`
- `reports`
- RLS policies so users can only read/write their own rows

In Supabase Auth settings, add this Cloudflare URL to allowed redirect URLs:

```txt
https://fear-challenge-ascii.pages.dev
```

The public publishable key is embedded client-side. Do not embed the service-role key.
