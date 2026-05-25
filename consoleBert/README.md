# consoleBert

A tone-aware text transformer and text-to-speech tool. Type any message, dial a tone (dry, plain, warm, firm, bright, low), and the system rewrites your text and speaks it in a matching voice.

## What you need

- Python 3.10+
- An **Anthropic API key** — get one at [console.anthropic.com](https://console.anthropic.com)
- An **ElevenLabs API key** — get one at [elevenlabs.io](https://elevenlabs.io) (free tier works)

## Setup

### 1. Install dependencies

```powershell
cd server
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### 2. Add your API keys

Copy the example env file and fill in your keys:

```powershell
copy server\.env.example server\.env
```

Open `server/.env` and replace the placeholders:

```
ELEVENLABS_API_KEY=your_elevenlabs_key_here
ANTHROPIC_API_KEY=your_anthropic_key_here
```

### 3. Start the backend server

```powershell
cd server
.\.venv\Scripts\Activate.ps1
uvicorn main:app --reload --port 8000
```

The server runs at `http://localhost:8000`. Visit `http://localhost:8000/docs` to test the API.

### 4. Start the frontend

From the project root, run the static server:

```powershell
.\tools\start_static_server.ps1
```

Open the URL it prints, then navigate to:

```
/10_projects/console14/prototype.html
```

## How to use it

1. Type a message in the **Enter your own text** box at the bottom of the page
2. Dial the tone and adjust the X/Y grid
3. Click **TRANSFORM** — Claude rewrites your message to match the selected tone and formality
4. Click **SPEAK** — ElevenLabs reads it aloud in a voice that matches the tone

## API keys on free tier

**Anthropic** — pay-per-use, transform calls use Claude Haiku which is very cheap.

**ElevenLabs** — free tier gives 10,000 characters/month. Only pre-made voices work on free tier. The app uses one voice per tone (Adam, Brian, Antoni, Daniel, Elli, Josh) which are all free-tier compatible. Do not swap these for other voices without checking they are pre-made voices, not Voice Library voices.
