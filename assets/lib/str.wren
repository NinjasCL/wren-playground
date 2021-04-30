// url: https://rosettacode.org/wiki/Category:Wren-str
// source: https://rosettacode.org/mw/index.php?title=Category_talk:Wren-str&action=edit&section=1
// file: str
// name: Wren-str
// author: PureFox
// license: MIT

/* Module "str.wren" */

/*
   Char contains routines to perform various operations on characters.
   A 'character' for this purpose is a single Unicode codepoint.
   Categorization and casing is supported for characters < 256 (Latin-1) but no higher.
   The 'symbol' category includes 'other letter', 'other number' and soft hyphen (ªº¹²³¼½¾¯).
   For convenience a string containing more than one character can be passed
   as an argument but the methods will only operate on the first character.
*/
class Char {
    // Returns the codepoint of the first character of a string.
    static code(c) { (c is String && !c.isEmpty) ? c.codePoints[0] :
                      Fiber.abort("Argument must be a non-empty string.") }

    // Convenience method to return a character from its codepoint.
    static fromCode(c) { String.fromCodePoint(c) }

    // Checks if the first character of a string falls into a particular category.
    static isAscii(c)       { code(c) < 128 }
    static isLatin1(c)      { code(c) < 256 }

    // ASCII categories.
    static isDigit(c)         { (c = code(c)) && c >= 48 && c <= 57 }
    static isAsciiLower(c)    { (c = code(c)) && c >= 97 && c <= 122 }
    static isAsciiUpper(c)    { (c = code(c)) && c >= 65 && c <= 90 }
    static isAsciiLetter(c)   { isAsciiLower(c) || isAsciiUpper(c) }
    static isAsciiAlphaNum(c) { isAsciiLower(c) || isAsciiUpper(c) || isDigit(c) }
    static isSpace(c)         { (c = code(c)) && (c == 32 || c == 9 || c == 10 || c == 13) }

    // Latin-1 categories.
    static isLower(c) {
        var d = code(c)
        return (d >= 97 && d <= 122) || (d == 181) || (d >= 223 && d <= 246) ||
               (d >= 248 && d <= 255)
    }

    static isUpper(c) {
        var d = code(c)
        return (d >= 65 && d <= 90) || (d >= 192 && d <= 214) || (d >= 216 && d <= 222)
    }

    static isLetter(c)       { isLower(c) || isUpper(c) }
    static isAlphaNumeric(c) { isLower(c) || isUpper(c) || isDigit(c) }

    static isControl(c) {
        var d = code(c)
        return d < 32 || (d >= 127 && d < 160)
    }

    static isPrintable(c) {
        var d = code(c)
        return (d >= 32 && d < 127) || (d >= 160 && d < 256)
    }

    static isGraphic(c) {
        var d = code(c)
        return (d >= 33 && d < 127) || (d >= 161 && d < 256)
    }

    static isWhitespace(c) {
        var d = code(c)
        return d == 32 || (d >= 9 && c <= 13) || d == 160
    }

    static isPunctuation(c) { code(c) && "!\"#\%&'()*,-./:;?@[\\]_{}¡§«¶·»¿".contains(c[0]) }

    static isSymbol(c) { isGraphic(c) && !isAlpaNumeric(c) && !isPunctuation(c) }

    static category(c) {
        var d = code(c)
        return (d  <  32)             ? "control"     :
               (d ==  32)             ? "space"       :
               (d >=  48 && d <= 57)  ? "digit"       :
               (d >=  65 && d <= 90)  ? "upper"       :
               (d >=  97 && d <= 122) ? "lower"       :
               (d >= 127 && d <= 159) ? "control"     :
               (d == 160)             ? "space"       :
               (d == 181)             ? "lower"       :
               (d >= 192 && d <= 214) ? "upper"       :
               (d >= 216 && d <= 222) ? "upper"       :
               (d >= 223 && d <= 246) ? "lower"       :
               (d >= 248 && d <= 255) ? "lower"       :
               (d >= 256)             ? "non-latin1"  :
               isPunctuation(c)       ? "punctuation" : "symbol"
    }

    // Returns the first character of a string converted to lower case.
    static lower(c) {
        var d = code(c)
        if ((d >= 65 && d <= 90) || (d >= 192 && d <= 214) || (d >= 216 && d <= 222)) {
            return fromCode(d+32)
        }
        return c[0]
    }

    // Returns the first character of a string converted to upper case.
    static upper(c) {
        var d = code(c)
        if ((d >= 97 && d <= 122) || (d >= 224 && d <= 246) || (d >= 248 && d <= 254)) {
            return fromCode(d-32)
        }
        return c[0]
    }

