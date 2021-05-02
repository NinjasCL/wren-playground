// url: https://rosettacode.org/wiki/Category:Wren-complex
// source: https://rosettacode.org/mw/index.php?title=Category_talk:Wren-complex&action=edit&section=2
// file: complex
// name: Wren-complex
// author: PureFox
// license: MIT

/* Module "complex.wren" */

import "./trait" for Cloneable

/* Complex represents a complex number of the form 'a + bi' where 'a' and 'b'
   are both Nums. Complex objects are immutable.
*/
class Complex is Cloneable {
    // Private helper function to check that 'o' is a suitable type and throw an error
    // otherwise. Real numbers, rationals and numeric strings are returned as complex numbers.
    static check_(o) {
        if (o is Complex) return o
        if (o is Num) return new_(o, 0)
        if ((o is List) && o.count == 2 && (o[0] is Num) && (o[1] is Num)) {
            return Complex.new_(o[0], o[1])
        }
        if (o.type.toString == "Rat") return new_(r.toFloat, 0)
        if (o is String) return fromString(o)
        Fiber.abort("Argument must be a number, pair of numbers, a rational number or a complex string.")
    }

    // Constants.
    static minusOne     { Complex.new_(-1,  0) }
    static zero         { Complex.new_( 0,  0) }
    static one          { Complex.new_( 1,  0) }
    static two          { Complex.new_( 2,  0) }
    static ten          { Complex.new_(10,  0) }
    static imagMinusOne { Complex.new_( 0, -1) }
    static imagOne      { Complex.new_( 0,  1) }
    static imagTwo      { Complex.new_( 0,  2) }
    static imagTen      { Complex.new_( 0, 10) }
    static i            { Complex.new_( 0,  1) } // same as imagOne

    static pi           { Complex.new_(Num.pi, 0) }
    static e            { Complex.new_(2.71828182845904523536, 0) }
    static phi          { Complex.new_(1.6180339887498948482,  0) } // golden ratio
    static tau          { Complex.new_(1.6180339887498948482,  0) } // synonym for phi
    static ln2          { Complex.new_(0.69314718055994530942, 0) } // 2.log
    static ln10         { Complex.new_(2.30258509299404568402, 0) } // 10.log

    // Determines whether a Complex object is always shown as such
    // or, if purely real, as a real.
    static showAsReal     { __showAsReal }
    static showAsReal=(b) { __showAsReal = b }

    // Constructs a new Complex object by passing it real and imaginary components.
    construct new(real, imag) {
        if (real.type != Num || imag.type != Num) System.print("Argument(s) must be numbers.")
        _real = real
        _imag = imag
    }

    // Convenience method which constructs a new Complex object from a Num by passing it
    // just a real component.
    static new(real) { new(real, 0) }

    // Private constructor which avoids type checking.
    construct new_(real, imag) {
        _real = real
        _imag = imag
    }

    // Constructs a Complex object from an ordered pair of numbers [real, imag].
    static fromPair(p) {
       if (p.type != List || p.count != 2 || p[0].type != Num || p[1].type != Num) {
            Fiber.abort("Argument must be an ordered pair of numbers.")
       }
       return Complex.new_(p[0], p[1])
    }

