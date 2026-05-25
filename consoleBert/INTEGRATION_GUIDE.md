# Integration Guide for Custom Text Transform UI

## Overview
This guide explains how to integrate the custom text input and BERT-based semantic transform feature into `prototype.html`.

## Files to Integrate

### 1. Styles (`custom-input-styles.css`)
Add the CSS from `custom-input-styles.css` into the `<style>` block of `prototype.html`, right before the closing `</style>` tag (around line 823).

### 2. HTML (`custom-input-html.txt`)
Add the HTML from `custom-input-html.txt` into the `<main>` element, right before the closing `</main>` tag (currently around line 916).

The section should be placed after `</section>` and before `</main>`.

### 3. JavaScript (`custom-input-js.txt`)
Add the JavaScript from `custom-input-js.txt` into the existing `<script>` block, after the line:
```javascript
const fieldCurrent = document.getElementById("fieldCurrent");
```

This adds:
- Element references for the custom input, buttons, and output
- A helper function `getToneName(index)` to map the tone dial index to tone family names
- `transformCustomText()` — fetches the BERT server and updates the output
- `speakCustom()` — speaks the transformed text using Web Speech API with tone-based prosody
- Event listeners for the TRANSFORM and SPEAK buttons

## How It Works

1. User types text into the textarea
2. User clicks TRANSFORM
3. The page sends a request to `POST http://localhost:8000/transform` with:
   - `text`: the user's input
   - `tone`: derived from current `toneIndex`
   - `x` and `y`: current grid coordinates
4. The BERT server uses the tone to select a semantic direction and performs masked-word replacement
5. The result is displayed in `.custom-output`
6. User can click SPEAK to hear the transformed text with tone-based prosody (rate/pitch)

## Prerequisites

Make sure the FastAPI server is running:
```powershell
cd c:\Users\benja\OneDrive\Documents\Berkeley\summer2026\console\CONSOLE\consoleBert\server
uvicorn main:app --reload --port 8000
```

The server will respond to `/transform` requests with semantically transformed text based on the supplied `tone`.

## Optional: CORS Setup

If you encounter CORS errors (blocked fetch requests), the FastAPI server may need a CORS middleware. Add this to `consoleBert/server/main.py` if needed:

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:*", "http://127.0.0.1:*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Testing

1. Open `http://localhost:8000/docs` in a browser to test the `/transform` endpoint manually
2. Open `prototype.html` in a browser (via the static server: `tools/start_static_server.ps1`)
3. Type a message in the custom text input box
4. Click TRANSFORM — you should see a semantically transformed version
5. Click SPEAK to hear it with tone-based prosody
