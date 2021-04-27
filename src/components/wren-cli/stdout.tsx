import React from 'react';

export default function beautifyMessages(messages: string[]) {
  return (
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
}
