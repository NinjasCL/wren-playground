// url: https://rosettacode.org/wiki/Category:Wren-fmt
// source: https://rosettacode.org/mw/index.php?title=Category_talk:Wren-fmt&action=edit&section=1
// file: fmt
// name: Wren-fmt
// author: PureFox
// license: MIT

/* Module "fmt.wren" */

/* Conv contains routines which do conversions between types. */
class Conv {
    // All possible digits.
    static digits { "0123456789abcdefghijklmnopqrstuvwxyz" }

    // All possible digits (upper case).
    static upperDigits { "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ" }

    // Maximum safe integer = 2^53 - 1.
    static maxSafeInt { 9007199254740991 }

    // Prefix map for different bases.
    static prefixes { { "b": "0b", "t": "0t", "o": "0o", "d": "0d", "x": "0x", "X": "0X" } }

    // Converts an integer to a numeric ASCII string with a base between 2 and 36.
    static itoa(n, b) {
        if (!(n is Num && n.isInteger && n.abs <= maxSafeInt)) Fiber.abort("Argument must be a safe integer.")
        if (b < 2 || b > 36) Fiber.abort("Base must be between 2 and 36.")
        if (n == 0) return "0"
        var neg = (n < 0)
        if (neg) n = -n
        var res = ""
        while (n > 0) {
            res = res + "%(digits[n%b])"
            n = (n/b).floor
        }
        return ((neg) ? "-" : "") + res[-1..0]
    }

    // Private helper function. Converts ASCII string to upper case.
    static upper_(s) { s.bytes.map { |b|
        return String.fromByte((b >= 97 && b <= 122) ? b - 32 : b)
    }.join() }

    // As itoa(n, b) but resulting digits are upper case.
    static Itoa(n, b) { (b < 11) ? itoa(n, b) : upper_(itoa(n, b)) }

    // Converts a numeric ASCII string with a base between 2 and 36 to an integer.
    // The string can optionally begin with a base specifier provided it is consistent with the base.
    static atoi(s, b) {
        if (!(s is String && s != "" && s.count == s.bytes.count)) Fiber.abort("Argument must be an ASCII string.")
        if (b < 2 || b > 36) Fiber.abort("Base must be between 2 and 36.")
        var neg = false
        if (s.startsWith("+")) {
            s = s[1..-1]
        } else if (s.startsWith("-")) {
            s = s[1..-1]
            neg = true
        }
        if (s == "") Fiber.abort("String must contain some digits.")
        s = upper_(s)
        if ((s.startsWith("0B") && b == 2) || (s.startsWith("0T") && b == 3) ||
            (s.startsWith("0O") && b == 8) || (s.startsWith("0X") && b == 16)) {
            s = s[2..-1]
            if (s == "") Fiber.abort("String after base specifier must contain some digits.")
        }
        var res = 0
        var digs = upperDigits[0...b]
        for (d in s) {
            var ix = digs.indexOf(d)
            if (ix == -1) Fiber.abort("String contains an invalid digit '%(d)'.")
            res = res * b + ix
        }
        return (neg) ? -res : res
    }

    // Convenience versions of itoa and atoi which use a base of 10.
    static itoa(s) { itoa(s, 10) }
    static atoi(s) { atoi(s, 10) }

    // Integer/bool conversion routines.
    static itob(i) { (i is Num && i.isInteger) ? (i != 0) : null }
    static btoi(b) { (b is Bool) ? (b ? 1 : 0) : null }

    // Integer/character conversion routines.
    static itoc(i) { (i is Num && i.isInteger && i >= 0 && i <= 0x10ffff) ? String.fromCodePoint(i) : null }
    static ctoi(c) { (c is String && c.count == 1) ? c.codePoints[0] : null }

    static bin(n) { itoa(n, 2) }        // Converts an integer to binary.
    static ter(n) { itoa(n, 3) }        // Converts an integer to ternary.
    static oct(n) { itoa(n, 8) }        // Converts an integer to octal.
    static dec(n) { itoa(n, 10) }       // Ensures safe decimal integers printed as such.
    static hex(n) { itoa(n, 16) }       // Converts an integer to hex.
    static Hex(n) { Conv.Itoa(n, 16) }  // Converts an integer to hex (upper case digits).

    static pdec(n) { ((n >= 0) ? "+" : "") + dec(n) }  // Adds '+' for non-negative integers.
    static mdec(n) { ((n >= 0) ? " " : "") + dec(n) }  // Only uses '-', leaves space for '+'.

    // Converts a non-negative integer to its ordinal equivalent.
    static ord(n) {
        if (!(n is Num && n.isInteger && n >= 0)) Fiber.abort("Argument must be a non-negative integer.")
        var m = n % 100
        if (m >= 4 && m <= 20) return "%(n)th"
        m = m % 10
        var suffix = "th"
        if (m == 1) {
            suffix = "st"
        } else if (m == 2) {
            suffix = "nd"
        } else if (m == 3) {
            suffix = "rd"
        }
        return "%(n)%(suffix)"
    }
}