    // Constructs a Complex object from a string of the form '±a±bi', '±a' or '±bi'
    // where 'a' and 'b' are string representations of Nums.
    static fromString(s) {
        if (s.type != String) Fiber.abort("Argument must be a complex string.")
        s = s.trim()
        if (s == "") Fiber.abort("Invalid complex string.")
        s = s.replace("--", "+")
        if (s[0] == "+") s = s[1..-1]
        if (s == "") Fiber.abort("Invalid complex string.")
        s = s.replace("e+", "e")
        var neg = s[0] == "-"
        if (neg) {
            s = s[1..-1]
            if (s == "") Fiber.abort("Invalid complex string.")
        }
        var negExp = s.indexOf("e-") >= 0
        if (negExp) s = s.replace("e-", "\v")
        if (s.indexOf("+") >= 0) {
            var split = s.split("+")
            if (split.count != 2) Fiber.abort("Invalid complex string.")
            if (negExp) for (i in 0..1) split[i] = split[i].replace("\v", "e-")
            var real = Num.fromString(split[0])
            if (!real) Fiber.abort("Invalid real part.")
            if (neg) real = -real
            if (!split[1].endsWith("i")) Fiber.abort("Invalid complex string.")
            var imag = Num.fromString(split[1][0..-2])
            if (!imag) Fiber.abort("Invalid imaginary part.")
            return Complex.new_(real, imag)
        } else if (s.indexOf("-") >= 0) {
            var split = s.split("-")
            if (split.count != 2) Fiber.abort("Invalid complex string.")
            if (negExp) for (i in 0..1) split[i] = split[i].replace("\v", "e-")
            var real = Num.fromString(split[0])
            if (!real) Fiber.abort("Invalid real part.")
            if (neg) real = -real
            if (!split[1].endsWith("i")) Fiber.abort("Invalid complex string.")
            var imag = Num.fromString(split[1][0..-2])
            if (!imag) Fiber.abort("Invalid imaginary part.")
            return Complex.new_(real, -imag)
        } else if (s.endsWith("i")) {
            if (negExp) s = s.replace("\v", "e-")
            var imag = Num.fromString(s[0..-2])
            if (!imag) Fiber.abort("Invalid imaginary part.")
            if (neg) imag = -imag
            return Complex.new_(0, imag)
        } else {
            if (negExp) s = s.replace("\v", "e-")
            var real = Num.fromString(s)
            if (!real) Fiber.abort("Invalid real part.")
            if (neg) real = -real
            return Complex.new_(real, 0)
        }
    }

    // Constructs a Complex object from a Rat object.
    static fromRat(r) {
        if (r.type.toString != "Rat") Fiber.abort("Argument must be a rational number.")
        return Complex.new_(r.toFloat, 0)
    }

    // Constructs a Complex object from polar coordinates (r, theta).
    static fromPolar(r, theta)  {
        if (r.type != Num || theta.type != Num) {
            Fiber.abort("Arguments must be numbers.")
        }
        return Complex.new_(r * theta.cos, r * theta.sin)
    }

    // Basic properties.
    real { _real }  // real component
    imag { _imag }  // imaginary component

    isInfinity { _real.isInfinity || _imag.isInfinty } // true if either part is infinite
    isNan      { _real.isNan || imag.isNan }           // true if either part is nan

    // Returns whether real component is an integer and imaginary component is zero.
    isRealInteger { _real.isInteger && _imag == 0 }

    // Returns whether imaginary component is an integer and real component is zero.
    isImagInteger { _imag.isInteger && _real == 0 }

    // Returns the ordered pair [_real, _imag].
    toPair { [_real, _imag] }

    // Returns the polar coordinates of this instance [modulus, phase].
    toPolar { [abs, phase] }

    // Returns a new instance which negates the current one.
    - { Complex.new_(-_real, -_imag) }

    // Returns the inverse or reciprocal of this instance.
    inverse {
        var denom = _real * _real + _imag * _imag
        return Complex.new_(_real/denom, -_imag/denom)
    }

    // Arithmetic operators (work with real numbers, rational numbers, complex strings
    // as well as other complex numbers). Always return a new instance.
    +(o) {
        o = Complex.check_(o)
        return Complex.new_(_real + o.real, _imag + o.imag)
    }

    -(o) { this + (-o) }

    *(o) {
        o = Complex.check_(o)
        return Complex.new_(
            _real * o.real - _imag * o.imag,
            _real * o.imag + _imag * o.real
        )
    }

    /(o) {
        o = Complex.check_(o)
        var i = o.inverse
        return Complex.new_(
            _real * i.real - _imag * i.imag,
            _real * i.imag + _imag * i.real
        )
    }

    // Returns the absolute value or modulus of this instance.
    abs { (_real*_real + _imag*_imag).sqrt }

    // Returns the phase or argument of the current instance in the range [-π, π].
    phase { _imag.atan(_real) }

    // Returns the complex conjugate of this instance
    conj { Complex.new_(_real, -_imag) }

    // Returns the square of this instance.
    square { Complex.new_(_real * _real - _imag * _imag, _real * _imag * 2) }

    // Returns the square root of this instance.
    sqrt {
        var m = abs
        var r = ((m + _real)/2).sqrt
        var i = ((m - _real)/2).sqrt
        if (_imag < 0) i = -i
        return Complex.new_(r, i)
    }

    // Returns the base 'e' exponential of this instance.
    exp {
        var e = Complex.e.real.pow(_real) /* change to _real.exp from version 0.4.0 */
        return Complex.new_(e * _imag.cos, e * _imag.sin)
    }

    // Returns the natural logarithm of the current instance.
    log {
        var p = phase
        if (p > Num.pi) p = p - Num.pi*2
        return Complex.new_(abs.log, p)
    }

