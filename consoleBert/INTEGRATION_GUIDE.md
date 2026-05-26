# Integration Guide for the Backend Experiment UI

## Boundary

Do not edit `10_projects/console14/prototype.html` or `10_projects/console14/prototype_resonance.html` for this route.

The backend experiment lives in:

```text
10_projects/console14/prototype_backend_experiment.html
```

The static mainline remains:

```text
10_projects/console14/prototype_resonance.html
```

## Backend Contract

Run the FastAPI server from the repository root:

```powershell
cd consoleBert\server
.\.venv\Scripts\Activate.ps1
uvicorn main:app --reload --port 8000
```

Expected local endpoints:

- `GET /`
- `GET /docs`
- `POST /transform` with `{text, tone, x, y}`
- `POST /tts` with `{text, tone}`

`/transform` is a Claude backend experiment. If Claude is unavailable, the server returns the original text with `source: "echo"` and a `warning`. The Render deployment path intentionally omits FLAN-T5, Transformers, and Torch to stay within free-instance memory.

`/tts` is an ElevenLabs proxy. `ELEVENLABS_API_KEY` is required for the normal speech path.

## Frontend Backend URL

The experiment page does not hard-code a deploy backend. Configure it by one of these routes:

- `window.CONSOLE14_BACKEND_URL = "https://your-backend.example.com"` before the page script runs.
- `<meta name="console14-backend-url" content="https://your-backend.example.com">`.
- For local testing only, append `?backend=http://127.0.0.1:8000`.

A public frontend deploy must point at a public backend URL, not a local port.

## Key Handling

Use platform environment variables for deployed services:

```text
ANTHROPIC_API_KEY
ELEVENLABS_API_KEY
```

Never commit key values, copy them into docs, or print them in verification logs.

## Smoke Test

1. Open `http://127.0.0.1:8000/docs`.
2. Open the experiment page through `tools/start_static_server.ps1`.
3. Type a message, click `TRANSFORM`, and confirm the status names the backend source or echo fallback.
4. Click `SPEAK`; ElevenLabs is the normal path, and browser speech is only a provider-unavailable fallback.