/* Fmt contains routines which format numbers or strings in various ways. */
class Fmt {
    // Left justifies 's' in a field of minimum width 'w' using the pad character 'p'.
    static ljust(w, s, p) {
        if (!w.isInteger || w < 0) Fiber.abort("Width must be a non-negative integer.")
        if (!(p is String) || p.count != 1) Fiber.abort("Padder must be a single character string.")
        if (!(s is String)) s = "%(s)"
        var c = s.count
        return (w > c) ? s + p * (w - c) : s
    }

    // Right justifies 's' in a field of minimum width 'w' using the pad character 'p'.
    static rjust(w, s, p) {
        if (!w.isInteger || w < 0) Fiber.abort("Width must be a non-negative integer.")
        if (!(p is String) || p.count != 1) Fiber.abort("Padder must be a single character string.")
        if (!(s is String)) s = "%(s)"
        var c = s.count
        return (w > c) ? p * (w - c) + s : s
    }

    // Centers 's' in a field of minimum width 'w' using the pad character 'p'.
    static cjust(w, s, p) {
        if (!w.isInteger || w < 0) Fiber.abort("Width must be a non-negative integer.")
        if (!(p is String) || p.count != 1) Fiber.abort("Padder must be a single character string.")
        if (!(s is String)) s = "%(s)"
        var c = s.count
        if (w <= c) return s
        var l = ((w-c)/2).floor
        return p * l + s + p * (w - c - l)
    }

    // Convenience versions of the above which use a space as the pad character.
    static ljust(w, s) { ljust(w, s, " ") }
    static rjust(w, s) { rjust(w, s, " ") }
    static cjust(w, s) { cjust(w, s, " ") }

    // Right justifies 's' in a field of minimum width 'w' using the pad character '0'.
    // Unlike rjust, any sign or elided sign (i.e. space) will be placed before the padding.
    // Should normally only be used with numbers or numeric strings.
    static zfill(w, s) {
        if (!w.isInteger || w < 0) Fiber.abort("Width must be a non-negative integer.")
        if (!(s is String)) s = "%(s)"
        var c = s.count
        if (w <= c) return s
        var sign = (c > 0 && "-+ ".contains(s[0])) ? s[0] : ""
        if (sign == "") return "0" * (w - c) + s
        return sign + "0" * (w - c) + s[1..-1]
    }

    // Private helper method for 'commatize' method.
    // Checks whether argument is a numeric decimal string.
    static isDecimal_(n) {
        if (!(n is String && n != "" && "+- 0123456789".contains(n[0]))) return false
        if ("-+ ".contains(n[0])) {
            if (n.count == 1) return false
            n = n[1..-1]
        }
        return n.all { |c| "0123456789".contains(c) }
    }

    // Adds 'thousand separators' to a decimal integer or string.
    static commatize(n, c) {
        if (!(n is Num && n.isInteger) && !isDecimal_(n)) Fiber.abort("Argument is not a decimal integer nor string.")
        if (!(c is String) || c.count != 1) Fiber.abort("Separator must be a single character string.")
        if (n is Num) n = "%(Conv.dec(n))"
        var signed = "-+ ".contains(n[0])
        var sign = ""
        if (signed) {
            sign = n[0]
            n = n[1..-1]
        }
        if (n.startsWith("0") && n != "0") {
            n = n.trimStart("0")
            if (n == "") n = "0"
        }
        var i = n.count - 3
        while (i >= 1) {
            n = n[0...i] + c + n[i..-1]
            i = i - 3
        }
        return (signed) ? sign + n : n
    }

    // Convenience version of the above method which uses a comma as the separator.
    static commatize(n) { commatize(n, ",") }

    // Adds 'thousand' separators' to an ordinal number.
    static ordinalize(n, c) { commatize(n, c) + Conv.ord(n)[-2..-1] }

    // Convenience version of the above method which uses a comma as the separator.
    static ordinalize(n) { ordinalize(n, ",") }

    // Private helper method for 'abbreviate' method.
    static sub_(s, r) { s.toList[r].join() }

    // Abbreviates a string 's' to a maximum number of characters 'w' (non-overlapping) at either end
    // or, if 'w' is negative from the front only, using 'sep' as the separator.
    // Doesn't abbreviate a string unless at least one character would need to be suppressed.
    static abbreviate(w, s, sep) {
        if (!(w is Num && w.isInteger && w.abs >= 1)) Fiber.abort("Maximum width must be a positive integer.")
        if (!(sep is String)) Fiber.abort("Separator must be a string.")
        if (!(s is String)) s = "%(s)"
        var c = s.count
        if (c <= ((w < 0) ? -w : 2*w)) return s
        var le = (w >= 0) ? w : -w
        return sub_(s, 0...le) + sep + ((w >= 0) ? sub_(s, -le..-1) : "")
    }

    // Convenience version of the above method which uses 'three dots' as the separator.
    static abbreviate(w, s) { abbreviate(w, s, "...") }

    // Gets or sets precision for 'f(w, n)' style convenience methods.
    static precision { ( __precision != null) ? __precision : 6 }
    static precision=(p) { __precision = ((p is Num) && p.isInteger && p >= 0) ? p : __precision }

    /* 'Short name' methods, useful for formatting values in interpolated strings. */

