#!/usr/bin/env node
'use strict';

const os = require('os');
const fs = require('fs');
const path = require('path');

function getLogDir() {
  return path.join(os.homedir(), '.config', 'opencode', 'logs');
}

let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => { input += chunk; });
process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    const command = (data.tool_args && data.tool_args.command) || '';
    if (!command) process.exit(0);

    const logDir = getLogDir();
    fs.mkdirSync(logDir, { recursive: true });

    const timestamp = new Date().toISOString();
    const cwd = process.cwd();
    const line = `${timestamp} | cwd:${cwd} | ${command.replace(/\n/g, ' \\n ')}\n`;

    fs.appendFileSync(path.join(logDir, 'commands.log'), line);
  } catch (_) {
    // never block execution on a log failure
  }
  process.exit(0);
});
