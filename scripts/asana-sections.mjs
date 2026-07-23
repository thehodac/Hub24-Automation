/**
 * List the sections (with their GIDs) of an Asana project, so you can pick the
 * one for ASANA_SECTION_GID. Reads ASANA_TOKEN from .env — no need to paste it.
 *
 * Usage:
 *   node scripts/asana-sections.mjs                 (uses ASANA_PROJECT_GID from .env)
 *   node scripts/asana-sections.mjs 1207751943301534 (pass the project GID directly)
 */
import fs from 'node:fs';

// Load .env into process.env (only vars not already set).
try {
  for (const line of fs.readFileSync('.env', 'utf8').split(/\r?\n/)) {
    const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/);
    if (m && !(m[1] in process.env)) process.env[m[1]] = m[2];
  }
} catch { /* no .env */ }

const token = process.env.ASANA_TOKEN;
const project = process.argv[2] || process.env.ASANA_PROJECT_GID;

if (!token) { console.error('❌ Missing ASANA_TOKEN in .env'); process.exit(1); }
if (!project) {
  console.error('❌ Missing project GID. Add ASANA_PROJECT_GID to .env, or pass it: node scripts/asana-sections.mjs <PROJECT_GID>');
  process.exit(1);
}

const res = await fetch(`https://app.asana.com/api/1.0/projects/${project}/sections`, {
  headers: { Authorization: `Bearer ${token}`, Accept: 'application/json' },
});
const json = await res.json();
if (!res.ok) { console.error('❌ Asana API error:', JSON.stringify(json)); process.exit(1); }

console.log(`\nSections in project ${project}:\n`);
for (const s of json.data ?? []) {
  console.log(`  "${s.name}"   ->   ASANA_SECTION_GID=${s.gid}`);
}
console.log('\nCopy the line for the section you want into your .env.\n');
