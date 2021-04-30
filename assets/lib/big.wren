/* Module "big.wren" */

import "./trait" for Comparable
import "random" for Random

/*
    BigInt represents an arbitrary length integer allowing arithmetic operations on integers of
    unlimited size. Internally, there are two kinds: 'small' (up to a magnitude of 2^53 -1)
    and 'big' (magnitude >= 2^53). The former are stored as ordinary Nums and the latter as a
    little-endian list of integers using a base of 1e7. In both cases, there is an additional Bool
    to indicate whether the integer is signed or not. BigInt objects are immutable.
*/
class BigInt is Comparable {
    // Constants.
    static minusOne { BigInt.small_(-1) }
    static zero     { BigInt.small_( 0) }
    static one      { BigInt.small_( 1) }
    static two      { BigInt.small_( 2) }
    static three    { BigInt.small_( 3) }
    static four     { BigInt.small_( 4) }
    static five     { BigInt.small_( 5) }
    static ten      { BigInt.small_(10) }

    // Private method to initialize static fields.
    static init_() {
        // All possible digits for bases 2 to 36.
        __alphabet = "0123456789abcdefghijklmnopqrstuvwxyz"

        // Maximum 'small' integer = 2^53 - 1
        __maxSmall = 9007199254740991

        // Random number generator.
        __rand = Random.new()

        // Threshold between small and big integers in 'list' format.
        __threshold = smallToList_(9007199254740992)

        // List of powers of 2 up to 1e7.
        __powersOfTwo = powersOfTwo_

        // Length of __powersOfTwo (pre-computed).
        __powers2Length = 24

        // Last element of __powersOfTwo (pre-computed).
        __highestPower2 = 8388608
    }

    // Returns the maximum 'small' BigInt = 2^53-1.
    static maxSmall { BigInt.small_(__maxSmall) }

    // Private property which returns powers of 2 up to 1e7.
    static powersOfTwo_ {
        var pot = [1]
        while (2 * pot[-1] <= 1e7) pot.add(2 * pot[-1])
        return pot
    }

    // Private method which returns the lowest one bit of a BigInt (rough).
    static roughLOB_(n) {
        var lobmask_i = 1 << 30
        var v = n.value_
        var x
        if (n.isSmall) {
            x =  v | lobmask_i
        } else {
            var base = 1e7
            var lobmask_bi = (base & -base) * (base & -base) | lobmask_i
            x = v[0] + v[1]*base | lobmask_bi
        }
        return x & -x
    }

    // Private method to return the integer logarithm of 'value' with respect to base 'base'
    // i.e.the number of times 'base' can be multiplied by itself without exceeding 'value'.
    static integerLogarithm_(value, base) {
        if (base <= value) {
            var tmp = integerLogarithm_(value, base.square)
            var p = tmp[0]
            var e = tmp[1]
            var t = p * base
            return (t <= value) ? [t, e*2 + 1] : [p, e * 2]
        }
        return [one, 0]
    }

    // Private method to determine whether a number is a small integer or not.
    static isSmall_(n) { (n is Num) && n.isInteger && n.abs <= __maxSmall }

    // Private method to convert a small integer to list format.
    static smallToList_(n) {
        if (n < 1e7) return [n]
        if (n < 1e14) return [n % 1e7, (n/1e7).floor]
        return [n % 1e7, ((n/1e7).floor) % 1e7, (n/1e14).floor]
    }

    // Private method to convert a list to a small integer where possible.
    static listToSmall_(a) {
        trim_(a)
        var length = a.count
        var base = 1e7
        if (length < 4 && compareAbs_(a, __threshold) < 0) {
            if (length == 0) return 0
            if (length == 1) return a[0]
            if (length == 2) return a[0] + a[1]*base
            return a[0] + (a[1] + a[2]*base) * base
        }
        return a
    }

    // Private method to check whether the magnitude of a number n <= 1e7.
    static shiftIsSmall_(n) { n.abs <= 1e7 }

    // Private method to remove any trailing zero elements from a list.
    static trim_(a) {
        var i = a.count - 1
        while (i >= 0 && a[i] == 0) {
            a.removeAt(i)
            i = i - 1
        }
    }

    // Private method to compare two lists, first by length and then by contents.
    static compareAbs_(a, b) {
        if (a.count != b.count) return (a.count > b.count) ? 1 : -1
        var i = a.count - 1
        while (i >= 0) {
            if (a[i] != b[i]) return (a[i] > b[i]) ? 1 : -1
            i = i - 1
        }
        return 0
    }

    // Private method to add two lists where a.count >= b.count.
    static add_(a, b) {
        var la = a.count
        var lb = b.count
        var r = List.filled(la, 0)
        var carry = 0
        var base = 1e7
        var sum = 0
        var i = 0
        while (i < lb) {
            sum = a[i] + b[i] + carry
            carry = (sum >= base) ? 1 : 0
            r[i] = sum - carry*base
            i = i + 1
        }
        while (i < la) {
            sum = a[i] + carry
            carry = (sum == base) ? 1 : 0
            r[i] = sum - carry*base
            i = i + 1
        }
        if (carry > 0) r.add(carry)
        return r
    }

    // Private method to add two lists regardless of length.
    static addAny_(a, b) { (a.count >= b.count) ? add_(a, b) : add_(b, a) }

    // Private method to add 'carry' (0 <= carry <= maxSmall) to a list 'a'.
    static addSmall_(a, carry) {
        var l = a.count
        var r = List.filled(l, 0)
        var base = 1e7
        var sum = 0
        for (i in 0...l) {
            sum = a[i] - base + carry
            carry = (sum/base).floor
            r[i] = sum - carry*base
            carry = carry + 1
        }
        while (carry > 0) {
            r.add(carry % base)
            carry = (carry/base).floor
        }
        return r
    }

    // Private method to subtract two lists where a.count >= b.count.
    static subtract_(a, b) {
        var la = a.count
        var lb = b.count
        var r = List.filled(la, 0)
        var borrow = 0
        var base = 1e7
        var diff = 0
        var i = 0
        while (i < lb) {
            diff = a[i] - borrow - b[i]
            if (diff < 0) {
                diff = diff + base
                borrow = 1
            } else borrow = 0
            r[i] = diff
            i = i + 1
        }
        while (i < la) {
            diff = a[i] - borrow
            if (diff < 0) {
                diff = diff + base
            } else {
                r[i] = diff
                i = i + 1
                break
            }
            r[i] = diff
            i = i + 1
        }
        while (i < la) {
            r[i] = a[i]
            i = i + 1
        }
        trim_(r)
        return r
    }

    // Private method to subtract lists regardless of length.
    static subtractAny_(a, b, signed) {
        var value
        if (compareAbs_(a, b) >= 0) {
            value = subtract_(a, b)
        } else {
            value = subtract_(b, a)
            signed = !signed
        }
        value = listToSmall_(value)
        if (value is Num) {
            if (signed) value = -value
            return BigInt.small_(value)
        }
        return BigInt.big_(value, signed)
    }

