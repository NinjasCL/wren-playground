import React, { useState, useRef, useEffect } from 'react';
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom';
import SplitPane from 'react-split-pane';

import Is from 'electron-is';
import Process from 'child_process';

import Temp from 'temp';
import CodeFlask from 'codeflask';

import path from 'path';
import { isPackaged } from 'electron-is-packaged';

import './App.global.css';

Temp.track();

const RESOURCES_PATH = isPackaged
    ? path.join(process.resourcesPath, 'assets')
    : path.join(__dirname, '../assets');

const getAssetPath = (...paths: string[]): string => {
    return path.join(RESOURCES_PATH, ...paths);
};

const onChange = (value, preview, setPreview) => {

  let cmd = getAssetPath('wren_cli-linux');
  if (Is.macOS()) {
    cmd = getAssetPath('wren_cli-macos');
  } else if (Is.windows()) {
    cmd = getAssetPath('wren_cli-windows.exe');
  }

  const stream = Temp.createWriteStream();
  stream.write(value.toString());

  const child = Process.spawn(cmd, [stream.path]);

  const beautify = (message) => {
    const content = message.toString().split('\n');

    // Look for info inside the error message from the cli
    const regex = /[\s\S]+line[\s\S]*([0-9])\]\s*([\S\s]+):([\S\s]*)/gimu;

    const errors = [];

    content.forEach((item) => {
      const groups = Array.from(item.matchAll(regex));
      if (!groups || groups == null || groups.length === 0) {
        return content;
      }

      const matches = groups[0];
      const error = {
        line: matches[1],
        context: matches[2],
        message: matches[3],
      };

      errors.push(error);
    });

    if (errors.length === 0) {
      return message.toString();
    }

    return errors
      .map(
        (error, index) => `
      <div class="wren-error">
        <h3>Error ${index}</h3>
        <ul>
          <li>line: ${error.line}</li>
          <li>context: ${error.context}</li>
          <li>message: ${error.message}</li>
        </ul>
      </div>
      `
      )
      .join('');
  };

  child.on('error', (err) => {
    setPreview(beautify(err || ''));
  });

  child.stdout.on('data', (message) => {
    setPreview(beautify(message || ''));
  });

  child.stderr.on('data', (message) => {
    setPreview(beautify(message || ''));
  });

  child.on('close', (code) => {
    stream.end();
  });
};

const Main = () => {
  const [preview, setPreview] = useState('');
  const [editor, setEditor] = useState(null);
  const [isSetupDone, setIsSetupDone] = useState(false);

  const editorRef = useRef(null);

  useEffect(() => {
    if (editorRef && !isSetupDone) {
      const options = {
        lineNumbers: true,
        language: 'js',
        defaultTheme: true,
      };

      const flask = new CodeFlask(editorRef.current, options);
      flask.onUpdate((value) => {
        onChange(value, preview, setPreview);
      });

      setEditor(flask);
      setIsSetupDone(true);
    }
  }, [editorRef, isSetupDone, setIsSetupDone, setEditor, preview, setPreview]);

  return (
    <div className="App">
      <SplitPane split="vertical" defaultSize="60%">
        <div id="editor-pane">
          <div id="code-editor" ref={editorRef} />
        </div>
        <div id="preview-pane" dangerouslySetInnerHTML={{ __html: preview }} />
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
