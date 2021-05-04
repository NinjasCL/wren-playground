// url: https://rosettacode.org/wiki/Category:Wren-rat
// source: https://rosettacode.org/mw/index.php?title=Category_talk:Wren-rat&action=edit&section=1
// file: rat
// name: Wren-rat
// author: PureFox
// license: MIT

/* Module "rat.wren" */

import "./trait" for Comparable

/* Rat represents a rational number as an integral numerator and (non-zero) denominator
   expressed in their lowest terms. Rat objects are immutable.
*/
class Rat is Comparable {
    // Maximum safe rational number = 2^53 - 1.
    static maxSafe { Rat.fromInt(9007199254740991) }

    // Private helper function to check that 'o' is a suitable type and throw an error otherwise.
    // Numbers and numeric strings are returned as rationals.
    static check_(o) {
        if (o is Rat) return o
        if (o is Num) return Rat.fromFloat(o)
        if (o is String) return (o.contains("_") && o.contains("/")) ? fromMixedString(o) :
                                 o.contains("/") ? fromRationalString(o) : fromString(o)
        Fiber.abort("Argument must either be a rational number, a number or a numeric string.")
    }

    // Private helper function which returns the greatest common divisor of 'n' and 'd'.
    static gcd_(n, d) {
        while (d != 0) {
            var t = d
            d = n % d
            n = t
        }
        return n
    }

    // Private helper method which constructs a Rat object from a non-integral numeric string.
    static fromDecimalString_(s) {
        if (s.contains("e")) Fiber.abort("Argument is out of range.")
        var ix = s.indexOf(".")
        var dp = s[ix+1..-1]
        var den = (10.pow(dp.count)).round
        var num = Num.fromString(s[0...ix] + dp)
        return Rat.new(num, den)
    }

    // Constants.
    static minusOne { Rat.new( -1,  1) }
    static zero     { Rat.new(  0,  1) }
    static one      { Rat.new(  1,  1) }
    static two      { Rat.new(  2,  1) }
    static ten      { Rat.new( 10,  1) }
    static half     { Rat.new(  1,  2) }
    static tenth    { Rat.new(  1, 10) }

    // Constructs a new Rat object by passing it a numerator and a denominator.
    construct new(n, d) {
        if (!(n is Num && n.isInteger)) Fiber.abort("Numerator must be an integer.")
        if (!(d is Num && d.isInteger && d != 0)) {
            Fiber.abort("Denominator must be a non-zero integer.")
        }
        if (n.abs > 9007199254740991) Fiber.abort("Numerator is out of range.")
        if (d.abs > 9007199254740991) Fiber.abort("Denominator is out of range.")
        if (n == 0) {
            d = 1
        } else if (d < 0) {
            n = -n
            d = -d
        }
        var g = Rat.gcd_(n, d).abs
        if (g > 1) {
            n = (n/g).truncate
            d = (d/g).truncate
        }
        _n = n
        _d = d
    }

    // Convenience method which constructs a new Rat object by passing it just a numerator.
    static new(n) { Rat.new(n, 1) }

    // Constructs a rational number from an integer.
    static fromInt(i) { Rat.new(i, 1) }

    // Constructs a rational number from a floating point number.
    static fromFloat(f) {
        if (!(f is Num)) Fiber.abort("Argument must be a number.")
        if (f.isInteger) return Rat.new(f, 1)
        var s = "%(f)"
        return fromDecimalString_(s)
    }

    // Constructs a rational number from a numeric string.
    static fromString(s) {
        var n
        if (!(n = Num.fromString(s))) Fiber.abort("Argument must be a numeric string.")
        if (n.isInteger) return Rat.new(n, 1)
        return fromDecimalString_(s.trim().trimEnd("0"))
    }

    // Constructs a rational number from a string of the form "n/d".
    // Improper fractions are allowed.
    static fromRationalString(s) {
        s = s.trim()
        var nd = s.split("/")
        if (nd.count != 2) Fiber.abort("Argument is not a suitable string.")
        var n = Num.fromString(nd[0])
        var d = Num.fromString(nd[1])
        if (!n || !d) Fiber.abort("Argument is not a suitable string.")
        return Rat.new(n, d)
    }

    // Constructs a rational number from a string of the form "i_n/d" where 'i' is an integer.
    // Improper and negative fractional parts are allowed.
    static fromMixedString(s) {
        var ind = s.split("_")
        if (ind.count != 2) Fiber.abort("Argument is not a suitable string.")
        var nd = fromRationalString(ind[1])
        var i = Rat.fromString(ind[0])
        var neg = i.isNegative || (i.isZero && ind[0][0] == "-")
        return neg ? i - nd : i + nd
    }

