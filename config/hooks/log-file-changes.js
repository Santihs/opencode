#!/usr/bin/env node
'use strict';

const os = require('os');
const fs = require('fs');
const path = require('path');

function getLogDir() {
  if (process.platform === 'win32') {
    const appData = process.env.APPDATA || path.join(os.homedir(), 'AppData', 'Roaming');
    return path.join(appData, 'opencode', 'logs');
  }
  return path.join(os.homedir(), '.config', 'opencode', 'logs');
}

let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => { input += chunk; });
process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    const toolName = data.tool_name || 'unknown';
    const filePath =
      (data.tool_args && (data.tool_args.filePath || data.tool_args.file_path || data.tool_args.path)) || '';
    if (!filePath) process.exit(0);

    const logDir = getLogDir();
    fs.mkdirSync(logDir, { recursive: true });

    const timestamp = new Date().toISOString();
    const line = `${timestamp} | ${toolName} | ${filePath}\n`;

    fs.appendFileSync(path.join(logDir, 'file-changes.log'), line);
  } catch (_) {
    // never block execution on a log failure
  }
  process.exit(0);
});
