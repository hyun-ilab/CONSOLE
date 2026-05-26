# consoleBert — Emotion Geometry Text & Voice Transformer

**Project:** consoleBert (part of the CONSOLE research prototype)
**Stack:** FastAPI (Python) · Anthropic Claude Haiku · ElevenLabs TTS · Vanilla JS canvas UI

---

## What it does

consoleBert takes a piece of text and an emotional target, then produces two outputs:

1. **Transformed text** — Claude rewrites the message in the emotional register of the target (e.g. "Can you send me the file?" becomes more urgent, warmer, or more resigned depending on the emotion chosen)
2. **Synthesized speech** — ElevenLabs reads the result aloud using voice parameters computed from the emotion's position in a 2D emotional space

The selection interface is a dropdown of 30 emotions paired with a live canvas that plots all emotions in valence-arousal space. Changing the selection moves an orange dot across the canvas, giving the user an immediate spatial sense of the emotional "distance" between options.

---

## The Science: Valence-Arousal Space

The core model is the **Circumplex Model of Affect** (Russell, 1980). The model organizes all emotions along two continuous, orthogonal dimensions:

| Dimension | Low end | High end |
|-----------|---------|----------|
| **Valence** | Negative (distressed, sad) | Positive (joyful, elated) |
| **Arousal** | Low energy (calm, serene) | High energy (panicked, excited) |

Every emotion can be placed as a coordinate `(valence, arousal)` in this space. Emotions that feel similar cluster together; opposites sit across the center. For example:

- `panicked` → valence −0.88, arousal +0.82 (top-left: very bad, very activated)
- `serene` → valence +0.40, arousal −0.72 (bottom-right: good, very calm)
- `neutral` → valence 0.00, arousal 0.00 (center)

This is not a categorical labeling system — it is a continuous geometry. The formulas for voice parameters are computed directly from the coordinates, so emotions that sit close together produce similar voice outputs, and the space between them is traversable.

---

## Voice Parameter Derivation

ElevenLabs exposes two primary expressive parameters: `stability` (how consistent and controlled the delivery is) and `style` (how much emotional coloring is added). We map from coordinates to parameters analytically:

```
stability  = clamp(0.50 − arousal × 0.32,  min=0.10, max=0.95)
intensity  = |valence| × 0.65 + |arousal| × 0.35
neg_boost  = max(0, −valence) × 0.18
style      = clamp(intensity × 0.75 + neg_boost,  min=0.00, max=1.00)
```

**Intuition:**
- High arousal → lower stability → more variation in delivery (urgent, frantic)
- High emotional intensity (either pole of valence, either pole of arousal) → higher style → more expressive coloring
- Negative valence gets a small extra style boost because sadness and distress tend to involve prosodic deviation even at low arousal

---

## Text Transformation

Text transformation uses Claude Haiku (`claude-haiku-4-5-20251001`) with a strict system prompt that enforces transformation-only behavior. The coordinates are converted to a natural-language style description (e.g. `"deeply negative, distressed, high energy and urgent"`) and passed as the target style.

The system prompt explicitly prohibits Claude from responding to questions or statements in the input — it must rephrase them, not answer them. This is the key prompt engineering constraint that makes the tool useful for message drafting rather than Q&A.

