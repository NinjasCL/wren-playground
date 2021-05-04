// url: https://rosettacode.org/wiki/Category:Wren-sort
// source: https://rosettacode.org/mw/index.php?title=Category_talk:Wren-sort&action=edit&section=1
// file: sort
// name: Wren-sort
// author: PureFox
// license: MIT

/* Module "sort.wren" */

import "./trait" for Comparable

/*
   Cmp provides standard comparison methods for use with the Sort and Find classes.
   All comparison methods return a function, which take two parameters p1 & p2 say and
   returns -1, 0, or +1 depending on whether p1 < p2, p1 == p2 or p1 > p2 respectively.
*/
class Cmp {
    static bool     { Fn.new { |b1, b2| (b1 == b2) ? 0 : (b1) ? 1 : -1 } }  // false < true
    static boolDesc { Fn.new { |b1, b2| (b1 == b2) ? 0 : (b1) ? -1 : 1 } }  // false > true

    static num      { Fn.new { |n1, n2| (n1-n2).sign } } // numerical order
    static numDesc  { Fn.new { |n1, n2| (n2-n1).sign } } // reverse numerical order

    // For other objects which define the comparison operators.
    static comparable     { Fn.new { |c1, c2| (c1 == c2) ? 0 : (c1 < c2) ? -1 :  1 } }
    static comparableDesc { Fn.new { |c1, c2| (c1 == c2) ? 0 : (c1 < c2) ?  1 : -1 } }

    // Lexicographical order of codepoints.
    static string {
        return Fn.new { |s1, s2|
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
    }

    // Reverse lexicographical order of codepoints.
    static stringDesc { Fn.new { |s1, s2| -string.call(s1, s2) } }

    // Private helper function to enable case insensitivity.
    static lower_(s) {
        if (s == "") return s
        var cps = s.codePoints.toList
        for (i in 0...cps.count) {
            var c = cps[i]
            if (c >= 65 && c <= 90) cps[i] = c + 32
        }
        return cps.reduce("") { |acc, c| acc + String.fromCodePoint(c) }
    }

    // As 'string' or 'stringDesc' but ignoring case.
    static insensitive     { Fn.new { |s1, s2| string.call(lower_(s1), lower_(s2))     } }
    static insensitiveDesc { Fn.new { |s1, s2| stringDesc.call(lower_(s1), lower_(s2)) } }

    // As 'string' or 'stringDesc' using the object's string representation.
    static general     { Fn.new { |g1, g2| string.call(g1.toString, g2.toString)       } }
    static generalDesc { Fn.new { |g1, g2| stringDesc.call(g1.toString, g2.toString)   } }

    // Provides a default comparison function depending on the type of 'v'.
    static default(v) {
        return (v is Num)        ? Cmp.num        :
               (v is String)     ? Cmp.string     :
               (v is Bool)       ? Cmp.bool       :
               (v is Comparable) ? Cmp.comparable : Cmp.general
    }

    // Provides a default descending comparison function depending on the type of 'v'.
    static defaultDesc(v) {
        return (v is Num)        ? Cmp.numDesc        :
               (v is String)     ? Cmp.stringDesc     :
               (v is Bool)       ? Cmp.boolDesc       :
               (v is Comparable) ? Cmp.comparableDesc : Cmp.generalDesc
    }
}

/*
    Sort contains various sorting methods which may be useful in different scenarios.
    As it would be too expensive to check that all elements of a large list are of the
    same type or compatible types, errors are left to emerge naturally.
*/
class Sort {
    // Private helper function to check that 'a' is a list and throw an error otherwise.
    static isList_(a) { (a is List) ? true : Fiber.abort("Argument must be a list.") }

    // In place quicksort. Unstable.
    static quick(a, s, e, cmp) {
        isList_(a)
        var c = a.count
        if (c < 2 || s < 0 || s >= c || e <= s || e >= c) return
        if (!e) e = c - 1
        if (cmp == true) cmp = Cmp.defaultDesc(a[0])
        if (!cmp) cmp = Cmp.default(a[0])
        quick_(a, s, e, cmp)
    }

