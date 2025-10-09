const { execSync } = require('node:child_process');
const { mkdirSync } = require('node:fs');
const { resolve } = require('node:path');

const SPEC = process.env.MP_OPENAPI_SPEC || 'https://backend.example.com/openapi/v1/openapi.yaml';
const OUTPUT = resolve(__dirname, '../sdk/generated');

mkdirSync(OUTPUT, { recursive: true });

console.log(`Generating TypeScript SDK from ${SPEC} -> ${OUTPUT}`);

try {
  execSync(
    `npx openapi-typescript-codegen --input ${SPEC} --output ${OUTPUT} --client fetch`,
    { stdio: 'inherit' },
  );
} catch (error) {
  console.warn('Failed to run openapi-typescript-codegen, writing placeholder files.');
  const fs = require('node:fs');
  fs.writeFileSync(
    resolve(OUTPUT, 'index.ts'),
    `// Placeholder SDK generated on ${new Date().toISOString()}\nexport const placeholder = true;\n`,
  );
}
