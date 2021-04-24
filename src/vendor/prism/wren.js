// Prism.languages.wren
export default (function (Prism) {
  var multilineComment = /\/\*(?:[^*/]|\*(?!\/)|\/(?!\*)|<self>)*\*\//.source;
  for (var i = 0; i < 2; i++) {
    // support 4 levels of nested comments
    multilineComment = multilineComment.replace(/<self>/g, function () { return multilineComment; });
  }
  multilineComment = multilineComment.replace(/<self>/g, function () { return /[^\s\S]/.source; });

  Prism.languages.wren = {
    'hashbang': {
      pattern: /^#!.*/,
      greedy: true,
      alias: 'comment'
    },
    'comment': [
      {
        pattern: RegExp(/(^|[^\\])/.source + multilineComment),
        lookbehind: true,
        greedy: true
      },
      {
        pattern: /(^|[^\\:])\/\/.*/,
        lookbehind: true,
        greedy: true
      }
    ],
    'triple-quoted-string': {
      pattern: /(?:[])?(""")[\s\S]*?\1/i,
      greedy: true,
      alias: 'string'
    },
    'string': {
      pattern: /(?:[])?(")[\s\S]*?\1/i,
      greedy: true
    },
    'class-name': {
      pattern: /(\b(?:class|is|Num|System|Object|Sequence|List|Map|Bool|String|Range|Fn|Fiber)\s+|\bcatch\s+\()[\w.\\]+/i,
      lookbehind: true,
      inside: {
        'punctuation': /[.\\]/
      }
    },
    'keyword': /\b(?:if|else|while|for|return|in|is|as|null|break|continue|foreign|construct|static|var|class|this|super|#!|#)\b/,
    'boolean': /\b(?:true|false)\b/,
    'number': /\b0x[\da-f]+\b|(?:\b\d+(?:\.\d*)?|\B\.\d+)(?:e[+-]?\d+)?/i,
    'null': {
      pattern: /\bnull\b/,
      alias: 'keyword'
    },
    'function': /(?!\d)\w+(?=\s*(?:[({]))/,
    'operator': [
        /[-+*%^&|#]|\/\/?|<[<=]?|>[>=]?|[=~]=?/,
        {
          // Match ".." but don't break "..."
          pattern: /(^|[^.])\.\.(?!\.)/,
          lookbehind: true
        }
      ],
    'punctuation': /[\[\](){},;]|\.+|:+/
  };
});