    // Private method to subtract 'b' (0 <= b <= maxSmall) from a list 'a'.
    static subtractSmall_(a, b, signed) {
        var l = a.count
        var r = List.filled(l, 0)
        var carry = -b
        var base = 1e7
        for (i in 0...l) {
            var diff = a[i] + carry
            carry = (diff/base).floor
            diff = diff % base
            r[i] = (diff < 0) ? diff + base : diff
        }
        r = listToSmall_(r)
        if (r is Num) {
            if (signed) r = -r
            return BigInt.small_(r)
        }
        return BigInt.big_(r, signed)
    }

    // Private method to multiply two lists.
    static multiplyLong_(a, b) {
        var la = a.count
        var lb = b.count
        var l  = la + lb
        var r  = List.filled(l, 0)
        var base = 1e7
        for (i in 0...la) {
            var ai = a[i]
            for (j in 0...lb) {
                var bj = b[j]
                var prod = ai*bj + r[i + j]
                var carry = (prod/base).floor
                r[i + j] = prod - carry*base
                r[i + j + 1] = r[i + j + 1] + carry
            }
        }
        trim_(r)
        return r
    }

    /// Private method to multiply a list 'a' by 'b' (|b| < 1e7).
    static multiplySmall_(a, b) {
        var l = a.count
        var r = List.filled(l, 0)
        var base = 1e7
        var carry = 0
        for (i in 0...l) {
            var prod = a[i]*b + carry
            carry = (prod/base).floor
            r[i] = prod - carry*base
        }
        while (carry > 0) {
            r.add(carry % base)
            carry = (carry/base).floor
        }
        return r
    }

    // Private helper method for multiplyKaratsuba_ method.
    static shiftLeft_(x, n) {
        var r = []
        while (n > 0) {
            n = n - 1
            r.add(0)
        }
        return r + x
    }

    // Private method to multiply two lists 'x' and 'y' using the Karatsuba algorithm.
    static multiplyKaratsuba_(x, y) {
        var n = (x.count > y.count) ? y.count : x.count
        if (n <= 30) return multiplyLong_(x, y)
        n = (n/2).floor
        var a = x[0...n]
        var b = x[n..-1]
        var c = y[0...n]
        var d = y[n..-1]
        var ac = multiplyKaratsuba_(a, c)
        var bd = multiplyKaratsuba_(b, d)
        var abcd = multiplyKaratsuba_(addAny_(a, b), addAny_(c, d))
        var s = subtract_(subtract_(abcd, ac), bd)
        var prod = addAny_(addAny_(ac, shiftLeft_(s, n)), shiftLeft_(bd, 2 * n))
        trim_(prod)
        return prod
    }

    // Private method to determine whether Karatsuba multiplication may be beneficial.
    static useKaratsuba_(l1, l2) { -0.012*l1 - 0.012*l2 + 0.000015*l1*l2 > 0 }

    // Private method to multiply a small integer 'a' (a >= 0) by a list 'b'.
    static multiplySmallAndList_(a, b, signed) {
        if (a < 1e7) return BigInt.big_(multiplySmall_(b, a), signed)
        return BigInt.big_(multiplyLong_(b, smallToList_(a)), signed)
    }

    // Private method to square a list.
    static square_(a) {
        var l = a.count
        var r = List.filled(l + l, 0)
        var base = 1e7
        for (i in 0...l) {
            var ai = a[i]
            var carry = 0 - ai*ai
            var j = i
            while (j < l) {
                var aj = a[j]
                var prod = 2*ai*aj + r[i + j] + carry
                carry = (prod/base).floor
                r[i + j] = prod - carry*base
                j = j + 1
            }
            r[i + l] = carry
         }
         trim_(r)
         return r
    }

    // Private method to 'div/mod' two lists, better for smaller sizes.
    static divMod1_(a, b) {
        var la = a.count
        var lb = b.count
        var base = 1e7
        var result = List.filled(la - lb + 1, 0)
        var divMostSigDigit = b[-1]
        // normalization
        var lambda = (base/(2*divMostSigDigit)).ceil
        var remainder = multiplySmall_(a, lambda)
        var divisor = multiplySmall_(b, lambda)
        if (remainder.count <= la) remainder.add(0)
        divisor.add(0)
        divMostSigDigit = divisor[lb-1]
        var shift = la - lb
        while (shift >= 0) {
            var quotDigit = base - 1
            if (remainder[shift+lb] != divMostSigDigit) {
                quotDigit = ((remainder[shift+lb]*base + remainder[shift+lb-1])/divMostSigDigit).floor
            }
            var carry = 0
            var borrow = 0
            var l = divisor.count
            for (i in 0...l) {
                carry = carry + quotDigit*divisor[i]
                var q = (carry/base).floor
                borrow = borrow + remainder[shift+i] - (carry - q*base)
                carry = q
                if (borrow < 0) {
                    remainder[shift+i] = borrow + base
                    borrow = -1
                } else {
                    remainder[shift+i] = borrow
                    borrow = 0
                }
            }
            while (borrow != 0) {
                quotDigit = quotDigit - 1
                carry = 0
                for (i in 0...l) {
                    carry = carry + remainder[shift+i] - base + divisor[i]
                    if (carry < 0) {
                        remainder[shift+i] = carry + base
                        carry = 0
                    } else {
                        remainder[shift+i] = carry
                        carry = 1
                    }
                }
                borrow = borrow + carry
            }
            result[shift] = quotDigit
            shift = shift - 1
        }
        // denormalization
        remainder = divModSmall_(remainder, lambda)[0]
        return [listToSmall_(result), listToSmall_(remainder)]
    }

    // Private method to 'div/mod' two lists, better for larger sizes.
    static divMod2_(a, b) {
        var la = a.count
        var lb = b.count
        var result = []
        var part = []
        var base = 1e7
        while (la != 0) {
            la = la - 1
            part = a[la..la] + part
            trim_(part)
            if (compareAbs_(part, b) < 0) {
                result.add(0)
            } else {
                var xlen = part.count
                var highx = part[xlen-1]*base + part[xlen-2]
                var highy = b[lb-1]*base + b[lb-2]
                if (xlen > lb) highx = (highx + 1) * base
                var guess = (highx/highy).ceil
                var check
                while (true) {
                    check = multiplySmall_(b, guess)
                    if (compareAbs_(check, part) <= 0) break
                    guess = guess - 1
                    if (guess == 0) break
                }
                result.add(guess)
                part = subtract_(part, check)
            }
        }
        result = result[-1..0]
        return [listToSmall_(result), listToSmall_(part)]
    }

    // Private method to 'div/mod' a list 'value' with an integer 'lambda'.
    static divModSmall_(value, lambda) {
        var length = value.count
        var quot = List.filled(length, 0)
        var base = 1e7
        var remainder = 0
        var i = length - 1
        while (i >= 0) {
            var divisor = remainder*base + value[i]
            var q = (divisor/lambda).truncate
            remainder = divisor - q*lambda
            quot[i] = q | 0
            i = i - 1
        }
        return [quot, remainder | 0]
    }

