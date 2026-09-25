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
  // WTF\Account\<acct>\edit-mode-cache-account.txt holds every layout the account
  // has saved, not just one. Shape, worked out from real files in four installs:
  //   <version> <settingCount> <settings...>
  //   then per layout: <nameLength> <name> [<layoutType> only in version 4+] <entryCount> <entries...>
  // The file ends with a null byte.
  function parseLayoutCache(str) {
    const bad = m => { throw new Error('That doesn\'t look like a WoW Edit Mode cache file' + (m ? ' (' + m + ')' : '') + '.'); };
    const t = str.replace(/\0/g, '').trim().split(/\s+/);
    let i = 0;
    const version = t[i++];
    const nSettings = parseInt(t[i++], 10);
    if (!/^\d+$/.test(version || '') || isNaN(nSettings) || nSettings < 0) bad('bad header');
    const settings = t.slice(i, i + nSettings); i += nSettings;
    if (settings.length !== nSettings) bad('truncated settings');
    const hasType = Number(version) >= 4; // version 4 carries a layout type, version 2 doesn't
    const layouts = [];
    while (i < t.length) {
      const nameLen = parseInt(t[i++], 10);
      if (isNaN(nameLen) || nameLen < 0) bad('bad layout name length');
      // A layout name can contain spaces, so rebuild it until it's the stated length.
      let name = '';
      while (i < t.length && name.length < nameLen) name += (name ? ' ' : '') + t[i++];
      if (name.length !== nameLen) bad('layout name does not match its stated length');
      const type = hasType ? t[i++] : null;
      const nEntries = parseInt(t[i++], 10);
      if (isNaN(nEntries) || nEntries < 0) bad('bad entry count');
      const flat = t.slice(i, i + nEntries * 10);
      if (flat.length !== nEntries * 10) bad('truncated layout "' + name + '"');
      i += nEntries * 10;
      const entries = [];
      for (let k = 0; k < flat.length; k += 10) entries.push(flat.slice(k, k + 10));
      layouts.push({ name, type, entries });
    }
    return { version, settings, layouts };
  }

  // Turns one layout out of that file back into the string Edit Mode's Export gives you.
  function cacheLayoutToString(version, layout) {
    const n = String(layout.entries.length);
    const header = Number(version) >= 4 ? [version, layout.type, n] : [version, n];
    return header.concat(...layout.entries).join(' ');
  }

  const api = { parseLayout, convertLayout, parseLayoutCache, cacheLayoutToString };
  if (typeof module !== 'undefined') module.exports = api; else root.WoWLayout = api;
})(this);