    // Private worker method for quicksort.
    static quick_(a, s, e, cmp) {
        if (e <= s) return
        var p = a[((s+e)/2).floor]
        var l = s
        var r = e
        while (l <= r) {
            while (cmp.call(a[l], p) < 0) l = l + 1
            while (cmp.call(a[r], p) > 0) r = r - 1
            if (l <= r) {
                var t = a[l]
                a[l] = a[r]
                a[r] = t
                l = l + 1
                r = r - 1
            }
        }
        quick_(a, s, r, cmp)
        quick_(a, l, e, cmp)
    }

    // Out of place merge sort. Stable.
    static merge(m, cmp) {
        isList_(m)
        var len = m.count
        if (len < 2) return m
        if (cmp == true) cmp = Cmp.defaultDesc(m[0])
        if (!cmp) cmp = Cmp.default(m[0])
        return merge_(m, cmp)
    }

    // Private worker function for merge sort.
    static merge_(m, cmp) {
        var len = m.count
        if (len < 2) return m
        var middle = (len/2).floor
        var left = m[0...middle]
        var right = m[middle..-1]
        left = merge_(left, cmp)
        right = merge_(right, cmp)
        if (cmp.call(left[-1], right[0]) <= 0) {
            left.addAll(right)
            return left
        }
        var result = []
        while (left.count > 0 && right.count > 0) {
            if (cmp.call(left[0], right[0]) <= 0) {
                result.add(left[0])
                left = left[1..-1]
            } else {
                result.add(right[0])
                right = right[1..-1]
            }
        }
        if (left.count > 0) result.addAll(left)
        if (right.count > 0) result.addAll(right)
        return result
    }

    // In place heap sort. Unstable.
    static heap(a, cmp) {
        isList_(a)
        var count = a.count
        if (count < 2) return
        if (cmp == true) cmp = Cmp.defaultDesc(a[0])
        if (!cmp) cmp = Cmp.default(a[0])
        var start = ((count - 2)/2).floor
        while (start >= 0) {
            siftDown_(a, start, count - 1, cmp)
            start = start - 1
        }
        var end = count - 1
        while (end > 0) {
            var t = a[end]
            a[end] = a[0]
            a[0] = t
            end = end - 1
            siftDown_(a, 0, end, cmp)
        }
    }

    // Private helper function for heap sort.
    static siftDown_(a, start, end, cmp) {
        var root = start
        while (root*2 + 1 <= end) {
            var child = root*2 + 1
            if (child + 1 <= end && cmp.call(a[child], a[child+1]) < 0) child = child + 1
            if (cmp.call(a[root], a[child]) < 0) {
                var t = a[root]
                a[root] = a[child]
                a[child] = t
                root = child
            } else {
                return
            }
        }
    }

    // In place insertion sort. Stable.
    static insertion(a, cmp) {
        isList_(a)
        var c = a.count
        if (c < 2) return
        if (cmp == true) cmp = Cmp.defaultDesc(a[0])
        if (!cmp) cmp = Cmp.default(a[0])
        for (i in 1..c-1) {
            var v = a[i]
            var j = i - 1
            while (j >= 0 && cmp.call(a[j], v) > 0) {
                a[j+1] = a[j]
                j = j - 1
            }
            a[j+1] = v
        }
    }

    // In place selection sort. Unstable.
    static selection(a, cmp) {
        isList_(a)
        var c = a.count
        if (c < 2) return
        if (cmp == true) cmp = Cmp.defaultDesc(a[0])
        if (!cmp) cmp = Cmp.default(a[0])
        var last = c - 1
        for (i in 0...last) {
            var iMin = i
            for (j in i+1..last) {
                if (cmp.call(a[j], a[iMin]) < 0) iMin = j
            }
            if (iMin != i) {
                var t = a[i]
                a[i] = a[iMin]
                a[iMin] = t
            }
        }
    }

    // In place shell sort. Unstable.
    static shell(a, cmp) {
        isList_(a)
        var n = a.count
        if (n < 2) return
        if (cmp == true) cmp = Cmp.defaultDesc(a[0])
        if (!cmp) cmp = Cmp.default(a[0])
        var gaps = [701, 301, 132, 57, 23, 10, 4, 1]
        for (gap in gaps) {
            if (gap < n) {
                for (i in gap...n) {
                    var t = a[i]
                    var j = i
                    while (j >= gap && cmp.call(a[j-gap], t) > 0) {
                        a[j] = a[j - gap]
                        j = j - gap
                    }
                    a[j] = t
                }
            }
        }
    }

