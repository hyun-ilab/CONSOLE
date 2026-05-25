# consoleBert

Scaffold for a lightweight BERT semantic transform route and a TTS proxy.

Run the FastAPI server for local testing:

```powershell
python -m venv .venv
.\\.venv\\Scripts\\Activate.ps1
pip install -r server/requirements.txt
uvicorn server.main:app --reload --port 8000
```

The server exposes:
- `POST /transform` — accepts JSON `{text, target_word?, target_meaning?, tone?, x?, y?}` and returns a semantically transformed sentence.
- `POST /tts` — proxies to ElevenLabs if `ELEVENLABS_API_KEY` is set in the environment.

For a general-case BERT-based semantic edit:
- pass `text` and `target_word` to change the meaning of a specific word in the sentence.
- optionally pass `target_meaning` to steer the replacement toward a semantic direction.
- if `target_word` is omitted, the server chooses a fallback target and applies the same model-based masked-word transform.

See `server/README.md` and `colab/consoleBert_bert_masked.ipynb` for the model example.
