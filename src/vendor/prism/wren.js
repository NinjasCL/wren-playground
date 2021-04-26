// https://wren.io/
// Prism.languages.wren
export default (function (Prism) {

  // Multiline based on prism-rust.js
  var multilineComment = /\/\*(?:[^*/]|\*(?!\/)|\/(?!\*)|<self>)*\*\//.source;
  for (var i = 0; i < 2; i++) {
      // Supports up to 4 levels of nested comments
      multilineComment = multilineComment.replace(/<self>/g, function () { return multilineComment; });
  }
  multilineComment = multilineComment.replace(/<self>/g, function () { return /[^\s\S]/.source; });

  var wren = {
      // Multiline comments in Wren can have nested multiline comments
      // Comments: // and /* */
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

      // Triple quoted strings are multiline but cannot have interpolation (raw strings)
      // Based on prism-python.js
      'triple-quoted-string': {
          pattern: /(""")[\s\S]*?\1/iu,
          greedy: true,
          alias: 'string'
      },

      // A single quote string is multiline and can have interpolation (similar to JS backticks ``)
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

      // Attributes are special keywords to add meta data to classes
      'attribute': [
          // #! attributes are stored in class properties
          // #!myvar = true
          // #attributes are not stored and dismissed at compilation
          {
              pattern: /#!?[ \t\u3000]*[A-Za-z_\d]+\b/u,
              alias: 'keyword'
          },
      ],
      // #!/usr/bin/env wren on the first line
      'hashbang': [
        {
          pattern: /#!\/[\S \t\u3000]+/u,
          greedy:true,
          alias:'constant'
        }
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
            pattern: /\b[A-Z][a-z\d_]*\b/,
            lookbehind:true,
            inside: {
              'punctuation': /[.\\]/
            }
          }
      ],

      // A constant can be a variable, class, property or method. Just named in all uppercase letters
      'constant': /\b[A-Z][A-Z\d_]*\b/,

      'keyword': /\b(?:if|else|while|for|return|in|is|as|null|break|continue|foreign|construct|static|var|class|this|super|#!|#|import)\b/,

      // Functions can be Class.method()
      'function': /(?!\d)\w+(?=\s*(?:[({]))/,

      // Traditional operators but adding .. and ... for Ranges e.g.: 1..2
      // Based on prism-lua.js
      'operator': [
          /[-+*%^&|]|\/\/?|<[<=]?|>[>=]?|[=~]=?/,
          {
              // Match ".." but don't break "..."
              pattern: /(^|[^.])\.\.(?!\.)/,
              lookbehind: true
          }
      ],
      // Traditional punctuation although ; is not used in Wren
      'punctuation': /[\[\](){},;]|\.+|:+/,
      'variable': /[a-zA-Z_\d]\w*\b/,
  };

  // Based on prism-javascript.js interpolation
  // "%(interpolation)"
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