    // Private method to 'div/mod' any two BigInts.
    static divModAny_(self, n) {
         var a = self.value_
         if (!(n is BigInt)) n = BigInt.new(n)
         var b = n.value_
         if (b == 0) Fiber.abort("Cannot divide by zero.")
         if (self.isSmall) {
            if (n.isSmall) {
                var c = (a/b).truncate
                return [BigInt.small_(c), BigInt.small_(a % b)]
            }
            return [zero, self]
         }
         var quotient
         if (n.isSmall) {
            if (b == 1) return [self, zero]
            if (b == -1) return [-self, zero]
            var ab = b.abs
            if (ab < 1e7) {
                var value = divModSmall_(a, ab)
                quotient = listToSmall_(value[0])
                var remainder = value[1]
                if (self.signed_) remainder = -remainder
                if (quotient is Num) {
                    if (self.signed_ != n.signed_) quotient = -quotient
                    return [BigInt.small_(quotient), BigInt.small_(remainder)]
                }
                return [BigInt.big_(quotient, self.signed_ != n.signed_), BigInt.small_(remainder)]
            }
            b = smallToList_(ab)
        }
        var comparison = compareAbs_(a, b)
        if (comparison == -1) return [BigInt.zero, self]
        if (comparison == 0) return [(self.signed_ == n.signed_) ? one : minusOne, zero]

        // divMod1 is faster on smaller input sizes
        var value = (a.count + b.count <= 200) ? divMod1_(a, b) : divMod2_(a, b)
        quotient = value[0]
        var qSign = self.signed_ != n.signed_
        var mod = value[1]
        var mSign = self.signed_
        if (quotient is Num) {
            if (qSign) quotient = -quotient
            quotient = BigInt.small_(quotient)
        } else quotient = BigInt.big_(quotient, qSign)
        if (mod is Num) {
            if (mSign) mod = -mod
            mod = BigInt.small_(mod)
        } else mod = BigInt.big_(mod, mSign)
        return [quotient, mod]
    }