---

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/` | Health check |
| `GET` | `/emotions` | Returns the full emotion map with valence/arousal coordinates |
| `POST` | `/transform` | Rewrites text in the target emotional style via Claude |
| `POST` | `/tts` | Synthesizes speech via ElevenLabs with emotion-derived voice settings |

**`POST /transform` body:**
```json
{ "text": "Can you send me the file?", "emotion": "desperate" }
```

**`POST /tts` body:**
```json
{ "text": "Can you send me the file?", "emotion": "desperate" }
```

---

## Emotion Map (30 emotions)

| Emotion | Valence | Arousal | Quadrant |
|---------|---------|---------|----------|
| panicked | −0.88 | +0.82 | neg/activated |
| desperate | −0.85 | +0.75 | neg/activated |
| furious | −0.80 | +0.88 | neg/activated |
| terrified | −0.82 | +0.78 | neg/activated |
| anxious | −0.55 | +0.65 | neg/activated |
| angry | −0.60 | +0.72 | neg/activated |
| frustrated | −0.48 | +0.52 | neg/activated |
| sad | −0.68 | −0.45 | neg/calm |
| defeated | −0.72 | −0.55 | neg/calm |
| resigned | −0.42 | −0.48 | neg/calm |
| gloomy | −0.58 | −0.35 | neg/calm |
| disappointed | −0.38 | −0.10 | neg/neutral |
| worried | −0.32 | +0.38 | neg/mild |
| uncertain | −0.15 | +0.12 | near center |
| neutral | 0.00 | 0.00 | center |
| dry | 0.00 | −0.52 | center/calm |
| plain | +0.05 | −0.20 | near center |
| calm | +0.25 | −0.65 | pos/calm |
| serene | +0.40 | −0.72 | pos/calm |
| content | +0.45 | −0.30 | pos/calm |
| reflective | +0.20 | −0.40 | pos/calm |
| warm | +0.58 | +0.22 | pos/mild |
| hopeful | +0.52 | +0.35 | pos/mild |
| confident | +0.55 | +0.45 | pos/moderate |
| firm | +0.30 | +0.50 | pos/moderate |
| excited | +0.78 | +0.72 | pos/activated |
| elated | +0.85 | +0.78 | pos/activated |
| joyful | +0.82 | +0.65 | pos/activated |
| bright | +0.65 | +0.60 | pos/activated |
| enthusiastic | +0.72 | +0.68 | pos/activated |

---

## Research References

**Foundational model**
- Russell, J. A. (1980). A circumplex model of affect. *Journal of Personality and Social Psychology, 39*(6), 1161–1178.
  The paper that established the two-dimensional valence-arousal framework used here. All 30 emotion coordinates in this project are placed relative to Russell's circumplex.

- Russell, J. A. (2003). Core affect and the psychological construction of emotion. *Psychological Review, 110*(1), 145–172.
  Extends the 1980 model; argues core affect (the valence-arousal state) is continuous, not categorical, and underlies all emotional experience.

**Measurement and norms**
- Bradley, M. M., & Lang, P. J. (1999). *Affective norms for English words (ANEW): Instruction manual and affective ratings* (Technical Report C-1). University of Florida.
  Provides empirical valence-arousal-dominance ratings for ~2,500 English words, used as a sanity check for coordinate placement in this project.

- Mehrabian, A., & Russell, J. A. (1974). *An approach to environmental psychology.* MIT Press.
  Introduced the PAD (Pleasure-Arousal-Dominance) model, the predecessor to the modern circumplex; explains how environment and stimuli induce affective states.

**AI / LLM emotion representation**
- Anthropic (2026). *Mapping emotion geometry in large language models.* arXiv:2604.07729.
  The primary motivation for this project. Finds that Claude's internal representations of emotional concepts are organized in a valence-arousal structure consistent with Russell's circumplex. The coordinate assignments in `EMOTION_MAP` are informed by the relative positions reported in this paper.

**Speech synthesis and prosody**
- Schröder, M. (2009). Expressive speech synthesis: Past, present, and possible futures. In *Affective Information Processing* (pp. 111–126). Springer.
  Reviews the relationship between affective dimensions (valence, arousal) and acoustic parameters in TTS — the direct precedent for our stability/style formula.

---

## Running Locally

```
# 1. Start the backend
cd consoleBert/server
.venv\Scripts\activate          # Windows
uvicorn main:app --reload       # runs on http://localhost:8000

# 2. Open the frontend
# Open 10_projects/console14/prototype.html in a browser
# No separate server needed
```

Requires `.env` in `consoleBert/server/` with:
```
ANTHROPIC_API_KEY=your_key_here
ELEVENLABS_API_KEY=your_key_here
```

API keys: [console.anthropic.com](https://console.anthropic.com) · [elevenlabs.io](https://elevenlabs.io)