    // Swaps the case of the first character in a string.
    static swapCase(c) {
        var d = code(c)
        if ((d >= 65 && d <= 90) || (d >= 192 && d <= 214) || (d >= 216 && d <= 222)) {
            return fromCode(d+32)
        }
        if ((d >= 97 && d <= 122) || (d >= 224 && d <= 246) || (d >= 248 && d <= 254)) {
            return fromCode(d-32)
        }
        return c[0]
    }
}

/* Str supplements the String class with various other operations on strings. */
class Str {
    // Mimics the comparison operators <, <=, >, >=
    // not supported by the String class.
    static lt(s1, s2) { compare(s1, s2) <  0 }
    static le(s1, s2) { compare(s1, s2) <= 0 }
    static gt(s1, s2) { compare(s1, s2) >  0 }
    static ge(s1, s2) { compare(s1, s2) >= 0 }

    // Compares two strings lexicographically by codepoint.
    // Returns -1, 0 or +1 depending on whether
    // s1 < s2, s1 == s2 or s1 > s2 respectively.
    static compare(s1, s2)  {
        if (s1 == s2) return 0
        var cp1 = s1.codePoints
        var cp2 = s2.codePoints
        var len = (cp1.count <= cp2.count) ? cp1.count : cp2.count
        for (i in 0...len) {
            if (cp1[i] < cp2[i]) return -1
            if (cp1[i] > cp2[i]) return 1
        }
        return (cp1.count < cp2.count) ? -1 : 1
    }

    // Checks if a string falls into a particular category.
    static allAscii(s)         { s.codePoints.all { |c| c < 128             } }
    static allLatin1(s)        { s.codePoints.all { |c| c < 256             } }
    static allDigits(s)        { s.codePoints.all { |c| c >= 48 && c <= 57  } }
    static allAsciiLower(s)    { s.codePoints.all { |c| c >= 97 && c <= 122 } }
    static allAsciiUpper(s)    { s.codePoints.all { |c| c >= 65 && c <= 90  } }
    static allAsciiLetters(s)  { s.toList.all { |c| Char.isAsciiLetter(c)   } }
    static allAsciiAlphaNum(s) { s.toList.all { |c| Char.isAsciiAlphaNum(c) } }
    static allSpace(s)         { s.toList.all { |c| Char.isSpace(c)         } }
    static allLower            { s.toList.all { |c| Char.isLower(c)         } }
    static allUpper            { s.toList.all { |c| Char.isUpper(c)         } }
    static allLetters          { s.toList.all { |c| Char.isLetter(c)        } }
    static allAlphaNumeric     { s.toList.all { |c| Char.isAlphanumeric(c)  } }
    static allPrintable        { s.toList.all { |c| Char.isPrintable(c)     } }
    static allGraphic          { s.toList.all { |c| Char.isGraphic(c)       } }
    static allWhitespace       { s.toList.all { |c| Char.isWhitespace(c)    } }

    // Checks whether a string can be parsed to a number, an integer or a non-integer (float).
    static isNumeric(s)  { Num.fromString(s)                  }
    static isIntegral(s) { (s = isNumeric(s)) && s.isInteger  }
    static isFloat(s)    { (s = isNumeric(s)) && !s.isInteger }

    // Converts a string to lower case.
    static lower(s) {
        if (!(s is String)) s = "%(s)"
        if (s == "") return s
        var chars = s.toList
        var count = chars.count
        var i = 0
        for (c in s.codePoints) {
            if ((c >= 65 && c <= 90) || (c >= 192 && c <= 214) || (c >= 216 && c <= 222)) {
                chars[i] = String.fromCodePoint(c + 32)
            }
            i = i + 1
        }
        return (count < 1000) ? Strs.concat_(chars) : Strs.concat(chars, 1000)
    }

    // Converts a string to upper case.
    static upper(s) {
        if (!(s is String)) s = "%(s)"
        if (s == "") return s
        var chars = s.toList
        var count = chars.count
        var i = 0
        for (c in s.codePoints) {
            if ((c >= 97 && c <= 122) || (c >= 224 && c <= 246) || (c >= 248 && c <= 254)) {
                chars[i] = String.fromCodePoint(c - 32)
            }
            i = i + 1
        }
        return (count < 1000) ? Strs.concat_(chars) : Strs.concat(chars, 1000)
    }

