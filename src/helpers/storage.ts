import Store from 'electron-store';
import Is from 'electron-is';

import Log from 'electron-log';

import Path from 'path';
import OS from 'os';
import File from 'fs';

import { asset } from './assets';

export const STORAGE_CODE = 'code';
export const STORAGE_CLI = 'cli';
export const STORAGE_UDATA = 'userData';
export const STORAGE_MODE = 'mode';

export default function setup() {
  const storage = new Store();

  const userData = storage.path.replace('config.json', '');
  storage.set(STORAGE_UDATA, userData);

  let cmd = asset('wren_cli-linux');

  // Enable providing a custom wren executable in userData dir
  let customWren = Path.join(userData, 'wren');
  if (Is.windows()) {
    customWren = Path.join(userData, 'wren.exe');
  }

  // If not found in userData check .wren home
  if (!File.existsSync(customWren)) {
    customWren = Path.join(OS.homedir(), '.wren', 'wren');
    if (Is.windows()) {
      customWren = Path.join(OS.homedir(), '.wren', 'wren.exe');
    }
  }

  if (!File.existsSync(customWren)) {
    // Look for wren_cli
    customWren = Path.join(userData, 'wren_cli');
    if (Is.windows()) {
      customWren = Path.join(userData, 'wren_cli.exe');
    }

    // If not found in userData check .wren home
    if (!File.existsSync(customWren)) {
      customWren = Path.join(OS.homedir(), '.wren', 'wren_cli');
      if (Is.windows()) {
        customWren = Path.join(OS.homedir(), '.wren', 'wren_cli.exe');
      }
    }
  }

  if (File.existsSync(customWren)) {
    Log.info('Using Custom Wren');
    cmd = customWren;
  } else if (Is.macOS()) {
    cmd = asset('wren_cli-macos');
    Log.info('Using MacOS');
  } else if (Is.windows()) {
    cmd = asset('wren_cli-windows.exe');
    Log.info('Using Windows');
  } else {
    Log.info('Using Linux');
  }

  Log.info(cmd);

  storage.set(STORAGE_CLI, cmd);
  storage.set(STORAGE_MODE, 'wren');

  return storage;
}