    // Returns the greater of two rational numbers.
    static max(r1, r2) { (r1 < r2) ? r2 : r1 }

    // Returns the smaller of two rational numbers.
    static min(r1, r2) { (r1 < r2) ? r1 : r2 }

    // Private helper method to compare two integers.
    static compareInts_(i, j) { (i - j).sign }

    // Determines whether a Rat object is always shown as such or, if integral, as an integer.
    static showAsInt     { __showAsInt }
    static showAsInt=(b) { __showAsInt = b }

    // Basic properties.
    num        { _n }                // numerator
    den        { _d }                // denominator
    ratio      { [_n, _d] }          // a two element list of the above
    isInteger  { toFloat.isInteger } // checks if integral or not
    isPositive { _n > 0 }            // checks if positive
    isNegative { _n < 0 }            // checks if negative
    isUnit     { _n.abs == 1 }       // checks if plus or minus one
    isZero     { _n == 0 }           // checks if zero

    // Rounding methods (similar to those in Num class).
    ceil     { Rat.fromInt(toFloat.ceil) }      // higher integer
    floor    { Rat.fromInt(toFloat.floor) }     // lower integer
    truncate { Rat.fromInt(toFloat.truncate) }  // lower integer, towards zero
    round    { Rat.fromInt(toFloat.round) }     // nearer integer
    fraction { this - truncate }                // fractional part (same sign as this.num)

    // Reciprocal
    inverse  { Rat.new(_d, _n) }

    // Integer division.
    idiv(o)  { (this/o).truncate }

    // Negation.
    -{ Rat.new(-_n, _d) }

    // Arithmetic operators (work with numbers and numeric strings as well as other rationals).
    +(o) { (o = Rat.check_(o)) && Rat.new(_n * o.den + _d * o.num, _d * o.den) }
    -(o) { (o = Rat.check_(o)) && (this + (-o)) }
    *(o) { (o = Rat.check_(o)) && Rat.new(_n * o.num, _d * o.den) }
    /(o) { (o = Rat.check_(o)) && Rat.new(_n * o.den, _d * o.num) }
    %(o) { (o = Rat.check_(o)) && (this - idiv(o) * o) }

    // Computes integral powers.
    pow(i) {
        if (!((i is Num) && i.isInteger)) Fiber.abort("Argument must be an integer.")
        if (i == 0) return this
        var np = _n.pow(i).round
        var dp = _d.pow(i).round
        return (i > 0) ? Rat.new(np, dp) : Rat.new(dp, np)
    }

    // Returns the square of the current instance.
    square { Rat.new(_n * _n , _d *_d) }

    // Other methods.
    inc { this + Rat.one }            // increment
    dec { this - Rat.one }            // decrement
    abs { (_n >= 0) ? this : -this }  // absolute value
    sign { _n.sign }                  // sign

    // The inherited 'clone' method just returns 'this' as Rat objects are immutable.
    // If you need an actual copy use this method instead.
    copy() { Rat.new(_n, _d) }

    // Compares this Rat with another one to enable comparison operators via Comparable trait.
    compare(other) {
        if ((other is Num) && other.isInfinity) return -other.sign
        other = Rat.check_(other)
        if (_d == other.den) return Rat.compareInts_(_n, other.num)
        return Rat.compareInts_(_n * other.den, other.num * _d)
    }

    // As above but compares the absolute values of the BigRats.
    compareAbs(other) { this.abs.compare(other.abs) }

    // Converts the current instance to a Num.
    toFloat { _n/_d }

    // Converts the current instance to an integer with any fractional part truncated.
    toInt { this.toFloat.truncate }

    // Returns a string represenation of this instance in the form "i_n/d" where 'i' is an integer.
    toMixedString {
        var q = _n / _d
        var r = _n % _d
        if (r.isNegative) r = -r
        return q.toString + "_" + r.toString + "/" + _d.toString
    }

    // Returns the string representation of this Rat object depending on 'showAsInt'.
    toString { (Rat.showAsInt && _d == 1) ? "%(_n)" : "%(_n)/%(_d)" }
}

/*  Rats contains various routines applicable to lists of rational numbers */
class Rats {
    static sum(a)  { a.reduce(Rat.zero) { |acc, x| acc + x } }
    static mean(a) { sum(a)/a.count }
    static prod(a) { a.reduce(Rat.one) { |acc, x| acc * x } }
    static max(a)  { a.reduce { |acc, x| (x > acc) ? x : acc } }
    static min(a)  { a.reduce { |acc, x| (x < acc) ? x : acc } }
}

// Type aliases for classes in case of any name clashes with other modules.
var Rat_Rat = Rat
var Rat_Rats = Rats
var Rat_Comparable = Comparable  // in case imported indirectly
