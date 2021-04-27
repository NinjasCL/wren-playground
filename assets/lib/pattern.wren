// url: https://rosettacode.org/wiki/Category:Wren-pattern
// source: https://rosettacode.org/mw/index.php?title=Category_talk:Wren-pattern&action=edit&section=2
// file: pattern
// name: Wren-pattern
// author: PureFox
// license: MIT

/* Module "pattern.wren" */

/* Match represents a single successful match made by methods in the Pattern class.
   Match objects are immutable.
*/
class Match {
    // Constructs a Match object from the text of the match, its starting index as a codepoint offset
    // from the start of the string and its capture list. This is a private constructor
    // intended to be called from the Pattern class as there should be no need for the user
    // to construct Match objects directly.
    construct new_(text, index, captures) {
        if (!(text is String)) Fiber.abort("Match text must be a string.")
        if (!((index is Num) && index.isInteger && index >= 0)) {
            Fiber.abort("Match index must be a non-negative integer.")
        }
        if (!(captures is List)) Fiber.abort("Match captures must be a list of Capture objects.")
        _text = text
        _index = index
        _captures = captures
    }

    // Properties.
    text     { _text }                                // the text of the match
    index    { _index }                               // its starting index (codepoints)
    length   { _text.count }                          // its length
    span     { [_index, index + length - 1] }         // a list of its starting and ending indices
    captures { _captures.toList }                     // the Capture objects associated with the match
    capsText { _captures.map { |c| c.text }.toList }  // a list of each capture's text property

    // String representation (excluding captures)
    toString { "{ text = %(_text), index = %(_index), length = %(length) }" }
}

/* Capture represents a single successful capture made by methods in the Pattern class.
   Capture objects are immutable.
*/
class Capture {
    // Constructs a capture object from the text of the capture and its starting index
    // as a codepoint offset from the start of the string. This is a private constructor
    // intended to be called from the Pattern class as there should be no need for the user
    // to construct Capture objects directly.
    construct new_(text, index) {
        if (!(text is String)) Fiber.abort("Capture text must be a string.")
        if (!((index is Num) && index.isInteger && index >= 0)) {
            Fiber.abort("Capture index must be a non-negative integer.")
        }
        _text = text
        _index = index
    }

    // Properties.
    text     { _text }                        //  the text of the capture
    index    { _index }                       //  its starting index (codepoints)
    length   { _text.count }                  //  its length
    span     { [_index, index + length - 1] } //  a list of its starting and ending indices

    // String representation.
    toString { "{ text = %(_text), index = %(_index), length = %(length) }" }
}

/* Pattern represents a pattern to be used for matching characters within a string.
   A Pattern object is immutable.
*/
class Pattern {
    // Constant pattern types.
    static within { 0 }   // matches anywhere within a string
    static start  { 1 }   // matches only at the start of a string
    static end    { 2 }   // matches only at the end of a string
    static whole  { 3 }   // matches the whole of a string

    static types { ["within", "start", "end", "whole"] }

