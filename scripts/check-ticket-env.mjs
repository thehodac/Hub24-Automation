/**
 * Verify the ticket-destination .env config after the user says "Done".
 * For every destination that is turned on (*_CREATE_TICKETS=true), check that
 * all required vars are filled. Prints ✅ ready / ❌ missing, and exits non-zero
 * if anything is incomplete (or nothing is enabled).
 *
 * Usage:  node scripts/check-ticket-env.mjs
 */
import fs from 'node:fs';

// Load .env into process.env (only vars not already set).
try {
  for (const line of fs.readFileSync('.env', 'utf8').split(/\r?\n/)) {
    const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/);
    if (m && !(m[1] in process.env)) process.env[m[1]] = m[2];
  }
} catch { /* no .env */ }

const has = (k) => !!(process.env[k] && process.env[k].trim());
const on = (k) => (process.env[k] || '').trim().toLowerCase() === 'true';

const dests = [
  { name: 'Jira',         flag: 'JIRA_CREATE_TICKETS',
    req: ['JIRA_BASE_URL', 'JIRA_EMAIL', 'JIRA_API_TOKEN', 'JIRA_PROJECT_KEY', 'JIRA_PARENT_KEY'] },
  { name: 'Asana',        flag: 'ASANA_CREATE_TICKETS',
    req: ['ASANA_TOKEN', 'ASANA_PROJECT_GID'] },  // ASANA_SECTION_GID optional
  { name: 'Azure DevOps', flag: 'AZURE_DEVOPS_CREATE_TICKETS',
    req: ['AZURE_DEVOPS_ORG', 'AZURE_DEVOPS_PROJECT', 'AZURE_DEVOPS_PAT'] },
  { name: 'Basecamp',     flag: 'BASECAMP_CREATE_TICKETS',
    req: ['BASECAMP_TOKEN', 'BASECAMP_ACCOUNT_ID', 'BASECAMP_PROJECT_ID', 'BASECAMP_TODOLIST_ID'] },
];

let enabled = 0, ok = 0;
console.log('\nTicket destination check:\n');
for (const d of dests) {
  if (!on(d.flag)) { console.log(`  – ${d.name}: off (${d.flag} not "true")`); continue; }
  enabled++;
  const missing = d.req.filter((k) => !has(k));
  if (missing.length === 0) { ok++; console.log(`  ✅ ${d.name}: ready`); }
  else console.log(`  ❌ ${d.name}: missing ${missing.join(', ')}`);
}
console.log('');

if (enabled === 0) {
  console.log('⚠️  No destination enabled. Set one of *_CREATE_TICKETS=true and fill its vars.\n');
  process.exit(1);
}
if (ok === enabled) {
  console.log('✅ Setup complete. You can now run the tests to auto-create tickets, e.g.:');
  console.log('     npm run test:e2e   (or test:api / test:a11y / test:visual:chromatic / test:browserstack)\n');
  process.exit(0);
}
console.log('❌ Some enabled destinations are incomplete — fill the missing vars in .env and run this again.\n');
process.exit(1);
