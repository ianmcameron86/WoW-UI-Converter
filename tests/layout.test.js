// Tests for the HUD layout converter. Usage: node tests/layout.test.js
const fs = require('fs');
const path = require('path');
const assert = require('assert');
const { parseLayout, convertLayout } = require('../src/layout.js');
const ref = f => fs.readFileSync(path.join(__dirname, '../reference/layouts', f), 'utf8').trim();
const retail = ref('retail-ian.txt');
const foreverDefault = ref('forever-beta-default.txt');
const foreverFinal = ref('forever-beta-ian-final.txt');
let n = 0; const t = (name, fn) => { fn(); n++; console.log('ok -', name); };

t('parses Retail (2-token header) and Forever beta (3-token header)', () => {
  assert.deepStrictEqual(parseLayout(retail).header, ['2', '52']);
  assert.deepStrictEqual(parseLayout(foreverDefault).header, ['4', '0', '59']);
  assert.strictEqual(parseLayout(retail).entries.length, 52);
  assert.strictEqual(parseLayout(foreverDefault).entries.length, 59);
});

t('Retail > Forever keeps Forever structure and Retail custom positions', () => {
  const { text, report } = convertLayout(retail, foreverDefault);
  const out = parseLayout(text);
  assert.deepStrictEqual(out.header, ['4', '0', '59']);
  assert.strictEqual(report.moved, 26);
  assert.deepStrictEqual(report.dropped, ['26:-1']);
  const player = out.entries.find(e => e[0] === '3' && e[1] === '0');
  assert.deepStrictEqual(player.slice(2, 9), ['0', '0', '0', 'UIParent', '537.5', '-622.5', '-1']);
});

t('Retail > Forever > Retail round trip returns the original string exactly', () => {
  const there = convertLayout(retail, foreverDefault).text;
  assert.strictEqual(convertLayout(there, retail).text, retail);
});

t('Ian\'s hand-tuned Forever layout converts back to a valid Retail layout', () => {
  const { text } = convertLayout(foreverFinal, retail);
  const out = parseLayout(text);
  assert.deepStrictEqual(out.header, ['2', '52']);
});

t('rejects text that is not a layout string', () => {
  assert.throws(() => parseLayout('hello world'));
});

console.log(`\n${n} tests passed`);