    // Formats an integer 'n' in (d)ecimal, (b)inary, (t)ernary, (o)ctal, he(x) or upper case he(X).
    // Pads with spaces to a minimum width of 'w'.
    // Negative 'w' left justifies, non-negative 'w' right justifies.
    static d(w, n) { (w >= 0) ? rjust(w, Conv.dec(n)) : ljust(-w, Conv.dec(n)) }
    static b(w, n) { (w >= 0) ? rjust(w, Conv.bin(n)) : ljust(-w, Conv.bin(n)) }
    static t(w, n) { (w >= 0) ? rjust(w, Conv.ter(n)) : ljust(-w, Conv.ter(n)) }
    static o(w, n) { (w >= 0) ? rjust(w, Conv.oct(n)) : ljust(-w, Conv.oct(n)) }
    static x(w, n) { (w >= 0) ? rjust(w, Conv.hex(n)) : ljust(-w, Conv.hex(n)) }
    static X(w, n) { (w >= 0) ? rjust(w, Conv.Hex(n)) : ljust(-w, Conv.Hex(n)) }

    // As above but pads with leading zeros instead of spaces.
    // Any minus sign will be placed before the padding.
    // When used with negative 'w' behaves the same as the above methods.
    static dz(w, n) { (w >= 0) ? zfill(w, Conv.dec(n)) : ljust(-w, Conv.dec(n)) }
    static bz(w, n) { (w >= 0) ? zfill(w, Conv.bin(n)) : ljust(-w, Conv.bin(n)) }
    static tz(w, n) { (w >= 0) ? zfill(w, Conv.ter(n)) : ljust(-w, Conv.ter(n)) }
    static oz(w, n) { (w >= 0) ? zfill(w, Conv.oct(n)) : ljust(-w, Conv.oct(n)) }
    static xz(w, n) { (w >= 0) ? zfill(w, Conv.hex(n)) : ljust(-w, Conv.hex(n)) }
    static Xz(w, n) { (w >= 0) ? zfill(w, Conv.Hex(n)) : ljust(-w, Conv.Hex(n)) }

    // Formats 'n' in decimal, space padded, with a leading '+' if 'n' is non-negative or '-' otherwise.
    static dp(w, n) { (w >= 0) ? rjust(w, Conv.pdec(n)) : ljust(-w, Conv.pdec(n)) }

    // Formats 'n' in decimal, space padded, with a leading ' ' if  'n' is non-negative or '-' otherwise.
    static dm(w, n) { (w >= 0) ? rjust(w, Conv.mdec(n)) : ljust(-w, Conv.mdec(n)) }

    // Formats 'n' in commatized form, space padded, using ',' as the separator.
    static dc(w, n) { (w >= 0) ? rjust(w, commatize(Conv.dec(n))): ljust(-w, commatize(Conv.dec(n))) }

    // Ranks a non-negative integer 'n' i.e. expresses it in ordinal form, space padded.
    static r(w, n) { (w >= 0) ? rjust(w, Conv.ord(n)) : ljust(-w, Conv.ord(n)) }

    // As the above method but commatizes the ordinal number, using ',' as the separator.
    static rc(w, n) { (w >= 0) ? rjust(w, ordinalize(n)) : ljust(-w, ordinalize(n)) }

    // Pads a character (equivalent to the codepoint 'n') with spaces to a minimum width of 'w'.
    // Negative 'w' left justifies, non-negative 'w' right justifies.
    static c(w, n)  { (w >= 0) ? rjust(w, Conv.itoc(n)): ljust(-w, Conv.itoc(n)) }

    // Pads a string or value 'v' with spaces to a minimum width of 'w'.
    // Negative 'w' left justifies, non-negative 'w' right justifies.
    static s(w, v)  { (w >= 0) ? rjust(w, v) : ljust(-w, v) }

    // As 's' above but pads with leading zeros instead of spaces.
    // Any minus sign will be placed before the padding.
    // When used with negative 'w' behaves the same as the above method.
    static sz(w, v) { (w >= 0) ? zfill(w, v) : ljust(-w, v) }

    // Formats a string or value 'v' in commatized form, space padded, using ',' as the separator.
    static sc(w, v) {
        if (!(v is String)) v = "%(v)"
        return (w >= 0) ? rjust(w, commatize(v)): ljust(-w, commatize(v))
    }

    // These methods use the appropriate 'd' format if 'v' is a safe integer or the 's' format otherwise.
    static i(w, v)  { (v is Num && v.isInteger && v.abs <= Conv.maxSafeInt) ? d (w, v) : s (w, v) }
    static iz(w, v) { (v is Num && v.isInteger && v.abs <= Conv.maxSafeInt) ? dz(w, v) : sz(w, v) }
    static ic(w, v) { (v is Num && v.isInteger && v.abs <= Conv.maxSafeInt) ? dc(w, v) : sc(w, v) }

    // Middles a string or value 'v' within a field of minimum width 'w'. Pads with spaces.
    static m(w, v)  { cjust(w, v) }

    // 'Short name' synonym for abbreviate(w, s) method except doesn't abbreviate (rather than throwing
    // an error) if a width of '0' is passed.
    static a(w, v)  { (w != 0) ? abbreviate(w, v) : s(0, v) }

