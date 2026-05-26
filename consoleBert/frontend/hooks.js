function apiUrl(path, backendUrl = "") {
  const base = backendUrl.replace(/\/+$/, "");
  if (!base) throw new Error("Backend URL not configured");
  return `${base}${path}`;
}

export async function transformText(text, tone, x, y, backendUrl = "") {
  try {
    const res = await fetch(apiUrl("/transform", backendUrl), {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ text, tone, x, y })
    });
    if (!res.ok) return { text };
    return await res.json();
  } catch (e) {
    return { text };
  }
}

// tone: one of "dry" | "plain" | "warm" | "firm" | "bright" | "low"
// voiceId: optional ElevenLabs voice ID override
export async function requestTTS(text, tone = "plain", voiceId = null, backendUrl = "") {
  const body = { text, tone };
  if (voiceId) body.voice_id = voiceId;

  const res = await fetch(apiUrl("/tts", backendUrl), {
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
