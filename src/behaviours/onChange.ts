/* eslint-disable @typescript-eslint/no-explicit-any */

import Temp from 'temp';
import Process from 'child_process';
import Path from 'path';

import debounce from 'lodash/Debounce';
import Log from 'electron-log';
import OS from 'os';

import { RESOURCES_PATH } from '../helpers/assets';
import { STORAGE_UDATA, STORAGE_CLI, STORAGE_CODE } from '../helpers/storage';

// Callback executed on every keystroke
Temp.track();
const onChange = (
  value: any,
  storage: any,
  { setPreview, setPreviewOK, setPreviewError, setPreviewCritical }: any
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
      `import "!/`,
      `import "${Path.relative(stream.path, Path.join(RESOURCES_PATH, 'lib'))}${
        Path.sep
      }`
    )
    // Import from home dir
    .replaceAll(
      `import "#/`,
      `import "${Path.relative(stream.path, OS.homedir())}${Path.sep}`
    )
    // Import from .wren dir
    .replaceAll(
      `import "~/`,
      `import "${Path.relative(stream.path, OS.homedir())}${Path.sep}.wren${
        Path.sep
      }`
    )
    // Import from user data
    .replaceAll(
      `import "$/`,
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

  const child = Process.spawn(cmd, [stream.path]);

  // Clean previous result
  // Add a little delay to avoid cleaning up too soon
  debounce(() => {
    setPreview('');
  }, 50);

  child.on('error', (err) => {
    Log.info('Received Critical Error');
    Log.error(err.toString());
    setPreviewCritical(err.toString());
  });

  const messages: string[] = [];

  child.stdout.on('data', (message) => {
    Log.info('Received Data');
    Log.debug(message.toString());
    messages.push(message.toString());
    setPreviewOK(messages);
  });

  child.stderr.on('data', (message) => {
    Log.info('Received Error');
    Log.debug(message.toString());
    setPreviewError(message.toString());
  });

  child.on('close', () => {
    Log.info('Stream Closed');
    stream.end();
  });
};

export default onChange;
