import Store from 'electron-store';
import Is from 'electron-is';

import Log from 'electron-log';

import Path from 'path';
import OS from 'os';
import File from 'fs';

import { asset } from './assets';

export const STORAGE_CODE = 'code';
export const STORAGE_CLI = 'cli';
export const STORAGE_UDATA = 'user-data';
export const STORAGE_LOCAL = 'local';
export const STORAGE_LOCAL_WREN = 'local-wren';
export const STORAGE_MODE = 'mode';
export const STORAGE_MAX_TIME = 'max-time'; // 3 seconds max execution time per script

const getCustomWren = (
  userData: string,
  localBin: string,
  localWren: string
) => {
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

  // Check in /usr/local/wren/bin
  // if (!File.existsSync(customWren)) {
  //   customWren = Path.join(localWren, 'wren');
  //   if (Is.windows()) {
  //     customWren = Path.join(localWren, 'wren.exe');
  //   }

  //   if (!File.existsSync(customWren)) {
  //     // Look for wren_cli
  //     customWren = Path.join(localWren, 'wren_cli');
  //     if (Is.windows()) {
  //       customWren = Path.join(localWren, 'wren_cli.exe');
  //     }
  //   }
  // }

  // // Check in /usr/local/bin
  // if (!File.existsSync(customWren)) {
  //   customWren = Path.join(localBin, 'wren');
  //   if (Is.windows()) {
  //     customWren = Path.join(localBin, 'wren.exe');
  //   }

  //   if (!File.existsSync(customWren)) {
  //     // Look for wren_cli
  //     customWren = Path.join(localBin, 'wren_cli');
  //     if (Is.windows()) {
  //       customWren = Path.join(localBin, 'wren_cli.exe');
  //     }
  //   }
  // }

  return customWren;
};

export default function setup() {
  const storage = new Store();

  const userData = storage.path.replace('config.json', '');
  const localBin = Path.join('/usr', 'local', 'bin');
  const localWren = Path.join('/usr', 'local', 'wren', 'bin');

  storage.set(STORAGE_UDATA, userData);
  storage.set(STORAGE_LOCAL, localBin);
  storage.set(STORAGE_LOCAL_WREN, localWren);
  storage.set(STORAGE_MAX_TIME, 3000);

  let cmd = getCustomWren(userData, localBin, localWren);

  if (File.existsSync(cmd)) {
    Log.info('Using Custom Wren');
  } else if (Is.macOS()) {
    cmd = asset('wren_cli-macos');
    Log.info('Using MacOS');
  } else if (Is.windows()) {
    cmd = asset('wren_cli-windows.exe');
    Log.info('Using Windows');
  } else {
    Log.info('Using Linux');
    cmd = asset('wren_cli-linux');
  }

  Log.info(cmd);

  storage.set(STORAGE_CLI, cmd);
  storage.set(STORAGE_MODE, 'wren');

  return storage;
}
