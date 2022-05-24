const { readFile } = require('fs/promises');
const glob = require('glob');
const { promisify } = require('util');

(async function() {
  const findingsFiles = await promisify(glob)('**/appmap-findings.json');
  const findingsData = (await Promise.all(findingsFiles.map(async (file) => readFile(file, 'utf8')))).map(JSON.parse);
  const findings = findingsData.reduce((acc, curr) => acc.concat(curr.findings), []);
  if ( findings.length === 0 ) return;

  console.log(`Found ${findings.length} AppMap findings:`)
  findings.map((finding) => `  - ${finding.message}`).forEach((f) => console.log(f))
  process.exit(1)
})();