    // Enables a value to be printed in its 'normal' form (i.e. by applying the 'toString' method),
    // within a space-padded minimum field of width 'w', notwithstanding any special formatting
    // that would otherwise be applied by 'short name' methods.
    static n(w, v) { s(w, v.toString) }

    // Applies the 's' format to the kind (i.e. type) of 'v'.
    static k(w, v) { s(w, v.type) }

    // Embeds a string or value 'v' in 'cc', a string with no more than two characters.
    // If it has none, no embedding takes place. If has one, it's doubled.
    // The first character is added at the left and the second at the right.
    static q(v, cc) {
        var len
        if (!(cc is String && (len = cc.count) < 3)) {
            Fiber.abort("Second argument must be a string with no more than 2 characters.")
        }
        if (len == 0) return (v is String) ? v : "%(v)"
        if (len == 1) cc = cc + cc
        return "%(cc[0])%(v)%(cc[1])"
    }

    // Convenience version of the above which uses double quotes as the embedding characters.
    static q(v) { "\"%(v)\"" }

    // Formats a number 'n' (using 'h' format) to a maximum precision of 14 decimal places.
    // It then converts it to exponential format and formats the mantissa to 'p' decimal places.
    // The result is then padded with spaces to a minimum width 'w'.
    // Negative 'w' left justifies, non-negative 'w' right justifies.
    static e(w, n, p) {
        var f = Fmt.h(w, n, 14).trim()
        if (f.contains("e") || n.isInfinity || n.isNan) return Fmt.s(w, n) // use 'normal' representation
        var dix = f.indexOf(".")
        if (dix >= 0) {
            f = f.replace(".", "")
        } else {
            dix = f.count
        }
        // look for index of first non-zero digit if there is one
        var nzix = -1
        var i = (f[0] == "-") ? 1 : 0
        while (i < f.count) {
            if (f[i] != "0") {
                nzix = i
                break
            }
            i = i + 1
        }
        if (nzix == -1) return "0e00"
        var delta = dix - nzix
        f = (nzix+1<f.count) ? f[nzix] + "." + f[nzix+1..-1] : f[nzix]
        if (n < 0) f = "-" + f
        f = Fmt.h(p+2, Num.fromString(f), p).trim()
        var exp = (delta >= 0) ? Fmt.dz(2, delta-1) : Fmt.dz(3, delta-1)
        return Fmt.s(w, "%(f)e%(exp)")
    }

    // Works like 'e' except that the exponent symbol 'e' is replaced by upper case 'E'.
    static E(w, n, p) { e(w, n, p).replace("e", "E") }

    // Pads a number 'n' with leading spaces to a minimum width 'w' and a precision of 'p' decimal places.
    // Precision is restricted to 14 places though entering a higher figure is not an error.
    // Numbers are rounded and/or decimal places are zero-filled where necessary.
    // Numbers which can't be expressed exactly use their default representation.
    // Negative 'w' left justifies, non-negative 'w' right justifies.
    static f(w, n, p) {
        if (!w.isInteger) Fiber.abort("Width must be an integer.")
        if (!(n is Num)) Fiber.abort("Argument must be a number.")
        if (!p.isInteger || p < 0) Fiber.abort("Precision must be a non-negative integer")
        if (n.abs > Conv.maxSafeInt || n.isInfinity || n.isNan) return s(w, n) // use 'normal' representation
        if (p > 14) p = 14
        var i = (p == 0) ? n.round : n.truncate
        var ns = "%(Conv.dec(i))"
        if (i == 0 && n < 0) ns = "-" + ns
        if (n.isInteger || p == 0) {
            if (p > 0) return s(w, ns + "." + "0" * p)
            return s(w, ns)
        }
        var d = (n - i).abs
        var pw = 10.pow(p)
        d = (d * pw).round
        if (d >= pw) {
            ns = "%(Conv.dec(n.round))"
            d = 0
        }
        if (d == 0) return s(w, ns + "." + "0" * p)
        var ds = "%(d)"
        var c = ds.count
        if (c < p) ds = "0" * (p-c) + ds
        return s(w, ns + "." + ds[0...p])
    }

    // Works like 'f' except replaces any trailing zeros after the decimal point with spaces.
    // If the resulting string would end with a decimal point, a zero is first added back.
    static g(w, n, p) {
        var f = f(w, n, p)
        if (f.contains(".") && (f[-1] == "0" || f[-1] == " ")) {
            var l1 = f.count
            f = f.trimEnd("0 ")
            if (f[-1] == ".") f = f + "0"
            f = f + (" " * (l1 - f.count))
        }
        return f
    }

    // Works like 'f' except replaces any trailing zeros after the decimal point with spaces.
    // If the resulting string would end with a decimal point, that is also replaced with a space.
    static h(w, n, p) {
        var f = f(w, n, p)
        if (f.contains(".") && (f[-1] == "0" || f[-1] == " ")) {
            var l1 = f.count
            f = f.trimEnd("0 ")
            if (f[-1] == ".") f = f[0..-2]
            f = f + (" " * (l1 - f.count))
        }
        return f
    }

