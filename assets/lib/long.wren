// url: https://rosettacode.org/wiki/Category:Wren-long
// source: https://rosettacode.org/mw/index.php?title=Category_talk:Wren-long&action=edit&section=2
// file: long
// name: Wren-long
// author: PureFox
// license: MIT

/* Module "long.wren" */

import "./trait" for Comparable

/*
    ULong represents a 64-bit unsigned integer together with arithmetic operations thereon.
    ULong objects are stored as two non-negative integers < 2^32 and are immutable.
*/
class ULong is Comparable {
    // Constants
    static zero     { lohi_( 0, 0) }
    static one      { lohi_( 1, 0) }
    static two      { lohi_( 2, 0) }
    static three    { lohi_( 3, 0) }
    static four     { lohi_( 4, 0) }
    static five     { lohi_( 5, 0) }
    static ten      { lohi_(10, 0) }

    // Returns the maximum 'short' ULong = 2^32-1 = 4294967295
    static maxShort { lohi_(4294967295, 0) }

    // Returns the maximum 'small' ULong = 2^53-1 = 9007199254740991
    static maxSmall { lohi_(4294967295, 2097151) }

    // Returns the largest ULong = 2^64-1 = 18446744073709551615
    static largest  { lohi_(4294967295, 4294967295) }

    // Returns the smallest ULong = 0
    static smallest { lohi_(0, 0) }

     // Private method to determine whether a number is a short unsigned integer or not.
    static isShort_(n) { (n is Num) && n.isInteger && n >= 0 && n <= 4294967295 }

    // Private method to determine whether a number is a small unsigned integer or not.
    static isSmall_(n) { (n is Num) && n.isInteger && n >= 0 && n <= 9007199254740991 }

    // Private method to calculate the base 2 logarithm of a number.
    static log2_(n) { n.log / 0.69314718055994530942 }

    // Private helper function to convert a string to lower case.
    static lower_(s) { s.codePoints.map { |c|
        return String.fromCodePoint((c >= 65 && c <= 90) ? c + 32 : c)
    }.join() }


    // Private helper method to convert a lower case base string to a small integer.
    static atoi_(s, base, digits) {
        var res = 0
        for (d in s) {
            var ix = digits.indexOf(d)
            res = res * base + ix
        }
        return res
    }

    // Private helper method to convert a small integer to a string with a base between 2 and 36.
    static itoa_(n, base, digits) {
        if (n == 0) return "0"
        var res = ""
        while (n > 0) {
            res = res + "%(digits[n%base])"
            n = (n/base).floor
        }
        return res[-1..0]
    }

    // Private helper method to check whether a 20 digit string exceeds the largest value string.
    static exceedsMaxString_(s) {
        var m = "18446744073709551615"
        if (s == m) return false
        var mb = m.bytes
        var sb = s.bytes
        for (i in 0..19) {
            if (mb[i] < sb[i]) return true
            if (mb[i] > sb[i]) return false
        }
    }

    // Returns the greater of two ULongs.
    static max(a, b) {
        if (!(a is ULong)) a = new(a)
        if (!(b is ULong)) b = new(b)
        return (a > b) ? a : b
    }

    // Returns the lesser of two ULongs.
    static min(a, b) {
        if (!(a is ULong)) a = new(a)
        if (!(b is ULong)) b = new(b)
        return (a < b) ? a : b
    }

    // Returns the greatest common divisor of a and b.
    static gcd(a, b) {
        if (!(a is ULong)) a = new(a)
        if (!(b is ULong)) b = new(b)
        while (!b.isZero) {
            var t = b
            b = a % b
            a = t
        }
        return a
    }

    // Returns the least common multiple of a and b.
    static lcm(a, b) {
        if (!(a is ULong)) a = new(a)
        if (!(b is ULong)) b = new(b)
        return a / gcd(a, b) * b
    }

    // Returns the factorial of 'n'. Can only be used for n <= 20
    static factorial(n) {
        if (!(((n is Num) || (n is ULong)) && n >= 0 && n <= 20)) {
            Fiber.abort("Argument must be a non-negative integer no larger than 20.")
        }
        if (n < 2) return one
        var fact = one
        var i = two
        while (i <= n) {
            fact = fact * i
            i = i + 1
        }
        return fact
    }

