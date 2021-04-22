/* eslint-disable @typescript-eslint/no-explicit-any */
// React
import React, { useState, useRef, useEffect } from 'react';
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom';

// Electron Extensions
import Is from 'electron-is';
import Store from 'electron-store';
import { isPackaged } from 'electron-is-packaged';

// NodeJS
import Process from 'child_process';
import Path from 'path';
import Temp from 'temp';

// External Components
import SplitPane from 'react-split-pane';

// Using a custom version of codeflask to avoid some bugs
import CodeFlask from './vendor/codeflask';

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
  const regex = /[\s\S]+line[\s\S]*([0-9])\]\s*([\S\s]+):([\S\s]*)/gimu;
  const errors: any = [];

  content.forEach((item: any) => {
    const groups = Array.from(item.matchAll(regex));
    if (groups && groups.length > 0) {
      const matches: any = groups[0];
      const error = {
        line: matches[1],
        context: matches[2],
        message: matches[3],
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
  const content = value.toString();
  stream.write(content);
  storage.set(STORAGE_KEY, content);

  const child = Process.spawn(cmd, [stream.path]);

  child.on('error', (err) => {
    setPreview(<div className="wren-critical">{err.toString()}</div>);
  });

  const messages: string[] = [];

  child.stdout.on('data', (message) => {
    messages.push(message.toString());
    setPreview(beautifyMessages(messages));
  });

  child.stderr.on('data', (message) => {
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
        lineNumbers: true,
        language: 'wren',
        defaultTheme: true,
      };

      const storage = new Store();

      const flask = new CodeFlask(editorRef.current, options);

      flask.updateCode(`System.print("Hello Wren")`);

      flask.onUpdate((value: any) => {
        onChange(value, preview, setPreview, storage);
      });

      const code = storage.get(STORAGE_KEY);
      if (code) {
        flask.updateCode(code);
      }

      // setEditor(flask);
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
        <div id="editor-pane">
          <div id="code-editor" ref={editorRef} />
        </div>
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
