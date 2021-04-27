/* eslint-disable @typescript-eslint/no-explicit-any */

// React
import React, { useState, useRef, useEffect } from 'react';
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom';

// Electron Extensions
import Log from 'electron-log';

// External Components
import SplitPane from 'react-split-pane';

import { CodeJar } from 'codejar';
import { withLineNumbers } from 'codejar/linenumbers';

// Internal Components
import Prism from './vendor/prism/prism';

import Storage, { STORAGE_CODE } from './helpers/storage';
import onChange from './behaviours/onChange';
import WrenCLI from './components/wren-cli';

// CSS
import './App.global.css';

// MARK: Main
const Main = () => {
  const [preview, setPreview] = useState(<></>);
  // const [editor, setEditor] = useState(null); // saved for future use maybe
  const [isSetupDone, setIsSetupDone] = useState(false);

  const editorRef = useRef(null);

  useEffect(() => {
    if (editorRef && !isSetupDone) {
      const options = {
        tab: ' '.repeat(2),
      };

      Log.info('Init');

      const storage = Storage();

      const codeEditor = CodeJar(
        editorRef.current,
        withLineNumbers(Prism.highlightElement),
        options
      );

      codeEditor.updateCode(`System.print("Hello Wren")`);

      codeEditor.onUpdate((value: any) => {
        onChange(value, storage, {
          setPreview,
          setPreviewOK: (values: string[]) =>
            setPreview(WrenCLI.WrenCLIOut(values)),
          setPreviewError: (message: string) =>
            setPreview(WrenCLI.WrenCLIError(message)),
          setPreviewCritical: (message: string) =>
            setPreview(WrenCLI.WrenCLICritical(message)),
        });
      });

      const code: any = storage.get(STORAGE_CODE);
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

export default function Application() {
  return (
    <Router>
      <Switch>
        <Route path="/" component={Main} />
      </Switch>
    </Router>
  );
}
