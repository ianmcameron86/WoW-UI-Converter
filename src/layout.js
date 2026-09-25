// Edit Mode layout string conversion. Shared by the page and the Node tests.
(function (root) {
  function parseLayout(str) {
    const t = str.trim().split(/\s+/);
    for (const h of [2, 3, 4]) {
      const n = parseInt(t[h - 1], 10);
      if (!isNaN(n) && (t.length - h) === n * 10) {
        const entries = [];
        for (let i = h; i < t.length; i += 10) entries.push(t.slice(i, i + 10));
        return { header: t.slice(0, h), entries };
      }
    }
    throw new Error("That doesn't look like an Edit Mode layout string. Paste the whole export, from the first number to the end.");
  }
  const key = e => e[0] + ':' + e[1];
  const settingKeys = s => { const k = []; for (let j = 0; j < s.length; j += 2) k.push(s[j]); return k.join(''); };

  // Keep the target game's structure; bring over the source's custom positions and settings.
  function convertLayout(sourceStr, targetStr) {
    const src = parseLayout(sourceStr), tgt = parseLayout(targetStr);
    const S = new Map(src.entries.map(e => [key(e), e]));
    const T = new Set(tgt.entries.map(key));
    const report = { moved: 0, settings: 0, keptTarget: [], dropped: [] };
    const out = tgt.entries.map(t => {
      const e = t.slice();
      const s = S.get(key(t));
      if (!s) { report.keptTarget.push(key(t)); return e; }
      if (s[2] === '0') { for (let i = 2; i <= 8; i++) e[i] = s[i]; report.moved++; }
      const sk = settingKeys(s[9]), tk = settingKeys(t[9]);
      if (s[9].length % 2 === 0 && t[9].length % 2 === 0) {
        if (sk === tk) { e[9] = s[9]; report.settings++; }
        else if (sk.startsWith(tk)) { e[9] = s[9].slice(0, t[9].length); report.settings++; }
        else if (tk.startsWith(sk)) { e[9] = s[9] + t[9].slice(s[9].length); report.settings++; }
      } else if (s[9] === t[9] || sk === tk) { e[9] = s[9]; }
      return e;
    });
    for (const e of src.entries) if (!T.has(key(e))) report.dropped.push(key(e));
    const header = tgt.header.slice(0, -1).concat(String(out.length));
    return { text: header.concat(...out).join(' '), report };
  }
  const api = { parseLayout, convertLayout };
  if (typeof module !== 'undefined') module.exports = api; else root.WoWLayout = api;
})(this);
