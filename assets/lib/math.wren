// url: https://rosettacode.org/wiki/Category:Wren-math
// source: https://rosettacode.org/mw/index.php?title=Category_talk:Wren-math&action=edit&section=1
// file: math
// name: Wren-math
// author: PureFox
// license: MIT

/* Module "math.wren" */
/* Math supplements the Num class with various other operations on numbers. */
class Math {
    // Constants.
    static e    { 2.71828182845904523536 } // base of natural logarithms
    static phi  { 1.6180339887498948482  } // golden ratio
    static tau  { 6.2831853071795864769  } // 2 * pi
    static ln2  { 0.69314718055994530942 } // natural logarithm of 2
    static ln10 { 2.30258509299404568402 } // natural logarithm of 10

    // Special values.
    static inf  { 1/0                    } // positive infinity
    static ninf { (-1)/0                 } // negative infinity
    static nan  { 0/0                    } // nan

    // Returns the base 'e' exponential of 'x'
    static exp(x) { e.pow(x) }

    // Log functions.
    static log2(x)  { x.log/ln2  }  // Base 2 logarithm
    static log10(x) { x.log/ln10 }  // Base 10 logarithm

    // Hyperbolic trig functions.
    static sinh(x) { (exp(x) - exp(-x))/2 } // sine
    static cosh(x) { (exp(x) + exp(-x))/2 } // cosine
    static tanh(x) { sinh(x)/cosh(x)      } // tangent

    // Inverse hyperbolic trig functions.
    static asinh(x) { (x + (x*x + 1).sqrt).log } // sine
    static acosh(x) { (x + (x*x - 1).sqrt).log } // cosine
    static atanh(x) { ((1+x)/(1-x)).log/2 }      // tangent

    // Angle conversions.
    static radians(d) { d * Num.pi / 180}
    static degrees(r) { r * 180 / Num.pi }

    // Returns the cube root of 'x'.
    static cbrt(x) { (x >= 0) ? x.pow(1/3) : -(-x).pow(1/3) }

    // Returns the square root of 'x' squared + 'y' squared.
    static hypot(x, y) { (x*x + y*y).sqrt }

    // Returns the integer and fractional parts of 'x'. Both values have the same sign as 'x'.
    static modf(x) { [x.truncate, x.fraction] }

    // Returns the IEEE 754 floating-point remainder of 'x/y'.
    static rem(x, y) {
        if (x.isNan || y.isNan || x.isInfinity || y == 0) return nan
        if (!x.isInfinity && y.isInfinity) return x
        var nf = modf(x/y)
        if (nf[1] != 0.5) {
            return x - (x/y).round * y
        } else {
            var n = nf[0]
            if (n%2 == 1) n = (n > 0) ? n + 1 : n - 1
            return x - n * y
        }
    }

    // Return the minimum and maximum of 'x' and 'y'.
    static min(x, y) { (x < y) ? x : y }
    static max(x, y) { (x > y) ? x : y }

    // Round away from zero.
    static roundUp(x) { (x >= 0) ? x.ceil : x.floor }

    // Round to 'p' decimal places, maximum 14.
    // Mode parameter specifies the rounding mode:
    // < 0 towards zero, == 0 nearest, > 0 away from zero.
    static toPlaces(x, p, mode) {
        if (p < 0) p = 0
        if (p > 14) p = 14
        var pw = 10.pow(p)
        var nf = modf(x)
        x = nf[1] * pw
        x = (mode < 0) ? x.truncate : (mode == 0) ? x.round : roundUp(x)
        return nf[0] + x/pw
    }

    // Convenience version of above method which uses 0 for the 'mode' parameter.
    static toPlaces(x, p) { toPlaces(x, p, 0) }

    // Gamma function using Lanczos approximation.
    static gamma(x) {
        var p = [
            0.99999999999980993,
          676.5203681218851,
        -1259.1392167224028,
          771.32342877765313,
         -176.61502916214059,
           12.507343278686905,
           -0.13857109526572012,
            9.9843695780195716e-6,
            1.5056327351493116e-7
        ]
        var t = x + 6.5
        var sum = p[0]
        for (i in 0..7) sum = sum + p[i+1]/(x + i)
        return 2.sqrt * Num.pi.sqrt * t.pow(x-0.5) * Math.exp(-t) * sum
    }
}

/* Int contains various routines which are only applicable to integers. */
class Int {
     // Maximum safe integer = 2^53 - 1.
    static maxSafe { 9007199254740991 }

    // Returns the greatest common divisor of 'x' and 'y'.
    static gcd(x, y) {
        while (y != 0) {
            var t = y
            y = x % y
            x = t
        }
        return x
    }

    // Returns the least common multiple of 'x' and 'y'.
    static lcm(x, y) { (x*y).abs / gcd(x, y) }

    // Returns the remainder when 'b' raised to the power 'e' is divided by 'm'.
    static modPow(b, e, m) {
        if (m == 1) return 0
        var r = 1
        b = b % m
        while (e > 0) {
            if (e%2 == 1) r = (r*b) % m
            e = e >> 1
            b = (b*b) % m
        }
        return r
    }