    // As above but pads with leading zeros instead of spaces.
    // Any minus sign will be placed before the padding.
    // When used with negative 'w' behaves the same as the above methods.
    static fz(w, n, p) { (w >= 0) ? zfill(w, f(w, n, p).trimStart()) : f(w, n, p) }
    static gz(w, n, p) { (w >= 0) ? zfill(w, g(w, n, p).trimStart()) : g(w, n, p) }
    static hz(w, n, p) { (w >= 0) ? zfill(w, h(w, n, p).trimStart()) : h(w, n, p) }

    // As above but prepends non-negative numbers with a '+' sign.
    static fp(w, n, p) { signFloat_("f", w, n, p) }
    static gp(w, n, p) { signFloat_("g", w, n, p) }
    static hp(w, n, p) { signFloat_("h", w, n, p) }

    // Private helper method for signing floating point numbers.
    static signFloat_(fn, w, n, p) {
        var fmt = "$%(w).%(p)%(fn)"
        if (n < 0) return swrite(fmt, n)
        if (n > 0) return swrite(fmt, -n).replace("-", "+")
        return swrite(fmt, -1).replace("-1", "+0")
    }

    // Formats the integer part of 'n' in commatized form, space padded,
    // using ',' as the separator. The decimal part is not affected.
    static fc(w, n, p) {
        var f = f(w, n, p)
        if (f.contains("infinity") || f == "nan" || f.contains("e")) return f
        var ix = f.indexOf(".")
        var dp = (ix >= 0) ? f[ix..-1] : ""
        var c = dp.count
        w = (w >= 0) ? w - c : w + c
        if (w < 0) w = 0
        return dc(w, n.truncate) + dp
    }

    // Works like 'fc' except replaces any trailing zeros after the decimal point with spaces.
    // If the resulting string would end with a decimal point, a zero is first added back.
    static gc(w, n, p) {
        var f = fc(w, n, p)
        if (f.contains(".") && (f[-1] == "0" || f[-1] == " ")) {
            var l1 = f.count
            f = f.trimEnd("0 ")
            if (f[-1] == ".") f = f + "0"
            f = f + (" " * (l1 - f.count))
        }
        return f
    }

    // Works like 'fc' except replaces any trailing zeros after the decimal point with spaces.
    // If the resulting string would end with a decimal point, that is also replaced with a space.
    static hc(w, n, p) {
        var f = fc(w, n, p)
        if (f.contains(".") && (f[-1] == "0" || f[-1] == " ")) {
            var l1 = f.count
            f = f.trimEnd("0 ")
            if (f[-1] == ".") f = f[0..-2]
            f = f + (" " * (l1 - f.count))
        }
        return f
    }

    // Applies the 'f' format to each component, x and y, of a complex number 'n'
    // before joining them together in the form x ± yi.
    static z(w, n, p) {
        if (n is Num) return f(w, n, p)
        if (n.type.toString != "Complex") Fiber.abort("Argument must be a complex or real number.")
        var real = f(w, n.real, p)
        var sign = (n.imag >= 0) ? " + " : " - "
        var imag = f(w, n.imag.abs, p)
        return real + sign + imag + "i"
    }

    // Convenience versions of the above methods which use the default precision.
    static e(w, n)  { e(w, n, precision)     }
    static E(w, n)  { Fmt.E(w, n, precision) }
    static f(w, n)  { f(w, n, precision)     }
    static g(w, n)  { g(w, n, precision)     }
    static h(w, n)  { h(w, n, precision)     }
    static z(w, n)  { z(w, n, precision)     }
    static fz(w, n) { fz(w, n, precision)    }
    static gz(w, n) { gz(w, n, precision)    }
    static hz(w, n) { hz(w, n, precision)    }
    static fp(w, n) { fp(w, n, precision)    }
    static gp(w, n) { gp(w, n, precision)    }
    static hp(w, n) { hp(w, n, precision)    }
    static fc(w, n) { fc(w, n, precision)    }
    static gc(w, n) { gc(w, n, precision)    }
    static hc(w, n) { hc(w, n, precision)    }

    // Private worker method which calls a 'short name' method and returns its result.
    static callFn_(fn, w, v, p) {
        return (fn == "d")  ? d(w, v)        :
               (fn == "b")  ? b(w, v)        :
               (fn == "t")  ? t(w, v)        :
               (fn == "o")  ? o(w, v)        :
               (fn == "x")  ? x(w, v)        :
               (fn == "X")  ? Fmt.X(w, v)    :
               (fn == "r")  ? r(w, v)        :
               (fn == "c")  ? c(w, v)        :
               (fn == "s")  ? s(w, v)        :
               (fn == "i")  ? i(w, v)        :
               (fn == "m")  ? m(w, v)        :
               (fn == "a")  ? a(w, v)        :
               (fn == "n")  ? n(w, v)        :
               (fn == "k")  ? k(w, v)        :
               (fn == "q")  ? q(v)           :
               (fn == "e")  ? e(w, v, p)     :
               (fn == "E")  ? Fmt.E(w, v, p) :
               (fn == "f")  ? f(w, v, p)     :
               (fn == "g")  ? g(w, v, p)     :
               (fn == "h")  ? h(w, v, p)     :
               (fn == "z")  ? z(w, v, p)     :
               (fn == "dz") ? dz(w, v)       :
               (fn == "bz") ? bz(w, v)       :
               (fn == "tz") ? tz(w, v)       :
               (fn == "oz") ? oz(w, v)       :
               (fn == "xz") ? xz(w, v)       :
               (fn == "Xz") ? Fmt.Xz(w, v)   :
               (fn == "sz") ? sz(w, v)       :
               (fn == "iz") ? iz(w, v)       :
               (fn == "fz") ? fz(w, v, p)    :
               (fn == "gz") ? gz(w, v, p)    :
               (fn == "hz") ? hz(w, v, p)    :
               (fn == "fp") ? fp(w, v, p)    :
               (fn == "gp") ? gp(w, v, p)    :
               (fn == "hp") ? hp(w, v, p)    :
               (fn == "dp") ? dp(w, v)       :
               (fn == "dm") ? dm(w, v)       :
               (fn == "dc") ? dc(w, v)       :
               (fn == "rc") ? rc(w, v)       :
               (fn == "sc") ? sc(w, v)       :
               (fn == "ic") ? ic(w, v)       :
               (fn == "fc") ? fc(w, v, p)    :
               (fn == "gc") ? gc(w, v, p)    :
               (fn == "hc") ? hc(w, v, p)    : Fiber.abort("Method not recognized.")
    }