    // Returns the logarithm to the base 2 of the current instance.
    log2  { log / Complex.two.log }

    // Returns the logarithm to the base 10 of the current instance.
    log10 { log / Complex.ten.log }

    // Returns this instance to the power of the complex number 'e'.
    pow(e) {
        e = Complex.check_(e)
        return (log * e).exp
    }

    // Returns the cosine of the current instance.
    cos {
        var i = Complex.i
        return ((i * this).exp + (i * (-this)).exp) / Complex.two
    }

    // Returns the sine of the current instance.
    sin {
        var i = Complex.i
        return ((i * this).exp - (i * (-this)).exp) / Complex.imagTwo
    }

    // Returns the tangent of the current instance.
    tan { sin / cos }

    // Returns the arc cosine of the current instance.
    acos {
        var c = (Complex.one - square).sqrt
        c = this + c * Complex.imagMinusOne
        return c.log * Complex.i
    }

    // Returns the arc sine of the current instance.
    asin {
        var c = (Complex.one - square).sqrt
        c = c + this * Complex.imagMinusOne
        return c.log * Complex.i
    }

    // Returns the arc tangent of the current instance.
    atan {
        var a = Complex.new_(_real, _imag - 1)
        var b = Complex.new_(-_real, -_imag - 1)
        return (Complex.imagMinusOne * (a/b).log) / Complex.two
    }

    // Returns the hyperbolic cosine of the current instance.
    cosh { (this.exp + (-this).exp)/Complex.two }

    // Returns the hyperbolic sine of the current instance.
    sinh { (this.exp - (-this).exp)/Complex.two }

    // Returns the hyperbolic tangent of the current instance.
    tanh { sinh/cosh }

    // Returns the inverse hyperbolic cosine of the current instance.
    acosh { (this + (square - Complex.one).sqrt).log }

    // Returns the inverse hyperbolic sine of the current instance.
    asinh { (this + (square + Complex.one).sqrt).log }

    // Returns the inverse hyperbolic tangent of the current instance.
    atanh {
        var c = (this + Complex.one).log
        c = c - (-(this - Complex.one)).log
        return c / Complex.two
    }

    // The inherited 'clone' method just returns 'this' as Complex objects are immutable.
    // If you need an actual copy use this method instead.
    copy() { Complex.new_(_real, _imag ) }

    // Equality operators.
    ==(o) {
        o = Complex.check_(o)
        return _real == o.real && _imag == o.imag
    }
    !=(o) { !(this == o) }

    // Returns the string representation of this Complex object depending on 'showAsReal'.
    toString {
        if (_real == -0) _real = 0
        if (_imag == -0) _imag = 0
        var s = (_imag >= 0) ? "%(_real) + %(_imag)" : "%(_real) - %(-_imag)"
        s = (_imag.abs != 1) ? s + "i" : s[0..-2] + "i"
        if (s.endsWith("- 0i")) s = s[0..-5] + "+ 0i"
        return (Complex.showAsReal && _imag == 0) ? s = s[0..-6] : s
    }
}

/*  Complexes contains routines applicable to lists of complex numbers. */
class Complexes {
    static sum(a)  { a.reduce(Complex.zero) { |acc, x| acc + x } }
    static mean(a) { sum(a)/a.count }
    static prod(a) { a.reduce(Complex.one)  { |acc, x| acc * x } }
}

/* CMatrix represents a two dimensional list of complex numbers. Once created the number of
   rows and columns of the matrix cannot be changed but individual elements can be.
*/
class CMatrix {
    // Returns an instance of the identity matrix for a given number of rows.
    static identity(numRows) {
        if (numRows.type != Num || !numRows.isInteger || numRows < 1) {
            Fiber.abort("Number of rows must be a positive integer.")
        }
        var id = new_(numRows, numRows, Complex.zero)
        for (i in 0...numRows) id.set_(i, i, Complex.one)
        return id
    }

    // Constructs a new CMatrix object by passing it the number of rows and
    // columns and the initial value for each element.
    construct new(numRows, numCols, filler) {
        if (numRows.type != Num || !numRows.isInteger || numRows < 1) {
            Fiber.abort("Number of rows must be a positive integer.")
        }
        if (numCols.type != Num || !numCols.isInteger || numCols < 1) {
            Fiber.abort("Number of columns must be a positive integer.")
        }
        if (filler.type != Complex && filler.type != Num) {
            Fiber.abort("Filler must be a complex or real number.")
        }
        if (filler.type == Num) filler = Complex.new_(filler, 0)
        _a = List.filled(numRows, null)
        for (i in 0...numRows) _a[i] = List.filled(numCols, filler)
        _nr = numRows
        _nc = numCols
    }