    // Private method to determine if a BigInt is a basic prime or not.
    static isBasicPrime_(n) {
        if (!(n is BigInt)) n = BigInt.new(n)
        if (n.isUnit) return false
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
            b = b / two
            r = r + 1
        }
        for (i in 0...a.count) {
            if (n >= a[i]) {
                var x = (a[i] is BigInt) ? a[i] : BigInt.new(a[i])
                x = x.modPow(b, n)
                if (!x.isUnit && x != nPrev) {
                    var d = r - 1
                    var next = false
                    while (d != 0) {
                        x = x.square % n
                        if (x.isUnit) return false
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

    // Private method to perform bitwise operations depending on the 'fn' passed in.
    static bitwise_(x, y, fn) {
        if (!(y is BigInt)) y = BigInt.new(y)
        var xSign = x.isNegative
        var ySign = y.isNegative
        var xRem = xSign ? ~x : x
        var yRem = ySign ? ~y : y
        var result = []
        while (!xRem.isZero || !yRem.isZero) {
            var xDivMod = divModAny_(xRem, __highestPower2)
            var xDigit = xDivMod[1].toNum
            if (xSign) {
                xDigit = __highestPower2 - 1 - xDigit // two's complement for negative numbers
            }
            var yDivMod = divModAny_(yRem, __highestPower2)
            var yDigit = yDivMod[1].toNum
            if (ySign) {
                yDigit = __highestPower2 - 1 - yDigit // two's complement for negative numbers
            }
            xRem = xDivMod[0]
            yRem = yDivMod[0]
            result.add(fn.call(xDigit, yDigit))
        }
        var sum = fn.call(xSign ? 1 : 0, ySign ? 1 : 0) != 0 ? minusOne : zero
        var i = result.count - 1
        var hp2 = BigInt.small_(__highestPower2)
        while (i >= 0) {
            sum = sum * hp2 + BigInt.new(result[i])
            i = i - 1
        }
        return sum
    }

    // Returns the greater of two BigInts.
    static max(a, b) {
        if (!(a is BigInt)) a = BigInt.new(a)
        if (!(b is BigInt)) b = BigInt.new(b)
        return (a > b) ? a : b
    }

    // Returns the lesser of two BigInts.
    static min(a, b) {
        if (!(a is BigInt)) a = BigInt.new(a)
        if (!(b is BigInt)) b = BigInt.new(b)
        return (a < b) ? a : b
    }

    // Returns the greatest common denominator of a and b.
    static gcd(a, b) {
        if (!(a is BigInt)) a = BigInt.new(a)
        if (!(b is BigInt)) b = BigInt.new(b)
        a = a.abs
        b = b.abs
        if (a == b) return a
        if (a.isZero) return b
        if (b.isZero) return a
        var c = one
        while (a.isEven && b.isEven) {
            var d = min(roughLOB_(a), roughLOB_(b))
            a = a / d
            b = b / d
            c = c * d
        }
        while (a.isEven) a = a / roughLOB_(a)
        while (true) {
            while (b.isEven) b = b / roughLOB_(b)
            if (a > b) {
                var t = b
                b = a
                a = t
            }
            b = b - a
            if (b.isZero) break
        }
        return c.isUnit ? a : a * c
    }

    // Returns the least common multiple of a and b.
    static lcm(a, b) {
        if (!(a is BigInt)) a = BigInt.new(a)
        if (!(b is BigInt)) b = BigInt.new(b)
        return a / gcd(a, b) * b
    }

    // Returns whether or not 'n' is an instance of BigInt.
    static isInstance(n) { n is BigInt }

    // Private helper method for 'randBetween'.
    static fromList_(digits, base, isNegative) {
        var digits2 = digits.map { |d| BigInt.new(d) }.toList
        return parseBaseFromList_(digits2, BigInt.new(base || 10), isNegative)
    }

    // Returns a random number between 'a' (inclusive) and 'b' (exclusive).
    static randBetween(a, b) {
        if (!(a is BigInt)) a = BigInt.new(a)
        if (!(b is BigInt)) b = BigInt.new(b)
        var low  = min(a, b)
        var high = max(a, b)
        var range = high - low + one
        if (range.isSmall) return low + (range.value_ * __rand.float()).floor
        var digits = toBase_(range, 1e7)[0]
        var result = []
        var restricted = true
        for (i in 0...digits.count) {
            var top = restricted ? digits[i] : 1e7
            var digit = (top * __rand.float()).truncate
            result.add(digit)
            if (digit < top) restricted = false
        }
        return low + fromList_(result, 1e7, false)
    }

    // Private method to provide the components for converting a BigInt to a different base.
    static toBase_(n, base) {
        if (!(base is BigInt)) base = BigInt.new(base)
        if (base < two) Fiber.abort("Bases less than 2 are not supported.")
        var neg = false
        if (n.isNegative) {
            neg = true
            n = n.abs
        }
        var out = []
        var left = n
        while (left.isNegative || left.compareAbs(base) >= 0) {
            var divmod = left.divMod(base)
            left = divmod[0]
            var digit = divmod[1]
            if (digit.isNegative) {
                digit = (base - digit).abs
                left = left.inc
            }
            out.add(digit.toNum)
        }
        out.add(left.toNum)
        return [out[-1..0], neg]
    }

    // Private method to parse a list, in a given base, to a BigInt.
    static parseBaseFromList_(digits, base, isNegative) {
        var val = zero
        var pow = one
        var i = digits.count - 1
        while (i >= 0) {
            val = val + digits[i]*pow
            pow = pow * base
            i = i - 1
        }
        return isNegative ? -val : val
    }

    // Private method to parse a numeric string, in a given base (2 to 36), to a BigInt.
    static parseBase_(text, base) {
        text = text.trim()
        if (text.count == 0) Fiber.abort("Invalid base string.")
        if (base > 10) text = lower_(text)
        var alphabet = __alphabet[0...base]
        var isNegative = text[0] == "-"
        if (isNegative || text[0] == "+") {
            text = text[1..-1]
            if (text.count == 0) Fiber.abort("Invalid base string.")
        }
        text = text.trimStart("0")
        if (text == "") text = "0"
        base = BigInt.small_(base)
        var digits = []
        for (c in text) {
            var ix = alphabet.indexOf(c)
            if (ix == - 1) Fiber.abort("%(c) is not a valid digit in base %(base).")
            digits.add(BigInt.small_(ix))
        }
        return parseBaseFromList_(digits, base, isNegative)
    }

    // Private helper function to convert a string to lower case.
    static lower_(s) { s.codePoints.map { |c|
        return String.fromCodePoint((c >= 65 && c <= 90) ? c + 32 : c)
    }.join() }

    // Private method to parse a base 10 numeric string 'v' to the components for a BigInt.
    static parseString_(v) {
        v = v.trim()
        if (v.count == 0) Fiber.abort("Invalid integer.")
        var signed = v[0] == "-"
        if (signed || v[0] == "+") {
            v = v[1..-1]
            if (v.count == 0) Fiber.abort("Invalid integer.")
        }
        v = v.trimStart("0")
        if (v == "") v = "0"
        v = lower_(v)
        var split = v.split("e")
        if (split.count > 2) Fiber.abort("Invalid integer.")
        if (split.count == 2) {
            var exp = split[1]
            if (exp[0] == "+") exp = exp[1..-1]
            exp = Num.fromString(exp)
            if (!isSmall_(exp)) Fiber.abort("Exponent is not valid.")
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
        var isValid = v.count > 0 && v.all { |d| "0123456789".contains(d) }
        if (!isValid) Fiber.abort("Invalid integer.")
        if (v.count <= 16) {
            var n = Num.fromString(v)
            if (isSmall_(n)) return (signed) ? [-n, true] : [n, false]
        }
        var r = []
        var max = v.count
        var lb = 7
        var min = max - lb
        while (max > 0) {
            r.add(Num.fromString(v[min...max]))
            min = min - lb
            if (min < 0) min = 0
            max = max - lb
        }
        trim_(r)
        return [r, signed]
    }

    // Constructs a BigInt object from either a numeric base 10 string or a 'safe' integer.
    construct new(value) {
         if (!(value is String) && !BigInt.isSmall_(value)) {
              Fiber.abort("Value must be a base 10 numeric string or a safe integer.")
         }
         if (value is String) {
             var res = BigInt.parseString_(value)
             _value  = res[0]
             _signed = res[1]
         } else {
             _value = value
             _signed = value < 0
         }
    }

    // Creates a BigInt object from an (unprefixed) numeric string in a given base (2 to 36).
    static fromBaseString(s, base) {
        if (!(s is String)) Fiber.abort("Value must be a numeric string in the given base.")
        if (!((base is Num) && base.isInteger && base >= 2 && base <= 36)) {
            Fiber.abort("Base must be an integer between 2 and 36.")
        }
        if (base == 10) return BigInt.new(s)
        return parseBase_(s, base)
    }

    // Private constructor which creates a BigInt object from a list of integers and a bool.
    construct big_(a, signed) {
        _value = a
        _signed = signed
    }

    // Private constructor which creates a BigInt object from a 'safe' integer and a bool.
    construct small_(a) {
        _value = a
        _signed = a < 0
    }

    // Private properties for internal use.
    value_   { _value  }
    signed_  { _signed }

    // Public self-evident properties.
    isSmall    { !(_value is List) }
    isEven     { (this.isSmall) ? (_value & 1) == 0 : (_value[0] & 1) == 0 }
    isOdd      { (this.isSmall) ? (_value & 1) == 1 : (_value[0] & 1) == 1 }
    isPositive { (this.isSmall) ? (_value > 0) : !_signed }
    isNegative { (this.isSmall) ? (_value < 0) :  _signed }
    isUnit     { (this.isSmall) ? _value.abs == 1 : false }
    isZero     { (this.isSmall) ? _value == 0 : false }

    isDivisibleBy(n) {
        if (!(n is BigInt)) n = BigInt.new(n)
        if (n.isZero) return false
        if (n.isUnit) return true
        if (n.compareAbs(BigInt.two) == 0) return this.isEven
        return (this % n).isZero
    }

    // Returns true if the current instance is prime, false otherwise.
    // Setting 'strict' to true enforces the GRH-supported lower bound of 2*log(N)^2.
    isPrime(strict) {
        if (!(strict is Bool)) Fiber.abort("Argument must be a boolean.")
        var isbp = BigInt.isBasicPrime_(this)
        if (isbp != null) return isbp
        var n = this.abs
        var bits = n.bitLength
        if (bits <= 64) {
            return BigInt.millerRabinTest_(n, [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37])
        }
        var logN = 2.log * bits.toNum
        var t = ((strict) ? (2 * logN.pow(2)) : logN).ceil
        var a = []
        for (i in 0...t) a.add(BigInt.new(i+2))
        return BigInt.millerRabinTest_(n, a)
    }

    // Returns true if the current instance is very likely to be prime, false otherwise.
    // The larger the number of 'iterations', the lower the chance of a false positive.
    isProbablePrime(iterations) {
        if (!((iterations is Num) && iterations.isInteger && iterations > 0)) {
            Fiber.abort("Iterations must be a positive integer.")
        }
        var isbp = BigInt.isBasicPrime_(this)
        if (isbp != null) return isbp
        var n = this.abs
        var a = []
        for (i in 0...iterations) a.add(BigInt.randBetween(BigInt.two, n - BigInt.two))
        return BigInt.millerRabinTest_(n, a)
    }

    // Convenience versions of the above methods which use default parameter values.
    isPrime         { isPrime(false) }
    isProbablePrime { isProbablePrime(5) }

    // Negates a BigInt.
    - { (this.isSmall) ? BigInt.small_(-_value) : BigInt.big_(_value, !_signed) }

    // Private method which adds a BigInt to a 'small' current instance.
    smallAdd_(n) {
        var a = _value
        if (_signed != n.signed_) return this - (-n)
        var b = n.value_
        if (n.isSmall) {
            var c = a + b
            if (BigInt.isSmall_(c)) return BigInt.small_(c)
            b = BigInt.smallToList_(b.abs)
        }
        return BigInt.big_(BigInt.addSmall_(b, a.abs), _signed)
    }

    // Adds a BigInt to the current instance.
    + (n) {
        if (!(n is BigInt)) n = BigInt.new(n)
        if (n.isZero) return this
        if (this.isSmall) return smallAdd_(n)
        if (_signed != n.signed_) return this - (-n)
        var a = _value
        var b = n.value_
        if (n.isSmall) {
            return BigInt.big_(BigInt.addSmall_(a, b.abs), _signed)
        }
        return BigInt.big_(BigInt.addAny_(a, b), _signed)
    }

    // Private method which subtracts a BigInt from a 'small' current instance.
    smallSubtract_(n) {
        var a = _value
        if (_signed != n.signed_) return this + (-n)
        var b = n.value_
        if (n.isSmall) return BigInt.small_(a - b)
        return BigInt.subtractSmall_(b, a.abs, !_signed)
    }

    // Subtracts a BigInt from the current instance.
    - (n) {
        if (!(n is BigInt)) n = BigInt.new(n)
        if (n.isZero) return this
        if (this.isSmall) return smallSubtract_(n)
        if (_signed != n.signed_) return this + (-n)
        var a = _value
        var b = n.value_
        if (n.isSmall) return BigInt.subtractSmall_(a, b.abs, _signed)
        return BigInt.subtractAny_(a, b, _signed)
    }

    // Private method which multiplies the current instance by a 'small' BigInt.
    multiplyBySmall_(a) {
        if (this.isSmall) {
            var c = a.value_ * _value
            if (BigInt.isSmall_(c)) return BigInt.small_(c)
            c = a.value_.abs
            return BigInt.multiplySmallAndList_(c, BigInt.smallToList_(_value.abs), _signed != a.signed_)
        }
        if (a.value_ == 0) return BigInt.zero
        if (a.value_ == 1) return this
        if (a.value_ == -1) return -this
        return BigInt.multiplySmallAndList_(a.value_.abs, _value, _signed != a.signed_)
    }

    // Multiplies the current instance by a BigInt.
    * (n) {
        if (!(n is BigInt)) n = BigInt.new(n)
        if (this.isSmall) return n.multiplyBySmall_(this)
        var a = _value
        var b = n.value_
        var signed = _signed != n.signed_
        if (n.isSmall) {
            if (b == 0) return BigInt.zero
            if (b == 1) return this
            if (b == -1) return -this
            var ab = b.abs
            if (ab < 1e7) return BigInt.big_(BigInt.multiplySmall_(a, ab), signed)
            b = BigInt.smallToList_(ab)
        }
        if (BigInt.useKaratsuba_(a.count, b.count)) {
            return BigInt.big_(BigInt.multiplyKaratsuba_(a, b), signed)
        }
        return BigInt.big_(BigInt.multiplyLong_(a, b), signed)
    }

    // Square the current instance.
    square {
        if (this.isSmall) {
            var value = _value * _value
            if (BigInt.isSmall_(value)) return BigInt.small_(value)
            return BigInt.big_(BigInt.square_(BigInt.smallToList_(_value.abs)), false)
        }
        return BigInt.big_(BigInt.square_(_value), false)
    }

    // Returns the integer square root of the current instance i.e. the largest integer 'r' such that
    // r.square <= this. Throws an error if the current instance is negative.
    isqrt {
        if (this.isNegative) Fiber.abort("Cannot take the square root of a negative number.")
        var q = BigInt.one
        while (q <= this) q = q * 4
        var z = this.copy()
        var r = BigInt.zero
        while (q > BigInt.one) {
            q = q / 4
            var t = z - r - q
            r = r / 2
            if (t >= 0) {
                z = t
                r = r + q
            }
        }
        return r
    }

    // Returns a list containing the quotient and the remainder after dividing the current instance
    // by a BigInt. The sign of the remainder will match the sign of the dividend.
    divMod(n) {
        if (!(n is BigInt)) n = BigInt.new(n)
        return BigInt.divModAny_(this, n)
    }

    // Divides the current instance by a BigInt.
    /(n) {
        if (!(n is BigInt)) n = BigInt.new(n)
        return BigInt.divModAny_(this, n)[0]
    }

    // Returns the remainder after dividing the current instance by a BigInt.
    // The sign of the remainder will match the sign of the dividend.
    %(n) {
        if (!(n is BigInt)) n = BigInt.new(n)
        return BigInt.divModAny_(this, n)[1]
    }

    // Returns the current instance raised to the power of a 'small' BigInt.
    // If the exponent is less than 0, returns 0. O.pow(0) returns one.
    pow(n) {
        if (!(n is BigInt)) n = BigInt.new(n)
        var a = _value
        var b = n.value_
        if (b == 0) return BigInt.one
        if (a == 0) return BigInt.zero
        if (a == 1) return BigInt.one
        if (a == -1) return n.isEven ? BigInt.one : BigInt.minusOne
        if (n.signed_) return BigInt.zero
        if (!n.isSmall) Fiber.abort("The exponent %(n) is too large.")
        if (this.isSmall) {
            var value = a.pow(b)
            if (BigInt.isSmall_(value)) return BigInt.small_(value.truncate)
        }
        var x = this
        var y = BigInt.one
        while (true) {
            if ((b & 1) == 1) {
                y = y * x
                b = b - 1
            }
            if (b == 0) break
            b = b / 2
            x = x.square
        }
        return y
    }

    // Returns the current instance to the power 'exp' modulo 'mod'.
    modPow(exp, mod) {
        if (!(exp is BigInt)) exp = BigInt.new(exp)
        if (!(mod is BigInt)) mod = BigInt.new(mod)
        if (mod.isZero) Fiber.abort("Cannot take modPow with modulus 0.")
        var r = BigInt.one
        var base = this % mod
        if (exp.isNegative) {
            exp = exp * BigInt.minusOne
            base = base.modInv(mod)
        }
        while (exp.isPositive) {
            if (base.isZero) return BigInt.zero
            if (exp.isOdd) r = (r * base) % mod
            exp = exp / BigInt.two
            base = base.square % mod
        }
        return r
    }

    // Returns the multiplicative inverse of the current instance modulo 'r'.
    modInv(n) {
        if (!(n is BigInt)) n = BigInt.new(n)
        var r = n
        var newR = this.abs
        var t = BigInt.zero
        var newT = BigInt.one
        while (!newR.isZero) {
            var q = r / newR
            var lastT = t
            var lastR = r
            t = newT
            r = newR
            newT = lastT - q*newT
            newR = lastR - q*newR
        }
        if (!r.isUnit) Fiber.abort("%(this) and %(n) are not co-prime.")
        if (t.compare(BigInt.zero) == -1) t = t + n
        if (this.isNegative) return -t
        return t
    }

    // Returns the sign of the current instance: 0 if zero, 1 if positive and -1 otherwise.
    sign { (this.isZero) ? 0 : (this.isPositive) ? 1 : -1 }

    // Increments the current instance by one.
    inc {
        var value = _value
        if (this.isSmall) {
            if (value + 1 <= __maxSmall) return BigInt.small_(value + 1)
            return BigInt.big_(__threshold, false)
        }
        if (_signed) return BigInt.subtractSmall_(value, 1, _signed)
        return BigInt.big_(BigInt.addSmall_(value, 1), _signed)
    }

    // Decrements the current instance by one.
    dec {
        var value = _value
        if (this.isSmall) {
            if (value - 1 >= -__maxSmall) return BigInt.small_(value - 1)
            return BigInt.big_(__threshold, true)
        }
        if (_signed) return BigInt.big_(BigInt.addSmall_(value, 1), true)
        return BigInt.subtractSmall_(value, 1, _signed)
    }

    // Bitwise operators. The operands are treated as if they were represented
    // using two's complement representation.
    ~     { (-this).dec }
    &(n)  { BigInt.bitwise_(this, n, Fn.new { |a, b| a & b }) }
    |(n)  { BigInt.bitwise_(this, n, Fn.new { |a, b| a | b }) }
    ^(n)  { BigInt.bitwise_(this, n, Fn.new { |a, b| a ^ b }) }

    <<(n) {
        if (!(n is BigInt)) n = BigInt.new(n)
        n = n.toNum
        if (!BigInt.shiftIsSmall_(n)) Fiber.abort("%(n) is too large for shifting.")
        if (n < 0) return this >> (-n)
        var result = this
        if (result.isZero) return result
        var hp2 = BigInt.small_(__highestPower2)
        while (n >= __powers2Length) {
            result = result * hp2
            n = n - (__powers2Length - 1)
        }
        return result * __powersOfTwo[n]
    }

    >>(n) {
        if (!(n is BigInt)) n = BigInt.new(n)
        n = n.toNum
        if (!BigInt.shiftIsSmall_(n)) Fiber.abort("%(n) is too large for shifting.")
        if (n < 0) return this << (-n)
        var result = this
        var remQuo
        var hp2 = BigInt.small_(__highestPower2)
        while (n >= __powers2Length) {
            if (result.isZero || (result.isNegative && result.isUnit)) return result
            remQuo = BigInt.divModAny_(result, hp2)
            result = remQuo[1].isNegative ? remQuo[0].dec : remQuo[0]
            n = n - (__powers2Length - 1)
        }
        remQuo = BigInt.divModAny_(result, __powersOfTwo[n])
        return remQuo[1].isNegative ? remQuo[0].dec : remQuo[0]
    }

    // Returns the absolute value of the current instance.
    abs { (this.isSmall) ? BigInt.small_(_value.abs) : BigInt.big_(_value, false) }

    // Compares the current instance with a BigInt. If they are equal returns 0.
    // If 'this' is greater, returns 1. Otherwise returns -1.
    // Also allows a comparison with an infinite number.
    compare(n) {
        if ((n is Num) && n.isInfinity) return -n.sign
        if (!(n is BigInt)) n = BigInt.new(n)
        var a = _value
        var b = n.value_
        if (this.isSmall) {
            if (n.isSmall) return (a == b) ? 0 : a > b ? 1 : -1
            if (_signed != n.signed_) return (_signed) ? -1 : 1
            return _signed ? 1 : -1
        }
        if (_signed != n.signed_) return n.signed_ ? 1 : -1
        if (n.isSmall) return _signed ? -1 : 1
        return BigInt.compareAbs_(a, b) * (_signed ? -1 : 1)
    }

    // As 'compare' but compares absolute values.
    compareAbs(n) {
        if ((n is Num) && n.isInfinity) return -n.sign
        if (!(n is BigInt)) n = BigInt.new(n)
        if (this.isSmall) {
            var a = _value.abs
            var b = n.value_
            if (n.isSmall) {
                b = b.abs
                return (a == b) ? 0 : (a > b) ? 1 : -1
            }
            return -1
        }
        if (n.isSmall) return 1
        return BigInt.compareAbs_(_value, n.value_)
    }

    // Returns the number of digits required to represent the current instance in binary.
    bitLength {
        var n = this
        if (n.isNegative) n = (-n) - BigInt.one
        if (n.isZero) return BigInt.zero
        return BigInt.new(BigInt.integerLogarithm_(n, BigInt.two)[1]) + BigInt.one
    }

     // Returns true if the 'n'th bit of the current instance is set or false otherwise.
    testBit(n) {
        if (n.type != Num || !n.isInteger || n < 0) Fiber.abort("Argument must be a non-negative integer.")
        return (this >> n) & BigInt.one != BigInt.zero
    }

    // The inherited 'clone' method just returns 'this' as BigInt objects are immutable.
    // If you need an actual copy use this method instead.
    copy() { (this.isSmall) ? BigInt.small_(_value) : BigInt.big_(_value, _signed) }

    // Converts the current instance to a 'small' integer where possible.
    // Otherwise returns null.
    toSmall { (this.isSmall) ? _value : null }

    // Converts the current instance to a Num where possible.
    // Will probably lose accuracy if the current instance is not 'small'.
    toNum { Num.fromString(this.toString) }

    // Returns the string representation of the current instance in a given base (2 to 36).
    toBaseString(base) {
        if (!((base is Num) && base.isInteger && base >= 2 && base <= 36)) {
            Fiber.abort("Base must be an integer between 2 and 36.")
        }
        if (base == 10) return this.toString
        var lst = BigInt.toBase_(this, base)
        return (lst[1] ? "-" : "") + lst[0].map { |d| __alphabet[d] }.join("")
    }

    // Returns the string representation of the current instance in base 10.
    toString {
        var v = (this.isSmall) ? BigInt.smallToList_(_value.abs) : _value
        var l = v.count - 1
        var str = v[l].toString
        var zeros = "0000000"
        var digit = ""
        l = l - 1
        while (l >= 0) {
            digit = v[l].toString
            str = str + zeros[digit.count..-1] + digit
            l = l - 1
        }
        var sign = _signed ? "-" : ""
        return sign + str
    }
}

/*  BigInts contains various routines applicable to lists of big integers. */
class BigInts {
    static sum(a)  { a.reduce(BigInt.zero) { |acc, x| acc + x } }
    static prod(a) { a.reduce(BigInt.one)  { |acc, x| acc * x } }
    static max(a)  { a.reduce { |acc, x| (x > acc) ? x : acc } }
    static min(a)  { a.reduce { |acc, x| (x < acc) ? x : acc } }
}

/* BigRat represents a rational number as a BigInt numerator and (non-zero) denominator
   expressed in their lowest terms. BigRat objects are immutable.
*/
class BigRat is Comparable {
    // Private helper function to check that 'o' is a suitable type and throw an error otherwise.
    // Rational numbers, numbers and numeric strings are returned as BigRats.
    static check_(o) {
        if (o is BigRat) return o
        if (o is BigInt) return BigRat.new(o, BigInt.one)
        if (o.type.toString == "Rat") return BigRat.fromRat(o)
        if (o is Num) return BigRat.fromFloat(o)
        if (o is String) return (o.contains("_") && o.contains("/")) ? fromMixedString(o) :
                                 o.contains("/") ? fromRationalString(o) : fromDecimal(o)
        Fiber.abort("Argument must either be a rational number, a number or a numeric string.")
    }

    // Constants.
    static minusOne { BigRat.new(BigInt.minusOne, BigInt.one) }
    static zero     { BigRat.new(BigInt.zero,     BigInt.one) }
    static one      { BigRat.new(BigInt.one,      BigInt.one) }
    static two      { BigRat.new(BigInt.two,      BigInt.one) }
    static ten      { BigRat.new(BigInt.ten,      BigInt.one) }
    static half     { BigRat.new(BigInt.one,      BigInt.two) }
    static tenth    { BigRat.new(BigInt.one,      BigInt.ten) }

    // Constructs a new BigRat object by passing it a numerator and a denominator.
    // These must either be BigInts or Nums/Strings which are capable of creating one
    // when passed to the BigInt.new constructor.
    construct new(n, d) {
        n = (n is BigInt) ? n.copy() : BigInt.new(n)
        d = (d is BigInt) ? d.copy() : BigInt.new(d)
        if (d == BigInt.zero) Fiber.abort("Denominator must be a non-zero integer.")
        if (n == BigInt.zero) {
            d = BigInt.one
        } else if (d < BigInt.zero) {
            n = -n
            d = -d
        }
        var g = BigInt.gcd(n, d).abs
        if (g > BigInt.one) {
            n = n / g
            d = d / g
        }
        _n = n
        _d = d
    }

    // Convenience method which constructs a new BigRat object by passing it just a numerator.
    static new(n) { BigRat.new(n, BigInt.one) }

    // Constructs a BigRat object from a Rat object. To use this method the Rat class needs
    // to be imported from the Wren-rat module as, to minimize dependencies,
    // this module does not do so.
    static fromRat(r) {
        if (r.type.toString != "Rat") Fiber.abort("Argument must be a rational number.")
        return BigRat.new(r.num, r.den)
    }

    // Constructs a BigRat object from a string of the form "n/d".
    // Improper fractions are allowed.
    static fromRationalString(s) {
        var nd = s.split("/")
        if (nd.count != 2) Fiber.abort("Argument is not a suitable string.")
        var n = BigInt.new(nd[0])
        var d = BigInt.new(nd[1])
        return BigRat.new(n, d)
    }

    // Constructs a BigRat object from a string of the form "i_n/d" where 'i' is an integer.
    // Improper and negative fractional parts are allowed.
    static fromMixedString(s) {
        var ind = s.split("_")
        if (ind.count != 2) Fiber.abort("Argument is not a suitable string.")
        var nd = fromRationalString(ind[1])
        var i = BigRat.new(ind[0])
        var neg = i.isNegative || (i.isZero && ind[0][0] == "-")
        return neg ? i - nd : i + nd
    }

    // Constructs a BigRat object from a decimal numeric string or value.
    static fromDecimal(s) {
        if (!(s is String)) s = s.toString
        if (s == "") Fiber.abort("Argument cannot be an empty string.")
        s = BigInt.lower_(s)
        var parts = s.split("e")
        if (parts.count > 2) Fiber.abort("Argument is invalid scientific notation.")
        if (parts.count == 2) {
            var isPositive = true
            if (parts[1][0] == "-") {
                parts[1] = parts[1][1..-1]
                isPositive = false
            }
            if (parts[1][0] == "+") parts[1] = parts[1][1..-1]
            var significand = fromDecimal(parts[0])
            var p = BigInt.new(parts[1])
            var exponent = BigRat.new(BigInt.ten.pow(p), BigInt.one)
            return (isPositive) ? significand * exponent : significand / exponent
        }
        s = s.trim().trimStart("0")
        if (s == "") return BigRat.zero
        if (s.startsWith(".")) s = "0" + s
        if (!s.contains(".")) {
            return BigRat.new(s)
        } else {
             s = s.trimEnd("0")
        }
        if (s.endsWith(".")) return BigRat.new(s[0..-2])
        var splits = s.split(".")
        if (splits.count != 2) Fiber.abort("Argument is not a decimal.")
        var num = splits[0]
        var isNegative = false
        if (num.startsWith("-")) {
            isNegative = true
            num = num[1..-1]
        } else if (num.startsWith("+")) {
            num = num[1..-1]
        }
        var den = splits[1]
        if (!num.all { |c| "0123456789".contains(c) } || !den.all { |c| "0123456789".contains(c) }) {
            Fiber.abort("Argument is not a decimal.")
        }
        num = BigInt.new(num + den)
        if (isNegative) num = -num
        den = BigInt.ten.pow(den.count)
        return BigRat.new(num, den)
    }

    // Constructs a rational number from a floating point number provided the latter is an integer
    // or has a decimal string representation.
    static fromFloat(n) {
        if (!(n is Num)) Fiber.abort("Argument must be a number.")
        if (n.isInteger) return BigRat.new(n, BigInt.one)
        return fromDecimal(n)
    }

    // Returns the greater of two BigRat objects.
    static max(r1, r2) { (r1 < r2) ? r2 : r1 }

    // Returns the smaller of two BigRat objects.
    static min(r1, r2) { (r1 < r2) ? r1 : r2 }

    // Determines whether a BigRat object is always shown as such or, if integral, as an integer.
    static showAsInt     { __showAsInt }
    static showAsInt=(b) { __showAsInt = b }

    // Basic properties.
    num        { _n }                   // numerator
    den        { _d }                   // denominator
    ratio      { [_n, _d] }             // a two element list of the above
    isInteger  { _d == 1 }              // checks if integral or not
    isPositive { _n > BigInt.zero }     // checks if positive
    isNegative { _n < BigInt.zero }     // checks if negative
    isUnit     { _n.abs == BigInt.one } // checks if plus or minus one
    isZero     { _n == BigInt.zero }    // checks if zero

    // Rounding methods (similar to those in Num class).
    ceil { // higher integer
        if (isInteger) return this
        var div = _n/_d
        if (!this.isNegative) div = div.inc
        return BigRat.new(div, BigInt.one)
    }

    floor { // lower integer
        if (isInteger) return this
        var div = _n/_d
        if (this.isNegative) div = div.dec
        return BigRat.new(div, BigInt.one)
    }

    truncate { this.isNegative ? ceil : floor } // lower integer, towards zero

    round { // nearer integer
        if (isInteger) return this
        var div = _n / _d
        if (_d == 2) {
            div = isNegative ? div.dec : div.inc // round 1/2 away from zero
            return BigRat.new(div, BigInt.one)
        }
        return (this + BigRat.half).floor
    }

    fraction { this - truncate } // fractional part (same sign as this.num)

    // Reciprocal
    inverse  { BigRat.new(_d, _n) }

    // Integer division.
    idiv(o)  { (this/o).truncate }

    // Negation.
    -{ BigRat.new(-_n, _d) }

    // Arithmetic operators (work with numbers and numeric strings as well as other rationals).
    +(o) { (o = BigRat.check_(o)) && BigRat.new(_n * o.den + _d * o.num, _d * o.den) }
    -(o) { (o = BigRat.check_(o)) && (this + (-o)) }
    *(o) { (o = BigRat.check_(o)) && BigRat.new(_n * o.num, _d * o.den) }
    /(o) { (o = BigRat.check_(o)) && BigRat.new(_n * o.den, _d * o.num) }
    %(o) { (o = BigRat.check_(o)) && (this - idiv(o) * o) }

    // Computes integral powers.
    pow(i) {
        if (!((i is Num) && i.isInteger)) Fiber.abort("Argument must be an integer.")
        if (i == 0) return this
        var np = _n.pow(i)
        var dp = _d.pow(i)
        return (i > 0) ? BigRat.new(np, dp) : BigRat.new(dp, np)
    }

    // Returns the square of the current instance.
    square { BigRat.new(_n * _n , _d *_d) }

    // Returns the square root of the current instance to 'digits' decimal places.
    // Five more decimals is used to try to ensure accuracy though this is not guaranteed.
    sqrt(digits) {
        if (!((digits is Num) && digits.isInteger && digits >= 0)) {
            Fiber.abort("Digits must be a non-negative integer.")
        }
        digits = digits + 5
        var powd = BigInt.ten.pow(digits)
        var sqtd = (powd.square * _n / _d).isqrt
        return BigRat.new(sqtd, powd)
    }

    // Convenience version of the above method which uses 14 decimal places.
    sqrt { sqrt(14) }

    // Other methods.
    inc  { this + BigRat.one }                  // increment
    dec  { this - BigRat.one }                  // decrement
    abs  { (_n >= BigInt.zero) ? this : -this } // absolute value
    sign { _n.sign }                            // sign

    // The inherited 'clone' method just returns 'this' as BigRat objects are immutable.
    // If you need an actual copy use this method instead.
    copy() { BigRat.new(_n, _d) }

    // Compares this BigRat with another one to enable comparison operators via Comparable trait.
    compare(other) {
        if ((other is Num) && other.isInfinity) return -other.sign
        other = BigRat.check_(other)
        if (_d == other.den) return _n.compare(other.num)
        return (_n * other.den).compare(other.num * _d)
    }

    // As above but compares the absolute values of the BigRats.
    compareAbs(other) { this.abs.compare(other.abs) }

    // Returns this BigRat expressed as a BigInt with any fractional part truncated.
    toBigInt { _n/_d }

    // Converts the current instance to a Num where possible.
    // Will probably lose accuracy if the numerator and/or denominator are not 'small'.
    toFloat { Num.fromString(this.toDecimal(14)) }

    // Converts the current instance to an integer where possible with any fractional part truncated.
    // Will probably lose accuracy if the numerator and/or denominator are not 'small'.
    toInt { this.toFloat.truncate }

    // Returns the decimal representation of this BigRat object to 'digits' decimal places.
    // If 'rounded' is true, the value is rounded to that number of places with halves
    // being rounded away from zero. Otherwise the value is truncated to that number of places.
    // If 'zfill' is true, any unfilled decimal places are filled with zeros.
    toDecimal(digits, rounded, zfill) {
        if (!(digits is Num && digits.isInteger && digits >= 0)) {
            Fiber.abort("Digits must be a non-negative integer")
        }
        if (rounded.type != Bool) Fiber.abort("Rounded must be true or false.")
        if (zfill.type != Bool) Fiber.abort("Zfill must be true or false.")
        var qr = _n.divMod(_d)
        var rem = BigRat.new(qr[1].abs, _d)
        // need to allow an extra digit if 'rounding' is true
        var digits2 = (rounded) ? digits + 1 : digits
        var shiftedRem = rem * BigRat.new("1e" + digits2.toString, BigInt.one)
        var decPart = (shiftedRem.num / shiftedRem.den).toString
        if (rounded) {
            var finalByte = decPart[-1].bytes[0]
            if (finalByte >= 53) {  // last character >= 5
                decPart = (BigInt.new(decPart) + 5).toString
                if (digits == 0) qr[0] = isNegative ? qr[0].dec : qr[0].inc
            }
            decPart = decPart[0...-1]  // remove last digit
        }
        if (decPart.count < digits) {
            decPart = ("0" * (digits - decPart.count)) + decPart
        }
        if ((shiftedRem.num % shiftedRem.den) == BigInt.zero)  {
            decPart = decPart.trimEnd("0")
        }
        if (digits < 1) decPart = ""
        var intPart = qr[0].toString
        if (this.isNegative && qr[0] == 0) intPart = "-" + intPart
        if (decPart == "") return intPart + (zfill ? "." + ("0" * digits) : "")
        return intPart + "." + decPart + (zfill ? ("0" * (digits - decPart.count)) : "")
    }

    // Convenience versions of the above which use default values for some or all parameters.
    toDecimal(digits, rounded) { toDecimal(digits, rounded, false) } // never trailing zeros
    toDecimal(digits)          { toDecimal(digits, true, false)    } // always rounded, never trailing zeros
    toDecimal                  { toDecimal(14, true, false)        } // 14 digits, always rounded, never trailing zeros

    // Returns a string represenation of this instance in the form "i_n/d" where 'i' is an integer.
    toMixedString {
        var q = _n / _d
        var r = _n % _d
        if (r.isNegative) r = -r
        return q.toString + "_" + r.toString + "/" + _d.toString
    }

    // Returns the string representation of this BigRat object depending on 'showAsInt'.
    toString { (BigRat.showAsInt && _d == BigInt.one) ? "%(_n)" : "%(_n)/%(_d)" }
}

/*  BigRats contains various routines applicable to lists of big rational numbers */
class BigRats {
    static sum(a)  { a.reduce(BigRat.zero) { |acc, x| acc + x } }
    static mean(a) { sum(a)/a.count }
    static prod(a) { a.reduce(BigRat.one) { |acc, x| acc * x } }
    static max(a)  { a.reduce { |acc, x| (x > acc) ? x : acc } }
    static min(a)  { a.reduce { |acc, x| (x < acc) ? x : acc } }
}

// Type aliases for classes in case of any name clashes with other modules.
var Big_BigInt  = BigInt
var Big_BigInts = BigInts
var Big_BigRat  = BigRat
var Big_BigRats = BigRats
var Big_Comparable = Comparable // in case imported indirectly

// Initialize static fields.
BigInt.init_()