    // Applies a 'short' formatting method to each element of a list or sequence 'seq'.
    // The method to be applied is specified (as a string) in 'fn'.
    // The parameters to be passed to the method are specified in 'w' and 'p'
    // 'p' is needed for 'e', 'E', 'f', 'g', 'h', 'z', 'fz', 'gz', 'hz', 'fp', 'gp'
    // 'hp', 'fc', 'gc' or 'hc' but is ignored otherwise.
    // The resulting strings are then joined together using the separator 'sep'.
    // having first applied the 'q' method, with parameter 'cc', to each of them.
    // Finally, the 'q' method is applied again, with parameter 'bb', to the whole
    // string, if a prefix/suffix is needed.
    static v(fn, w, seq, p, sep, bb, cc) {
        var l = List.filled(seq.count, "")
        var i = 0
        for (e in seq) {
            l[i] = q(callFn_(fn, w, e, p), cc)
            i = i + 1
        }
        return q(l.join(sep), bb)
    }

    // Convenience versions of the above method which use default values
    // for some parameters.
    static v(fn, w, seq, p, sep, bb) { v(fn, w, seq, p, sep, bb, "") }
    static v(fn, w, seq, p, sep)     { v(fn, w, seq, p, sep, "[]", "") }
    static v(fn, w, seq, p)          { v(fn, w, seq, p, ", ", "[]", "") }
    static v(fn, w, seq)             { v(fn, w, seq, precision, ", ", "[]", "") }

    // Applies a 'short' formatting method to each element of a two-dimensional
    // list or sequence 'm'.
    // A Matrix or CMatrix object is automatically converted to a 2D list of numbers.
    // The parameters: 'fn', 'w', 'p', 'sep', 'bb' and 'cc'
    // are applied using the 'v' method to each row of 'm'.
    // The rows are then joined together using the separator 'ss'.
    static v2(fn, w, m, p, sep, bb, cc, ss) {
        var s = m.type.toString
        if (s == "Matrix" || s == "CMatrix") m = m.toList
        var nr = m.count
        if (nr == 0) return ""
        var l = List.filled(nr, "")
        var i = 0
        for (row in m) {
            l[i] = v(fn, w, row, p, sep, bb, cc)
            i = i + 1
        }
        return l.join(ss)
    }

    // Convenience versions of the above method which use default values
    // for some parameters.
    static v2(fn, w, m, p, sep, bb, cc) { v(fn, w, m, p, sep, bb, cc, "\n") }
    static v2(fn, w, m, p, sep, bb)     { v(fn, w, m, p, sep, bb, "", "\n") }
    static v2(fn, w, m, p, sep)         { v(fn, w, m, p, sep, "|", "", "\n") }
    static v2(fn, w, m, p)              { v(fn, w, m, p, " ", "|", "", "\n") }
    static v2(fn, w, m)                 { v(fn, w, m, precision, " ", "|", "", "\n") }