    // Swaps the case of each character in a string.
    static swapCase(s) {
        if (!(s is String)) s = "%(s)"
        if (s == "") return s
        var chars = s.toList
        var count = chars.count
        var i = 0
        for (c in s.codePoints) {
            if ((c >= 65 && c <= 90) || (c >= 192 && c <= 214) || (c >= 216 && c <= 222)) {
                chars[i] = String.fromCodePoint(c + 32)
            } else if ((c >= 97 && c <= 122) || (c >= 224 && c <= 246) ||
                       (c >= 248 && c <= 254)) {
                chars[i] = String.fromCodePoint(c - 32)
            }
            i = i + 1
        }
        return (count < 1000) ? Strs.concat_(chars) : Strs.concat(chars, 1000)
    }

    // Capitalizes the first character of a string.
    static capitalize(s) {
        if (!(s is String)) s = "%(s)"
        if (s == "") return s
        var start = (s.startsWith("[") && s.count > 1) ? 1 : 0
        var c = s[start].codePoints[0]
        if ((c >= 97 && c <= 122) || (c >= 224 && c <= 246) || (c >= 248 && c <= 254)) {
            var cs = String.fromCodePoint(c - 32) + s[start+1..-1]
            if (start == 1) cs = "[" + cs
            return cs
        }
        return s
    }

    // Capitalizes the first character of each word of a string.
    static title(s) {
        if (!(s is String)) s = "%(s)"
        if (s == "") return s
        var words = s.split(" ")
        return Strs.join(words.map { |w| capitalize(w) }.toList, " ")
    }

    // Reverses the characters (not necessarily single bytes) of a string.
    static reverse(s) {
        if (!(s is String)) s = "%(s)"
        return (s != "") ? s[-1..0] : s
    }

    // Performs a circular shift of the characters of 's' one place to the left.
    static lshift(s) {
        if (!(s is String)) s = "%(s)"
        var chars = s.toList
        var count = chars.count
        if (count < 2) return s
        var t = chars[0]
        for (i in 0..count-2) chars[i] = chars[i+1]
        chars[-1] = t
        return (count < 1000) ? Strs.concat_(chars) : Strs.concat(chars, 1000)
    }

    // Performs a circular shift of the characters of 's' one place to the right.
    static rshift(s) {
        if (!(s is String)) s = "%(s)"
        var chars = s.toList
        var count = chars.count
        if (count < 2) return s
        var t = chars[-1]
        for (i in count-2..0) chars[i+1] = chars[i]
        chars[0] = t
        return (count < 1000) ? Strs.concat_(chars) : Strs.concat(chars, 1000)
    }

    /* The indices (or ranges thereof) for all the following functions are measured in codepoints (not bytes). Negative indices count backwards from the end of the string.
       As with core library methods, the indices must be within bounds or errors will be generated. */

    // Extracts the sub-string of 's' over the range 'r'.
    static sub(s, r) {
        if (!(r is Range)) Fiber.abort("Second argument must be a range.")
        if (!(s is String)) s = "%(s)"
        return Strs.concat(s.toList[r])
    }

    // Private helper method to check whether an index is valid.
    static checkIndex_(s, index, inc) {
        if (index.type != Num || !index.isInteger) Fiber.abort("Index must be an integer.")
        var c = s.count + inc
        if (index >= c || index < -c) Fiber.abort("Index is out of bounds.")
    }

    // Gets the character of 's' at index 'i'. Throws an error if 'i is out of bounds.
    static get(s, i) {
        if (!(s is String)) s = "%(s)"
        checkIndex_(s, i, 0)
        if (i < 0) i = s.count + i
        return s.toList[i]
    }

    // Gets the character of 's' at index 'i'. Returns null if 'i is out of bounds.
    static getOrNull(s, i) {
        if (!(s is String)) s = "%(s)"
        if (!(i is Num && i.isInteger)) Fiber.abort("Index must be an integer.")
        if (i < 0) i = s.count + i
        return (i >= 0 && i < s.count) ? s.toList[i] : null
    }

    // Returns the codepoint index (not byte index) at which 'search' first occurs in 's'
    // or -1 if 'search' is not found.
    static indexOf(s, search) {
        if (!(search is String)) Fiber.abort("Search argument must be a string.")
        if (!(s is String)) s = "%(s)"
        var ix = s.indexOf(search)
        if (ix == -1) return -1
        if (ix == 0) return 0
        var cpCount = 1
        var byteCount = 0
        for (cp in s.codePoints) {
            byteCount = byteCount + Utf8.byteCount(cp)
            if (ix == byteCount) return cpCount
            cpCount = cpCount + 1
        }
    }