    // Returns whether or not 'n' is an instance of ULong.
    static isInstance(n) { n is ULong }

    // Private method to determine if a ULong is a basic prime or not.
    static isBasicPrime_(n) {
        if (!(n is ULong)) n = new(n)
        if (n.isOne) return false
        if (n == two || n == three || n == five) return true
        if (n.isEven || n.isDivisibleBy(three) || n.isDivisibleBy(five)) return false
        if (n < 49) return true
        return null // unknown if prime or not
    }

    // Private method to apply the Miller-Rabin test.
    static millerRabinTest_(n, a) {
        var nPrev = n.dec
        var b = nPrev
        var r = 0
        while (b.isEven) {
            b = b >> 1
            r = r + 1
        }
        for (i in 0...a.count) {
            if (n >= a[i]) {
                var x = (a[i] is ULong) ? a[i] : new(a[i])
                x = x.modPow(b, n)
                if (!x.isOne && x != nPrev) {
                    var d = r - 1
                    var next = false
                    while (d != 0) {
                        x = x.square % n
                        if (x.isOne) return false
                        if (x == nPrev) {
                            next = true
                            break
                        }
                        d = d - 1
                    }
                    if (!next) return false
                }
            }
        }
        return true
    }

    // Private constructor which creates a ULong object from low and high components.
    construct lohi_(low, high) {
        _lo = low
        _hi = high
    }

    // Private constructor which creates a ULong object from a 'small' integer.
    construct fromSmall_(v) {
        var p = 4294967296  // 2 ^ 32
        _lo = (v % p)
        _hi = (v / p).floor
    }

    // Private constructor which creates a ULong object from a Num.
    // If 'v' is not small, will probably lose accuracy.
    construct fromNum_(v) {
        if (v < 0 || v.isNan) return ULong.zero
        var m = 4294967296  // 2 ^ 32
        if (v >= 2.pow(64)) return ULong.lohi_(m - 1, m - 1)
        return ULong.lohi_(v % m, (v / m).floor)
    }

    // Private constructor which creates a ULong object from a base 10 numeric string.
    // Scientific notation is permitted.
    // Raises an error if the result is out of bounds.
    construct fromString_(v) {
        v = v.trim()
        if (v.count == 0 || v[0] == "-") Fiber.abort("Invalid unsigned integer.")
        if (v[0] == "+") {
            v = v[1..-1]
            if (v.count == 0) Fiber.abort("Invalid unsigned integer.")
        }
        v = v.trimStart("0")
        if (v == "") v = "0"
        v = ULong.lower_(v)
        var split = v.split("e")
        if (split.count > 2) Fiber.abort("Invalid unsigned integer.")
        if (split.count == 2) {
            var exp = split[1]
            if (exp[0] == "+") exp = exp[1..-1]
            exp = Num.fromString(exp)
            if (!ULong.isSmall_(exp)) Fiber.abort("Exponent is not valid.")
            var text = split[0]
            var dp = text.indexOf(".")
            if (dp >= 0) {
                exp = exp - (text.count - dp - 1)
                text = text[0...dp] + text[dp+1..-1]
            }
            if (exp < 0) Fiber.abort("Exponent cannot be negative.")
            text = text + ("0" * exp)
            v = text
        }
        var len = v.count
        var isValid = len > 0 && v.all { |d| "0123456789".contains(d) }
        if (!isValid) Fiber.abort("Invalid unsigned integer.")
        if (len > 20 || (len == 20 && ULong.exceedsMaxString_(v))) {
            Fiber.abort("Integer is too big.")
        }
        if (len <= 16) {
            var n = Num.fromString(v)
            if (ULong.isSmall_(n)) return ULong.fromSmall_(n)
        }
        // process in 10 digit chunks
        var r = ULong.zero
        var pow10 = ULong.fromSmall_(10.pow(10))
        var i = 0
        while (i < len) {
            var chunkSize = ((len - i) < 10) ? len - i : 10
            var chunk = Num.fromString(v[i...i + chunkSize])
            if (chunkSize < 10) {
                var psize = ULong.fromSmall_(10.pow(chunkSize))
                r = r * psize + ULong.fromSmall_(chunk)
            } else {
                r = r * pow10 + ULong.fromSmall_(chunk)
            }
            i = i + 10
        }
        return r
    }

