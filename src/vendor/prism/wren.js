// Prism.languages.wren
export default (function (Prism) {

  var multilineComment = /\/\*(?:[^*/]|\*(?!\/)|\/(?!\*)|<self>)*\*\//.source;
  for (var i = 0; i < 2; i++) {
      // Supports up to 4 levels of nested comments
      multilineComment = multilineComment.replace(/<self>/g, function () { return multilineComment; });
  }
  multilineComment = multilineComment.replace(/<self>/g, function () { return /[^\s\S]/.source; });

  var wren = {
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
          pattern: /(?:[])?(""")[\s\S]*?\1/iu,
          greedy: true,
          alias: 'string'
      },
      'string': {
          pattern: /"(?:\\[\s\S]|%\((?:[^()]|\((?:[^()]|\([^)]*\))*\))+\)|(?!%\()[^\\"])*"/u,
          greedy: true,
          inside: {}
          // Interpolation defined at the end of this function
      },
      'boolean': /\b(?:true|false)\b/,
      'number': /\b0x[\da-f]+\b|(?:\b\d+(?:\.\d*)?|\B\.\d+)(?:e[+-]?\d+)?/i,
      'null': {
          pattern: /\bnull\b/,
          alias: 'keyword'
      },
      // Highlight predefined classes and wren_cli classes as builtin
      'builtin': /\b(?:Num|System|Object|Sequence|List|Map|Bool|String|Range|Fn|Fiber|Meta|Random|File|Directory|Stat|Stdin|Stdout|Platform|Process|Scheduler|Timer)\b/,
      'attribute': [
          {
              pattern: /^#.*/,
              greedy: false,
              alias: 'keyword'
          },
          {
              pattern: /^#!.*/,
              greedy: false,
              alias: 'variable'
          },
      ],
      'class-name': [
          {
              // class definition
              // class Meta {}
              pattern: /(\b(?:class)\s+)[\w.\\]+/i,
              lookbehind: true,
              inside: {
                  'punctuation': /[.\\]/
              }
          },
          {
            // A class must always start with an uppercase.
            // File.read
            pattern:/\b[A-Z](?:[_a-z]|\dx?)*\b/,
            lookbehind:true,
            inside: {
              'punctuation': /[.\\]/
            }
          }
      ],
      'constant': /\b[A-Z](?:[A-Z_]|\dx?)*\b/,
      'keyword': /\b(?:if|else|while|for|return|in|is|as|null|break|continue|foreign|construct|static|var|class|this|super|#!|#|import)\b/,
      'function': /(?!\d)\w+(?=\s*(?:[({]))/,
      'operator': [
          /[-+*%^&|#]|\/\/?|<[<=]?|>[>=]?|[=~]=?/,
          {
              // Match ".." but don't break "..."
              pattern: /(^|[^.])\.\.(?!\.)/,
              lookbehind: true
          }
      ],
      'punctuation': /[\[\](){},;]|\.+|:+/,
      'variable': /[a-zA-Z_]\w*(?:[]|\b)/,
  };

  var stringInside = {
    'template-punctuation': {
      pattern: /^"|"$/,
      alias: 'string'
    },
    'interpolation': {
      pattern: /((?:^|[^\\])(?:\\{2})*)%\((?:[^()]|\((?:[^()]|\([^)]*\))*\))+\)/,
      lookbehind: true,
      inside: {
        'interpolation-punctuation': {
          pattern: /^%(|)$/,
          alias: 'punctuation'
        },
        rest: wren
      }
    },
    'string': /[\s\S]+/iu
  };

  // Only single quote strings can have interpolation
  wren['string'].inside = stringInside;

  Prism.languages.wren = wren;
});
