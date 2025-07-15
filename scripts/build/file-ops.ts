// file-ops.ts - File system utilities for build scripts

import fs from 'fs';
import path from 'path';

function fileExists(filePath: string): boolean {
  return fs.existsSync(filePath);
}

function isRegularFile(filePath: string): boolean {
  try {
    const stat = fs.lstatSync(filePath);
    return stat.isFile();
  } catch (e) {
    return false;
  }
}

function isSymlink(filePath: string): boolean {
  try {
    const stat = fs.lstatSync(filePath);
    return stat.isSymbolicLink();
  } catch (e) {
    return false;
  }
}

function readFile(filePath: string, encoding: BufferEncoding = 'utf8'): string | null {
  try {
    return fs.readFileSync(filePath, encoding);
  } catch (e) {
    return null;
  }
}

function realPath(filePath: string): string | null {
  try {
    return fs.realpathSync.native(filePath);
  } catch (e) {
    return null;
  }
}

export {
  fileExists,
  isRegularFile,
  isSymlink,
  readFile,
  realPath
};