    // Changes the character of 's' at index 'i' to the string 't'.
    static change(s, i, t) {
        if (!(t is String)) Fiber.abort("Replacement must be a string.")
        if (!(s is String)) s = "%(s)"
        checkIndex_(s, i, 0)
        if (i < 0) i = s.count + i
        var chars = s.toList
        chars[i] = t
        return Strs.concat(chars)
    }

    // Inserts at index 'i' of 's' the string 't'.
    static insert(s, i, t) {
        if (!(t is String)) Fiber.abort("Insertion must be a string.")
        if (!(s is String)) s = "%(s)"
        checkIndex_(s, i, 1)
        if (i < 0) i = s.count + i + 1
        var chars = s.toList
        chars.insert(i, t)
        return Strs.concat(chars)
    }

    // Deletes the character of 's' at index 'i'.
    static delete(s, i) {
        if (!(s is String)) s = "%(s)"
        checkIndex_(s, i, 0)
        if (i < 0) i = s.count + i
        var chars = s.toList
        chars.removeAt(i)
        return Strs.concat(chars)
    }

    // Exchanges the characters of 's' at indices 'i' and 'j'
    static exchange(s, i, j) {
        if (!(s is String)) s = "%(s)"
        checkIndex_(s, i, 0)
        if (i < 0) i = s.count + i
        checkIndex_(s, j, 0)
        if (j < 0) j = s.count + j
        if (i == j) return s
        var chars = s.toList
        var t = chars[i]
        chars[i] = chars[j]
        chars[j] = t
        return Strs.concat(chars)
    }

     // Private helper method for 'repeat'.
    static repeat_(s, reps) {
        var rs = ""
        for (i in 0...reps) rs = rs + s
        return rs
    }

    // Returns 's' repeated 'reps' times.
    // If 'chunkSize' is chosen appropriately, this should be much faster than String's * operator
    // for a large number of repetitions.
    static repeat(s, reps, chunkSize) {
        if (!(s is String)) s = "%(s)"
        if (!(reps is Num && reps.isInteger && reps > 0)) {
            Fiber.abort("Repetitions must be a positive integer.")
        }
        if (!(chunkSize is Num && chunkSize.isInteger && chunkSize > 0)) {
            Fiber.abort("Chunk size must be a positive integer.")
        }
        if (reps == 0) return ""
        var chunks = (reps/chunkSize).floor
        if (chunks == 0) return repeat_(s, reps)
        var lastSize = reps % chunkSize
        if (lastSize == 0) {
            lastSize = chunkSize
        } else {
            chunks = chunks + 1
        }
        var rs = ""
        var chunk = repeat_(s, chunkSize)
        var lastChunk = repeat_(s, lastSize)
        for (i in 0...chunks) {
            rs = rs + ((i < chunks - 1) ? chunk : lastChunk)
        }
        return rs
    }

    // Convenience version of the above which uses a 'chunkSize' of 8000. This usually gives a good result.
    static repeat(s, reps) { repeat(s, reps, 8000) }

    // Splits a string 's' into chunks of not more than 'size' characters.
    // Returns a list of these chunks, preserving order.
    static chunks(s, size) {
        if (!(size is Num && size.isInteger && size > 0)) {
            Fiber.abort("Size must be a positive integer.")
        }
        if (!(s is String)) s = "%(s)"
        var c = s.count
        if (size >= c) return [s]
        var res = []
        var n = (c/size).floor
        var final = c % size
        var first = 0
        var last  = first + size - 1
        for (i in 0...n) {
            res.add(sub(s, first..last))
            first = last + 1
            last  = first + size - 1
        }
        if (final > 0) res.add(sub(s, first..-1))
        return res
    }
}

/*
    Strs contains routines applicable to lists of strings.
*/
class Strs {
    // Private helper method for 'concat'.
    static concat_(ls) {
        var s = ""
        for (e in ls) {
            s = s + e
        }
        return s
    }