    // Creates a ULong object from an (unprefixed) numeric string in a given base (2 to 36).
    // Scientific notation is not permitted.
    // Wraps out of range values.
    construct fromBaseString(v, base) {
        if (!(v is String)) Fiber.abort("Value must be a numeric string in the given base.")
        if (!((base is Num) && base.isInteger && base >= 2 && base <= 36)) {
            Fiber.abort("Base must be an integer between 2 and 36.")
        }
        v = v.trim()
        if (v.count == 0 || v[0] == "-") Fiber.abort("Invalid unsigned integer.")
        if (v[0] == "+") {
            v = v[1..-1]
            if (v.count == 0) Fiber.abort("Invalid unsigned integer.")
        }
        v = v.trimStart("0")
        if (v == "") v = "0"
        if (base > 10) v = ULong.lower_(v)
        var alphabet = "0123456789abcdefghijklmnopqrstuvwxyz"
        var digits = alphabet[0...base]
        var len = v.count
        var isValid = len > 0 && v.all { |d| digits.contains(d) }
        if (!isValid) Fiber.abort("Invalid unsigned integer.")
        // process in 10 digit chunks
        var r = ULong.zero
        var powb = ULong.fromSmall_(base.pow(10))
        var i = 0
        while (i < len) {
            var chunkSize = ((len - i) < 10) ? len - i : 10
            var chunk = ULong.atoi_(v[i...i + chunkSize], base, digits)
            if (chunkSize < 10) {
                var psize = ULong.fromSmall_(base.pow(chunkSize))
                r = r * psize + ULong.fromSmall_(chunk)
            } else {
                r = r * powb + ULong.fromSmall_(chunk)
            }
            i = i + 10
        }
        return r
    }

    // Creates a ULong object from either a numeric base 10 string or an unsigned 'small' integer.
    static new(value) {
         if (!(value is String) && !isSmall_(value)) {
              Fiber.abort("Value must be a base 10 numeric string or an unsigned small integer.")
         }
         return (value is String) ? fromString_(value) : fromSmall_(value)
    }

    // Creates a ULong object from an (unprefixed) hexadecimal string. Wraps out of range values.
    static fromHexString(v) { fromBaseString(v, 16) }

    // Creates a ULong object from a pair (low and high) of unsigned 'short' integers.
    static fromPair(low, high) {
        if (!isShort_(low) || !isShort_(high)) {
            Fiber.abort("Low and high components must both be unsigned 32-bit integers.")
        }
        return lohi_(low, high)
    }

    // Creates a ULong object from a list of 8 unsigned bytes in little-endian format.
    static fromBytes(bytes) {
        if (bytes.count != 8) Fiber.abort("There must be exactly 8 bytes in the list.")
        for (b in bytes) {
            if (!(b is Num && b.isInteger && b >= 0 && b < 256)) {
                Fiber.abort("Each byte must be an integer between 0 and 255.")
            }
        }
        var low  = bytes[0] | bytes[1] << 8 | bytes[2] << 16 | bytes[3] << 24
        var high = bytes[4] | bytes[5] << 8 | bytes[6] << 16 | bytes[7] << 24
        return lohi_(low, high)
    }

    // Properties to return the low and high 32-bit portions of this instance.
    low  { _lo }
    high { _hi }

    // Public self-evident properties.
    isShort { _hi == 0 }
    isSmall { _hi <= 2097151 }
    isEven  { _lo % 2 == 0 }
    isOdd   { _lo % 2 == 1 }
    isOne   { _lo == 1 && _hi == 0 }
    isZero  { _lo == 0 && _hi == 0 }

    // Returns true if 'n' is a divisor of the current instance, false otherwise
    isDivisibleBy(n) { (this % n).isZero }

    // Returns true if the current instance is prime, false otherwise.
    isPrime {
        var isbp = ULong.isBasicPrime_(this)
        if (isbp != null) return isbp
        return ULong.millerRabinTest_(this, [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37])
    }

