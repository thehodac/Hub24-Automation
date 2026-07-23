/**
 * Convert every test-cases/**\/<feature>.json into a matching <feature>.feature
 * (Cucumber / Gherkin) file next to it.
 *
 * Each JSON file is an array of test cases:
 *   [{ "scenario_id", "tags", "scenario", "description" }, ...]
 * where "description" holds Given/When/Then lines separated by "\n".
 *
 * Usage:  node scripts/json-to-feature.mjs
 */
import fs from 'node:fs';
import path from 'node:path';

const ROOT = path.resolve('test-cases');

function titleCase(slug) {
  return slug.replace(/-/g, ' ').replace(/\b\w/g, (m) => m.toUpperCase());
}

function toFeature(featureName, cases) {
  const lines = [`Feature: ${featureName}`, ''];
  for (const c of cases) {
    if (c.tags) lines.push(`  ${c.tags}`);
    lines.push(`  Scenario: ${c.scenario ?? c.scenario_id}`);
    for (const step of String(c.description ?? '').split('\n')) {
      const s = step.trim();
      if (s) lines.push(`    ${s}`);
    }
    lines.push('');
  }
  return lines.join('\n');
}

function walk(dir) {
  let count = 0;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, entry.name);
    if (entry.isDirectory()) count += walk(p);
    else if (entry.isFile() && entry.name.endsWith('.json')) {
      try {
        const cases = JSON.parse(fs.readFileSync(p, 'utf8'));
        if (!Array.isArray(cases)) continue;
        const featureName = titleCase(path.basename(entry.name, '.json'));
        const out = p.replace(/\.json$/, '.feature');
        fs.writeFileSync(out, toFeature(featureName, cases));
        console.log('Wrote', path.relative(process.cwd(), out));
        count += 1;
      } catch (e) {
        console.warn('Skip', p, '-', String(e));
      }
    }
  }
  return count;
}

if (!fs.existsSync(ROOT)) {
  console.error('No test-cases/ folder found at', ROOT);
  process.exit(1);
}
const n = walk(ROOT);
console.log(`Done. Generated ${n} .feature file(s).`);