    // Constants to help construct user-defined patterns.
    static lower  { "abcdefghijklmnopqrstuvwxyz" }
    static upper  { "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
    static letter { lower + upper }
    static digit  { "0123456789" }
    static alpha  { letter + digit }

    // Private method to initialize function tables and back-reference symbols.
    static init_() {
        // character classes
        __fns = [
            Fn.new { |c| (c >= 65 && c <= 90) || (c >= 97 && c <= 122) },                         // a
            Fn.new { |c|  c == 48 || c == 49 },                                                   // b
            Fn.new { |c|  c <  32 || c == 127 },                                                  // c
            Fn.new { |c|  c >= 48 && c <= 57 },                                                   // d
            Fn.new { |c| (c >= 48 && c <= 57) || ".+-Ee".codePoints.contains(c) },                // e
            Fn.new { |c| (c >= 48 && c <= 57) || c == 46 },                                       // f
            Fn.new { |c|  c >= 33 && c < 127 },                                                   // g
            Fn.new { |c| (c >= 48 && c <= 57) || (c >= 65 && c <= 70) || (c >= 97 && c <= 102) }, // h
            Fn.new { |c, p|  p.i.codePoints.contains(c) },                                        // i
            Fn.new { |c, p|  p.j.codePoints.contains(c) },                                        // j
            Fn.new { |c, p|  p.k.codePoints.contains(c) },                                        // k
            Fn.new { |c|  c >= 97 && c <= 122 },                                                  // l
            Fn.new { |c| (c >= 97 && c <= 122) || (c >= 48 && c <= 57) },                         // m
            Fn.new { |c|  c == 43 || c == 45 },                                                   // n
            Fn.new { |c|  c >= 48 && c <= 55 },                                                   // o
            Fn.new { |c| (c >= 33 && c < 127) && !__fns[22].call(c) },                            // p
            Fn.new { |c|  c == 34 || c == 39 || c == 96 },                                        // q
            Fn.new { |c|  c < 128 },                                                              // r
            Fn.new { |c|  c == 32 || (c >= 9 && c <= 13) },                                       // s
            Fn.new { |c| ((c >= 9 && c <= 13) || (c >= 32 && c < 127)) && !__fns[22].call(c) },   // t
            Fn.new { |c|  c >= 65 && c <= 90 },                                                   // u
            Fn.new { |c| (c >= 65 && c <= 90) || (c >= 48 && c <= 57) },                          // v
            Fn.new { |c| (c >= 48 && c <= 57) || (c >= 65 && c <= 90) || (c >= 97 && c <= 122) }, // w
            Fn.new { |c|  __fns[22].call(c) || c == 95 },                                         // x
            Fn.new { |c|  __fns[22].call(c) || c == 95 || c == 39 || c == 45 },                   // y
            Fn.new { |c|  true }                                                                  // z
        ]

        // extended classes
        __fns2 = [
            Fn.new { |c|  __fns2[11].call(c) || __fns2[20].call(c) },                               // a
            Fn.new { |c|  c == 48 || c == 49 },                                                     // b
            Fn.new { |c|  c <  32 || (c >=  127 && c < 160) },                                      // c
            Fn.new { |c|  c >= 48 && c <= 57 },                                                     // d
            Fn.new { |c| (c >= 48 && c <= 57) || ".+-Ee".codePoints.contains(c) },                  // e
            Fn.new { |c| (c >= 48 && c <= 57) || c == 46 },                                         // f
            Fn.new { |c| (c >= 33 && c < 127) || (c >= 161 && c <= 255) },                          // g
            Fn.new { |c| (c >= 48 && c <= 57) || (c >= 65 && c <= 70) || (c >= 97 && c <= 102) },   // h
            Fn.new { |c, p|  p.i.codePoints.contains(c) },                                          // i
            Fn.new { |c, p|  p.j.codePoints.contains(c) },                                          // j
            Fn.new { |c, p|  p.k.codePoints.contains(c) },                                          // k
            Fn.new { |c| (c >= 97 && c <= 122) || c == 181 || (c >= 223 && c <= 255 && c != 247) }, // l
            Fn.new { |c|  __fns2[11].call(c) || (c >= 48 && c <= 57) },                             // m
            Fn.new { |c|  c == 43 || c == 45 || c == 177 },                                         // n
            Fn.new { |c|  c >= 48 && c <= 55 },                                                     // o
            Fn.new { |c|  __fns2[6].call(c) && !__fns2[22].call(c) },                               // p
            Fn.new { |c|  c == 34 || c == 39 || c == 96 || c == 171 || c == 187 },                  // q
            Fn.new { |c|  c < 256 },                                                                // r
            Fn.new { |c|  c == 32 || (c >= 9 && c <= 13) || c == 160 },                             // s
            Fn.new { |c|  __fns2[15].call || __fns2[18].call },                                     // t
            Fn.new { |c| (c >= 65 && c <= 90) || (c >= 192 && c <= 222 && c != 215) },              // u
            Fn.new { |c|  __fns2[20].call(c) || (c >= 48 && c <= 57) },                             // v
            Fn.new { |c| (c >= 48 && c <= 57) || __fns2[0].call(c) },                               // w
            Fn.new { |c|  __fns2[22].call(c) || c == 95 },                                          // x
            Fn.new { |c|  __fns2[22].call(c) || c == 95 || c == 39 || c == 45 || c == 173 },        // y
            Fn.new { |c|  true }                                                                    // z
        ]

        // back reference symbols
        __backRefs = ["$1", "$2", "$3", "$4", "$5", "$6", "$7", "$8", "$9"]
    }

    // Returns a list of the text properties of each match in matches.
    static matchesText(matches) { matches.map { |m| m.text }.toList }

    // Returns whether a pattern string is valid or not.
    static validate(pattern) {
        if (!((pattern is String) && pattern != "")) return false
        return !Fiber.new {
            validate_(pattern)
        }.try()
    }

    // Private worker method to validate and tokenize a pattern and get its minimum matching length.
    static validate_(pattern) {
        var min = 0                        // minimum length
        var pc = pattern.codePoints.toList // pattern codepoints
        var lpc = pc.count                 // pattern length
        var i = 0                          // codepoint index
        var cap = false                    // whether within a capture
        var captures = []                  // stores min length for each capture
        var curMin = 0                     // minimum length of current mini-pattern
        var capMin = 0                     // minimum length of current capture
        var c = 0                          // current codepoint
        var tokens = []                    // tokenize pattern to make subsequent matching easier

        // Increments min or curMin.
        var increment = Fn.new { |imin|
            if (!cap) {
                min = min + imin
            } else {
                curMin = curMin + imin
            }
        }

        // Handles the slash or ampersand metacharacters.
        var slashOrAmp = Fn.new { |reps|
            i = i + 1
            if (i == lpc) Fiber.abort("Invalid pattern - missing character at index %(i).")
            var d = pc[i]
            if (reps > 0) increment.call(reps)
            if (d >= 97 && d <= 122) {
                tokens.add(-c)
                tokens.add(d - 97)
            } else if (d >= 65 && d <= 89) {
                tokens.add(-c)
                tokens.add(d - 39)
            } else {
                tokens.add(d)
            }
        }

        // Handles the caret or at sign metacharacters.
        var caretOrAt = Fn.new { |reps|
            i = i + 1
            if (i == lpc) Fiber.abort("Invalid pattern - missing character at index %(i).")
            if (reps > 0) increment.call(reps)
            var d = pc[i]
            if (c == 94) {
                tokens.add(-c)
                tokens.add(d)
            } else {
                if (__fns2[20].call(d)) {
                    tokens.add(-c)
                    tokens.add(d)
                    tokens.add(d + 32)
                } else if (__fns2[11].call(d) && d != 181 && d != 223 && d != 255) {
                    tokens.add(-c)
                    tokens.add(d)
                    tokens.add(d - 32)
                } else {
                    tokens.add(d)
                }
            }
        }

        while (i < lpc) {
            c = pc[i]                          // current codepoint
            if (c == 47 || c == 38) {          // slash = character class, ampersand = extended class
                slashOrAmp.call(1)
            } else if (c == 94 || c == 64 ) {  // caret = complement, at sign = either-case
                caretOrAt.call(1)
            } else if (c == 61 || c == 43 || c == 35) { // multiple, minimum or range
                i = i + 1
                if (i == lpc) Fiber.abort("Invalid pattern - missing digit at index %(i).")
                var d = pc[i]                  // get the next codepoint
                if (d < 48 || d > 57) Fiber.abort("Invalid pattern - non-digit found at index %(i).")
                tokens.add(-c)
                var reps = d - 48
                tokens.add(reps)
                if (c == 61) {        // equals sign = multiple
                    if (reps < 2) {
                        reps = reps + 10
                        tokens[-1] = reps
                    }
                } else if (c == 35) { // hash = range
                    if (reps == 9) {
                        Fiber.abort("Invalid pattern - first digit cannot exceed eight at index %(i).")
                    }
                    i = i + 1
                    if (i == lpc) Fiber.abort("Invalid pattern - missing second digit at index %(i).")
                    var e = pc[i]
                    if (e < 48 || e > 57) Fiber.abort("Invalid pattern - non-digit found at index %(i).")
                    if (e <= d) {
                        Fiber.abort("Invalid pattern - seocond digit must be greater than first at index %(i).")
                    }
                    tokens.add(e - 48)
                }
                i = i + 1
                if (i == pc.count) {
                    Fiber.abort("Invalid pattern - missing 'single' at index %(i).")
                }
                c = pc[i]   // get the next codepoint
                if (c == 47 || c == 38) {
                    slashOrAmp.call(reps)
                } else if (c == 94 || c == 64) {
                    caretOrAt.call(reps)
                } else if ("=+#~[]|$".codePoints.contains(c)) {
                    Fiber.abort("Invalid pattern - missing 'single' at index %(i).")
                } else {
                    increment.call(reps)
                    tokens.add(c)
                }
            } else if (c == 126) { // tilde == optional
                i = i + 1
                if (i == lpc) Fiber.abort("Invalid pattern - missing 'single' at index %(i).")
                tokens.add(-35) // use range for tokenization purposes
                tokens.add(0)
                tokens.add(1)
                c = pc[i]  // get the next codepoint
                if (c == 47 || c == 38) {
                    slashOrAmp.call(0)
                } else if (c == 94 || c == 64) {
                    caretOrAt.call(0)
                } else if ("=+#~[]|$".codePoints.contains(c)) {
                    Fiber.abort("Invalid pattern - missing 'single' at index %(i).")
                } else {
                    tokens.add(c)
                }
            } else if (c == 91) { // left square bracket = capture opening
                if (cap) Fiber.abort("Invalid pattern - orphan [ found.")
                cap = true
                curMin = 0
                capMin = Num.largest
                tokens.add(-91)
            } else if (c == 124) { // vertical bar = end of mini-pattern
                if (!cap) Fiber.abort("Invalid pattern - orphan | found.")
                if (curMin < capMin) capMin = curMin
                curMin = 0
                tokens.add(-124)
            } else if (c == 93) { // right square bracket = capture end
                if (!cap) Fiber.abort("Invalid pattern - orphan ] found.")
                if (curMin < capMin) capMin = curMin
                cap = false
                increment.call(capMin)
                captures.add(capMin)
                tokens.add(-93)
            } else if (c == 36) { // dollar sign = back-reference
                i = i + 1
                if (i == lpc) Fiber.abort("Invalid pattern - missing digit at index %(i).")
                c = pc[i]       // get the next codepoint
                if (c < 48 || c > 57) Fiber.abort("Invalid pattern - non-digit found at index %(i).")
                c = c - 48
                if (c == 0) {
                    increment.call(min)
                } else if (c > captures.count) {
                    Fiber.abort("Invalid pattern - back-reference exceeds capture count at %(i).")
                } else {
                    increment.call(captures[c-1])
                }
                tokens.add(-36)
                tokens.add(c)
            } else { // normal character
                increment.call(1)
                tokens.add(c)
            }
            i = i + 1
        }
        if (cap) Fiber.abort("Invalid pattern - capture unfinished at %(i).")
        return [min, tokens]
    }

    // Private worker method.
    // Looks for a pattern match for the string 's' starting from codepoint index 'start'.
    // Returns a Match object if a match is found or null otherwise.
    match_(s, start) {
        var tokens = _tokens.toList     // use a copy as we might change it
        var tc = tokens.count           // tokens length
        var ti = 0                      // tokens index
        var t = tokens[ti]              // current token
        var codes = s.codePoints.toList // string codepoints
        var sc = s.count                // string codepoints count
        var si = start                  // string codepoints index
        var c = -1                      // string current codepoint
        var consumed = false            // whether current codepoint has been consumed
        var cap = false                 // whether within a capture
        var captures = []               // stores captures
        var wm = ""                     // matched so far in string as a whole
        var cm = ""                     // matched so far in current capture
        var ci = 0                      // string index at which capture started

        if (si < sc) c = codes[si]

        // Consume current character.
        var consume = Fn.new {
            if (!cap) {
                wm = wm + String.fromCodePoint(c)
            } else {
                cm = cm + String.fromCodePoint(c)
            }
            consumed = true
        }

        // Moves token index, where necessary, to next metacharacter
        var moveTokenIndex = Fn.new { |z|
             if (z == -47 || z == -38 || z == -94) {
                ti = ti + 1
             } else if (z == -64) {
                ti = ti + 2
             }
        }

        // Checks if there's another mini-pattern in the current capture and if so prepares to match it.
        var nextMiniPattern = Fn.new {
            while (true) {
                ti = ti + 1
                t = tokens[ti]
                if (t == -93) return false // end of capture
                if (t == -124) {
                    cm = ""
                    si = ci
                    c = codes[si]
                    break
                }
            }
            return true
        }

        // Checks that there are no more options to consider before declaring a non-match.
        var noMore = Fn.new { !cap || !nextMiniPattern.call() }

        // Checks if character class matches and if so consumes character.
        var slash = Fn.new { |inc|
            if (inc) ti = ti + 1
            var u = tokens[ti]
            if (u >= 8 && u <= 10) {
                if (!__fns[u].call(c, this)) return false
            } else if (u < 26) {
                if (!__fns[u].call(c)) return false
            } else if (u >= 34 && u <= 36) {
                if (__fns[u-26].call(c, this)) return false
            } else {
                if (__fns[u-26].call(c)) return false
            }
            consume.call()
            return true
        }

        // Checks if extended class matches and if so consumes character.
        var ampersand = Fn.new { |inc|
            if (inc) ti = ti + 1
            var u = tokens[ti]
            if (u >= 8 && u <= 10) {
                if (!__fns2[u].call(c, this)) return false
            } else if (u < 26) {
                if (!__fns2[u].call(c)) return false
            } else if (u >= 34 && u <= 36) {
                if (__fns2[u-26].call(c, this)) return false
            } else {
                if (__fns2[u-26].call(c)) return false
            }
            consume.call()
            return true
        }

        // Checks if complement matches and if so consumes character.
        var caret = Fn.new { |inc|
            if (inc) ti = ti + 1
            var u = tokens[ti]
            if (c == u) return false
            consume.call()
            return true
        }

        // Checks if either-case matches and if so consumes character.
        var at = Fn.new { |inc|
            var u
            var v
            if (inc) {
                u = tokens[ti + 1]
                v = tokens[ti + 2]
                ti = ti + 2
            } else {
                u = tokens[ti-1]
                v = tokens[ti]
            }
            if (u > v) { // lower case first
                if (c != u && c != v) return false
            } else {
                if (c == u || c == v) return false
            }
            consume.call()
            return true
        }

        // Checks if ordinary character matches and if so consumes character.
        var character = Fn.new { |z|
            if (c != z) return false
            consume.call()
            return true
        }

        while (true) {
            for (i in 1..1) { // dummy loop so break can emulate goto
                if (t == -47) {  // slash = character class
                    if (si == sc) if (noMore.call()) return null else break
                    if (!slash.call(true) && noMore.call()) return null
                } else if (t == -38) { // ampersand = extended class
                    if (si == sc) if (noMore.call()) return null else break
                    if (!ampersand.call(true) && noMore.call()) return null
                } else if (t == -94) { // caret = complement
                    if (si == sc) if (noMore.call()) return null else break
                    if (!caret.call(true) && noMore.call()) return null
                } else if (t == -64) { // at sign = either-case
                    if (si == sc) if (noMore.call) return null else break
                    if (!at.call(true) && noMore.call()) return null
                } else if (t == -61 || t == -43 || t == -35) { // quantifier
                    ti = ti + 1
                    var required = tokens[ti]
                    var reps
                    if (t == -61) {        // equals sign = multiple
                        reps = required
                    } else if (t == -43) { // plus sign = minimum
                        reps = Num.largest
                    } else if (t == -35) { // hash sign = range
                        ti = ti + 1
                        reps = tokens[ti]
                    }
                    ti = ti + 1
                    var z = tokens[ti]
                    if (si == sc) {
                        if (required > 0) {
                            if (noMore.call()) return null else break
                        } else {
                            moveTokenIndex.call(z)
                            break
                        }
                    }
                    if (z >= 0) { // ordinary character
                        for (i in 1..reps) {
                            if (!character.call(z)) {
                                if (i <= required && noMore.call()) return null
                                break
                            }
                            if (i == reps) break
                            si = si + 1
                            consumed = false
                            if (si == sc) {
                                if (i < required && noMore.call()) return null
                                break
                            }
                            c = codes[si]
                        }
                    } else if (z == -47) { // character class
                        for (i in 1..reps) {
                            if (!slash.call(i == 1)) {
                                if (i <= required && noMore.call()) return null
                                break
                            }
                            if (i == reps) break
                            si = si + 1
                            consumed = false
                            if (si == sc) {
                                if (i < required && noMore.call()) return null
                                break
                            }
                            c = codes[si]
                        }
                    } else if (z == -38) { // extended class
                        for (i in 1..reps) {
                            if (!ampersand.call(i == 1)) {
                                if (i <= required && noMore.call()) return null
                                break
                            }
                            if (i == reps) break
                            si = si + 1
                            consumed = false
                            if (si == sc) {
                                if (i < required && noMore.call()) return null
                                break
                            }
                            c = codes[si]
                        }
                    } else if (z == -94) { // complement
                        for (i in 1..reps) {
                            if (!caret.call(i == 1)) {
                                if (i <= required && noMore.call()) return null
                                break
                            }
                            if (i == reps) break
                            si = si + 1
                            consumed = false
                            if (si == sc) {
                                if (i < required && noMore.call()) return null
                                break
                            }
                            c = codes[si]
                        }
                    } else if (z == -64) { // either-case
                        for (i in 1..reps) {
                            if (!at.call(i == 1)) {
                                if (i <= required && noMore.call()) return null
                                break
                            }
                            if (i == reps) break
                            si = si + 1
                            consumed = false
                            if (si == sc) {
                                if (i < required && noMore.call()) return null
                                break
                            }
                            c = codes[si]
                        }
                    }
                } else if (t == -91) { // capture opening
                    cap = true
                    cm = ""
                    ci = si
                } else if (t == -124) { // end of mini-pattern
                    captures.add(Capture.new_(cm, ci))
                    wm = wm + cm
                    cap = false
                    while (true) { // find capture end
                        ti = ti + 1
                        t = tokens[ti]
                        if (t == -93) break
                    }
                } else if (t == -93) { // capture end
                    captures.add(Capture.new_(cm, ci))
                    wm = wm + cm
                    cap = false
                } else if (t == -36) { // back-reference
                    ti = ti + 1
                    var cn = tokens[ti]
                    var text = (cn > 0) ? captures[cn-1].text : wm
                    if (si == sc && text.Count > 0 && noMore.call()) return null
                    var tokens1 = tokens[0..ti]
                    var tokens2 = tokens[ti+1..-1]
                    tokens = tokens1 + text.codePoints.toList + tokens2
                    tc = tokens.count
                } else { // ordinary character
                    if (si == sc) if (noMore.call()) return null else break
                    if (!character.call(t) && noMore.call()) return null
                }
            } // end for loop
            ti = ti + 1
            if (ti == tc) break
            t = tokens[ti]
            if (consumed) {
                si = si + 1
                consumed = false
                if (si < sc) {
                    c = codes[si]
                }
            }
        }

        return Match.new_(wm, start, captures)
    }

    // Constructs a Pattern object from a pattern, its type and its user defined character
    // classes. If an empty string is passed for the latter, they use their defaults.
    construct new(pattern, type, i, j, k) {
        if (!((pattern is String) && pattern != "")) {
            Fiber.abort("Pattern must be a non-empty string.")
        }
        var mt = Pattern.validate_(pattern)
        _minLen = mt[0]
        _tokens = mt[1]
        _pattern = pattern
        if (!((type is Num) && type.isInteger && type >= 0 &&  type <= 3)) {
             Fiber.abort("Pattern type must be an integer between 0 and 3 inclusive.")
        }
        _type = type
        if (!((i is String) && (j is String) && (k is String))) {
            Fiber.abort("Used defined class must be a string.")
        }
        _i = (i != "") ? i : "012"
        _j = (j != "") ? j : "0123"
        _k = (k != "") ? k : "01234"
    }

    // Convenience methods which call the constructor with default values for some arguments.
    static new(pattern, type, i, j) { new(pattern, type,  i,  j, "") }
    static new(pattern, type, i)    { new(pattern, type,  i, "", "") }
    static new(pattern, type)       { new(pattern, type, "", "", "") }
    static new(pattern)             { new(pattern,    0, "", "", "") }

    // Properties.
    pattern  { _pattern }   // the pattern string
    type     { _type    }   // its type
    minLen   { _minLen  }   // its minimum matching length (possibly zero)
    i        { _i }         // the user defined character class represented by /i
    j        { _j }         // the user defined character class represented by /j
    k        { _k }         // the user defined character class represented by /k

    // Checks whether the pattern matches a string or not.
    isMatch(s) { find(s) != null }

    // Finds and returns the first match (as a Match object) or null if there are no matches.
    find(s) {
        if (!(s is String)) Fiber.abort("Argument must be a string.")
        var sc = s.count
        if (sc < _minLen) return null
        if (_type == Pattern.within) {
            var maxStart = sc - _minLen
            for (start in 0..maxStart) {
                var m = match_(s, start)
                if (m) return m
            }
            return null
        }
        if (_type == Pattern.start) return match_(s, 0)
        if (_type == Pattern.end) {
            var maxStart = sc - _minLen
            for (start in 0..maxStart) {
                var m = match_(s, start)
                if (m && ((start + m.length) == sc)) return m
            }
            return null
        }
        if (_type == Pattern.whole) {
            var m = match_(s, 0)
            if (!m || m.length < sc) return null
            return m
        }
    }

    // Finds and returns all successive non-overlapping matches, if there are any,
    // as a list of Match objects. The list will be empty if there are no matches.
    // To prevent infinite recursion, it stops at (but includes) the first empty match.
    // Note that apart from Pattern.within there can never be more than one match.
    findAll(s) {
        var m = find(s)
        if (!_type == Pattern.within) {
            return (m) ? [m] : []
        }
        if (!m) return []
        var sc = s.count
        var matches = [m]
        if (m.length == 0) return matches
        var start = m.index + m.length
        while (start + _minLen <= sc) {
            m = match_(s, start)
            if (m) {
                matches.add(m)
                if (m.length == 0) break
                start = start + m.length
            } else {
                start = start + 1
            }
        }
        return matches
    }

    // Replaces up to 'n' successive matches in 's', optionally skipping some of those 'n', by the
    // replacement string 'repl'. If there are no (or not enough) matches, returns 's' itself.
    // If n <= 1, uses all matches as separators.
    replace(s, repl, n, skip) {
        if (!(s is String) || !(repl is String)) Fiber.abort("First two arguments must be strings.")
        if (!((n is Num) && n.isInteger)) Fiber.abort("Third argument must be an integer.")
        if (!((skip is Num) && skip.isInteger && skip >= 0)) {
            Fiber.abort("Fourth argument must be a non-negative integer.")
        }
        var matches = findAll(s)
        var c = matches.count
        if (c == 0) return s
        if (n < 1 || n > c) n = c
        if (n <= skip) return s
        if (skip > 0 || n < c) matches = matches[skip...n]
        var cps = s.codePoints.toList
        var addIndex = 0
        for (m in matches) {
            var caps = m.captures
            var count = 0
            for (br in __backRefs[0...caps.count]) {
                repl = repl.replace(br, caps[count].text)
                count = count + 1
            }
            repl = repl.replace("$0", m.text)
            repl = repl.replace("$$", "$")
            var s1 = cps[0...addIndex + m.index]
            var s2 = repl.codePoints.toList
            var s3 = cps[addIndex + m.index + m.length..-1]
            cps = s1 + s2 + s3
            addIndex = addIndex + s2.count - m.length
        }
        return cps.map { |cp| String.fromCodePoint(cp) }.join()
    }

    // Convenience version of the above method which replaces all matches.
    replaceAll(s, repl) { replace(s, repl, 0, 0) }

    // Splits the string into a list of up to 'n+1' substrings using pattern matches as the separators
    // optionally skipping some of those 'n' separators.
    // If there are no matches returns a list with a single element, 's' itself.
    // If n < 1, uses all the matches as separators.
    split(s, n, skip) {
        if (!(s is String)) Fiber.abort("First argument must be a string.")
        if (!((n is Num) && n.isInteger)) Fiber.abort("Second argument must be an integer.")
        if (!((skip is Num) && skip.isInteger && skip >= 0)) {
            Fiber.abort("Third argument must be a non-negative integer.")
        }
        var matches = findAll(s)
        var c = matches.count
        if (c == 0) return [s]
        if (n < 1 || n > c) n = c
        if (n <= skip) return [s]
        if (skip > 0 || n < c) matches = matches[skip...n]
        var cps = s.codePoints.toList
        var splits = []
        var prev = 0
        for (m in matches) {
            var next = m.index
            var item = cps[prev...next]
            splits.add(item.map { |cp| String.fromCodePoint(cp) }.join())
            prev = next + m.length
        }
        splits.add(cps[prev..-1].map { |cp| String.fromCodePoint(cp) }.join())
        return splits
    }

    // Convenience version of the above method which uses all the matches as separators.
    splitAll(s) { split(s, 0, 0) }

    // String representation (excluding user defined character classes).
    toString { "{ pattern = %(_pattern), type = %(Pattern.types[_type]), min length = %(_minLen) }" }
}

// Type aliases for classes in case of any name clashes with other modules.
var Pattern_Match   = Match
var Pattern_Capture = Capture
var Pattern_Pattern = Pattern

Pattern.init_()
