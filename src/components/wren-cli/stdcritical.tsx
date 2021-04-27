import React from 'react';

export default function critical(message: string) {
  return <div className="wren-critical">{message}</div>;
}