    // Returns the strings in the list 'ls' concatenated together.
    // If 'chunkSize' is chosen appropriately, this should be much faster than Sequence.join()
    // for a large list of strings. For extra speed, only minimal type checks are made.
    static concat(ls, chunkSize) {
        if (!(ls is List)) Fiber.abort("First argument must be a list of strings.")
        if (chunkSize.type != Num || !chunkSize.isInteger || chunkSize < 1) {
            Fiber.abort("Second argument must be a positive integer.")
        }
        var count = ls.count
        if (count == 0) return ""
        if (ls[0].type != String) Fiber.abort("First argument must be a list of strings.")
        var chunks = (count/chunkSize).floor
        if (chunks == 0) return concat_(ls)
        var lastSize = count % chunkSize
        if (lastSize == 0) {
            lastSize = chunkSize
        } else {
            chunks = chunks + 1
        }
        var s = ""
        for (i in 0...chunks) {
            var endSize = (i < chunks-1) ? chunkSize : lastSize
            s = s + concat_(ls[i*chunkSize...(i*chunkSize + endSize)])
        }
        return s
    }

    // Convenience version of the above which uses a 'chunkSize' of 1000. This usually gives a good result.
    static concat(ls) { concat(ls, 1000) }

    // Private helper method for 'join'.
    static join_(ls, sep) {
        var first = true
        var s = ""
        for (e in ls) {
            if (!first) s = s + sep
            first = false
            s = s + e
        }
        return s
    }

    // Returns the strings in the list 'ls' joined together using the separator 'sep'.
    // If 'chunkSize' is chosen appropriately, this should be much faster than Sequence.join(sep)
    // for a large list of strings. For extra speed, only minimal type checks are made.
    static join(ls, sep, chunkSize) {
        if (!(ls is List)) Fiber.abort("First argument must be a list of strings.")
        if (sep.type != String) Fiber.abort("Second argument must be a string")
        if (sep == "") return concat(ls, chunkSize)
        if (chunkSize.type != Num || !chunkSize.isInteger || chunkSize < 1) {
            Fiber.abort("Third argument must be a positive integer.")
        }
        var count = ls.count
        if (count == 0) return ""
        if (ls[0].type != String) Fiber.abort("First argument must be a list of strings.")
        var chunks = (count/chunkSize).floor
        if (chunks == 0) return join_(ls, sep)
        var lastSize = count % chunkSize
        if (lastSize == 0) {
            lastSize = chunkSize
        } else {
            chunks = chunks + 1
        }
        var s = ""
        for (i in 0...chunks) {
            if (i > 0) s = s + sep
            var endSize = (i < chunks-1) ? chunkSize : lastSize
            s = s + join_(ls[i*chunkSize...(i*chunkSize + endSize)], sep)
        }
        return s
    }

    // Convenience version of the above which uses a 'chunkSize' of 1000. This usually gives a good result.
    static join(ls, sep) { join(ls, sep, 1000) }
}

/*
    Utf8 contains routines which are specific to the UTF-8 encoding of a string's bytes or codepoints.
*/
class Utf8 {
    // Returns the number of bytes in the UTF-8 encoding of its codepoint argument.
    static byteCount(cp) {
        if (cp < 0 || cp > 0x10ffff) Fiber.abort("Codepoint is out of range.")
        if (cp < 0x80) return 1
        if (cp < 0x800) return 2
        if (cp < 0x10000) return 3
        return 4
    }

    // Converts a Unicode codepoint into its constituent UTF-8 bytes.
    static encode(cp) { String.fromCodePoint(cp).bytes.toList }

    // Converts a list of UTF-8 encoded bytes into the equivalent Unicode codepoint.
    static decode(b) {
        if (!((b is List) && b.count >= 1 && b.count <= 4 && (b[0] is Num) && b[0].isInteger)) {
            Fiber.abort("Argument must be a byte list of length 1 to 4.")
        }
        var mbMask = 0x3f // non-first bytes start 10 and carry 6 bits of data
        var b0 = b[0]
        if (b0 < 0x80) {
            return b0
        } else if (b0 < 0xe0) {
            var b2Mask = 0x1f // first byte of a 2-byte encoding starts 110 and carries 5 bits of data
            return (b0 & b2Mask) <<  6 | (b[1] & mbMask)
        } else if (b0 < 0xf0) {
            var b3Mask = 0x0f // first byte of a 3-byte encoding starts 1110 and carries 4 bits of data
            return (b0 & b3Mask) << 12 | (b[1] & mbMask) <<  6 | (b[2] & mbMask)
        } else {
            var b4Mask = 0x07 // first byte of a 4-byte encoding starts 11110 and carries 3 bits of data
            return (b0 & b4Mask) << 18 | (b[1] & mbMask) << 12 | (b[2] & mbMask) << 6 | (b[3] & mbMask)
        }
    }
}

// Type aliases for classes in case of any name clashes with other modules.
var Str_Char = Char
var Str_Str = Str
var Str_Strs = Strs
var Str_Utf8 = Utf8
