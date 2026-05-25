const GRID_X_STEPS = 10;
const GRID_Y_STEPS = 10;
const MATRIX_TOTAL = 60 * GRID_X_STEPS * GRID_Y_STEPS;

const config = window.CONSOLE_MOBILE_PROTOTYPE || {};
const root = document.documentElement;
const shell = document.querySelector(".prototype-shell");
const dial = document.getElementById("dial");
const dialGrid = document.getElementById("dialGrid");
const field = document.getElementById("field");
const toneRail = document.getElementById("toneRail");
const sentenceEl = document.getElementById("sentence");
const displayId = document.getElementById("displayId");
const speakButton = document.getElementById("speakButton");
const topTone = document.getElementById("topTone");
const topX = document.getElementById("topX");
const topY = document.getElementById("topY");
const fieldCurrent = document.getElementById("fieldCurrent");
const thumbBubble = document.getElementById("thumbBubble");
const pressureArm = document.getElementById("pressureArm");
const guardStatus = document.getElementById("guardStatus");

const formalityAxis = [
  { label: "CLOSE", ask: "Can you send me {item} {time}", tell: "Send me {item} {time}", question: true },
  { label: "CASUAL", ask: "Could you send me {item} {time}", tell: "Please send me {item} {time}", question: true },
  { label: "RELAXED", ask: "Could you please send me {item} {time}", tell: "Please send me {item} {time}", question: true },
  { label: "NEUTRAL", ask: "Please send me {item} {time}", tell: "Please send me {item} {time}", question: false },
  { label: "CLEAR", ask: "Please send {item} to me {time}", tell: "Please send {item} to me {time}", question: false },
  { label: "COURTEOUS", ask: "Would you please send {item} to me {time}", tell: "Please send {item} to me {time}", question: true },
  { label: "POLISHED", ask: "Could you please send {item} to me {time}", tell: "Please send {item} to me {time}", question: true },
  { label: "FORMAL", ask: "Would you be able to send {item} to me {time}", tell: "Please send {item} to me {time}", question: true },
  { label: "DISTANT", ask: "Please arrange to send {item} to me {time}", tell: "Please arrange to send {item} to me {time}", question: false },
  { label: "OFFICIAL", ask: "Please ensure {item} is sent to me {time}", tell: "Please ensure {item} is sent to me {time}", question: false }
];

const directnessAxis = [
  { label: "OPEN", time: "when you have a moment", force: 0 },
  { label: "SOFT", time: "when you can", force: 1 },
  { label: "EASY", time: "this week", force: 2 },
  { label: "CLEAR", time: "by Friday if possible", force: 3 },
  { label: "DIRECT", time: "by Friday", force: 4 },
  { label: "PUSHED", time: "by Friday morning", force: 5 },
  { label: "PRESSING", time: "before the review", force: 6 },
  { label: "URGENT", time: "by noon Friday", force: 7 },
  { label: "STRICT", time: "before Friday closes", force: 8 },
  { label: "NO LATER", time: "by Friday, no later", force: 9 }
];

const toneClosers = {
  dry: ["Draft only.", "No context needed.", "Use the latest version.", "Keep it brief.", "Send the file.", "No cover note.", "Plain copy is fine.", "Just the draft.", "Attach the file.", "End there."],
  plain: ["That works.", "Please confirm.", "The current draft is fine.", "Send the latest version.", "A short note is enough.", "No extra formatting needed.", "Please include the file.", "Use the shared version.", "That should cover it.", "That will be enough."],
  warm: ["Thanks.", "I appreciate it.", "That would help.", "Thank you.", "I would appreciate it.", "Thanks for making room for it.", "That would really help.", "Thank you for prioritizing it.", "I appreciate you handling it.", "Thanks for taking care of it."],
  firm: ["I need it for the next step.", "Please prioritize it.", "I am counting on it.", "This needs to stay on track.", "Please make this the priority.", "I need it to move forward.", "Please treat this as time-sensitive.", "This is the deadline.", "Please do not let this slip.", "No later than that."],
  bright: ["That would be great.", "Thanks so much.", "Perfect, thanks.", "That would be a big help.", "Really appreciate it.", "Great if you can.", "Thanks, that keeps us moving.", "That would be excellent.", "Appreciate the quick turn.", "Thanks for jumping on it."],
  low: ["No rush beyond that.", "Keep it simple.", "That is enough.", "Steady is fine.", "No extra polish needed.", "Just the draft is fine.", "Please keep it focused.", "I only need the draft.", "Keep the handoff quiet.", "That closes the loop."]
};