    // Convenience version of the public constructor which uses a filler of zero.
    static new(numRows, numCols) { new(numRows, numCols, Complex.zero) }

    // Private version of above constructor to avoid type checks.
    construct new_(numRows, numCols, filler) {
        _a = List.filled(numRows, null)
        for (i in 0...numRows) _a[i] = List.filled(numCols, filler)
        _nr = numRows
        _nc = numCols
    }

    // Constructs a new CMatrix object from a two dimensional list of complex numbers.
    construct new(a) {
        if (a.type != List || a.count == 0 || a[0].type != List || a[0].count == 0 || a[0][0].type != Complex) {
            Fiber.abort("Argument must be a non-empty two dimensional list of complex numbers.")
        }
        _nr = a.count
        _nc = a[0].count
        // copy the list so it can be mutated independently
        _a = List.filled(_nr, null)
        for (i in 0..._nr) _a[i] = a[i].toList
    }

    // Private version of above constructor to avoid type checks and copying.
    construct new_(a) {
        _a  = a
        _nr = a.count
        _nc = a[0].count
    }

    // Constructs a new CMatrix object from a two dimensional list of real numbers.
    static fromReals(a) {
        if (a.type != List || a.count == 0 || a[0].type != List || a[0].count == 0 || a[0][0].type != Num) {
            Fiber.abort("Argument must be a non-empty two dimensional list of real numbers.")
        }
        var ca = List.filled(a.count, null)
        for (i in 0...a.count) {
            ca[i] = List.filled(a[0].count, null)
            for (j in 0...a[0].count) ca[i][j] = Complex.new(a[i][j])
        }
        return new_(ca)
    }

    // Basic properties.
    numRows     { _nr }         // returns the number of rows
    numCols     { _nc }         // returns the number of columns
    size        { [_nr, _nc] }  // returns both the above in a list
    numElements { _nr * _nc  }  // returns the number of elements
    first       { _a[0][0]   }  // returns the first element
    last        { _a[-1][-1] }  // returns the last element

    // Creates another CMatrix by multiplying all elements of the current instance by -1.
    - { this * Complex.minusOne }

    // Creates another CMatrix by either:
    // 1. adding another CMatrix of the same size to the current instance; or
    // 2. adding a complex or real number to each element of the current instance.
    +(b) {
        if (b is Num) b = Complex.new_(b, 0)
        var c = List.filled(_nr, null)
        if (b is Complex) {
            for (i in 0..._nr) {
                c[i] = List.filled(_nc, null)
                for (j in 0..._nc) c[i][j] = _a[i][j] + b
            }
        } else if (b is CMatrix) {
            if (!sameSize(b)) Fiber.abort("Matrices must be of the same size.")
            for (i in 0..._nr) {
                c[i] = List.filled(_nc, null)
                for (j in 0..._nc) c[i][j] = _a[i][j] + b.get_(i, j)
            }
        } else {
            Fiber.abort("Argument must be a complex matrix, a complex number or a real number.")
        }
        return CMatrix.new_(c)
    }

    // Creates another CMatrix by either:
    // 1. subtracting another CMatrix of the same size from the current instance; or
    // 2. subtracting a complex or real number from each element of the current instance.
    -(b) { this + (-b) }

    // Creates another CMatrix by either:
    // 1. multiplying the current instance by another CMatrix of appropriate size; or
    // 2. multiplying each element of the current instance by a complex or real number.
    *(b) {
        if (b is Num) b = Complex.new_(b, 0)
        var c = List.filled(_nr, null)
        if (b is Complex) {
            for (i in 0..._nr) {
                c[i] = List.filled(_nc, null)
                for (j in 0..._nc) c[i][j] = _a[i][j] * b
            }
        } else if (b is CMatrix) {
            if (_nc != b.numRows) Fiber.abort("Cannot multiply these matrices.")
            for (i in 0..._nr) {
                c[i] = List.filled(b.numCols, Complex.zero)
                for (j in 0...b.numCols) {
                    for (k in 0..._nc) c[i][j] = c[i][j] + _a[i][k] * b.get_(k, j)
                }
            }
        } else {
            Fiber.abort("Argument must be a complex matrix, a complex number or a real number.")
        }
        return CMatrix.new_(c)
    }

