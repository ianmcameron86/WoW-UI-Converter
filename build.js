// Builds index.html (the published page) from src/.
// Usage: node build.js
const fs = require('fs');
const path = require('path');
const root = __dirname;
const page = fs.readFileSync(path.join(root, 'src/page.html'), 'utf8');
const layoutJs = fs.readFileSync(path.join(root, 'src/layout.js'), 'utf8');
const foreverDefault = fs.readFileSync(path.join(root, 'reference/layouts/forever-beta-default.txt'), 'utf8').trim();
const out = page
  .replace('/*LAYOUT_JS*/', () => layoutJs)
  .replace('/*FOREVER_DEFAULT*/', () => JSON.stringify(foreverDefault));
fs.writeFileSync(path.join(root, 'index.html'), out);
console.log('Built index.html (' + out.length + ' bytes)');