const toneFamilies = [
  { name: "dry", label: "DRY", font: '"IBM Plex Mono", monospace', weight: 600, tracking: "0.01em", rate: 0.84, pitch: 0.82 },
  { name: "plain", label: "PLAIN", font: '"Inter", Arial, sans-serif', weight: 600, tracking: "0.01em", rate: 0.9, pitch: 0.9 },
  { name: "warm", label: "WARM", font: '"Newsreader", Georgia, serif', weight: 600, tracking: "0.01em", rate: 0.94, pitch: 1 },
  { name: "firm", label: "FIRM", font: '"IBM Plex Sans Condensed", Arial Narrow, sans-serif', weight: 600, tracking: "0.01em", rate: 0.88, pitch: 0.86 },
  { name: "bright", label: "BRIGHT", font: '"Space Grotesk", Arial, sans-serif', weight: 600, tracking: "0.01em", rate: 0.98, pitch: 1.06 },
  { name: "low", label: "LOW", font: '"IBM Plex Serif", Georgia, serif', weight: 600, tracking: "0.01em", rate: 0.8, pitch: 0.76 }
];

let toneIndex = Number.isFinite(config.toneIndex) ? config.toneIndex : 12;
let gridXIndex = Number.isFinite(config.gridXIndex) ? config.gridXIndex : 1;
let gridYIndex = Number.isFinite(config.gridYIndex) ? config.gridYIndex : 3;
let draggingDial = false;
let draggingField = false;
let draggingRail = false;
let pressureArmed = false;
let fitFrame = 0;

function pad(value, width = 2) {
  return String(Math.round(value)).padStart(width, "0");
}

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function clampIndex(value, steps) {
  return clamp(Math.round(value), 0, steps - 1);
}

function cellCenter(index, steps) {
  return ((index + 0.5) / steps) * 100;
}

function snapIndexFromPointer(clientValue, rectStart, rectSize, steps) {
  const ratio = clamp((clientValue - rectStart) / rectSize, 0, 1);
  return clampIndex(ratio * steps - 0.5, steps);
}

function toneFamily(index = toneIndex) {
  return toneFamilies[Math.min(toneFamilies.length - 1, Math.floor(index / 10))];
}

function fillTemplate(template, values) {
  return template.replace(/\{item\}/g, values.item).replace(/\{time\}/g, values.time);
}

function finishSentence(text, question = false) {
  const clean = text.replace(/\s+/g, " ").trim();
  return `${clean}${question ? "?" : "."}`;
}

function sentence(t, x, y) {
  const tone = toneFamily(t);
  const step = t % 10;
  const formality = formalityAxis[x];
  const directness = directnessAxis[y];
  const values = {
    item: "the draft",
    time: directness.time
  };
  const highPressure = directness.force >= 7;
  const mediumPressure = directness.force >= 4;
  const closer = toneClosers[tone.name][step];
  let line = "";

  if (tone.name === "dry") {
    line = finishSentence(fillTemplate(mediumPressure ? formality.tell : formality.ask, values), false);
  } else if (tone.name === "warm") {
    line = finishSentence(fillTemplate(highPressure ? formality.tell : formality.ask, values), !highPressure && formality.question);
  } else if (tone.name === "firm") {
    line = finishSentence(fillTemplate(formality.tell, values), false);
  } else if (tone.name === "bright") {
    line = finishSentence(fillTemplate(highPressure ? formality.tell : formality.ask, values), !highPressure && formality.question);
  } else if (tone.name === "low") {
    line = finishSentence(fillTemplate(highPressure ? formality.tell : formality.ask, values), false);
  } else {
    line = finishSentence(fillTemplate(highPressure ? formality.tell : formality.ask, values), !highPressure && formality.question);
  }

  return closer ? `${line} ${closer}` : line;
}

function buildDialGrid() {
  if (!dialGrid || dialGrid.children.length) return;
  for (let index = 0; index < 60; index += 1) {
    const tick = document.createElement("i");
    tick.className = `tick${index % 5 === 0 ? " major" : ""}${index % 10 === 0 ? " decade" : ""}`;
    tick.dataset.index = String(index + 1);
    dialGrid.appendChild(tick);
  }
  positionDialGrid();
}

function positionDialGrid() {
  if (!dialGrid) return;
  const radius = dialGrid.getBoundingClientRect().width / 2 - 8;
  Array.from(dialGrid.children).forEach((tick, index) => {
    tick.style.transform = `rotate(${index * 6}deg) translateY(${-radius}px)`;
  });
}

function fitDisplayText() {
  root.style.setProperty("--display-font-size", "clamp(14px, 3.7vw, 20px)");
  if (fitFrame) cancelAnimationFrame(fitFrame);
  fitFrame = requestAnimationFrame(() => {
    fitFrame = 0;
    sentenceEl.style.fontSize = "";
    let size = Number.parseFloat(window.getComputedStyle(sentenceEl).fontSize);
    while ((sentenceEl.scrollWidth > sentenceEl.clientWidth || sentenceEl.scrollHeight > sentenceEl.clientHeight + 1) && size > 8) {
      size -= 1;
      sentenceEl.style.fontSize = `${size}px`;
    }
    if (sentenceEl.scrollWidth > sentenceEl.clientWidth || sentenceEl.scrollHeight > sentenceEl.clientHeight + 1) {
      sentenceEl.style.fontSize = "8px";
    }
  });
}