    // Private method to calculate the index of this instance's most significant bit (0 to 63).
    msb_ {
        if (_hi == 0) return (_lo > 0) ? ULong.log2_(_lo).floor : 0
        return ULong.log2_(_hi).floor + 32
    }

    // Returns the bitwise complement of the current instance.
    ~ { ULong.lohi_(~_lo, ~_hi) }

    // Adds a ULong to the current instance. Wraps on overflow.
    + (n) {
        if (!(n is ULong)) n = ULong.new(n)
        if (this.isZero) return n.copy()
        if (n.isZero) return this.copy()
        var low  = _lo + n.low
        var high = _hi + n.high
        var m = 4294967296 // 2^32
        if (low >= m) {
            low = low - m
            high = high + 1
        }
        if (high >= m) {
            high = high - m
        }
        return ULong.lohi_(low, high)
    }

    // Subtracts a ULong from the current instance. Wraps on underflow.
    - (n) {
        if (!(n is ULong)) n = ULong.new(n)
        if (n.isZero) return this.copy()
        return this + (~n) + ULong.one
    }

    // Multiplies the current instance by a ULong. Wraps on overflow.
    * (n) {
        if (!(n is ULong)) n = ULong.new(n)
        if (this.isZero || n.isZero) return ULong.zero
        // if the sum of the msbs for both ULongs is less than 51 use Num multiplication
        if (this.msb_ + n.msb_ < 51) return ULong.fromSmall_(this.toNum * n.toNum)
        // otherwise split the operands into 16 bit pieces to do the multiplication
        var a3 = _hi >> 16
        var a2 = _hi & 0xffff
        var a1 = _lo >> 16
        var a0 = _lo & 0xffff

        var b3 = n.high >> 16
        var b2 = n.high & 0xffff
        var b1 = n.low >> 16
        var b0 = n.low & 0xffff

        var c0 = a0 * b0
        var c1 = (c0 >> 16) + a1 * b0
        c0 = c0 & 0xffff
        var c2 = c1 >> 16
        c1 = (c1 & 0xffff) + a0 * b1
        c2 = c2 + (c1 >> 16) + a2 * b0
        c1 = c1 & 0xffff
        var c3 = c2 >> 16
        c2 = (c2 & 0xffff) + a1 * b1
        c3 = c3 + (c2 >> 16)
        c2 = (c2 & 0xffff) + a0 * b2
        c3 = c3 + (c2 >> 16)
        c2 = c2 & 0xffff
        c3 = (c3 + a3 * b0 + a2 * b1 + a1 * b2 + a0 * b3) & 0xffff

        return ULong.lohi_((c1 << 16) | c0, (c3 << 16) | c2)
    }

    // Returns a list containing the quotient and the remainder after dividing
    // the current instance by a ULong.
    divMod(n) {
        if (!(n is ULong)) n = ULong.new(n)
        if (n.isZero) Fiber.abort("Cannot divide by zero.")
        // if both operands are 'small' use Num division.
        if (this.isSmall && n.isSmall) {
             var a = this.toNum
             var b = n.toNum
             return [ULong.fromSmall_((a/b).floor), ULong.fromSmall_(a%b)]
        }
        if (this.isZero) return [ULong.zero, ULong.zero]
        if (n.isOne) return [this.copy(), ULong.zero]
        if (n > this) return [ULong.zero, this.copy()]
        // use Num division to estimate the answer and refine it until the exact answer is found.
        var div = ULong.zero
        var rem = this.copy()
        // iterate until the remainder is less than the divisor
        while (rem >= n) {
            var est = (rem.toNum / n.toNum).floor
            if (est < 1) est = 1  // must be at least 1
            var emsb = ULong.log2_(est).ceil
            // calculate an adjustment to use based on the size of the estimate
            var adj = (emsb <= 53) ? 1 : 1 << (emsb-53)
            var div2 = ULong.fromNum_(est)
            var rem2 = div2 * n
            var rem3 = rem2 - div2 // to check whether rem2 has overflowed
            // reduce the estimated remainder until it is no greater than the actual remainder
            while (rem2 > rem || rem3 >= rem2) {
                est = est - adj
                div2 = ULong.fromNum_(est)
                rem2 = div2 * n
                rem3 = rem2 - div2
            }
            if (div2.isZero) div2 = ULong.one // must be at least one
            div = div + div2
            rem = rem - rem2
        }
        return [div, rem]
    }

