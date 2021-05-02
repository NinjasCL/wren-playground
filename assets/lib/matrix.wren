// url: https://rosettacode.org/wiki/Category:Wren-matrix
// source: https://rosettacode.org/mw/index.php?title=Category_talk:Wren-matrix&action=edit&section=1
// file: matrix
// name: Wren-matrix
// author: PureFox
// license: MIT

/* Module "matrix.wren" */

/* Matrix represents a two dimensional list of Nums. Once created the number of
   rows and columns of the matrix cannot be changed but individual elements can be.
*/
class Matrix {
    // Returns an instance of the identity matrix for a given number of rows.
    static identity(numRows) {
        if (numRows.type != Num || !numRows.isInteger || numRows < 1) {
            Fiber.abort("Number of rows must be a positive integer.")
        }
        var id = new_(numRows, numRows, 0)
        for (i in 0...numRows) id.set_(i, i, 1)
        return id
    }

    // Constructs a new Matrix object by passing it the number of rows and
    // columns and the initial value for each element.
    construct new(numRows, numCols, filler) {
        if (numRows.type != Num || !numRows.isInteger || numRows < 1) {
            Fiber.abort("Number of rows must be a positive integer.")
        }
        if (numCols.type != Num || !numCols.isInteger || numCols < 1) {
            Fiber.abort("Number of columns must be a positive integer.")
        }
        if (filler.type != Num) Fiber.abort("Filler must be a number.")
        _a = List.filled(numRows, null)
        for (i in 0...numRows) _a[i] = List.filled(numCols, filler)
        _nr = numRows
        _nc = numCols
    }

    // Convenience version of the public constructor which uses a filler of zero.
    static new(numRows, numCols) { new(numRows, numCols, 0) }

    // Private version of above constructor to avoid type checks.
    construct new_(numRows, numCols, filler) {
        _a = List.filled(numRows, null)
        for (i in 0...numRows) _a[i] = List.filled(numCols, filler)
        _nr = numRows
        _nc = numCols
    }