    // Returns the factorial of 'n'. Inaccurate for n > 18.
    static factorial(n) {
        if (!(n is Num && n >= 0)) Fiber.abort("Argument must be a non-negative integer")
        if (n < 2) return 1
        var fact = 1
        for (i in 2..n) fact = fact * i
        return fact
    }

    // Determines whether 'n' is prime using a wheel with basis [2, 3].
    static isPrime(n) {
        if (!n.isInteger || n < 2) return false
        if (n%2 == 0) return n == 2
        if (n%3 == 0) return n == 3
        var d = 5
        while (d*d <= n) {
            if (n%d == 0) return false
            d = d + 2
            if (n%d == 0) return false
            d = d + 4
        }
        return true
    }

    // Sieves for primes up to and including 'limit'.
    // If primesOnly is true returns a list of the primes found.
    // If primesOnly is false returns a bool list 'c' of size (limit + 1) where:
    // c[i] is false if 'i' is prime or true if 'i' is composite.
    static primeSieve(limit, primesOnly) {
        if (limit < 2) return []
        var c = [false] * (limit + 1) // composite = true
        c[0] = true
        c[1] = true
        // if not primesOnly we need to process the even numbers > 2
        if (!primesOnly) {
            var i = 4
            while (i <= limit) {
                c[i] = true
                i = i + 2
            }
        }
        var p = 3
        var p2 = p * p
        while (p2 <= limit) {
            var i = p2
            while (i <= limit) {
                c[i] = true
                i = i + 2*p
            }
            var ok = true
            while (ok) {
                p = p + 2
                ok = c[p]
            }
            p2 = p * p
        }
        if (!primesOnly) return c
        var primes = [2]
        var i = 3
        while (i <= limit) {
            if (!c[i]) primes.add(i)
            i = i + 2
        }
        return primes
    }

    // Convenience version of above method which uses true for the primesOnly parameter.
    static primeSieve(limit) { primeSieve(limit, true) }

    // Returns the prime factors of 'n' in order using a wheel with basis [2, 3, 5].
    static primeFactors(n) {
        if (!n.isInteger || n < 2) return []
        var inc = [4, 2, 4, 2, 4, 6, 2, 6]
        var factors = []
        while (n%2 == 0) {
            factors.add(2)
            n = (n/2).truncate
        }
        while (n%3 == 0) {
            factors.add(3)
            n = (n/3).truncate
        }
        while (n%5 == 0) {
            factors.add(5)
            n = (n/5).truncate
        }
        var k = 7
        var i = 0
        while (k * k <= n) {
            if (n%k == 0) {
                factors.add(k)
                n = (n/k).truncate
            } else {
                k = k + inc[i]
                i = (i + 1) % 8
            }
        }
        if (n > 1) factors.add(n)
        return factors
    }

    // Returns all the divisors of 'n' including 1 and 'n' itself.
    static divisors(n) {
        if (!n.isInteger || n < 1) return []
        var divisors = []
        var divisors2 = []
        var i = 1
        var k = (n%2 == 0) ? 1 : 2
        while (i <= n.sqrt) {
            if (n%i == 0) {
                divisors.add(i)
                var j = (n/i).floor
                if (j != i) divisors2.add(j)
            }
            i = i + k
        }
        if (!divisors2.isEmpty) divisors = divisors + divisors2[-1..0]
        return divisors
    }

    // Returns all the divisors of 'n' excluding 'n'.
    static properDivisors(n) {
        var d = divisors(n)
        var c = d.count
        return (c <= 1) ? [] : d[0..-2]
    }

    // Private helper method which checks a number and base for validity.
    static check_(n, b) {
        if (!(n is Num && n.isInteger && n >= 0)) {
            Fiber.abort("Number must be a non-negative integer.")
        }
        if (!(b is Num && b.isInteger && b >= 2 && b < 64)) {
            Fiber.abort("Base must be an integer between 2 and 63.")
        }
    }

    // Returns a list of an integer n's digits in base b. Optionally checks n and b are valid.
    static digits(n, b, check) {
        if (check) check_(n, b)
        if (n == 0) return [0]
        var digs = []
        while (n > 0) {
            digs.add(n%b)
            n = (n/b).floor
        }
        return digs[-1..0]
    }

    // Returns the sum of an integer n's digits in base b. Optionally checks n and b are valid.
    static digitSum(n, b, check) {
        if (check) check_(n, b)
        var sum = 0
        while (n > 0) {
            sum = sum + (n%b)
            n = (n/b).floor
        }
        return sum
    }

    // Returns the digital root and additive persistence of an integer n in base b.
    // Optionally checks n and b are valid.
    static digitalRoot(n, b, check) {
        if (check) check_(n, b)
        var ap = 0
        while (n > b - 1) {
            n = digitSum(n, b)
            ap = ap + 1
        }
        return [n, ap]
    }

