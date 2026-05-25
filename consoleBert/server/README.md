# consoleBert server

This directory contains a lightweight FastAPI scaffold for local experiments with a BERT-based text transform route and an optional ElevenLabs TTS proxy.

Install and run:

```powershell
python -m venv .venv
.\\.venv\\Scripts\\Activate.ps1
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

Endpoints:
- `POST /transform` — JSON `{text, target_word?, target_meaning?, tone?, x?, y?}`.
  - If `target_word` is supplied, the server masks that word and uses a distilled BERT masked language model to replace it.
  - If `target_meaning` is supplied, the model chooses a replacement candidate that is semantically closer to that meaning.
  - If `target_word` is omitted, the server chooses a fallback word from the input and attempts the same masked-word transform.
- `POST /tts` — JSON `{text}`. Proxies to ElevenLabs when `ELEVENLABS_API_KEY` is set in the environment. Returns raw audio bytes.

Notes:
- The `/transform` route is designed to support general text edits using a small BERT masked language model (`distilbert-base-uncased`).
- The `/tts` route is a minimal proxy example and may need adjustment for ElevenLabs voice IDs, payloads, and account settings.
- The new BERT route is useful for changing the semantics of a specific word in an input sentence.
