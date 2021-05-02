/* eslint-disable @typescript-eslint/no-explicit-any */

import Temp from 'temp';
import Path from 'path';

import Log from 'electron-log';
import OS from 'os';
import Process from 'child_process';
import * as _ from 'lodash';

import { RESOURCES_PATH } from '../helpers/assets';
import {
  STORAGE_UDATA,
  STORAGE_CLI,
  STORAGE_CODE,
  STORAGE_MAX_TIME,
} from '../helpers/storage';

// Callback executed on every keystroke
Temp.track();

const childs: any = [];

const kill = (child: any) => child.kill('SIGKILL');

const onChange = async (
  value: any,
  storage: any,
  { setPreviewOK, setPreviewError }: any
) => {
  const userData = storage.get(STORAGE_UDATA);
  const cmd = storage.get(STORAGE_CLI);

  Log.info('Stream Created');
  const stream = Temp.createWriteStream();

  // Replace !/ and ~/ for fullpaths to allow using included libraries
  const content = value
    .toString()
    // Import from internal libs
    .replaceAll(
      `import "!`,
      `import "${Path.relative(stream.path, Path.join(RESOURCES_PATH, 'lib'))}${
        Path.sep
      }`
    )
    // Import from home dir
    .replaceAll(
      `import "~`,
      `import "${Path.relative(stream.path, OS.homedir())}${Path.sep}`
    )
    .replaceAll(
      `\${~}`,
      `${Path.relative(stream.path, OS.homedir())}${Path.sep}`
    )
    // Import from .wren dir
    .replaceAll(
      `import "#`,
      `import "${Path.relative(stream.path, OS.homedir())}${Path.sep}.wren${
        Path.sep
      }`
    )
    .replaceAll(
      `\${#}`,
      `${Path.relative(stream.path, OS.homedir())}${Path.sep}.wren${Path.sep}`
    )
    // Import from user data
    .replaceAll(
      `import "$`,
      `import "${Path.relative(stream.path, userData)}${Path.sep}`
    );

  Log.info('Evaluating Content');

  const debugLog = {
    tempFile: stream.path,
    resources: RESOURCES_PATH,
    home: OS.homedir(),
    userData,
    content,
    raw: value.toString(),
    cache: storage.path,
    wren: cmd,
    run: `"${cmd}" "${stream.path}"`,
  };

  Log.info(debugLog.run);

  // eslint-disable-next-line no-console
  console.table(debugLog);

  stream.write(content);
  storage.set(STORAGE_CODE, value.toString());

  // Kill previous childs
  childs.forEach((cid: any, index: number) => {
    Log.debug(`Killing ${cid.pid}`);
    kill(cid);
    delete childs[index];
  });

  const child = Process.spawn(cmd, [stream.path], {});

  child.stdout.setEncoding('utf8');
  child.stderr.setEncoding('utf8');

  childs.push(child);

  // Set seconds max execution time
  // Protection from while(true)
  setTimeout(() => {
    Log.info(`Child ${child.pid} timeout reached`);
    kill(child);
    stream.close();
  }, storage.get(STORAGE_MAX_TIME));

  // Clean previous result
  // Add a little delay to avoid cleaning up too soon
  _.debounce(() => {
    Log.info('Debounced Cleanup');
    setPreviewOK(['']);
  }, 20);

  child.on('error', (err) => {
    Log.info('Received Critical Error');
    Log.error(err.toString());
    setPreviewError(err.toString());
    kill(child);
  });

  child.stdout.on('data', (message) => {
    Log.info('Received Data');
    Log.debug(message.toString());
    setPreviewOK([message.toString()]);
  });

  child.stderr.on('data', (message) => {
    Log.info('Received Error');
    Log.debug(message.toString());
    setPreviewError(message.toString());
    kill(child);
  });

  child.on('close', () => {
    Log.info('Stream Closed');
    stream.end();
  });

  child.on('exit', () => {
    Log.info(`Killed ${child.pid}`);
  });
};

export default onChange;