    // Creates another CMatrix by dividing each element of the current instance by a complex or real number.
    /(n) {
        if (n is Num) n = Complex.new_(n, 0)
        return this * n.inverse
    }

    // Synomym for pow(n).
    ^(n) { pow(n) }

    // Creates another CMatrix by applying the 'abs' method to each element of the
    // current instance.
    abs { apply { |e| e.abs } }

    // Creates another CMatrix by multiplying the current instance by itself 'n' times.
    pow(n) {
        if (n.type != Num || !n.isInteger || n < 0) {
            Fiber.abort("Argument must be a non-negative integer.")
        }
        if (n == 0) return CMatrix.identity(_nr)
        if (n == 1) return this.copy()
        var p = CMatrix.identity(_nr)
        var base = this.copy()
        while (n > 0) {
            if ((n & 1) == 1) p = p * base
            n = n >> 1
            base = base * base
        }
        return p
    }

    // Private methods to check that a row or column number are valid.
    validRowNum_(rn) { rn.type == Num && rn.isInteger && rn >= 0 && rn < _nr }
    validColNum_(cn) { cn.type == Num && cn.isInteger && cn >= 0 && cn < _nc }

    // Returns a copy of this instance's 'i'th row.
    row(i) { validRowNum_(i) ? _a[i].toList : Fiber.abort("Invalid row number.") }

    // Returns a copy of this instance's 'i'th column.
    col(i) {
        if (!validColNum_(i)) Fiber.abort("Invalid column number.")
        var t = List.filled(_nc, null)
        for (r in 0..._nr) t[r] = _a[r][i]
        return t
    }

    // Returns a copy of this instance's main diagonal as long as its square.
    diag {
        if (!isSquare) Fiber.abort("Matrix must be square.")
        var d = List.filled(_nr, null)
        for (i in 0..._nr) d[i] = _a[i][i]
        return d
    }

    // Returns a copy of this instance's 'i'th row (synonym for row(i)).
    [i] { row(i) }

    // Returns the element at row 'i' and column 'j' of the current instance.
    [i, j] { (validRowNum_(i) && validColNum_(j)) ? _a[i][j] : Fiber.abort("Out of range.") }

    // Sets the element at row 'i' and column 'j' of the current instance to value 'v'.
    [i, j]=(v) {
        if (!validRowNum_(i) || !validColNum_(j)) Fiber.abort("Out of range.")
        if (v.type != Complex && v.type != Num) Fiber.abort("Element value must be a complex or real number.")
        if (v.type == Num) v = Complex.new_(v, 0)
        _a[i][j] = v
    }

    // Private methods to get or set the elements at row 'i' and column 'j' of the current
    // instance without any validity checks.
    get_(i, j)    { _a[i][j] }
    set_(i, j, v) { _a[i][j] = v }

    // Returns whether or not this instance is the same size as another CMatrix or Matrix.
    sameSize(b) { _nr == b.numRows && _nc == b.numCols }

    // Various self-explanatory properties.
    isSquare        { _nr == _nc }
    isRowVector     { _nr == 1 }
    isColVector     { _nc == 1 }
    isSymmetric     { isSquare && this == this.transpose }
    isSkewSymmetric { isSquare && this == -this.transpose }
    isOrthogonal    { isSquare && inverse == transpose }
    isIdempotent    { isSquare && (this * this == this) }
    isInvolutory    { isSquare && (this * this == CMatrix.identity(_nr)) }
    isSingular      { det == Complex.zero }

    isHermitian     { isSquare && this == this.conjTranspose }
    isSkewHermitian { isSquare && this == -this.conjTranspose }
    isNormal        { isSquare && this * conjTranspose == conjTranspose * this }
    isUnitary       { isSquare && this * conjTranspose == CMatrix.identity(_nr) }

    // Returns whether all the elements of the current instance outside the main diagonal
    // are zero.
    isDiagonal {
        if (!isSquare) return false
        for (i in 0..._nr) {
            for (j in 0..._nr) {
                if (i != j && _a[i][j] != Complex.zero) return false
            }
        }
        return true
    }

    // Returns whether all the current instance's elements above the main diagonal are zero.
    isLowerTriangular {
        if (!isSquare) return false
        for (i in 0..._nr - 1) {
            for (j in i + 1..._nr) {
                if (_a[i][j] != Complex.zero) return false
            }
        }
        return true
    }