function setGuardMessage(message) {
  if (guardStatus) guardStatus.textContent = message;
}

function update() {
  toneIndex = ((Math.round(toneIndex) % 60) + 60) % 60;
  gridXIndex = clampIndex(gridXIndex, GRID_X_STEPS);
  gridYIndex = clampIndex(gridYIndex, GRID_Y_STEPS);

  if (config.variant === "pressure-guard" && gridYIndex >= 7 && !pressureArmed) {
    gridYIndex = 6;
    setGuardMessage("Guard held pressure at Y 07");
  } else if (config.variant === "pressure-guard") {
    setGuardMessage(pressureArmed ? "High pressure armed" : "Guard active below Y 08");
  }

  const angle = toneIndex * 6;
  const tone = toneFamily();
  const tonePercent = (toneIndex / 59) * 100;
  const gridXPercent = cellCenter(gridXIndex, GRID_X_STEPS);
  const gridYPercent = cellCenter(gridYIndex, GRID_Y_STEPS);
  const currentSentence = sentence(toneIndex, gridXIndex, gridYIndex);
  const toneCount = toneIndex + 1;
  const xCount = gridXIndex + 1;
  const yCount = gridYIndex + 1;

  root.style.setProperty("--dial-angle", `${angle}deg`);
  root.style.setProperty("--grid-x-pos", `${gridXPercent}%`);
  root.style.setProperty("--grid-y-pos", `${gridYPercent}%`);
  root.style.setProperty("--grid-cell-x", `${100 / GRID_X_STEPS}%`);
  root.style.setProperty("--grid-cell-y", `${100 / GRID_Y_STEPS}%`);
  root.style.setProperty("--tone-value", `${tonePercent}%`);
  root.style.setProperty("--sentence-font", tone.font);
  root.style.setProperty("--sentence-weight", String(tone.weight));
  root.style.setProperty("--sentence-tracking", tone.tracking);

  sentenceEl.textContent = currentSentence;
  topTone.textContent = `TONE ${pad(toneCount, 3)} / 060 ${tone.label}`;
  topX.textContent = `X ${pad(xCount)} / ${pad(GRID_X_STEPS)} ${formalityAxis[gridXIndex].label}`;
  topY.textContent = `Y ${pad(yCount)} / ${pad(GRID_Y_STEPS)} ${directnessAxis[gridYIndex].label}`;
  fieldCurrent.textContent = `X ${formalityAxis[gridXIndex].label} / Y ${directnessAxis[gridYIndex].label}`;
  displayId.textContent = `SIG / T${pad(toneCount, 2)} X${pad(xCount)} Y${pad(yCount)} / ${MATRIX_TOTAL}`;

  if (thumbBubble) {
    thumbBubble.innerHTML = `T ${pad(toneCount, 3)} ${tone.label}<br>X ${formalityAxis[gridXIndex].label}<br>Y ${directnessAxis[gridYIndex].label}`;
  }

  if (dial) {
    dial.setAttribute("aria-valuenow", String(toneCount));
    dial.setAttribute("aria-valuetext", `Tone ${toneCount} of 60, ${tone.label.toLowerCase()} style and attitude`);
  }
  if (toneRail) {
    toneRail.setAttribute("aria-valuenow", String(toneCount));
    toneRail.setAttribute("aria-valuetext", `Tone ${toneCount} of 60, ${tone.label.toLowerCase()} style and attitude`);
  }
  field.setAttribute(
    "aria-valuetext",
    `X ${xCount} of ${GRID_X_STEPS}, formality ${formalityAxis[gridXIndex].label.toLowerCase()}; Y ${yCount} of ${GRID_Y_STEPS}, directness ${directnessAxis[gridYIndex].label.toLowerCase()}`
  );
  fitDisplayText();
}

function setToneFromPointer(event) {
  const rect = dial.getBoundingClientRect();
  const cx = rect.left + rect.width / 2;
  const cy = rect.top + rect.height / 2;
  const raw = (Math.atan2(event.clientY - cy, event.clientX - cx) * 180) / Math.PI + 90;
  const normalized = ((raw % 360) + 360) % 360;
  toneIndex = Math.round(normalized / 6) % 60;
  update();
}

function setToneFromRail(event) {
  const rect = toneRail.getBoundingClientRect();
  toneIndex = clampIndex(((event.clientX - rect.left) / rect.width) * 60 - 0.5, 60);
  update();
}

