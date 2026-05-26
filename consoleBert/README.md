# consoleBert

`consoleBert` is now the historical folder name for the Console14 backend experiment. The runnable server is not a BERT masked-word service: it tries a Claude rewrite and then returns the original text with a clear `source: "echo"` and `warning` if Claude is unavailable.

The BERT notebooks in `colab/` are historical/notebook-only references unless a future task explicitly revives that route.

## What You Need

- Python 3.10+; Python 3.12 is the tested local target.
- `ANTHROPIC_API_KEY` for Claude transforms.
- `ELEVENLABS_API_KEY` for ElevenLabs TTS.
- Keep key values out of git, logs, screenshots, and copied prompts.

For deployed services, set keys in the platform environment-variable UI. Do not commit `.env` files. For local-only testing, `server/.env` is supported and ignored by git.

## Local Setup

From the repository root:

```powershell
cd consoleBert\server
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

Check `http://127.0.0.1:8000/` and `http://127.0.0.1:8000/docs`.

## Frontend Experiment

The backend experiment frontend is:

```text
10_projects/console14/prototype_backend_experiment.html
```

Public deployment: frontend `https://console-demo.netlify.app/10_projects/console14/prototype_backend_experiment.html`; backend `https://console14-backend.onrender.com`.

Run the static server from the repository root:

```powershell
.\tools\start_static_server.ps1
```

Open `http://127.0.0.1:<printed-port>/10_projects/console14/prototype_backend_experiment.html?backend=http://127.0.0.1:8000`.

The preserved static build remains `10_projects/console14/prototype_resonance.html`.

## Voice Route

ElevenLabs is the normal speech provider. The current server uses one Brian voice ID with tone-specific voice settings. Browser Web Speech is only a provider-unavailable fallback in the experiment UI, not the expected production path.