    // Constructs a new Matrix object from a two dimensional list of numbers.
    construct new(a) {
        if (a.type != List || a.count == 0 || a[0].type != List || a[0].count == 0 || a[0][0].type != Num) {
            Fiber.abort("Argument must be a non-empty two dimensional list of numbers.")
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

    // Basic properties.
    numRows     { _nr }         // returns the number of rows
    numCols     { _nc }         // returns the number of columns
    size        { [_nr, _nc] }  // returns both the above in a list
    numElements { _nr * _nc  }  // returns the number of elements
    first       { _a[0][0]   }  // returns the first element
    last        { _a[-1][-1] }  // returns the last element

    // Creates another Matrix by multiplying all elements of the current instance by -1.
    - { this * -1 }

    // Creates another Matrix by either:
    // 1. adding another Matrix of the same size to the current instance; or
    // 2. adding a number to each element of the current instance.
    +(b) {
        var c = List.filled(_nr, null)
        if (b is Num) {
            for (i in 0..._nr) {
                c[i] = List.filled(_nc, 0)
                for (j in 0..._nc) c[i][j] = _a[i][j] + b
            }
        } else if (b is Matrix) {
            if (!sameSize(b)) Fiber.abort("Matrices must be of the same size.")
            for (i in 0..._nr) {
                c[i] = List.filled(_nc, 0)
                for (j in 0..._nc) c[i][j] = _a[i][j] + b.get_(i, j)
            }
        } else {
            Fiber.abort("Argument must either be a matrix or a number.")
        }
        return Matrix.new_(c)
    }

    // Creates another Matrix by either:
    // 1. subtracting another Matrix of the same size from the current instance; or
    // 2. subtracting a number from each element of the current instance.
    -(b) { this + (-b) }

    // Creates another Matrix by either:
    // 1. multiplying the current instance by another Matrix of appropriate size; or
    // 2. multiplying each element of the current instance by a number.
    *(b) {
        var c = List.filled(_nr, null)
        if (b is Num) {
            for (i in 0..._nr) {
                c[i] = List.filled(_nc, 0)
                for (j in 0..._nc) c[i][j] = _a[i][j] * b
            }
        } else if (b is Matrix) {
            if (_nc != b.numRows) Fiber.abort("Cannot multiply these matrices.")
            for (i in 0..._nr) {
                c[i] = List.filled(b.numCols, 0)
                for (j in 0...b.numCols) {
                    for (k in 0..._nc) c[i][j] = c[i][j] + _a[i][k] * b.get_(k, j)
                }
            }
        } else {
            Fiber.abort("Argument must either be a matrix or a number.")
        }
        return Matrix.new_(c)
    }

    // Creates another Matrix by dividing each element of the current instance by a number.
    /(n) { this * (1/n) }

    // Creates another Matrix by applying the modulus operator to each element of the
    // current instance.
    %(n) { apply { |e| e % n } }

    // Synomym for pow(n).
    ^(n) { pow(n) }

    // Creates another Matrix by applying the 'abs' method to each element of the
    // current instance.
    abs { apply { |e| e.abs } }

    // Creates another matrix by multiplying the current instance by itself 'n' times.
    pow(n) {
        if (n.type != Num || !n.isInteger || n < 0) {
            Fiber.abort("Argument must be a non-negative integer.")
        }
        if (n == 0) return Matrix.identity(_nr)
        if (n == 1) return this.copy()
        var p = Matrix.identity(_nr)
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
        var t = List.filled(_nc, 0)
        for (r in 0..._nr) t[r] = _a[r][i]
        return t
    }

    // Returns a copy of this instance's main diagonal as long as its square.
    diag {
        if (!isSquare) Fiber.abort("Matrix must be square.")
        var d = List.filled(_nr, 0)
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
        if (v.type != Num) Fiber.abort("Element value must be a number.")
        _a[i][j] = v
    }

    // Private methods to get or set the elements at row 'i' and column 'j' of the current
    // instance without any validity checks.
    get_(i, j)    { _a[i][j] }
    set_(i, j, v) { _a[i][j] = v }

    // Returns whether or not this instance is the same size as another Matrix
    sameSize(b) { _nr == b.numRows && _nc == b.numCols }

    // Various self-explanatory properties.
    isSquare        { _nr == _nc }
    isRowVector     { _nr == 1 }
    isColVector     { _nc == 1 }
    isSymmetric     { isSquare && this == this.transpose }
    isSkewSymmetric { isSquare && this == -this.transpose }
    isOrthogonal    { isSquare && inverse == transpose }
    isIdempotent    { isSquare && (this * this == this) }
    isInvolutory    { isSquare && (this * this == Matrix.identity(_nr)) }
    isSingular      { det == 0 }

    // Returns whether all the elements of the current instance outside the main diagonal
    // are zero.
    isDiagonal {
        if (!isSquare) return false
        for (i in 0..._nr) {
            for (j in 0..._nr) {
                if (i != j && _a[i][j] != 0) return false
            }
        }
        return true
    }

    // Returns whether the current instance is 'diagonally dominant' i.e. whether, for every
    // row, the absolute value of the diagonal element in a row is greater than or
    // equal to the sum of the absolute values of all the other elements in that row.
    isDiagonallyDominant {
        if (!isSquare) return false
        for (i in 0..._nr) {
            var sum = 0
            for (j in 0..._nr) sum = sum + _a[i][j].abs
            sum = sum - _a[i][i].abs
            if (_a[i][i].abs < sum) return false
        }
        return true
    }

    // Returns whether all the current instance's elements above the main diagonal are zero.
    isLowerTriangular {
        if (!isSquare) return false
        for (i in 0..._nr - 1) {
            for (j in i + 1..._nr) {
                if (_a[i][j] != 0) return false
            }
        }
        return true
    }

    // Returns whether all the current instance's elements below the main diagonal are zero.
    isUpperTriangular {
        if (!isSquare) return false
        for (i in 1..._nr) {
            for (j in 0...i) {
                if (_a[i][j] != 0) return false
            }
        }
        return true
    }

    // Returns whether the current instance is lower or upper triangular.
    isTriangular { isLowerTrinagular || isUpperTriangular }

    // Returns whether or not current instance's elements are either 0 or 1.
    isBinary {
        for (i in 0..._nr) {
            for (j in 0..._nc) {
                if (_a[i][j] != 0 && _a[i][j] != 1) return false
             }
        }
        return true
    }

    // Returns the transpose of the current instance.
    transpose {
        var t = Matrix.new_(_nc, _nr, 0)
        for (i in 0..._nc) {
            for (j in 0..._nr) t.set_(i, j, _a[j][i])
        }
        return t
    }

    // Returns a new Matrix formed by applying a function ( Num -> Num )
    // to each element of the current instance.
    apply(f) {
        var t = Matrix.new_(_nc, _nr, 0)
        for (i in 0..._nr) {
            for (j in 0..._nc) t.set_(i, j, f.call(_a[i][j]))
        }
        return t
    }

    // Transforms the current instance by applying a function ( Num -> Num )
    // to each of its elements.
    transform(f) {
        for (i in 0..._nr) {
            for (j in 0..._nc) _a[i][j] = f.call(_a[i][j])
        }
    }

    // Changes all elements of the current instance by multiplying them by 'm'
    // and then adding 'a'.
    changeAll(m, a) {
        if (m.type != Num || a.type != Num) Fiber.abort("Multiplier and addend must be numbers.")
        for (i in 0..._nr) {
            for (j in 0..._nc) _a[i][j] = _a[i][j]*m + a
        }
    }

    // Changes all elements of a specified row of the current instance by multiplying
    // them by 'm' and then adding 'a'.
    changeRow(rowNum, m, a) {
        if (!validRowNum_(rowNum)) Fiber.abort("Invalid row number.")
        if (m.type != Num || a.type != Num) Fiber.abort("Multiplier and addend must be numbers.")
        for (j in 0..._nc) _a[rowNum][j] = _a[rowNum][j]*m + a
    }

    // Changes all elements of a specified column of the current instance by multiplying
    // them by 'm' and then adding 'a'.
    changeCol(colNum, m, a) {
        if (!validColNum_(colNum)) Fiber.abort("Invalid column number.")
        if (m.type != Num || a.type != Num) Fiber.abort("Multiplier and addend must be numbers.")
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
    copy() { Matrix.new_(this.toList) }

    // Checks whether or not the current instance's elements all have the same
    // values as the corresponding elements of another Matrix.
    ==(b) {
        if (b.type != Matrix) Fiber.abort("Argument must be a matrix.")
        if (!sameSize(b)) return false
        for (i in 0..._nr) {
            for (j in 0..._nc) if (_a[i][j] != b.get_(i, j)) return false
        }
        return true
    }

    // Checks whether or not all the current instance's elements do not have the same
    // values as the corresponding elements of another Matrix.
    !=(b) { !(this == b) }

    // Checks whether or not the current instance's elements all have the same values
    // as the corresponding elements of another Matrix to within a specified tolerance,
    almostEquals(b, tol) {
        if (b.type != Matrix) Fiber.abort("Argument must be a matrix.")
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
            result[i] = List.filled(len, 0)
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
        return Matrix.new_(result)
    }

    // Returns the matrix of cofactors of the current instance.
    cofactors {
        if (!isSquare) Fiber.abort("Matrix must be square.")
        var cf = List.filled(_nr, null)
        for (i in 0..._nr) {
            cf[i] = List.filled(_nc, 0)
            for (j in 0..._nc)  cf[i][j] = minor_(i, j).det * (-1).pow(i + j)
        }
        return Matrix.new_(cf)
    }

    // Returns the adjugate of the current instance.
    adjugate { cofactors.transpose }

    // Returns the inverse of this instance if it's square and if it exists
    // using the Gauss-Jordan method.
    inverse {
        if (!isSquare) Fiber.abort("Matrix must be square.")
        if (det == 0) Fiber.abort("No inverse as determinant is zero.")
        var aug = Matrix.new_(_nr, 2 *_nr, 0)
        for (i in 0..._nr) {
            for (j in 0..._nr) aug.set_(i, j, _a[i][j])
            aug.set_(i, i + _nr, 1)
        }
        aug.toReducedRowEchelonForm
        var inv = Matrix.new_(_nr, _nr, 0)
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
            while (_a[i][lead] == 0) {
                i = i + 1
                if (_nr == i) {
                    i = r
                    lead = lead + 1
                    if (_nc == lead) return
                }
            }
            swapRows_(i, r)
            if (_a[r][lead] != 0) {
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
        var t = Matrix.new_(rowNum2 - rowNum1 + 1, colNum2 - colNum1 + 1, 0)
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
        var sum = 0
        for (i in 0..._nr) sum = sum + _a[i][i]
        return sum
    }

    // Returns the determinant of the current instance if it's square using
    // Laplace expansion.
    det {
        if (!isSquare) Fiber.abort("Cannot calculate the determinant of a non-square matrix.")
        if (_nr == 1) return _a[0][0]
        if (_nr == 2) return _a[1][1] * _a[0][0] - _a[0][1] * _a[1][0]
        var sign = 1
        var sum = 0
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
        var sum = 0
        for (i in 0..._nr) {
            var m = minor_(0, i)
            sum = sum + _a[0][i] * m.perm
        }
        return sum
    }

    // Returns the Kronecker product of this instance with another Matrix.
    kronecker(b) {
        if (b.type != Matrix) Fiber.abort("Argument must be a matrix.")
        var m = _nr
        var n = _nc
        var p = b.numRows
        var q = b.numCols
        var rtn = m * p
        var ctn = n * q
        var r = List.filled(rtn, null)
        for (i in 0...rtn) r[i] = List.filled(ctn, 0)
        for (i in 0...m) {
            for (j in 0...n) {
                for (k in 0...p) {
                    for (l in 0...q) {
                        r[p * i + k][q * j + l] = _a[i][j] * b.get_(k, l)
                    }
                }
            }
        }
        return Matrix.new_(r)
    }

    // Returns the sum of all elements of the current instance.
    sum {
        var sum = 0
        for (i in 0..._nr) {
            for (j in 0..._nc) sum = sum + _a[i][j]
        }
        return sum
    }

    // Returns the mean of all elements of the current instance.
    mean { sum / (_nc * _nr) }

    // Returns the norm of all elements of the current instance.
    norm {
        var sum = 0
        for (i in 0..._nr) {
            for (j in 0..._nc) sum = sum + _a[i][j] * _a[i][j]
        }
        return sum.sqrt
    }

    // Returns the product of all elements of the current instance.
    prod {
        var prd = 1
        for (i in 0..._nr) {
            for (j in 0..._nc) {
                if (_a[i][j] == 0) return 0
                prd = prd * _a[i][j]
            }
        }
        return prd
    }

    // Returns the greatest element of the current instance.
    max {
        var m = -1/0
        for (i in 0..._nr) {
            for (j in 0..._nc) if (_a[i][j] > m) m = _a[i][j]
        }
        return m
    }

    // Returns the smallest element of the current instance.
    min {
        var m = 1/0
        for (i in 0..._nr) {
            for (j in 0..._nc) if (_a[i][j] < m) m = _a[i][j]
        }
        return m
    }

    // Private helper method for 'lup' which returns 'p' and the sign of 'p'.
    pivotize_() {
        var im = Matrix.identity(_nr)
        var sign = 1
        for (i in 0..._nr) {
            var max = _a[i][i]
            var row = i
            for (j in i..._nr) {
                if (_a[j][i] > max) {
                    max = _a[j][i]
                    row = j
                }
            }
            if (i != row) {
               im.swapRows_(i, row)
               sign = -sign
            }
        }
        return [im, sign]
    }

    // Applies LU decomposition with partial pivoting to the current instance if it's square
    // and returns the list [l, u, p, sign] were 'l' is a lower triangular matrix, 'u' is
    // an upper triangular matrix, 'p' is a permutation matrix such that p * this = l * u
    // and 'sign' is the sign (+1 or -1) of 'p'.
    lup {
        if (!isSquare) Fiber.abort("Matrix must be square.")
        var l = Matrix.new_(_nr, _nr, 0)
        var u = Matrix.new_(_nr, _nr, 0)
        var res = pivotize_()
        var p = res[0]
        var sign = res[1]
        var a = p * this
        for (j in 0..._nr) {
            l.set_(j, j, 1)
            for (i in 0..j) {
                var sum = 0
                for (k in 0...i) sum = sum + u.get_(k, j) * l.get_(i, k)
                u.set_(i, j, a.get_(i, j) - sum)
            }
            for (i in j..._nr) {
                var sum2 = 0
                for (k in 0...j) sum2 = sum2 + u.get_(k, j) * l.get_(i, k)
                l.set_(i, j, (a.get_(i, j) - sum2) / u.get_(j, j))
            }
        }
        return [l, u, p, sign]
    }

    // Returns the lower Cholesky factor (a lower triangular matrix) of the current instance
    // provided its symmetric and otherwise suitable.
    cholesky() {
        if (!isSymmetric) Fiber.abort("Matrix must be symmetric.")
        var n = _nr
        var res = List.filled(n, null)
        for (r in 0...n) {
            res[r] = List.filled(n, 0)
            for (c in 0..r) {
                var sum = 0
                if (c == r) {
                    for (j in 0...c) sum = sum + res[c][j] * res[c][j]
                    res[c][c] = (_a[c][c] - sum).sqrt
                } else {
                    for (j in 0...c) sum = sum + res[r][j] * res[c][j]
                    res[r][c] = (_a[r][c] - sum) / res[c][c]
                }
            }
        }
        return Matrix.new_(res)
    }

    // Prints the current instance's elements as a 2D list with each row on a new line.
    print() { System.print(_a.join("\n")) }

    // Returns the current instance's elements as a string.
    toString { _a.toString }
}

/*  Matrices contains various routines applicable to lists of Matrix objects. */
class Matrices {
    static sum(a)  { a.reduce { |acc, x| acc + x } }
    static mean(a) { sum(a)/a.count }
    static prod(a) { a[1..-1].reduce(a[0]) { |acc, x| acc * x } }
}

// Type aliases for classes in case of any name clashes with other modules.
var Matrix_Matrix   = Matrix
var Matrix_Matrices = Matrices