function setGridFromPointer(event) {
  const rect = field.getBoundingClientRect();
  gridXIndex = snapIndexFromPointer(event.clientX, rect.left, rect.width, GRID_X_STEPS);
  gridYIndex = snapIndexFromPointer(event.clientY, rect.top, rect.height, GRID_Y_STEPS);
  update();
}

function speakSentence() {
  if (!("speechSynthesis" in window)) return;
  const tone = toneFamily();
  window.speechSynthesis.cancel();
  const utterance = new SpeechSynthesisUtterance(sentenceEl.textContent);
  utterance.lang = "en-US";
  utterance.rate = tone.rate + (toneIndex % 10) * 0.006;
  utterance.pitch = tone.pitch + (gridYIndex - (GRID_Y_STEPS - 1) / 2) * 0.04;
  window.speechSynthesis.speak(utterance);
}

function nudge(kind, amount) {
  if (kind === "tone") toneIndex += amount;
  if (kind === "x") gridXIndex += amount;
  if (kind === "y") gridYIndex += amount;
  update();
}

if (dial) {
  dial.addEventListener("pointerdown", (event) => {
    draggingDial = true;
    shell.classList.add("is-interacting");
    dial.setPointerCapture(event.pointerId);
    setToneFromPointer(event);
  });

  dial.addEventListener("pointermove", (event) => {
    if (draggingDial) setToneFromPointer(event);
  });

  dial.addEventListener("pointerup", () => {
    draggingDial = false;
    shell.classList.remove("is-interacting");
  });

  dial.addEventListener("pointercancel", () => {
    draggingDial = false;
    shell.classList.remove("is-interacting");
  });

  dial.addEventListener("keydown", (event) => {
    if (event.key === "ArrowRight" || event.key === "ArrowUp") {
      event.preventDefault();
      nudge("tone", 1);
    }
    if (event.key === "ArrowLeft" || event.key === "ArrowDown") {
      event.preventDefault();
      nudge("tone", -1);
    }
  });
}

field.addEventListener("pointerdown", (event) => {
  draggingField = true;
  field.classList.add("is-dragging");
  shell.classList.add("is-interacting");
  field.setPointerCapture(event.pointerId);
  setGridFromPointer(event);
});

field.addEventListener("pointermove", (event) => {
  if (draggingField) setGridFromPointer(event);
});

field.addEventListener("pointerup", () => {
  draggingField = false;
  field.classList.remove("is-dragging");
  shell.classList.remove("is-interacting");
});

field.addEventListener("pointercancel", () => {
  draggingField = false;
  field.classList.remove("is-dragging");
  shell.classList.remove("is-interacting");
});

field.addEventListener("keydown", (event) => {
  const step = event.shiftKey ? 5 : 1;
  if (event.key === "ArrowRight") {
    event.preventDefault();
    nudge("x", step);
  }
  if (event.key === "ArrowLeft") {
    event.preventDefault();
    nudge("x", -step);
  }
  if (event.key === "ArrowDown") {
    event.preventDefault();
    nudge("y", step);
  }
  if (event.key === "ArrowUp") {
    event.preventDefault();
    nudge("y", -step);
  }
});

if (toneRail) {
  toneRail.addEventListener("pointerdown", (event) => {
    draggingRail = true;
    shell.classList.add("is-interacting");
    toneRail.setPointerCapture(event.pointerId);
    setToneFromRail(event);
  });

  toneRail.addEventListener("pointermove", (event) => {
    if (draggingRail) setToneFromRail(event);
  });

  toneRail.addEventListener("pointerup", () => {
    draggingRail = false;
    shell.classList.remove("is-interacting");
  });

  toneRail.addEventListener("pointercancel", () => {
    draggingRail = false;
    shell.classList.remove("is-interacting");
  });

  toneRail.addEventListener("keydown", (event) => {
    if (event.key === "ArrowRight" || event.key === "ArrowUp") {
      event.preventDefault();
      nudge("tone", 1);
    }
    if (event.key === "ArrowLeft" || event.key === "ArrowDown") {
      event.preventDefault();
      nudge("tone", -1);
    }
  });
}

if (pressureArm) {
  pressureArm.addEventListener("click", () => {
    pressureArmed = !pressureArmed;
    pressureArm.setAttribute("aria-pressed", String(pressureArmed));
    update();
  });
}

document.querySelectorAll("[data-step]").forEach((button) => {
  button.addEventListener("click", () => {
    nudge(button.dataset.step, Number(button.dataset.amount || 1));
  });
});

speakButton.addEventListener("click", speakSentence);
window.addEventListener("resize", () => {
  positionDialGrid();
  fitDisplayText();
});
if (document.fonts) {
  document.fonts.ready.then(fitDisplayText);
}

buildDialGrid();
update();
