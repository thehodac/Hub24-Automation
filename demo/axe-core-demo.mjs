import { JSDOM } from 'jsdom';
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const axeSource = readFileSync(require.resolve('axe-core'), 'utf8');

// A login page modeled on SauceDemo's layout, seeded with COMMON a11y problems
// so we can watch axe-core detect and report them. Same engine @axe-core/playwright uses.
const html = `<!DOCTYPE html>
<html>
<head></head>
<body>
  <div class="login_logo"><img src="/logo.png"></div>
  <form>
    <input id="user-name" type="text" placeholder="Username">
    <input id="password" type="password" placeholder="Password">
    <button id="login-button" type="submit"></button>
  </form>
  <a href="/help"><img src="/icon.png"></a>
</body>
</html>`;

const dom = new JSDOM(html, { runScripts: 'dangerously', pretendToBeVisual: true });
const { window } = dom;
const script = window.document.createElement('script');
script.textContent = axeSource;
window.document.head.appendChild(script);

const results = await window.axe.run(window.document, {
  runOnly: { type: 'tag', values: ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'] },
});

const line = '-'.repeat(72);
console.log(`\n${line}\naxe-core ${window.axe.version}  --  scan summary`);
console.log(line);
console.log(`violations:   ${results.violations.length}   (rules that FAILED)`);
console.log(`passes:       ${results.passes.length}   (rules that PASSED)`);
console.log(`incomplete:   ${results.incomplete.length}   (needs real browser, e.g. color-contrast)`);
console.log(`inapplicable: ${results.inapplicable.length}   (rules with nothing to check)`);
console.log(line);

for (const [i, v] of results.violations.entries()) {
  console.log(`\n${i + 1}. [${(v.impact || 'n/a').toUpperCase()}] rule "${v.id}"`);
  console.log(`   what: ${v.help}`);
  console.log(`   wcag: ${v.tags.filter(t => t.startsWith('wcag')).join(', ')}`);
  console.log(`   docs: ${v.helpUrl.split('?')[0]}`);
  console.log(`   failing elements (${v.nodes.length}):`);
  for (const node of v.nodes) {
    console.log(`      - selector: ${node.target.join(' ')}`);
    console.log(`        html:     ${node.html}`);
  }
}
console.log(`\n${line}`);
console.log('Each violation = one axe RULE that failed, listing every element (node)');
console.log('that broke it. checkA11y() asserts violations.length === 0, so any of');
console.log('the above would FAIL the Playwright test.');
console.log(line);