    // Provides a 'sprintf' style method where the arguments are passed in a separate list and
    // formatted in turn by verbs embedded in a format string. Excess arguments are ignored but
    // it is an error to provide insufficient arguments. Verbs must be given in this form:
    // $[flag][width][.precision][letter] of which all bracketed items except [letter] are optional.
    // The letter must be one of the 'short' methods:
    // a, b, c, d, e, E, f, g, h, i, k, m, n, o, q, r, s, t, x, X or z.
    // If present, the flag (there can only be one) must be one of the following:
    //     +    always prints a + or - sign ('dp', 'fp', 'gp' or 'hp' methods)
    //  (space) leaves a space for the sign but only prints minus ('dm' method)
    //     ,    commatizes the following number ('dc', 'rc', 'sc', 'ic', 'fc', 'gc' or 'hc' methods)
    //     #    adds the appropriate prefix for the number formats: b, t, o, d, x and X
    //     *    reads the width from the argument before the one to be formatted
    //     0    when followed by an explicit width, pads with leading zeros rather than spaces:
    //          ('dz', 'bz', 'tz', 'oz', 'xz, 'Xz', 'sz', iz', 'fz', 'gz' and 'hz' methods)
    // If present, the width is the minimum width (+/-) to be passed to the appropriate method.
    // It doesn't include any '#' flag prefix. If [width] is absent, a width of one is passed.
    // If present, the precision is the number of decimal places to be passed to the appropriate
    // 'e', 'E', 'f', 'g', 'h' or 'z' style method. If absent, the default precision is passed.
    // Where any optional item is inappropriate to the method being used it is simply ignored.
    // Where one of the arguments is a sequence (other than a string) this method senses it
    // and applies the 'v' method to it. However, the 'sep' parameter is always a single space
    // and the 'bb' and 'cc' parameters are always empty strings.
    static slwrite(fmt, a) {
        if (!(fmt is String)) Fiber.abort("First argument must be a string.")
        if (!(a is List)) Fiber.abort("Second argument must be a list.")
        if (fmt == "") return ""
        var cps = fmt.codePoints.toList
        var le = cps.count      // number of codepoints
        var s = ""              // accumulates the result string
        var i = 0               // current codepoint index
        var cp = 0              // current codepoint
        var next = 0            // index of next argument to be formatted

        // Gets the next numeric string from the format.
        var getNumber = Fn.new { |minusAllowed|
            i = i + 1
            if (i == le) Fiber.abort("Invalid format string.")
            cp = cps[i]
            var ns = ""
            if (cp == 45) {
                if (!minusAllowed) Fiber.abort("Invalid format string")
                ns = "-"
                i = i + 1
                if (i == le) Fiber.abort("Invalid format string.")
                cp = cps[i]
            }
            while (cp >= 48 && cp <= 57) {
                ns = ns + Conv.itoc(cp)
                i = i + 1
                if (i == le) Fiber.abort("Invalid format string.")
                cp = cps[i]
            }
            if (ns == "-") Fiber.abort("Invalid format string.")
            return ns
        }

        while (i < le) {
            cp = cps[i]
            if (cp != 36) { // not a dollar sign
                s = s + Conv.itoc(cp)
            } else if (i < le -1 && cps[i + 1] == 36) { // check for $$
                s = s + "$"
                i = i + 1
            } else {
                var ns = getNumber.call(true)
                if (ns != "" && "*+,#".codePoints.contains(cp)) {
                    Fiber.abort("Invalid format string.")
                }
                var plus  = false
                var comma = false
                var space = false
                var hash  = false
                var fn = ""
                var ds = ""
                if ("abcdeEfghikmnoqrstxXz".codePoints.contains(cp)) { // format letter
                    fn = Conv.itoc(cp)
                } else if (cp == 42) {    // star
                    if (next < a.count) {
                        ns = "%(a[next])"
                        next = next + 1
                    } else {
                        Fiber.abort("Insufficient arguments passed.")
                    }
                    i = i + 1
                    cp = cps[i]
                    if (cp == 46) ds = getNumber.call(false)
                } else if (cp == 43) {  // plus sign
                    plus = true
                    ns = getNumber.call(true)
                    if (cp == 46) ds = getNumber.call(false)
                } else if (cp == 44) {  // comma
                    comma = true
                    ns = getNumber.call(true)
                    if (cp == 46) ds = getNumber.call(false)
                } else if (cp == 46) {  // dot
                    ds = getNumber.call(false)
                } else if (cp == 32) {  // space
                    space = true
                    ns = getNumber.call(true)
                    if (cp == 46) ds = getNumber.call(false)
                } else if (cp == 35) {  // hash
                    hash = true
                    ns = getNumber.call(true)
                    if (cp == 46) ds = getNumber.call(false)
                } else {
                    Fiber.abort("Unrecognized character in format string.")
                }

                if (fn == "") {
                    if (!"abcdeEfghikmnoqrstxXz".codePoints.contains(cp)) {
                        Fiber.abort("Unrecognized character in format string.")
                    }
                    fn = Conv.itoc(cp)
                }
                if (fn == "d") {
                    if (plus) {
                        fn = "dp"
                    } else if (space) {
                        fn = "dm"
                    } else if (comma) {
                        fn = "dc"
                    }
                } else if ((fn == "f" || fn == "g" || fn == "h") && plus) {
                    fn = fn + "p"
                } else if ((fn == "r" || fn == "s" || fn == "i" || fn == "f" ||
                            fn == "g" || fn == "h") && comma) {
                    fn = fn + "c"
                }
                if (ns == "") ns = "1"
                if (ns[0] == "0" && ns.count > 1 && "dbtoxXsifgh".contains(fn[0])) {
                    fn = fn[0] + "z"
                }
                var w = Num.fromString(ns)
                var p = (ds != "") ? Num.fromString(ds) : precision
                if (next < a.count) {
                    var e = a[next]
                    if ((e is Sequence) && !(e is String) && fn != "n") {
                        if (hash && "btodxX".contains(fn[0])) {
                            var rr = []
                            for (ee in e) {
                                var r = callFn_(fn, w, ee, p)
                                if (r[0] == "-") {
                                    r = "-" + Conv.prefixes[fn[0]] + r[1..-1]
                                } else {
                                    r = Conv.prefixes[fn[0]] + r
                                }
                                rr.add(r)
                            }
                            s = s + rr.join(" ")
                        } else {
                            s = s + Fmt.v(fn, w, e, p, " ", "", "")
                        }
                    } else {
                        var r = callFn_(fn, w, e, p)
                        if (hash && "btodxX".contains(fn[0])) {
                            if (r[0] == "-") {
                                r = "-" + Conv.prefixes[fn[0]] + r[1..-1]
                            } else {
                                r = Conv.prefixes[fn[0]] + r
                            }
                        }
                        s = s + r
                    }
                    next = next + 1
                } else {
                    Fiber.abort("Insufficient arguments passed.")
                }
            }
            i = i + 1
        }
        return s
    }

