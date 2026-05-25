export async function transformText(text, tone, x, y, targetWord = null, targetMeaning = null) {
  try {
    const res = await fetch("http://localhost:8000/transform", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ text, tone, x, y, target_word: targetWord, target_meaning: targetMeaning })
    });
    if (!res.ok) return { text };
    return await res.json();
  } catch (e) {
    return { text };
  }
}

// tone: one of "dry" | "plain" | "warm" | "firm" | "bright" | "low"
// voiceId: optional ElevenLabs voice ID override
export async function requestTTS(text, tone = "plain", voiceId = null) {
  const body = { text, tone };
  if (voiceId) body.voice_id = voiceId;

  const res = await fetch("http://localhost:8000/tts", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body)
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.detail || "TTS request failed");
  }
  const blob = await res.blob();
  const url = URL.createObjectURL(blob);
  return { audioUrl: url };
}
