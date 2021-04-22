const BACKGROUND_COLOR = '#fff';
const LINE_HEIGHT = '20px';
const FONT_SIZE = '13px';
const defaultCssTheme = `\n.codeflask {\n  background: ${BACKGROUND_COLOR};\n  color: #4f559c;\n}\n\n.codeflask .token.punctuation {\n  color: #4a4a4a;\n}\n\n.codeflask .token.keyword {\n  color: #8500ff;\n}\n\n.codeflask .token.operator {\n  color: #ff5598;\n}\n\n.codeflask .token.string {\n  color: #41ad8f;\n}\n\n.codeflask .token.comment {\n  color: #9badb7;\n}\n\n.codeflask .token.function {\n  color: #8500ff;\n}\n\n.codeflask .token.boolean {\n  color: #8500ff;\n}\n\n.codeflask .token.number {\n  color: #8500ff;\n}\n\n.codeflask .token.selector {\n  color: #8500ff;\n}\n\n.codeflask .token.property {\n  color: #8500ff;\n}\n\n.codeflask .token.tag {\n  color: #8500ff;\n}\n\n.codeflask .token.attr-value {\n  color: #8500ff;\n}\n`;
function cssSupports(e, t) {
  return CSS ? CSS.supports(e, t) : toCamelCase(e) in document.body.style;
}
function toCamelCase(e) {
  return (
    (e = e
      .split('-')
      .filter(function (e) {
        return !!e;
      })
      .map(function (e) {
        return e[0].toUpperCase() + e.substr(1);
      })
      .join(''))[0].toLowerCase() + e.substr(1)
  );
}
const FONT_FAMILY =
  '"SFMono-Regular", Consolas, "Liberation Mono", Menlo, Courier, monospace';
const COLOR = cssSupports('caret-color', '#000') ? BACKGROUND_COLOR : '#ccc';
const LINE_NUMBER_WIDTH = '40px';
const editorCss = `\n  .codeflask {\n    position: absolute;\n    width: 100%;\n    height: 100%;\n    overflow: hidden;\n  }\n\n  .codeflask, .codeflask * {\n    box-sizing: border-box;\n  }\n\n  .codeflask__pre {\n    pointer-events: none;\n    z-index: 3;\n    overflow: hidden;\n  }\n\n  .codeflask__textarea {\n    background: none;\n    border: none;\n    color: ${COLOR};\n    z-index: 1;\n    resize: none;\n    font-family: ${FONT_FAMILY};\n    -webkit-appearance: pre;\n    caret-color: #111;\n    z-index: 2;\n    width: 100%;\n    height: 100%;\n  }\n\n  .codeflask--has-line-numbers .codeflask__textarea {\n    width: calc(100% - ${LINE_NUMBER_WIDTH});\n  }\n\n  .codeflask__code {\n    display: block;\n    font-family: ${FONT_FAMILY};\n    overflow: hidden;\n  }\n\n  .codeflask__flatten {\n    padding: 10px;\n    font-size: ${FONT_SIZE};\n    line-height: ${LINE_HEIGHT};\n    white-space: pre;\n    position: absolute;\n    top: 0;\n    left: 0;\n    overflow: auto;\n    margin: 0 !important;\n    outline: none;\n    text-align: left;\n  }\n\n  .codeflask--has-line-numbers .codeflask__flatten {\n    width: calc(100% - ${LINE_NUMBER_WIDTH});\n    left: ${LINE_NUMBER_WIDTH};\n  }\n\n  .codeflask__line-highlight {\n    position: absolute;\n    top: 10px;\n    left: 0;\n    width: 100%;\n    height: ${LINE_HEIGHT};\n    background: rgba(0,0,0,0.1);\n    z-index: 1;\n  }\n\n  .codeflask__lines {\n    padding: 10px 4px;\n    font-size: 12px;\n    line-height: ${LINE_HEIGHT};\n    font-family: 'Cousine', monospace;\n    position: absolute;\n    left: 0;\n    top: 0;\n    width: ${LINE_NUMBER_WIDTH};\n    height: 100%;\n    text-align: right;\n    color: #999;\n    z-index: 2;\n  }\n\n  .codeflask__lines__line {\n    display: block;\n  }\n\n  .codeflask.codeflask--has-line-numbers {\n    padding-left: ${LINE_NUMBER_WIDTH};\n  }\n\n  .codeflask.codeflask--has-line-numbers:before {\n    content: '';\n    position: absolute;\n    left: 0;\n    top: 0;\n    width: ${LINE_NUMBER_WIDTH};\n    height: 100%;\n    background: #eee;\n    z-index: 1;\n  }\n`;
function injectCss(e, t, n) {
  const a = t || 'codeflask-style';
  const s = n || document.head;
  if (!e) return !1;
  if (document.getElementById(a)) return !0;
  const o = document.createElement('style');
  return (o.innerHTML = e), (o.id = a), s.appendChild(o), !0;
}
const entityMap = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#39;',
  '/': '&#x2F;',
  '`': '&#x60;',
  '=': '&#x3D;',
};
function escapeHtml(e) {
  return String(e).replace(/[&<>"'`=/]/g, function (e) {
    return entityMap[e];
  });
}
const commonjsGlobal =
  typeof window !== 'undefined'
    ? window
    : typeof global !== 'undefined'
    ? global
    : typeof self !== 'undefined'
    ? self
    : {};