    // Returns whether all the current instance's elements below the main diagonal are zero.
    isUpperTriangular {
        if (!isSquare) return false
        for (i in 1..._nr) {
            for (j in 0...i) {
                if (_a[i][j] != Complex.zero) return false
            }
        }
        return true
    }

    // Returns whether the current instance is lower or upper triangular.
    isTriangular { isLowerTrinagular || isUpperTriangular }

    // Returns the conjugate of the current instance.
    conj {
        var c = CMatrix.new_(_nr, _nc, Complex.zero)
        for (i in 0..._nc) {
            for (j in 0..._nr) c.set_(i, j, _a[i][j].conj)
        }
        return c
    }

    // Returns the transpose of the current instance.
    transpose {
        var t = CMatrix.new_(_nc, _nr, Complex.zero)
        for (i in 0..._nc) {
            for (j in 0..._nr) t.set_(i, j, _a[j][i])
        }
        return t
    }

    // Returns the conjugate transpose of the current instance.
    conjTranspose {
        var ct = CMatrix.new_(_nc, _nr, Complex.zero)
        for (i in 0..._nc) {
            for (j in 0..._nr) ct.set_(i, j, _a[j][i].conj)
        }
        return ct
    }

    // Returns a new CMatrix formed by applying a function ( Complex -> Complex )
    // to each element of the current instance.
    apply(f) {
        var t = CMatrix.new_(_nc, _nr, Complex.zero)
        for (i in 0..._nr) {
            for (j in 0..._nc) t.set_(i, j, f.call(_a[i][j]))
        }
        return t
    }

    // Transforms the current instance by applying a function ( Complex -> Complex )
    // to each of its elements.
    transform(f) {
        for (i in 0..._nr) {
            for (j in 0..._nc) _a[i][j] = f.call(_a[i][j])
        }
    }

    // Changes all elements of the current instance by multiplying them by 'm'
    // and then adding 'a'.
    changeAll(m, a) {
        if ((m.type != Complex && m != Num) || (a.type != Complex && a.type != Num)) {
            Fiber.abort("Multiplier and addend must be complex or real numbers.")
        }
        for (i in 0..._nr) {
            for (j in 0..._nc) _a[i][j] = _a[i][j]*m + a
        }
    }

    // Changes all elements of a specified row of the current instance by multiplying
    // them by 'm' and then adding 'a'.
    changeRow(rowNum, m, a) {
        if (!validRowNum_(rowNum)) Fiber.abort("Invalid row number.")
        if ((m.type != Complex && m != Num) || (a.type != Complex && a.type != Num)) {
            Fiber.abort("Multiplier and addend must be complex or real numbers.")
        }
        for (j in 0..._nc) _a[rowNum][j] = _a[rowNum][j]*m + a
    }

    // Changes all elements of a specified column of the current instance by multiplying
    // them by 'm' and then adding 'a'.
    changeCol(colNum, m, a) {
        if (!validColNum_(colNum)) Fiber.abort("Invalid column number.")
        if ((m.type != Complex && m != Num) || (a.type != Complex && a.type != Num)) {
            Fiber.abort("Multiplier and addend must be complex or real numbers.")
        }
        for (i in 0..._nr) _a[i][colNum] = _a[i][colNum]*m + a
    }

    // Swaps two specified rows of the current instance.
    swapRows(rowNum1, rowNum2) {
        if (!validRowNum_(rowNum1) || !validRowNum_(rowNum2)) Fiber.abort("Invalid row number.")
        swapRows_(rowNum1, rowNum2)
    }

    // Private method to swap two rows of the current instance without checking validity.
    swapRows_(rowNum1, rowNum2) {
        if (rowNum1 == rowNum2) return
        var t = row(rowNum1)
        for (j in 0..._nc) {
            _a[rowNum1][j] = _a[rowNum2][j]
            _a[rowNum2][j] = t[j]
        }
    }

    // Swaps two specified columns of the current instance.
    swapCols(colNum1, colNum2) {
        if (!validColNum_(colNum1) || !validColNum_(colNum2)) Fiber.abort("Invalid column number.")
        if (colNum1 == colNum2) return
        var t = col(colNum1)
        for (i in 0..._nr) {
            _a[i][colNum1] = _a[i][colNum2]
            _a[i][colNum2] = t[i]
        }
    }

    // Copies the elements of the current instance to a 2D list.
    toList {
        var l = List.filled(_nr, null)
        for (i in 0..._nr) l[i] = _a[i].toList
        return l
    }

