/* eslint-disable @typescript-eslint/no-explicit-any */
import React from 'react';
import { v4 as Uuid } from 'uuid';

export default function beautifyError(message: any) {
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
    <div className="wren-error" key={Uuid()}>
      <h3>Error {index}</h3>
      <ul>
        <li>line: {error.line}</li>
        <li>context: {error.context}</li>
        <li>message: {error.message}</li>
      </ul>
    </div>
  ));
}
