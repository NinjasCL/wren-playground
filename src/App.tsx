/* eslint-disable @typescript-eslint/no-explicit-any */

// React
import React, { useState, useRef, useEffect } from 'react';
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom';

// Electron Extensions
import Is from 'electron-is';
import Store from 'electron-store';
import { isPackaged } from 'electron-is-packaged';
import Log from 'electron-log';

// NodeJS
import Process from 'child_process';
import Path from 'path';
import Temp from 'temp';
import OS from 'os';

// External Components
import SplitPane from 'react-split-pane';

import { CodeJar } from 'codejar';
import { withLineNumbers } from 'codejar/linenumbers';

// custom prism version
import Prism from './vendor/prism/prism';

// CSS
import './App.global.css';

// MARK: App
const STORAGE_KEY = 'code';

// Helper Methods
const RESOURCES_PATH = isPackaged
  ? Path.join(process.resourcesPath, 'assets')
  : Path.join(__dirname, '../assets');

const getAssetPath = (...paths: string[]): string => {
  return Path.join(RESOURCES_PATH, ...paths);
};

const beautifyError = (message: any) => {
  const content = message.toString().split('\n');

  // Look for info inside the error message from the cli
  const regex = /[\s\S]+line[\s\S]*([0-9]+)\]\s*([\S\s]+):([\S\s]*)/gimu;
  const errors: any = [];

  content.forEach((item: any) => {
    const groups = Array.from(item.matchAll(regex));
    if (groups && groups.length > 0) {
      const matches: any = groups[0];
      const error = {
        line: matches[1],
        context: matches[2],
        message: matches[3],
        raw: message.toString(),
      };

      errors.push(error);
    }
  });

  if (errors.length === 0) {
    return (
      <div className="wren-error">
        <p>{message.toString()}</p>
      </div>
    );
  }

  return errors.map((error: any, index: number) => (
    <div className="wren-error" key={JSON.stringify(error)}>
      <h3>Error {index}</h3>
      <ul>
        <li>line: {error.line}</li>
        <li>context: {error.context}</li>
        <li>message: {error.message}</li>
      </ul>
    </div>
  ));
};

const beautifyMessages = (messages: string[]) => (
  <div className="wren-messages">
    {messages.map((message: string, index: number) => {
      // Transform newlines to <br/>
      if (message.indexOf('\n') > 0) {
        return (
          // eslint-disable-next-line react/no-array-index-key
          <p key={index}>
            {message.split('\n').map((item: string, key: number) => {
              // Transform tabs to &nbsp;
              if (item.indexOf('\t') > 0) {
                return (
                  // eslint-disable-next-line react/no-array-index-key
                  <span key={key}>
                    {item.split('\t').map((msg, id) => {
                      // eslint-disable-next-line react/no-array-index-key
                      return <span key={id}>{msg}&nbsp;&nbsp;</span>;
                    })}
                    <br />
                  </span>
                );
              }

              return (
                // eslint-disable-next-line react/no-array-index-key
                <span key={key}>
                  {item}
                  <br />
                </span>
              );
            })}
          </p>
        );
      }

      // Transform tabs to &nbsp;
      if (message.indexOf('\t') > 0) {
        return (
          // eslint-disable-next-line react/no-array-index-key
          <span key={index}>
            {message.split('\t').map((msg, id) => {
              // eslint-disable-next-line react/no-array-index-key
              return <span key={id}>{msg}&nbsp;&nbsp;</span>;
            })}
          </span>
        );
      }
      // eslint-disable-next-line react/no-array-index-key
      return <p key={index}>{message}</p>;
    })}
  </div>
);

// Callback executed on every keystroke
Temp.track();
const onChange = (value: any, _preview: any, setPreview: any, storage: any) => {
  let cmd = getAssetPath('wren_cli-linux');
  if (Is.macOS()) {
    cmd = getAssetPath('wren_cli-macos');
  } else if (Is.windows()) {
    cmd = getAssetPath('wren_cli-windows.exe');
  }

  const stream = Temp.createWriteStream();

  // Replace !/ and ~/ for fullpaths to allow using included libraries
  const content = value
    .toString()
    .replaceAll(
      `import "!/`,
      `import "${Path.relative(stream.path, Path.join(RESOURCES_PATH, 'lib'))}${
        Path.sep
      }`
    )
    .replaceAll(
      `import "~/`,
      `import "${Path.relative(stream.path, OS.homedir())}${Path.sep}`
    );

  Log.debug(content);

  stream.write(content);
  storage.set(STORAGE_KEY, value.toString());

  const child = Process.spawn(cmd, [stream.path]);

  // Clean previous result
  setPreview('');

  child.on('error', (err) => {
    setPreview(<div className="wren-critical">{err.toString()}</div>);
  });

  const messages: string[] = [];

  child.stdout.on('data', (message) => {
    messages.push(message.toString());
    setPreview(beautifyMessages(messages));
  });

  child.stderr.on('data', (message) => {
    Log.debug(message.toString());
    setPreview(beautifyError(message || ''));
  });

  child.on('close', () => {
    stream.end();
  });
};

// MARK: Main

const Main = () => {
  const [preview, setPreview] = useState('');
  // const [editor, setEditor] = useState(null); // saved for future use maybe
  const [isSetupDone, setIsSetupDone] = useState(false);

  const editorRef = useRef(null);

  useEffect(() => {
    if (editorRef && !isSetupDone) {
      const options = {
        tab: ' '.repeat(2),
      };

      const storage = new Store();

      const codeEditor = CodeJar(
        // eslint-disable-next-line
        editorRef.current,
        withLineNumbers(Prism.highlightElement),
        options
      );

      codeEditor.updateCode(`System.print("Hello Wren")`);

      codeEditor.onUpdate((value: any) => {
        onChange(value, preview, setPreview, storage);
      });

      const code: any = storage.get(STORAGE_KEY);
      if (code) {
        codeEditor.updateCode(code);
      }

      // setEditor(codeEditor);
      setIsSetupDone(true);
    }
  }, [
    editorRef,
    isSetupDone,
    setIsSetupDone,
    /* setEditor, */ preview,
    setPreview,
  ]);

  return (
    <div className="App">
      <SplitPane split="vertical" defaultSize="60%">
        <div id="code-editor" ref={editorRef} className="language-wren" />
        <div id="preview-pane">{preview}</div>
      </SplitPane>
    </div>
  );
};

export default function App() {
  return (
    <Router>
      <Switch>
        <Route path="/" component={Main} />
      </Switch>
    </Router>
  );
}