    // Convenience versions of the 'slwrite' method which allow up to 5 arguments
    // to be passed individually rather than in a list.
    static swrite(fmt, a1, a2, a3, a4, a5)  { slwrite(fmt, [a1, a2, a3, a4, a5]) }
    static swrite(fmt, a1, a2, a3, a4)      { slwrite(fmt, [a1, a2, a3, a4]) }
    static swrite(fmt, a1, a2, a3)          { slwrite(fmt, [a1, a2, a3]) }
    static swrite(fmt, a1, a2)              { slwrite(fmt, [a1, a2]) }
    static swrite(fmt, a1)                  { slwrite(fmt, [a1]) }

    // Applies slwrite to the arguments and then 'writes' it (no following \n) to stdout.
    static write(fmt, a1, a2, a3, a4, a5) { System.write(slwrite(fmt, [a1, a2, a3, a4, a5])) }
    static write(fmt, a1, a2, a3, a4)     { System.write(slwrite(fmt, [a1, a2, a3, a4])) }
    static write(fmt, a1, a2, a3)         { System.write(slwrite(fmt, [a1, a2, a3])) }
    static write(fmt, a1, a2)             { System.write(slwrite(fmt, [a1, a2])) }
    static write(fmt, a1)                 { System.write(slwrite(fmt, [a1])) }
    static lwrite(fmt, a)                 { System.write(slwrite(fmt, a)) }

    // Applies slwrite to the arguments and then 'prints' it (with a following \n) to stdout.
    static print(fmt, a1, a2, a3, a4, a5) { System.print(slwrite(fmt, [a1, a2, a3, a4, a5])) }
    static print(fmt, a1, a2, a3, a4)     { System.print(slwrite(fmt, [a1, a2, a3, a4])) }
    static print(fmt, a1, a2, a3)         { System.print(slwrite(fmt, [a1, a2, a3])) }
    static print(fmt, a1, a2)             { System.print(slwrite(fmt, [a1, a2])) }
    static print(fmt, a1)                 { System.print(slwrite(fmt, [a1])) }
    static lprint(fmt, a)                 { System.print(slwrite(fmt, a)) }

    // Prints (with a following \n) an array 'a' to stdout using a typical layout.
    // An 'array' for this purpose is a list or sequence of objects.
    // The parameters: 'w', 'p' and 'bb' are applied using the 'v' method to 'a'.
    // The settings for the other parameters are:
    // 'fn' = "f" for numbers, "z" for complex numbers,"s" otherwise
    // ('p' is ignored for latter) 'sep' = " ", 'cc' = "".
    static aprint(a, w, p, bb) {
        var fn = (a.count > 0 && (a[0] is Num)) ? "f" :
                 (a.count > 0 && (a[0].type.toString == "Complex")) ? "z" : "s"
        System.print(Fmt.v(fn, w, a, p, " ", bb, ""))
    }

    // Convenience versions of the above method which use default values for
    // some parameters.
    static aprint(a, w, p) { aprint(a, w, p, "[]") }
    static aprint(a, w)    { aprint(a, w, precision, "[]") }
    static aprint(a)       { aprint(a, 0, precision, "[]") }

    // Prints (with a following \n) a matrix 'm' to stdout using a typical layout.
    // A 'matrix' for this purpose is a two-dimensional list or sequence of objects.
    // A Matrix or CMatrix object is automatically converted to a 2D list of numbers.
    // The parameters: 'w', 'p' and 'bb' are applied using the 'v2' method to 'm'.
    // The settings for the other parameters are:
    // 'fn' = "f" for numbers, "z" for complex numbers, "s" otherwise
    // ('p' is ignored for latter) 'sep' = " ", 'cc' = "", 'ss' = "\n".
    static mprint(m, w, p, bb) {
       var s = m.type.toString
       if (s == "Matrix" || s == "CMatrix") m = m.toList
       var fn = (m.count > 0 && m[0].count > 0 && (m[0][0] is Num)) ? "f" :
                (m.count > 0 && m[0].count > 0 && (m[0][0].type.toString == "Complex")) ? "z" : "s"
       System.print(Fmt.v2(fn, w, m, p, " ", bb, "", "\n"))
    }

    // Convenience versions of the above method which use default values for
    // some parameters.
    static mprint(m, w, p) { mprint(m, w, p, "|") }
    static mprint(m, w)    { mprint(m, w, precision, "|") }
    static mprint(m)       { mprint(m, 0, precision, "|") }
}

// Type aliases for classes in case of any name clashes with other modules.
var Fmt_Conv = Conv
var Fmt_Fmt = Fmt