    // Flattens the current instance by transferring all its elements row by row
    // to a new single dimensional list.
    flatten() {
        var t = []
        for (i in 0..._nr) t.addAll(_a[i])
        return t
    }

    // Returns a copy of this instance
    copy() { CMatrix.new_(this.toList) }

    // Checks whether or not the current instance's elements all have the same
    // values as the corresponding elements of another CMatrix.
    ==(b) {
        if (b.type != CMatrix) Fiber.abort("Argument must be a complex matrix.")
        if (!sameSize(b)) return false
        for (i in 0..._nr) {
            for (j in 0..._nc) if (_a[i][j] != b.get_(i, j)) return false
        }
        return true
    }

    // Checks whether or not all the current instance's elements do not have the same
    // values as the corresponding elements of another CMatrix.
    !=(b) { !(this == b) }

    // Checks whether or not the current instance's elements all have the same values
    // as the corresponding elements of another CMatrix to within a specified tolerance,
    almostEquals(b, tol) {
        if (b.type != CMatrix) Fiber.abort("Argument must be a complex matrix.")
        if (!sameSize(b)) return false
        if (tol.type != Num || tol <= 0 || tol >= 1e-5) {
            Fiber.abort("Tolerance must be a positive number <= 1e-5.")
        }
        var d = this - b
        for (i in 0..._nr) {
            for (j in 0..._nc) if (d.get_(i, j).abs > tol) return false
        }
        return true
    }

    // Convenince version of above method which uses a tolerance of 1e-14.
    almostEquals(b) { almostEquals(b, 1e-14) }

    // Returns a minor of the current instance after removing a specified row
    // and a specified column.
    minor(rowNum, colNum) {
        if (!isSquare) Fiber.abort("Matrix must be square.")
        if (!validRowNum_(rowNum)) Fiber.abort("Invalid row number.")
        if (!validColNum_(colNum)) Fiber.abort("Invalid column number.")
        return minor_(rowNum, colNum)
    }

    // Private version of the above method which returns the minor without
    // validity checks.
    minor_(x, y) {
        var len = _nr - 1
        var result = List.filled(len, null)
        for (i in 0...len) {
            result[i] = List.filled(len, null)
            for (j in 0...len) {
                if (i < x && j < y) {
                    result[i][j] = _a[i][j]
                } else if (i >= x && j < y) {
                    result[i][j] = _a[i+1][j]
                } else if (i < x && j >= y) {
                    result[i][j] = _a[i][j+1]
                } else {
                    result[i][j] = _a[i+1][j+1]
                }
            }
        }
        return CMatrix.new_(result)
    }

    // Returns the complex matrix of cofactors of the current instance.
    cofactors {
        if (!isSquare) Fiber.abort("Matrix must be square.")
        var cf = List.filled(_nr, null)
        for (i in 0..._nr) {
            cf[i] = List.filled(_nc, null)
            for (j in 0..._nc)  cf[i][j] = minor_(i, j).det * (Complex.minusOne.pow(i + j))
        }
        return CMatrix.new_(cf)
    }

    // Returns the adjugate of the current instance.
    adjugate { cofactors.transpose }

    // Returns the inverse of this instance if it's square and if it exists
    // using the Gauss-Jordan method.
    inverse {
        if (!isSquare) Fiber.abort("Matrix must be square.")
        if (det == Complex.zero) Fiber.abort("No inverse as determinant is zero.")
        var aug = CMatrix.new_(_nr, 2 *_nr, Complex.zero)
        for (i in 0..._nr) {
            for (j in 0..._nr) aug.set_(i, j, _a[i][j])
            aug.set_(i, i + _nr, Complex.one)
        }
        aug.toReducedRowEchelonForm
        var inv = CMatrix.new_(_nr, _nr, Complex.zero)
        for (i in 0..._nr) {
            for (j in _nr...2 *_nr) inv.set_(i, j - _nr, aug.get_(i, j))
        }
        return inv
    }

    // Converts the current instance in place to reduced row echelon form.
    toReducedRowEchelonForm {
        var lead = 0
        for (r in 0..._nr) {
            if (_nc <= lead) return
            var i = r
            while (_a[i][lead] == Complex.zero) {
                i = i + 1
                if (_nr == i) {
                    i = r
                    lead = lead + 1
                    if (_nc == lead) return
                }
            }
            swapRows_(i, r)
            if (_a[r][lead] != Complex.zero) {
                var div = _a[r][lead]
                for (j in 0..._nc) _a[r][j] = _a[r][j] / div
            }
            for (k in 0..._nr) {
                if (k != r) {
                    var mult = _a[k][lead]
                    for (j in 0..._nc) _a[k][j] = _a[k][j] - _a[r][j] * mult
                }
            }
            lead = lead + 1
        }
    }

