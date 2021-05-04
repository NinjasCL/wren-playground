import React from 'react';
import { v4 as Uuid } from 'uuid';

export default function beautifyMessages(messages: string[]) {
  return (
    <div className="wren-messages">
      {messages.map((message: string) => {
        // Transform newlines to <br/>
        if (message.indexOf('\n') > 0) {
          return (
            <p key={Uuid()}>
              {message.split('\n').map((item: string) => {
                // Transform tabs to &nbsp;
                if (item.indexOf('\t') > 0) {
                  return (
                    <span key={Uuid()}>
                      {item.split('\t').map((msg) => {
                        return <span key={Uuid()}>{msg}&nbsp;&nbsp;</span>;
                      })}
                      <br />
                    </span>
                  );
                }

                return (
                  <span key={Uuid()}>
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
            <span key={Uuid()}>
              {message.split('\t').map((msg) => {
                return <span key={Uuid()}>{msg}&nbsp;&nbsp;</span>;
              })}
            </span>
          );
        }
        return <p key={Uuid()}>{message}</p>;
      })}
    </div>
  );
}