    // Convenience methods which sort the whole of a list using a particular sorting
    // method with default parameters. 'false' indicates a default ascending sort.
    static quick(a)     { quick(a, 0, a.count-1, false) }
    static merge(a)     { merge(a, false)               }
    static heap(a)      { heap(a, false)                }
    static insertion(a) { insertion(a, false)           }
    static selection(a) { selection(a, false)           }
    static shell(a)     { shell(a, false)               }

    // As above but sort in descending order.
    static quickDesc(a)     { quick(a, 0, a.count-1, true) }
    static mergeDesc(a)     { merge(a, true)               }
    static heapDesc(a)      { heap(a, true)                }
    static insertionDesc(a) { insertion(a, true)           }
    static selectionDesc(a) { selection(a, true)           }
    static shellDesc(a)     { shell(a, true)               }

    // Convenience methods which sort the whole of a list of strings ignoring case
    // using quicksort with the appropriate comparison function.
    static insensitive(a)     { quick(a, 0, a.count-1, Cmp.insensitive)     }
    static insensitiveDesc(a) { quick(a, 0, a.count-1, Cmp.insensitiveDesc) }

    // Checks whether a list is already sorted.
    static isSorted(a, cmp) {
        isList_(a)
        var c = a.count
        if (c < 2) return true
        if (cmp == true) cmp = Cmp.defaultDesc(a[0])
        if (!cmp) cmp = Cmp.default(a[0])
        for (i in 1...c) {
            if (cmp.call(a[i-1], a[i]) > 0) return false
        }
        return true
    }

    // Convenience versions of the above.
    static isSorted(a)     { isSorted(a, false) }
    static isSortedDesc(a) { isSorted(a, true)  }

    // Reverses a list in place.
    static reverse(a) {
        var c = a.count
        if (c < 2) return
        var i = 0
        var j = a.count - 1
        while (i < j) {
            var t = a[i]
            a[i] = a[j]
            a[j] = t
            i = i + 1
            j = j - 1
        }
    }
}

/*
    Find contains methods to search for values in lists where a comparison function is needed.
    As it would be too expensive to check that all elements of a large list are of the same
    or compatible types and are already sorted, errors are left to emerge naturally.
*/
class Find {
    // Searches a sorted list for all instances of a particular value
    // using the binary search algorithm and the comparison function
    // by which it was (hopefully) sorted in the first place.
    // Returns a list of three items:
    // The first item is a Bool indicating whether the value was found.
    // The second item is the number of times the value was found.
    // The third item is the range of indices at which the value was found or, if not found,
    // the index at which it would need to be inserted.
    static all(a, value, cmp) {
        Sort.isList_(a)
        var count = a.count
        if (count == 0) return [false, 0, 0..0]
        if (cmp == true) cmp = Cmp.defaultDesc(a[0])
        if (!cmp) cmp = Cmp.default(a[0])
        var low = 0
        var high = count - 1
        while (low <= high) {
            var mid = ((low + high)/2).floor
            if (cmp.call(a[mid], value) >= 0) {
                high = mid - 1
            } else {
                low = mid + 1
            }
        }
        var found = (low < count && a[low] == value)
        if (!found) return [false, 0, low..low]
        if (low == a.count - 1) return [true, 1, low..low]
        var last = low + 1
        while (last < a.count) {
            if (a[last] != value) break
            last = last + 1
        }
        return [true, last-low, low..last-1]
    }

    // Works similarly to 'all' but only returns the index of the first match
    // or -1 if there were no matches at all.
    static first(a, value, cmp) {
        var t = all(a, value, cmp)
        return (t[1] > 0) ? t[2].from : -1
    }

    // Works similarly to 'all' but only returns the index of the last match
    // or -1 if there were no matches at all.
    static last(a, value, cmp) {
        var t = all(a, value, cmp)
        return (t[1] > 0) ? t[2].to : -1
    }

