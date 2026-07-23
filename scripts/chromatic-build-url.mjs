/**
 * Run Chromatic and save the build URL to `.chromatic-build-url`, so the Bug
 * Report reporter can link visual changes to the Chromatic build.
 *
 * Usage:  npm run chromatic:report        (needs CHROMATIC_PROJECT_TOKEN)
 * Any extra args are forwarded to the chromatic CLI.
 */
import { spawn } from 'node:child_process';
import fs from 'node:fs';

const extra = process.argv.slice(2);
const child = spawn('npx', ['chromatic', '--playwright', ...extra], { shell: true });

let out = '';
const capture = (d) => { const s = d.toString(); out += s; process.stdout.write(s); };
child.stdout.on('data', capture);
child.stderr.on('data', capture);

child.on('close', (code) => {
  const m = out.match(/https:\/\/www\.chromatic\.com\/build\?[^\s"]+/);
  if (m) {
    fs.writeFileSync('.chromatic-build-url', m[0]);
    console.log('\nSaved Chromatic build URL -> .chromatic-build-url');
  } else {
    console.log('\n(No Chromatic build URL found in output; reporter will skip the link.)');
  }
  process.exit(code ?? 0);
});