    // Convenience versions of the above methods which never check for validity
    // and/or use base 10 by default.
    static digits(n, b)      { digits(n, b, false) }
    static digits(n)         { digits(n, 10, false) }
    static digitSum(n, b)    { digitSum(n, b, false) }
    static digitSum(n)       { digitSum(n, 10, false) }
    static digitalRoot(n, b) { digitalRoot(n, b, false) }
    static digitalRoot(n)    { digitalRoot(n, 10, false) }

    // Returns the unique non-negative integer that is associated with a pair
    // of non-negative integers 'x' and 'y' according to Cantor's pairing function.
    static cantorPair(x, y) {
        if (x.type != Num || !x.isInteger || x < 0) {
            Fiber.abort("Arguments must be non-negative integers.")
        }
        if (y.type != Num || !y.isInteger || y < 0) {
            Fiber.abort("Arguments must be non-negative integers.")
        }
        return (x*x + 3*x + 2*x*y + y + y*y) / 2
    }

    // Returns the pair of non-negative integers that are associated with a single
    // non-negative integer 'z' according to Cantor's pairing function.
    static cantorUnpair(z) {
        if (z.type != Num || !z.isInteger || z < 0) {
            Fiber.abort("Argument must be a non-negative integer.")
        }
        var i = (((1 + 8*z).sqrt-1)/2).floor
        return [z - i*(1+i)/2, i*(3+i)/2 - z]
    }
}

/*
    Nums contains various routines applicable to lists or ranges of numbers
    many of which are useful for statistical purposes.
*/
class Nums {
    // Methods to calculate sum, various means, product and maximum/minimum element of 'a'.
    // The sum and product of an empty list are considered to be 0 and 1 respectively.
    static sum(a)  { a.reduce(0) { |acc, x| acc + x } }
    static mean(a) { sum(a)/a.count }
    static geometricMean(a) { a.reduce { |prod, x| prod * x}.pow(1/a.count) }
    static harmonicMean(a) { a.count / a.reduce { |acc, x| acc + 1/x } }
    static quadraticMean(a) { (a.reduce(0) { |acc, x| acc + x*x }/a.count).sqrt }
    static prod(a) { a.reduce(1) { |acc, x| acc * x } }
    static max(a)  { a.reduce { |acc, x| (x > acc) ? x : acc } }
    static min(a)  { a.reduce { |acc, x| (x < acc) ? x : acc } }

    // Returns the median of a sorted list 'a'.
    static median(a) {
        var c = a.count
        if (c == 0) {
            Fiber.abort("An empty list cannot have a median")
        } else if (c%2 == 1) {
            return a[(c/2).floor]
        } else {
            var d = (c/2).floor
            return (a[d] + a[d-1])/2
        }
    }

    // Returns a list whose first element is a list of the mode(s) of 'a'
    // and whose second element is the number of times the mode(s) occur.
    static modes(a) {
        var m = {}
        for (e in a) m[e] = (!m[e]) ? 1 : m[e] + 1
        var max = 0
        for (e in a) if (m[e] > max) max = m[e]
        var res = []
        for (k in m.keys) if (m[k] == max) res.add(k)
        return [max, res]
    }

    // Returns the sample variance of 'a'.
    static variance(a) {
        var m = mean(a)
        var c = a.count
        return (a.reduce(0) { |acc, x| acc + x*x } - m*m*c) / (c-1)
    }

    // Returns the population variance of 'a'.
    static popVariance(a) {
        var m = mean(a)
        return (a.reduce(0) { |acc, x| acc + x*x }) / a.count - m*m
    }

    // Returns the sample standard deviation of 'a'.
    static stdDev(a) { variance(a).sqrt }

    // Returns the population standard deviation of 'a'.
    static popStdDev(a) { popVariance(a).sqrt }

    // Returns the mean deviation of 'a'.
    static meanDev(a) {
        var m = mean(a)
        return a.reduce { |acc, x| acc + (x - m).abs } / a.count
    }
}

/* Boolean supplements the Bool class with bitwise operations on boolean values. */
class Boolean {
    // Private helper method to convert a boolean to an integer.
    static btoi_(b) { b ? 1 : 0 }

    // Private helper method to convert an integer to a boolean.
    static itob_(i) { i != 0 }

    // Private helper method to check its arguments are both booleans.
    static check_(b1, b2) {
        if (!((b1 is Bool) && (b2 is Bool))) Fiber.abort("Both arguments must be booleans.")
    }

    // Returns the logical 'and' of its boolean arguments.
    static and(b1, b2) {
        check_(b1, b2)
        return itob_(btoi_(b1) & btoi_(b2))
    }

    // Returns the logical 'or' of its boolean arguments.
    static or(b1, b2) {
        check_(b1, b2)
        return itob_(btoi_(b1) | btoi_(b2))
    }

    // Returns the logical 'xor' of its boolean arguments.
    static xor(b1, b2) {
        check_(b1, b2)
        return itob_(btoi_(b1) ^ btoi_(b2))
    }
}

// Type aliases for classes in case of any name clashes with other modules.
var Math_Math = Math
var Math_Int = Int
var Math_Nums = Nums
var Math_Boolean = Boolean