    // Create a new submatrix from rowNum1 to rowNum2 inclusive and from
    // colNum1 to colNum2 inclusive of the current instance.
    subMatrix(rowNum1, colNum1, rowNum2, colNum2) {
        if (!validRowNum_(rowNum1)) Fiber.abort("Invalid first row number.")
        if (!validColNum_(colNum1)) Fiber.abort("Invalid first column number.")
        if (!validRowNum_(rowNum2)) Fiber.abort("Invalid second row number.")
        if (!validColNum_(colNum2)) Fiber.abort("Invalid second column number.")
        if (rowNum1 > rowNum2) Fiber.abort("First row number cannot be greater than second.")
        if (colNum1 > colNum2) Fiber.abort("First column number cannot be greater than second.")
        return subMatrix_(rowNum1, colNum1, rowNum2, colNum2)
    }

    // Private version of the above method which returns the submatrix without
    // validity checks.
    subMatrix_(rowNum1, colNum1, rowNum2, colNum2) {
        var t = CMatrix.new_(rowNum2 - rowNum1 + 1, colNum2 - colNum1 + 1, Complex.zero)
        for (i in rowNum1..rowNum2) {
            for (j in colNum1..colNum2) {
                t.set_(i - rowNum1, j - colNum1, _a[i][j])
            }
        }
        return t
    }

    // Returns the trace of the current instance if it's square.
    trace {
        if (!isSquare) Fiber.abort("Cannot calculate the trace of a non-square matrix.")
        var sum = Complex.zero
        for (i in 0..._nr) sum = sum + _a[i][i]
        return sum
    }

    // Returns the determinant of the current instance if it's square using
    // Laplace expansion.
    det {
        if (!isSquare) Fiber.abort("Cannot calculate the determinant of a non-square matrix.")
        if (_nr == 1) return _a[0][0]
        if (_nr == 2) return _a[1][1] * _a[0][0] - _a[0][1] * _a[1][0]
        var sign = Complex.one
        var sum = Complex.zero
        for (i in 0..._nr) {
            var m = minor_(0, i)
            sum = sum + sign * _a[0][i] * m.det
            sign = -sign
        }
        return sum
    }

    // Returns the permanent of the current instance if it's square using
    // Laplace expansion.
    perm {
        if (!isSquare) Fiber.abort("Cannot calculate the permanent of a non-square matrix.")
        if (_nr == 1) return _a[0][0]
        var sum = Complex.zero
        for (i in 0..._nr) {
            var m = minor_(0, i)
            sum = sum + _a[0][i] * m.perm
        }
        return sum
    }

    // Returns the sum of all elements of the current instance.
    sum {
        var sum = Complex.zero
        for (i in 0..._nr) {
            for (j in 0..._nc) sum = sum + _a[i][j]
        }
        return sum
    }

    // Returns the norm of all elements of the current instance.
    norm {
        var sum = Complex.zero
        for (i in 0..._nr) {
            for (j in 0..._nc) sum = sum + _a[i][j] * _a[i][j]
        }
        return sum.sqrt
    }

    // Returns the product of all elements of the current instance.
    prod {
        var prd = Complex.one
        for (i in 0..._nr) {
            for (j in 0..._nc) {
                if (_a[i][j] == Complex.zero) return Complex.zero
                prd = prd * _a[i][j]
            }
        }
        return prd
    }

    // Prints the current instance's elements as a 2D list with each row on a new line.
    print() { System.print(_a.join("\n")) }

    // Returns the current instance's elements as a string.
    toString { _a.toString }
}

/*  CMatrices contains various routines applicable to lists of CMatrix objects. */
class CMatrices {
    static sum(a)  { a.reduce { |acc, x| acc + x } }
    static prod(a) { a[1..-1].reduce(a[0]) { |acc, x| acc * x } }
}

// Type aliases for classes in case of any name clashes with other modules.
var Complex_Complex  = Complex
var Complex_Complexes = Complexes
var Complex_CMatrix   = CMatrix
var Complex_CMatrices = CMatrices
var Complex_Cloneable = Cloneable // in case imported indirectly