    // Finds the lowest value in an unsorted list according to 'cmp' but without sorting.
    // Returns a list of three items:
    // The first item is the lowest value.
    // The second item is the number of times the lowest value was found.
    // The third item is a list of indices at which the lowest value was found.
    static lowest(a, cmp) {
        Sort.isList_(a)
        var count = a.count
        if (count == 0) Fiber.abort("An empty list does not have a lowest element.")
        if (count == 1) return [a[0], 1, [0]]
        if (cmp == true) cmp = Cmp.defaultDesc(a[0])
        if (!cmp) cmp = Cmp.default(a[0])
        var min = a[0]
        var iMin = [0]
        for (i in 1...count) {
            var m = cmp.call(a[i], min)
            if (m < 0) {
                min = a[i]
                iMin = [i]
            } else if (m == 0) {
                iMin.add(i)
            }
        }
        return [min, iMin.count, iMin]
    }

    // As 'lowest' but finds the highest value of the list according to 'cmp'
    static highest(a, cmp) {
        Sort.isList_(a)
        var count = a.count
        if (count == 0) Fiber.abort("An empty list does not have a lowest element.")
        if (count == 1) return [a[0], 1, [0]]
        if (cmp == true) cmp = Cmp.defaultDesc(a[0])
        if (!cmp) cmp = Cmp.default(a[0])
        var max = a[0]
        var iMax = [0]
        for (i in 1...count) {
            var m = cmp.call(a[i], max)
            if (m > 0) {
                max = a[i]
                iMax = [i]
            } else if (m == 0) {
                iMax.add(i)
            }
        }
        return [max, iMax.count, iMax]
    }

    // Private helper function for 'quick' method.
    static partition_(a, left, right, pivotIndex, cmp) {
        var pivotValue = a[pivotIndex]
        a[pivotIndex] = a[right]
        a[right] = pivotValue
        var storeIndex = left
        var i = left
        while (i < right) {
            if (cmp.call(a[i], pivotValue) < 0) {
                var t = a[storeIndex]
                a[storeIndex] = a[i]
                a[i] = t
                storeIndex = storeIndex + 1
            }
            i = i + 1
        }
        var temp = a[right]
        a[right] = a[storeIndex]
        a[storeIndex] = temp
        return storeIndex
    }

    // Finds the 'k'th smallest element of an unsorted list according to 'cmp'
    // using the 'quickselect' algorithm. 'k' is zero based.
    static quick(a, k, cmp) {
        Sort.isList_(a)
        if (k.type != Num || !k.isInteger || k < 0) {
            Fiber.abort("'k' must be a non-negative integer")
        }
        var count = a.count
        if (count <= k) Fiber.abort("The list is too small.")
        if (count == 1) return a[0]
        if (cmp == true) cmp = Cmp.defaultDesc(a[0])
        if (!cmp) cmp = Cmp.default(a[0])
        var left = 0
        var right = count - 1
        while (true) {
            if (left == right) return a[left]
            var pivotIndex = ((left + right)/2).floor
            pivotIndex = partition_(a, left, right, pivotIndex, cmp)
            if (k == pivotIndex) {
                return a[k]
            } else if (k < pivotIndex) {
                right = pivotIndex - 1
            } else {
                left = pivotIndex + 1
            }
        }
    }

    // Convenience versions of the above which use default values for the 'cmp' parameter.
    static all(a, value)   { all(a, value, false)   }
    static first(a, value) { first(a, value, false) }
    static last(a, value)  { last(a, value, false)  }
    static lowest(a)       { lowest(a, false)       }
    static highest(a)      { highest(a, false)      }
    static quick(a, k)     { quick(a, k, false)     }

    // Finds the median element(s) of a sorted list.
    // Returns a list of three items:
    // The first item is a list of the median element(s).
    // The second item is the number of median element(s).
    // The third item is the range of indices at which the median element(s) occur.
    static median(a) {
        Sort.isList_(a)
        var c = a.count
        if (c == 0) Fiber.abort("An empty list does not have a median element.")
        var hc = (c/2).floor
        return (c%2 == 1) ? [[a[hc]], 1, hc..hc] : [[a[hc-1], a[hc]], 2, hc-1..hc]
    }
}

// Type aliases for classes in case of any name clashes with other modules.
var Cmp_Cmp  = Cmp
var Cmp_Sort = Sort
var Cmp_Find = Find
var Cmp_Comparable = Comparable // in case imported indirectly