function createCommonjsModule(e, t) {
  return e((t = { exports: {} }), t.exports), t.exports;
}
const prism = createCommonjsModule(function (e) {
  const t =
    typeof window !== 'undefined'
      ? window
      : typeof WorkerGlobalScope !== 'undefined' &&
        self instanceof WorkerGlobalScope
      ? self
      : {};
  const n = (function () {
    const e = /\blang(?:uage)?-([\w-]+)\b/i;
    let n = 0;
    var a = (t.Prism = {
      manual: t.Prism && t.Prism.manual,
      disableWorkerMessageHandler:
        t.Prism && t.Prism.disableWorkerMessageHandler,
      util: {
        encode(e) {
          return e instanceof s
            ? new s(e.type, a.util.encode(e.content), e.alias)
            : a.util.type(e) === 'Array'
            ? e.map(a.util.encode)
            : e
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/\u00a0/g, ' ');
        },
        type(e) {
          return Object.prototype.toString.call(e).match(/\[object (\w+)\]/)[1];
        },
        objId(e) {
          return (
            e.__id || Object.defineProperty(e, '__id', { value: ++n }), e.__id
          );
        },
        clone(e, t) {
          const n = a.util.type(e);
          switch (((t = t || {}), n)) {
            case 'Object':
              if (t[a.util.objId(e)]) return t[a.util.objId(e)];
              var s = {};
              for (const o in ((t[a.util.objId(e)] = s), e))
                e.hasOwnProperty(o) && (s[o] = a.util.clone(e[o], t));
              return s;
            case 'Array':
              if (t[a.util.objId(e)]) return t[a.util.objId(e)];
              s = [];
              return (
                (t[a.util.objId(e)] = s),
                e.forEach(function (e, n) {
                  s[n] = a.util.clone(e, t);
                }),
                s
              );
          }
          return e;
        },
      },
      languages: {
        extend(e, t) {
          const n = a.util.clone(a.languages[e]);
          for (const s in t) n[s] = t[s];
          return n;
        },
        insertBefore(e, t, n, s) {
          const o = (s = s || a.languages)[e];
          if (arguments.length == 2) {
            for (var i in (n = arguments[1]))
              n.hasOwnProperty(i) && (o[i] = n[i]);
            return o;
          }
          const r = {};
          for (const l in o)
            if (o.hasOwnProperty(l)) {
              if (l == t) for (var i in n) n.hasOwnProperty(i) && (r[i] = n[i]);
              r[l] = o[l];
            }
          return (
            a.languages.DFS(a.languages, function (t, n) {
              n === s[e] && t != e && (this[t] = r);
            }),
            (s[e] = r)
          );
        },
        DFS(e, t, n, s) {
          for (const o in ((s = s || {}), e))
            e.hasOwnProperty(o) &&
              (t.call(e, o, e[o], n || o),
              a.util.type(e[o]) !== 'Object' || s[a.util.objId(e[o])]
                ? a.util.type(e[o]) !== 'Array' ||
                  s[a.util.objId(e[o])] ||
                  ((s[a.util.objId(e[o])] = !0), a.languages.DFS(e[o], t, o, s))
                : ((s[a.util.objId(e[o])] = !0),
                  a.languages.DFS(e[o], t, null, s)));
        },
      },
      plugins: {},
      highlightAll(e, t) {
        a.highlightAllUnder(document, e, t);
      },
      highlightAllUnder(e, t, n) {
        const s = {
          callback: n,
          selector:
            'code[class*="language-"], [class*="language-"] code, code[class*="lang-"], [class*="lang-"] code',
        };
        a.hooks.run('before-highlightall', s);
        for (
          var o, i = s.elements || e.querySelectorAll(s.selector), r = 0;
          (o = i[r++]);

        )
          a.highlightElement(o, !0 === t, s.callback);
      },
      highlightElement(n, s, o) {
        for (var i, r, l = n; l && !e.test(l.className); ) l = l.parentNode;
        l &&
          ((i = (l.className.match(e) || [, ''])[1].toLowerCase()),
          (r = a.languages[i])),
          (n.className = `${n.className
            .replace(e, '')
            .replace(/\s+/g, ' ')} language-${i}`),
          n.parentNode &&
            ((l = n.parentNode),
            /pre/i.test(l.nodeName) &&
              (l.className = `${l.className
                .replace(e, '')
                .replace(/\s+/g, ' ')} language-${i}`));
        const c = {
          element: n,
          language: i,
          grammar: r,
          code: n.textContent,
        };
        if ((a.hooks.run('before-sanity-check', c), !c.code || !c.grammar))
          return (
            c.code &&
              (a.hooks.run('before-highlight', c),
              (c.element.textContent = c.code),
              a.hooks.run('after-highlight', c)),
            void a.hooks.run('complete', c)
          );
        if ((a.hooks.run('before-highlight', c), s && t.Worker)) {
          const u = new Worker(a.filename);
          (u.onmessage = function (e) {
            (c.highlightedCode = e.data),
              a.hooks.run('before-insert', c),
              (c.element.innerHTML = c.highlightedCode),
              o && o.call(c.element),
              a.hooks.run('after-highlight', c),
              a.hooks.run('complete', c);
          }),
            u.postMessage(
              JSON.stringify({
                language: c.language,
                code: c.code,
                immediateClose: !0,
              })
            );
        } else
          (c.highlightedCode = a.highlight(c.code, c.grammar, c.language)),
            a.hooks.run('before-insert', c),
            (c.element.innerHTML = c.highlightedCode),
            o && o.call(n),
            a.hooks.run('after-highlight', c),
            a.hooks.run('complete', c);
      },
      highlight(e, t, n) {
        const o = { code: e, grammar: t, language: n };
        return (
          a.hooks.run('before-tokenize', o),
          (o.tokens = a.tokenize(o.code, o.grammar)),
          a.hooks.run('after-tokenize', o),
          s.stringify(a.util.encode(o.tokens), o.language)
        );
      },
      matchGrammar(e, t, n, s, o, i, r) {
        const l = a.Token;
        for (const c in n)
          if (n.hasOwnProperty(c) && n[c]) {
            if (c == r) return;
            let u = n[c];
            u = a.util.type(u) === 'Array' ? u : [u];
            for (let d = 0; d < u.length; ++d) {
              let h = u[d];
              const p = h.inside;
              const g = !!h.lookbehind;
              const f = !!h.greedy;
              let m = 0;
              const b = h.alias;
              if (f && !h.pattern.global) {
                const k = h.pattern.toString().match(/[imuy]*$/)[0];
                h.pattern = RegExp(h.pattern.source, `${k}g`);
              }
              h = h.pattern || h;
              for (let y = s, C = o; y < t.length; C += t[y].length, ++y) {
                let v = t[y];
                if (t.length > e.length) return;
                if (!(v instanceof l)) {
                  if (f && y != t.length - 1) {
                    if (((h.lastIndex = C), !(_ = h.exec(e)))) break;
                    for (
                      var x = _.index + (g ? _[1].length : 0),
                        w = _.index + _[0].length,
                        F = y,
                        T = C,
                        L = t.length;
                      F < L && (T < w || (!t[F].type && !t[F - 1].greedy));
                      ++F
                    )
                      x >= (T += t[F].length) && (++y, (C = T));
                    if (t[y] instanceof l) continue;
                    (E = F - y), (v = e.slice(C, T)), (_.index -= C);
                  } else {
                    h.lastIndex = 0;
                    var _ = h.exec(v);
                    var E = 1;
                  }
                  if (_) {
                    g && (m = _[1] ? _[1].length : 0);
                    w = (x = _.index + m) + (_ = _[0].slice(m)).length;
                    const N = v.slice(0, x);
                    const S = v.slice(w);
                    const A = [y, E];
                    N && (++y, (C += N.length), A.push(N));
                    const I = new l(c, p ? a.tokenize(_, p) : _, b, _, f);
                    if (
                      (A.push(I),
                      S && A.push(S),
                      Array.prototype.splice.apply(t, A),
                      E != 1 && a.matchGrammar(e, t, n, y, C, !0, c),
                      i)
                    )
                      break;
                  } else if (i) break;
                }
              }
            }
          }
      },
      tokenize(e, t, n) {
        const s = [e];
        const o = t.rest;
        if (o) {
          for (const i in o) t[i] = o[i];
          delete t.rest;
        }
        return a.matchGrammar(e, s, t, 0, 0, !1), s;
      },
      hooks: {
        all: {},
        add(e, t) {
          const n = a.hooks.all;
          (n[e] = n[e] || []), n[e].push(t);
        },
        run(e, t) {
          const n = a.hooks.all[e];
          if (n && n.length) for (var s, o = 0; (s = n[o++]); ) s(t);
        },
      },
    });
    var s = (a.Token = function (e, t, n, a, s) {
      (this.type = e),
        (this.content = t),
        (this.alias = n),
        (this.length = 0 | (a || '').length),
        (this.greedy = !!s);
    });
    if (
      ((s.stringify = function (e, t, n) {
        if (typeof e === 'string') return e;
        if (a.util.type(e) === 'Array')
          return e
            .map(function (n) {
              return s.stringify(n, t, e);
            })
            .join('');
        const o = {
          type: e.type,
          content: s.stringify(e.content, t, n),
          tag: 'span',
          classes: ['token', e.type],
          attributes: {},
          language: t,
          parent: n,
        };
        if (e.alias) {
          const i = a.util.type(e.alias) === 'Array' ? e.alias : [e.alias];
          Array.prototype.push.apply(o.classes, i);
        }
        a.hooks.run('wrap', o);
        const r = Object.keys(o.attributes)
          .map(function (e) {
            return `${e}="${(o.attributes[e] || '').replace(/"/g, '&quot;')}"`;
          })
          .join(' ');
        return `<${o.tag} class="${o.classes.join(' ')}"${r ? ` ${r}` : ''}>${
          o.content
        }</${o.tag}>`;
      }),
      !t.document)
    )
      return t.addEventListener
        ? (a.disableWorkerMessageHandler ||
            t.addEventListener(
              'message',
              function (e) {
                const n = JSON.parse(e.data);
                const s = n.language;
                const o = n.code;
                const i = n.immediateClose;
                t.postMessage(a.highlight(o, a.languages[s], s)),
                  i && t.close();
              },
              !1
            ),
          t.Prism)
        : t.Prism;
    const o =
      document.currentScript ||
      [].slice.call(document.getElementsByTagName('script')).pop();
    return (
      o &&
        ((a.filename = o.src),
        a.manual ||
          o.hasAttribute('data-manual') ||
          (document.readyState !== 'loading'
            ? window.requestAnimationFrame
              ? window.requestAnimationFrame(a.highlightAll)
              : window.setTimeout(a.highlightAll, 16)
            : document.addEventListener('DOMContentLoaded', a.highlightAll))),
      t.Prism
    );
  })();
  e.exports && (e.exports = n),
    void 0 !== commonjsGlobal && (commonjsGlobal.Prism = n),
    (n.languages.markup = {
      comment: /<!--[\s\S]*?-->/,
      prolog: /<\?[\s\S]+?\?>/,
      doctype: /<!DOCTYPE[\s\S]+?>/i,
      cdata: /<!\[CDATA\[[\s\S]*?]]>/i,
      tag: {
        pattern: /<\/?(?!\d)[^\s>\/=$<%]+(?:\s+[^\s>\/=]+(?:=(?:("|')(?:\\[\s\S]|(?!\1)[^\\])*\1|[^\s'">=]+))?)*\s*\/?>/i,
        greedy: !0,
        inside: {
          tag: {
            pattern: /^<\/?[^\s>\/]+/i,
            inside: { punctuation: /^<\/?/, namespace: /^[^\s>\/:]+:/ },
          },
          'attr-value': {
            pattern: /=(?:("|')(?:\\[\s\S]|(?!\1)[^\\])*\1|[^\s'">=]+)/i,
            inside: {
              punctuation: [/^=/, { pattern: /(^|[^\\])["']/, lookbehind: !0 }],
            },
          },
          punctuation: /\/?>/,
          'attr-name': {
            pattern: /[^\s>\/]+/,
            inside: { namespace: /^[^\s>\/:]+:/ },
          },
        },
      },
      entity: /&#?[\da-z]{1,8};/i,
    }),
    (n.languages.markup.tag.inside['attr-value'].inside.entity =
      n.languages.markup.entity),
    n.hooks.add('wrap', function (e) {
      e.type === 'entity' &&
        (e.attributes.title = e.content.replace(/&amp;/, '&'));
    }),
    (n.languages.xml = n.languages.markup),
    (n.languages.html = n.languages.markup),
    (n.languages.mathml = n.languages.markup),
    (n.languages.svg = n.languages.markup),
    (n.languages.css = {
      comment: /\/\*[\s\S]*?\*\//,
      atrule: {
        pattern: /@[\w-]+?.*?(?:;|(?=\s*\{))/i,
        inside: { rule: /@[\w-]+/ },
      },
      url: /url\((?:(["'])(?:\\(?:\r\n|[\s\S])|(?!\1)[^\\\r\n])*\1|.*?)\)/i,
      selector: /[^{}\s][^{};]*?(?=\s*\{)/,
      string: {
        pattern: /("|')(?:\\(?:\r\n|[\s\S])|(?!\1)[^\\\r\n])*\1/,
        greedy: !0,
      },
      property: /[-_a-z\xA0-\uFFFF][-\w\xA0-\uFFFF]*(?=\s*:)/i,
      important: /\B!important\b/i,
      function: /[-a-z0-9]+(?=\()/i,
      punctuation: /[(){};:]/,
    }),
    (n.languages.css.atrule.inside.rest = n.languages.css),
    n.languages.markup &&
      (n.languages.insertBefore('markup', 'tag', {
        style: {
          pattern: /(<style[\s\S]*?>)[\s\S]*?(?=<\/style>)/i,
          lookbehind: !0,
          inside: n.languages.css,
          alias: 'language-css',
          greedy: !0,
        },
      }),
      n.languages.insertBefore(
        'inside',
        'attr-value',
        {
          'style-attr': {
            pattern: /\s*style=("|')(?:\\[\s\S]|(?!\1)[^\\])*\1/i,
            inside: {
              'attr-name': {
                pattern: /^\s*style/i,
                inside: n.languages.markup.tag.inside,
              },
              punctuation: /^\s*=\s*['"]|['"]\s*$/,
              'attr-value': { pattern: /.+/i, inside: n.languages.css },
            },
            alias: 'language-css',
          },
        },
        n.languages.markup.tag
      )),
    (n.languages.clike = {
      comment: [
        { pattern: /(^|[^\\])\/\*[\s\S]*?(?:\*\/|$)/, lookbehind: !0 },
        { pattern: /(^|[^\\:])\/\/.*/, lookbehind: !0, greedy: !0 },
      ],
      string: {
        pattern: /(["'])(?:\\(?:\r\n|[\s\S])|(?!\1)[^\\\r\n])*\1/,
        greedy: !0,
      },
      'class-name': {
        pattern: /((?:\b(?:class|interface|extends|implements|trait|instanceof|new)\s+)|(?:catch\s+\())[\w.\\]+/i,
        lookbehind: !0,
        inside: { punctuation: /[.\\]/ },
      },
      keyword: /\b(?:if|else|while|do|for|return|in|instanceof|function|new|try|throw|catch|finally|null|break|continue)\b/,
      boolean: /\b(?:true|false)\b/,
      function: /[a-z0-9_]+(?=\()/i,
      number: /\b0x[\da-f]+\b|(?:\b\d+\.?\d*|\B\.\d+)(?:e[+-]?\d+)?/i,
      operator: /--?|\+\+?|!=?=?|<=?|>=?|==?=?|&&?|\|\|?|\?|\*|\/|~|\^|%/,
      punctuation: /[{}[\];(),.:]/,
    }),
    (n.languages.javascript = n.languages.extend('clike', {
      keyword: /\b(?:as|async|await|break|case|catch|class|const|continue|debugger|default|delete|do|else|enum|export|extends|finally|for|from|function|get|if|implements|import|in|instanceof|interface|let|new|null|of|package|private|protected|public|return|set|static|super|switch|this|throw|try|typeof|var|void|while|with|yield)\b/,
      number: /\b(?:0[xX][\dA-Fa-f]+|0[bB][01]+|0[oO][0-7]+|NaN|Infinity)\b|(?:\b\d+\.?\d*|\B\.\d+)(?:[Ee][+-]?\d+)?/,
      function: /[_$a-z\xA0-\uFFFF][$\w\xA0-\uFFFF]*(?=\s*\()/i,
      operator: /-[-=]?|\+[+=]?|!=?=?|<<?=?|>>?>?=?|=(?:==?|>)?|&[&=]?|\|[|=]?|\*\*?=?|\/=?|~|\^=?|%=?|\?|\.{3}/,
    })),
    n.languages.insertBefore('javascript', 'keyword', {
      regex: {
        pattern: /((?:^|[^$\w\xA0-\uFFFF."'\])\s])\s*)\/(\[[^\]\r\n]+]|\\.|[^/\\\[\r\n])+\/[gimyu]{0,5}(?=\s*($|[\r\n,.;})\]]))/,
        lookbehind: !0,
        greedy: !0,
      },
      'function-variable': {
        pattern: /[_$a-z\xA0-\uFFFF][$\w\xA0-\uFFFF]*(?=\s*=\s*(?:function\b|(?:\([^()]*\)|[_$a-z\xA0-\uFFFF][$\w\xA0-\uFFFF]*)\s*=>))/i,
        alias: 'function',
      },
      constant: /\b[A-Z][A-Z\d_]*\b/,
    }),
    n.languages.insertBefore('javascript', 'string', {
      'template-string': {
        pattern: /`(?:\\[\s\S]|\${[^}]+}|[^\\`])*`/,
        greedy: !0,
        inside: {
          interpolation: {
            pattern: /\${[^}]+}/,
            inside: {
              'interpolation-punctuation': {
                pattern: /^\${|}$/,
                alias: 'punctuation',
              },
              rest: null,
            },
          },
          string: /[\s\S]+/,
        },
      },
    }),
    (n.languages.javascript[
      'template-string'
    ].inside.interpolation.inside.rest = n.languages.javascript),
    n.languages.markup &&
      n.languages.insertBefore('markup', 'tag', {
        script: {
          pattern: /(<script[\s\S]*?>)[\s\S]*?(?=<\/script>)/i,
          lookbehind: !0,
          inside: n.languages.javascript,
          alias: 'language-javascript',
          greedy: !0,
        },
      }),
    (n.languages.js = n.languages.javascript),
    typeof self !== 'undefined' &&
      self.Prism &&
      self.document &&
      document.querySelector &&
      ((self.Prism.fileHighlight = function () {
        const e = {
          js: 'javascript',
          py: 'python',
          rb: 'ruby',
          ps1: 'powershell',
          psm1: 'powershell',
          sh: 'bash',
          bat: 'batch',
          h: 'c',
          tex: 'latex',
        };
        Array.prototype.slice
          .call(document.querySelectorAll('pre[data-src]'))
          .forEach(function (t) {
            for (
              var a,
                s = t.getAttribute('data-src'),
                o = t,
                i = /\blang(?:uage)?-([\w-]+)\b/i;
              o && !i.test(o.className);

            )
              o = o.parentNode;
            if ((o && (a = (t.className.match(i) || [, ''])[1]), !a)) {
              const r = (s.match(/\.(\w+)$/) || [, ''])[1];
              a = e[r] || r;
            }
            const l = document.createElement('code');
            (l.className = `language-${a}`),
              (t.textContent = ''),
              (l.textContent = 'Loading…'),
              t.appendChild(l);
            const c = new XMLHttpRequest();
            c.open('GET', s, !0),
              (c.onreadystatechange = function () {
                c.readyState == 4 &&
                  (c.status < 400 && c.responseText
                    ? ((l.textContent = c.responseText), n.highlightElement(l))
                    : c.status >= 400
                    ? (l.textContent = `✖ Error ${c.status} while fetching file: ${c.statusText}`)
                    : (l.textContent =
                        '✖ Error: File does not exist or is empty'));
              }),
              c.send(null);
          }),
          n.plugins.toolbar &&
            n.plugins.toolbar.registerButton('download-file', function (e) {
              const t = e.element.parentNode;
              if (
                t &&
                /pre/i.test(t.nodeName) &&
                t.hasAttribute('data-src') &&
                t.hasAttribute('data-download-link')
              ) {
                const n = t.getAttribute('data-src');
                const a = document.createElement('a');
                return (
                  (a.textContent =
                    t.getAttribute('data-download-link-label') || 'Download'),
                  a.setAttribute('download', ''),
                  (a.href = n),
                  a
                );
              }
            });
      }),
      document.addEventListener('DOMContentLoaded', self.Prism.fileHighlight));
});
const CodeFlask = function (e, t) {
  if (!e)
    throw Error(
      'CodeFlask expects a parameter which is Element or a String selector'
    );
  if (!t)
    throw Error(
      'CodeFlask expects an object containing options as second parameter'
    );
  if (e.nodeType) this.editorRoot = e;
  else {
    const n = document.querySelector(e);
    n && (this.editorRoot = n);
  }
  (this.opts = t), this.startEditor();
};
(CodeFlask.prototype.startEditor = function () {
  if (!injectCss(editorCss, null, this.opts.styleParent))
    throw Error('Failed to inject CodeFlask CSS.');
  this.createWrapper(),
    this.createTextarea(),
    this.createPre(),
    this.createCode(),
    this.runOptions(),
    this.listenTextarea(),
    this.populateDefault(),
    this.updateCode(this.code);
}),
  (CodeFlask.prototype.createWrapper = function () {
    (this.code = this.editorRoot.innerHTML),
      (this.editorRoot.innerHTML = ''),
      (this.elWrapper = this.createElement('div', this.editorRoot)),
      this.elWrapper.classList.add('codeflask');
  }),
  (CodeFlask.prototype.createTextarea = function () {
    (this.elTextarea = this.createElement('textarea', this.elWrapper)),
      this.elTextarea.classList.add(
        'codeflask__textarea',
        'codeflask__flatten'
      );
  }),
  (CodeFlask.prototype.createPre = function () {
    (this.elPre = this.createElement('pre', this.elWrapper)),
      this.elPre.classList.add('codeflask__pre', 'codeflask__flatten');
  }),
  (CodeFlask.prototype.createCode = function () {
    (this.elCode = this.createElement('code', this.elPre)),
      this.elCode.classList.add(
        'codeflask__code',
        `language-${this.opts.language || 'html'}`
      );
  }),
  (CodeFlask.prototype.createLineNumbers = function () {
    (this.elLineNumbers = this.createElement('div', this.elWrapper)),
      this.elLineNumbers.classList.add('codeflask__lines'),
      this.setLineNumber();
  }),
  (CodeFlask.prototype.createElement = function (e, t) {
    const n = document.createElement(e);
    return t.appendChild(n), n;
  }),
  (CodeFlask.prototype.runOptions = function () {
    (this.opts.rtl = this.opts.rtl || !1),
      (this.opts.tabSize = this.opts.tabSize || 2),
      (this.opts.enableAutocorrect = this.opts.enableAutocorrect || !1),
      (this.opts.lineNumbers = this.opts.lineNumbers || !1),
      (this.opts.defaultTheme = !1 !== this.opts.defaultTheme),
      (this.opts.areaId = this.opts.areaId || null),
      (this.opts.ariaLabelledby = this.opts.ariaLabelledby || null),
      (this.opts.readonly = this.opts.readonly || null),
      typeof this.opts.handleTabs !== 'boolean' && (this.opts.handleTabs = !0),
      typeof this.opts.handleSelfClosingCharacters !== 'boolean' &&
        (this.opts.handleSelfClosingCharacters = !0),
      typeof this.opts.handleNewLineIndentation !== 'boolean' &&
        (this.opts.handleNewLineIndentation = !0),
      !0 === this.opts.rtl &&
        (this.elTextarea.setAttribute('dir', 'rtl'),
        this.elPre.setAttribute('dir', 'rtl')),
      !1 === this.opts.enableAutocorrect &&
        (this.elTextarea.setAttribute('spellcheck', 'false'),
        this.elTextarea.setAttribute('autocapitalize', 'off'),
        this.elTextarea.setAttribute('autocomplete', 'off'),
        this.elTextarea.setAttribute('autocorrect', 'off')),
      this.opts.lineNumbers &&
        (this.elWrapper.classList.add('codeflask--has-line-numbers'),
        this.createLineNumbers()),
      this.opts.defaultTheme &&
        injectCss(defaultCssTheme, 'theme-default', this.opts.styleParent),
      this.opts.areaId && this.elTextarea.setAttribute('id', this.opts.areaId),
      this.opts.ariaLabelledby &&
        this.elTextarea.setAttribute(
          'aria-labelledby',
          this.opts.ariaLabelledby
        ),
      this.opts.readonly && this.enableReadonlyMode();
  }),
  (CodeFlask.prototype.updateLineNumbersCount = function () {
    for (var e = '', t = 1; t <= this.lineNumber; t++)
      e = `${e}<span class="codeflask__lines__line">${t}</span>`;
    this.elLineNumbers.innerHTML = e;
  }),
  (CodeFlask.prototype.listenTextarea = function () {
    const e = this;
    this.elTextarea.addEventListener('input', function (t) {
      (e.code = t.target.value),
        (e.elCode.innerHTML = escapeHtml(t.target.value)),
        e.highlight(),
        setTimeout(function () {
          e.runUpdate(), e.setLineNumber();
        }, 1);
    }),
      this.elTextarea.addEventListener('keydown', function (t) {
        e.handleTabs(t),
          e.handleSelfClosingCharacters(t),
          e.handleNewLineIndentation(t);
      }),
      this.elTextarea.addEventListener('scroll', function (t) {
        (e.elPre.style.transform = `translate3d(-${t.target.scrollLeft}px, -${t.target.scrollTop}px, 0)`),
          e.elLineNumbers &&
            (e.elLineNumbers.style.transform = `translate3d(0, -${t.target.scrollTop}px, 0)`);
      });
  }),
  (CodeFlask.prototype.handleTabs = function (e) {
    if (this.opts.handleTabs) {
      if (e.keyCode !== 9) return;
      e.preventDefault();
      const t = this.elTextarea;
      const n = t.selectionDirection;
      const a = t.selectionStart;
      const s = t.selectionEnd;
      const o = t.value;
      let i = o.substr(0, a);
      let r = o.substring(a, s);
      const l = o.substring(s);
      const c = ' '.repeat(this.opts.tabSize);
      if (a !== s && r.length >= c.length) {
        const u = a - i.split('\n').pop().length;
        let d = c.length;
        let h = c.length;
        if (e.shiftKey)
          o.substr(u, c.length) === c
            ? ((d = -d),
              u > a
                ? ((r = r.substring(0, u) + r.substring(u + c.length)), (h = 0))
                : u === a
                ? ((d = 0), (h = 0), (r = r.substring(c.length)))
                : ((h = -h),
                  (i = i.substring(0, u) + i.substring(u + c.length))))
            : ((d = 0), (h = 0)),
            (r = r.replace(
              new RegExp(`\n${c.split('').join('\\')}`, 'g'),
              '\n'
            ));
        else
          (i = i.substr(0, u) + c + i.substring(u, a)),
            (r = r.replace(/\n/g, `\n${c}`));
        (t.value = i + r + l),
          (t.selectionStart = a + d),
          (t.selectionEnd = a + r.length + h),
          (t.selectionDirection = n);
      } else
        (t.value = i + c + l),
          (t.selectionStart = a + c.length),
          (t.selectionEnd = a + c.length);
      const p = t.value;
      this.updateCode(p),
        (this.elTextarea.selectionEnd = s + this.opts.tabSize);
    }
  }),
  (CodeFlask.prototype.handleSelfClosingCharacters = function (e) {
    if (this.opts.handleSelfClosingCharacters) {
      const t = e.key;
      if (
        ['(', '[', '{', '<', "'", '"'].includes(t) ||
        [')', ']', '}', '>', "'", '"'].includes(t)
      )
        switch (t) {
          case '(':
          case ')':
            this.closeCharacter(t);
            break;
          case '[':
          case ']':
            this.closeCharacter(t);
            break;
          case '{':
          case '}':
            this.closeCharacter(t);
            break;
          case '<':
          case '>':
          case "'":
          case '"':
            this.closeCharacter(t);
        }
    }
  }),
  (CodeFlask.prototype.setLineNumber = function () {
    (this.lineNumber = this.code.split('\n').length),
      this.opts.lineNumbers && this.updateLineNumbersCount();
  }),
  (CodeFlask.prototype.handleNewLineIndentation = function (e) {
    if (this.opts.handleNewLineIndentation && e.keyCode === 13) {
      e.preventDefault();
      const t = this.elTextarea;
      const n = t.selectionStart;
      const a = t.selectionEnd;
      const s = t.value;
      const o = s.substr(0, n);
      const i = s.substring(a);
      const r = s.lastIndexOf('\n', n - 1);
      const l = r + s.slice(r + 1).search(/[^ ]|$/);
      const c = l > r ? l - r : 0;
      const u = `${o}\n${' '.repeat(c)}${i}`;
      (t.value = u),
        (t.selectionStart = n + c + 1),
        (t.selectionEnd = n + c + 1),
        this.updateCode(t.value);
    }
  }),
  (CodeFlask.prototype.closeCharacter = function (e) {
    const t = this.elTextarea.selectionStart;
    const n = this.elTextarea.selectionEnd;
    if (this.skipCloseChar(e)) {
      const a = this.code.substr(n, 1) === e;
      const s = a ? n + 1 : n;
      const o = !a && ["'", '"'].includes(e) ? e : '';
      const i = `${this.code.substring(0, t)}${o}${this.code.substring(s)}`;
      this.updateCode(i),
        (this.elTextarea.selectionEnd = ++this.elTextarea.selectionStart);
    } else {
      let r = e;
      switch (e) {
        case '(':
          r = String.fromCharCode(e.charCodeAt() + 1);
          break;
        case '<':
        case '{':
        case '[':
          r = String.fromCharCode(e.charCodeAt() + 2);
      }
      const l = this.code.substring(t, n);
      const c = `${this.code.substring(0, t)}${l}${r}${this.code.substring(n)}`;
      this.updateCode(c);
    }
    this.elTextarea.selectionEnd = t;
  }),
  (CodeFlask.prototype.skipCloseChar = function (e) {
    const t = this.elTextarea.selectionStart;
    const n = this.elTextarea.selectionEnd;
    const a = Math.abs(n - t) > 0;
    return [')', '}', ']', '>'].includes(e) || (["'", '"'].includes(e) && !a);
  }),
  (CodeFlask.prototype.updateCode = function (e) {
    (this.code = e),
      (this.elTextarea.value = e),
      (this.elCode.innerHTML = escapeHtml(e)),
      this.highlight(),
      this.setLineNumber(),
      setTimeout(this.runUpdate.bind(this), 1);
  }),
  (CodeFlask.prototype.updateLanguage = function (e) {
    const t = this.opts.language;
    this.elCode.classList.remove(`language-${t}`),
      this.elCode.classList.add(`language-${e}`),
      (this.opts.language = e),
      this.highlight();
  }),
  (CodeFlask.prototype.addLanguage = function (e, t) {
    prism.languages[e] = t;
  }),
  (CodeFlask.prototype.populateDefault = function () {
    this.updateCode(this.code);
  }),
  (CodeFlask.prototype.highlight = function () {
    prism.highlightElement(this.elCode, !1);
  }),
  (CodeFlask.prototype.onUpdate = function (e) {
    if (e && {}.toString.call(e) !== '[object Function]')
      throw Error('CodeFlask expects callback of type Function');
    this.updateCallBack = e;
  }),
  (CodeFlask.prototype.getCode = function () {
    return this.code;
  }),
  (CodeFlask.prototype.runUpdate = function () {
    this.updateCallBack && this.updateCallBack(this.code);
  }),
  (CodeFlask.prototype.enableReadonlyMode = function () {
    this.elTextarea.setAttribute('readonly', !0);
  }),
  (CodeFlask.prototype.disableReadonlyMode = function () {
    this.elTextarea.removeAttribute('readonly');
  });
export default CodeFlask;
