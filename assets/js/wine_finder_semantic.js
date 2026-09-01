/*
 * wine_finder_semantic.js — optional semantic layer for the wine finder.
 *
 * Loaded as <script type="module">; EXCLUDED from jekyll-minifier (see _config.yml)
 * because it uses dynamic import() and modern syntax that uglifier cannot parse.
 *
 * Nothing heavy runs until pipe() is called: transformers.js and the ~25 MB model
 * are fetched on first use, then cached by the browser. Per-wine embedding vectors
 * are cached in IndexedDB, keyed by a hash of the profile text so they refresh when
 * the text changes.
 *
 * Everything here is free: the model (Xenova/all-MiniLM-L6-v2, Apache-2.0) comes
 * from a public CDN and all inference runs on the visitor's device. No key, no server.
 */

const TRANSFORMERS_URL =
  "https://cdn.jsdelivr.net/npm/@xenova/transformers@2.17.2/dist/transformers.min.js";
const MODEL = "Xenova/all-MiniLM-L6-v2";
const DB_NAME = "wine-finder";
const STORE = "vectors";

let _pipelinePromise = null;

async function loadPipeline(onProgress) {
  const transformers = await import(/* webpackIgnore: true */ TRANSFORMERS_URL);
  transformers.env.allowLocalModels = false;
  transformers.env.useBrowserCache = true;
  return transformers.pipeline("feature-extraction", MODEL, {
    quantized: true,
    progress_callback: (p) => {
      if (onProgress && p && p.status === "progress" && typeof p.progress === "number") {
        onProgress(Math.round(p.progress));
      }
    },
  });
}

// Resolve (and cache) the feature-extraction pipeline. onProgress(percent) fires
// during the one-time model download.
function pipe(onProgress) {
  if (!_pipelinePromise) {
    _pipelinePromise = loadPipeline(onProgress).catch((err) => {
      _pipelinePromise = null; // let a later call retry
      throw err;
    });
  }
  return _pipelinePromise;
}

async function embed(text) {
  const extractor = await pipe();
  const out = await extractor(String(text || ""), { pooling: "mean", normalize: true });
  return Array.from(out.data); // 384-d, unit length
}

function openDb() {
  return new Promise((resolve, reject) => {
    const req = indexedDB.open(DB_NAME, 1);
    req.onupgradeneeded = () => req.result.createObjectStore(STORE);
    req.onsuccess = () => resolve(req.result);
    req.onerror = () => reject(req.error);
  });
}

async function cacheGet(key) {
  try {
    const db = await openDb();
    return await new Promise((resolve) => {
      const r = db.transaction(STORE).objectStore(STORE).get(key);
      r.onsuccess = () => resolve(r.result || null);
      r.onerror = () => resolve(null);
    });
  } catch (e) {
    return null;
  }
}

async function cacheSet(key, value) {
  try {
    const db = await openDb();
    await new Promise((resolve) => {
      const r = db.transaction(STORE, "readwrite").objectStore(STORE).put(value, key);
      r.onsuccess = () => resolve();
      r.onerror = () => resolve();
    });
  } catch (e) {
    /* cache is best-effort */
  }
}

// items: [{ key, text }]  ->  { key: Float vector }.  onProgress(done, total, phase).
async function embedCorpus(items, onProgress) {
  const vectors = {};
  let done = 0;
  for (const it of items) {
    let v = await cacheGet(it.key);
    if (!Array.isArray(v)) {
      v = await embed(it.text);
      await cacheSet(it.key, v);
    }
    vectors[it.key] = v;
    done += 1;
    if (onProgress) onProgress(done, items.length, "embed");
  }
  return vectors;
}

function cosine(a, b) {
  if (!a || !b) return 0;
  let s = 0;
  for (let i = 0; i < a.length; i += 1) s += a[i] * b[i];
  return s; // both vectors are unit length
}

window.WineSemantic = { pipe, embed, embedCorpus, cosine };
window.dispatchEvent(new Event("winesemantic:ready"));
