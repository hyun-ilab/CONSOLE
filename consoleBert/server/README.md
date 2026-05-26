# Console14 Backend Experiment Server

This FastAPI server backs `prototype_backend_experiment.html`.

It is a Claude sentence rewrite experiment plus an ElevenLabs TTS proxy. It is not the historical BERT masked-word route described in older notes; BERT and FLAN work are notebook-only unless revived later.

Public backend: `https://console14-backend.onrender.com`
Public frontend: `https://console-demo.netlify.app/10_projects/console14/prototype_backend_experiment.html`

## Run Locally

From the repository root:

```powershell
cd consoleBert\server
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

Local `.env` is optional and ignored by git:

```text
ANTHROPIC_API_KEY=...
ELEVENLABS_API_KEY=...
```

Do not paste key values into docs, logs, commits, or issue comments. On deployed backends, set these as platform environment variables.

## Endpoints

- `GET /` - health and endpoint list.
- `GET /docs` - FastAPI docs.
- `POST /transform` - JSON `{ "text": "...", "tone": "plain", "x": 2, "y": 4 }`.
- `POST /tts` - JSON `{ "text": "...", "tone": "plain", "voice_id": "optional" }`; returns audio bytes from ElevenLabs.
- `GET /voices` - optional ElevenLabs voice list when `ELEVENLABS_API_KEY` is configured.

`/transform` tries Claude when `ANTHROPIC_API_KEY` exists, then returns the original text with `source: "echo"` and a `warning` if Claude is unavailable. The Render deployment path intentionally does not load FLAN-T5, Transformers, or Torch.

`target_word` and `target_meaning` are not part of this runnable API.

## Voice Configuration

All tone families currently use the Brian voice ID with different ElevenLabs voice settings. Do not document this as one distinct voice per tone unless separate voice IDs are actually configured.