    // Divides the current instance by a ULong.
    / (n) { divMod(n)[0] }

    // Returns the remainder after dividing the current instance by a ULong.
    % (n) { divMod(n)[1] }

    //Returns the bitwise 'and' of the current instance and another ULong.
    & (n) {
        if (!(n is ULong)) n = ULong.new(n)
        return ULong.lohi_(_lo & n.low, _hi & n.high)
    }

    // Returns the bitwise 'or' of the current instance and another ULong.
    | (n) {
        if (!(n is ULong)) n = ULong.new(n)
        return ULong.lohi_(_lo | n.low, _hi | n.high)
    }

    // Returns the bitwise 'xor' of the current instance and another ULong.
    ^ (n) {
        if (!(n is ULong)) n = ULong.new(n)
        return ULong.lohi_(_lo ^ n.low, _hi ^ n.high)
    }

    // Shifts the bits of the current instance 'n' places to the left. Wraps modulo 64.
    // Negative shifts are allowed.
    << (n) {
        if (n is ULong) n = n.toNum
        n = n & 63
        if (n == 0) return this.copy()
        if (n < 32) {
            return ULong.lohi_(_lo << n, (_hi << n) | (_lo >> (32 - n)))
        }
        return ULong.lohi_(0, _lo << (n - 32))
    }

    // Shifts the bits of the current instance 'n' places to the right. Wraps modulo 64.
    // Negative shifts are allowed.
    >> (n) {
        if (n is ULong) n = n.toNum
        n = n & 63
        if (n == 0) return this.copy()
        if (n < 32) {
            return ULong.lohi_(_lo >> n | (_hi << (32 - n)), _hi >> n)
        }
        return ULong.lohi_(_hi >> (n - 32), 0)
    }

    // The inherited 'clone' method just returns 'this' as ULong objects are immutable.
    // If you need an actual copy use this method instead.
    copy() { ULong.lohi_(_lo, _hi) }

    // Compares the current instance with a ULong. If they are equal returns 0.
    // If 'this' is greater, returns 1. Otherwise returns -1.
    // Also allows a comparison with positive infinity.
    compare(n) {
        if ((n is Num) && n.isInfinity && n > 0) return -1
        if (!(n is ULong)) n = ULong.new(n)
        if (_hi == n.high && _lo == n.low) return 0
        if (_hi > n.high) return 1
        if (_hi < n.high) return -1
        return (_lo < n.low) ? -1 : 1
    }

    // Returns the greater of this instance and another ULong instance.
    max(n) { ULong.max(this, n) }

    // Returns the smaller of this instance and another ULong instance.
    min(n) { ULong.min(this, n) }

    // Clamps this instance into the range [a, b].
    // If this instance is less than min, min is returned.
    // If it's more than max, max is returned. Otherwise, this instance is returned.
    clamp(a, b) {
        if (!(a is ULong)) a = ULong.new(a)
        if (!(b is ULong)) b = ULong.new(b)
        if (a > b) Fiber.abort("Range cannot be decreasing.")
        if (this < a) return a
        if (this > b) return b
        return this.copy()
    }

    // Squares the current instance. Wraps on overflow.
    square { this * this }

    // Returns the integer square root of the current instance i.e. the largest integer 'x0'
    // such that x0.square <= this.
    isqrt {
        if (isSmall) return ULong.fromSmall_(toNum.sqrt.floor)
        // otherwise use Newton's method
        var x0 = this >> 1
        var x1 = (x0 + this/x0) >> 1
        while (x1 < x0) {
            x0 = x1
            x1 = (x0 + this/x0) >> 1
        }
        return x0
    }

    // Returns the current instance raised to the power of a 'small' ULong. Wraps on overflow.
    // If the exponent is less than 0, returns 0. O.pow(0) returns one.
    pow(n) {
        if (!(n is ULong)) n = ULong.new(n)
        if (n.isZero) return ULong.one
        if (n.isOne) return this.copy()
        if (this.isZero) return ULong.zero
        if (this.isOne) return ULong.one
        if (!n.isSmall) Fiber.abort("The exponent %(n) is too large.")
        if (this.isSmall) {
            var value = this.toNum.pow(n.toNum)
            if (ULong.isSmall_(value)) return ULong.fromSmall_(value)
        }
        var x = this
        var y = ULong.one
        var z = n
        while (true) {
            if (z.isOdd) {
                y = y * x
                z = z - 1
            }
            if (z.isZero) break
            z = z >> 1
            x = x.square
        }
        return y
    }

    // Returns the current instance to the power 'exp' modulo 'mod'.
    modPow(exp, mod) {
        if (!(exp is ULong)) exp = ULong.new(exp)
        if (!(mod is ULong)) mod = ULong.new(mod)
        if (mod.isZero) Fiber.abort("Cannot take modPow with modulus 0.")
        var r = ULong.one
        var base = this % mod
        while (!exp.isZero) {
            if (base.isZero) return ULong.zero
            if (exp.isOdd) r = (r * base) % mod
            exp = exp >> 1
            base = base.square % mod
        }
        return r
    }

    // Increments the current instance by one.
    inc { this + ULong.one }

    // Decrements the current instance by one.
    dec { this - ULong.one }

    // Returns 0 if the current instance is zero or 1 otherwise.
    sign { isZero ? 0 : 1 }

    // Returns the number of digits required to represent the current instance in binary.
    bitLength { msb_ + 1 }

    // Returns true if the 'n'th bit of the current instance is set or false otherwise.
    testBit(n) {
        if (n.type != Num || !n.isInteger || n < 0 || n > 63) {
            Fiber.abort("Argument must be a non-negative integer less than 64.")
        }
        return (this >> n) & ULong.one != ULong.zero
    }

    // Converts the current instance to a Num where possible.
    // Will probably lose accuracy if the current instance is not 'small'.
    toNum { _hi * 4294967296 + _lo }

    // Converts the current instance to a 'small' integer where possible.
    // Otherwise returns null.
    toSmall { isSmall ? toNum : null }

    // Expresses the current instance as a pair of 'short' integers, low and high.
    toPair { [_lo, _hi] }

    // Expresses the current instance as a list of 8 unsigned bytes in little-endian format.
    toBytes {
        return [_lo & 0xff, _lo >> 8 & 0xff, _lo >> 16 & 0xff, _lo >> 24       ,
                _hi & 0xff, _hi >> 8 & 0xff, _hi >> 16 & 0xff, _hi >> 24]
    }

    // Private worker method for toBaseString, toHexString and toString.
    toBaseString_(base) {
        if (isZero) return "0"
        // process in 6 digit chunks
        var pow6 = ULong.fromSmall_(base.pow(6))
        var alphabet = "0123456789abcdefghijklmnopqrstuvwxyz"
        var rem = this
        var res = ""
        while (true) {
            var div = rem / pow6
            var val = (rem - div * pow6).toNum >> 0
            var digits = ULong.itoa_(val, base, alphabet[0...base])
            rem = div
            if (rem.isZero) return digits + res
            if (digits.count < 6) digits = "0" * (6 - digits.count) + digits
            res = digits + res
        }
    }

    // Returns the string representation of the current instance in a given base (2 to 36).
    toBaseString(base) {
        if (!((base is Num) && base.isInteger && base >= 2 && base <= 36)) {
            Fiber.abort("Base must be an integer between 2 and 36.")
        }
        return toBaseString_(base)
    }

    // Returns the string representation of the current instance in base 16.
    toHexString { toBaseString_(16) }

    // Returns the string representation of the current instance in base 10.
    toString { toBaseString_(10) }
}

/*  ULongs contains various routines applicable to lists of unsigned 64-bit integers. */
class ULongs {
    static sum(a)  { a.reduce(ULong.zero) { |acc, x| acc + x } }
    static mean(a) { sum(a)/a.count }
    static prod(a) { a.reduce(ULong.one) { |acc, x| acc * x } }
    static max(a)  { a.reduce { |acc, x| (x > acc) ? x : acc } }
    static min(a)  { a.reduce { |acc, x| (x < acc) ? x : acc } }
}

// Type aliases for classes in case of any name clashes with other modules.
var Long_ULong  = ULong
var Long_ULongs = ULongs
var Long_Comparable = Comparable // in case imported indirectly
