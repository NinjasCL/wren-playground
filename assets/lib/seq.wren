// url: https://rosettacode.org/wiki/Category:Wren-seq
// source: https://rosettacode.org/mw/index.php?title=Category_talk:Wren-seq&action=edit&section=1
// file: seq
// name: Wren-seq
// author: PureFox
// license: MIT

/* Module "seq.wren" */

import "/trait" for Cloneable, CloneableSeq

/* Seq supplements the Sequence class with some other operations on sequences. */
class Seq {
    // Private helper method to check that 's' is a sequence and throw an error otherwise.
    static isSeq_(s) { (s is Sequence) ? true : Fiber.abort("Argument must be a sequence.") }

    // Returns true if a sequence contains ALL the elements of a sequence, false otherwise.
    static containsAll(s, elements) {
        isSeq_(s)
        for (element in elements) {
            if (!s.contains(element)) return false
        }
        return true
    }

    // Returns a new 'lazy' sequence that iterates only the last 'count' elements of
    // the original sequence.
    static takeLast(s, count) {
        isSeq_(s)
        if (!(count is Num) || !count.isInteger || count < 0) {
            Fiber.abort("Count must be a non-negative integer.")
        }
        count = s.count - count
        if (count <= 0) count = 0
        return  s.skip(count)
    }

    // Returns a new 'lazy' sequence that skips the last 'count' elements of
    // the original sequence.
    static skipLast(s, count) {
        isSeq_(s)
        if (!(count is Num) || !count.isInteger || count < 0) {
            Fiber.abort("Count must be a non-negative integer.")
        }
        count = a.count - count
        if (count <= 0) count = 0
        return  a.take(count)
    }
}

/* Lst supplements the List class with various other operations on lists. */
class Lst {
    // Private helper method to check that 'a' is a list and throw an error otherwise.
    static isList_(a) { (a is List) ? true : Fiber.abort("Argument must be a list.") }

    // Private helper method to check whether a start index is valid.
    static checkStart_(a, start) {
        if (start.type != Num || !start.isInteger) Fiber.abort("Start must be an integer.")
        var c = a.count
        if (start >= c || start < -c) Fiber.abort("Start is out of bounds.")
    }

    // Searches an unsorted list linearly for a particular value from a start index.
    // If the start index is negative, it counts backwards from the end of the list.
    // Returns a list of three items:
    // The first item is a Bool indicating whether the value was found.
    // The second item is the number of times the value was found.
    // The third item is a list of indices at which the value was found.
    static indicesOf(a, value, start) {
        isList_(a)
        checkStart_(a, start)
        var count = a.count
        var indices = []
        if (count == 0) return [false, 0, indices]
        if (start < 0) start = count + start
        for (i in start...count) {
            if (a[i] == value) indices.add(i)
        }
        if (indices.isEmpty) return [false, 0, indices]
        return [true, indices.count, indices]
    }

    // Works similarly to 'indicesOf' but only returns the index of the first match
    // or -1 if there were no matches at all.
    static indexOf(a, value, start) {
        isList_(a)
        checkStart_(a, start)
        return indexOf_(a, value, start)
    }

    // Private helper method for 'indexOf' which avoids type and bounds checks.
    static indexOf_(a, value, start) {
        var count = a.count
        if (count == 0) return -1
        if (start < 0) start = count + start
        for (i in start...count) {
            if (a[i] == value) return i
        }
        return -1
    }

    // Returns the index of the last occurrence of 'value' in 'a' or -1 if no matches.
    static lastIndexOf(a, value) {
        if (a.count == 0) return 0
        for (i in a.count-1..0) {
            if (a[i] == value) return i
        }
        return -1
    }

    // Works similarly to 'indexOf' but returns the index of the first match
    // of ANY of a sequence of values or -1 if none of them matched.
    static indexOfAny(a, values, start) {
        isList_(a)
        checkStart_(a, start)
        var i
        for (value in values) {
            if ((i = indexOf_(a, value, start)) >= 0) return i
        }
        return -1
    }

    // Convenience versions of the above which use a value for 'start' of 0.
    static indicesOf(a, value)   { indicesOf(a, value, 0)   }
    static indexOf(a, value)     { indexOf(a, value, 0)     }
    static indexOfAny(a, values) { indexOfAny(a, values, 0) }

    // Exchanges the elements at indices 'i' and 'j' of 'a'.
    static exchange(a, i, j) {
        isList_(a)
        if (i == j) return
        var t = a[i]
        a[i] = a[j]
        a[j] = t
    }

    // Returns true if 'a' contains ALL the values of a sequence, false otherwise.
    static containsAll(a, values) {
        isList_(a)
        return Seq.containsAll(a, values)
    }

    // Returns true if 'a' contains ANY of the values, false otherwise.
    static containsAny(a, values) { indexOfAny(a.values) >= 0 }

    // Returns true if 'a' contains NONE of the values, false otherwise.
    static containsNone(a, values) { !contains.any(a, values) }

    // Groups each individual element of a list by count and indices, preserving order.
    // Returns a list of three element lists, one for each individual element.
    // The content of each three element list is as follows:
    // The first item is the individual element itself.
    // The second item is the number of times the individual element was found.
    // The third item is a list of indices at which the individual element was found.
    static individuals(a) {
        isList_(a)
        var c = a.count
        var m = {}
        var g = []
        var ix = 0
        for (i in 0...c) {
            if (!m[a[i]]) {
                g.add([a[i], 1, [i]])
                m[a[i]] = ix
                ix = ix + 1
            } else {
                var v = g[m[a[i]]]
                v[1] = v[1] + 1
                v[2].add(i)
            }
        }
        return g
    }

    // Groups each element of a list by the result of applying a function to it preserving order.
    // Returns a two element list for each distinct result as follows:
    // The first element is the result itself.
    // The second element is a list of three element lists consisting of:
    // A distinct element in the group.
    // The number of times that element occurs.
    // The indices at which it occurs.
    static groups(a, fn) {
        isList_(a)
        var c = a.count
        var m = {}
        var g = []
        var ix = 0
        for (i in 0...c) {
            var k = fn.call(a[i])
            if (!m[k]) {
                g.add([k, [[a[i], 1, [i]]]])
                m[k] = ix
                ix = ix + 1
            } else {
                var v = g[m[k]]
                var existing = false
                for (e in v[1]) {
                   if (e[0] == a[i]) {
                        e[1] = e[1] + 1
                        e[2].add(i)
                        existing = true
                        break
                   }
                }
                if (!existing) v[1].add([a[i], 1, [i]])
            }
        }
        return g
    }

    // Splits a list into two partitions depending on whether an element
    // satisfies a predicate function or not and preserving order.
    // Returns a two element list of these partitions, the 'true' partition first.
    static partitions(a, pf) {
        isList_(a)
        var res = [[], []]
        a.each { |e| pf.call(e) ? res[0].add(e) : res[1].add(e) }
        return res
    }

    // Finds those elements of a list which occur the most times, preserving order.
    // Returns a list of three element lists, one for each such element.
    // The format of each three element list is similar to the 'lowest' method.
    static modes(a) {
        var gr = individuals(a)
        var max = gr.reduce(0) { |acc, g| (g[1] > acc) ? g[1] : acc }
        var res = []
        for (g in gr) {
            if (g[1] == max) res.add(g)
        }
        return res
    }

    // Finds all distinct elements of a list, preserving order.
    // Similar to 'individuals' but only returns a list of the distinct elements.
    static distinct(a) {
        var gr = individuals(a)
        var res = []
        for (g in gr) res.add(g[0])
        return res
    }

    // Returns true if all elements of a list are the same, false otherwise.
    static allSame(a) { distinct(a).count == 1 }

    // Splits a list into chunks of not more than 'size' elements.
    // Returns a list of these chunks, preserving order.
    static chunks(a, size) {
        isList_(a)
        var c = a.count
        if (!(size is Num && size.isInteger && size > 0)) {
            Fiber.abort("Size must be a positive integer.")
        }
        if (size >= c) return [a]
        var res = []
        var n = (c/size).floor
        var final = c % size
        var first = 0
        var last  = first + size - 1
        for (i in 0...n) {
            res.add(a[first..last])
            first = last + 1
            last  = first + size - 1
        }
        if (final > 0) res.add(a[first..-1])
        return res
    }

    // Replaces all occurrences of 'old' by 'swap' in 'a' and returns ['old', 'swap'].
    static replace(a, old, swap) {
        isList_(a)
        for (i in 0...a.count) {
            if (a[i] == old) a[i] = swap
        }
        return [old, swap]
    }

    // Returns a clone of 'a' by recursively cloning any elements which are
    // themselves lists. However, at the scalar level elements cannot be deeply cloned
    // unless they are either immutable or inherit from the Cloneable trait.
    static clone(a) {
        isList_(a)
        var res = []
        clone_(res, a)
        return res
    }

    // Private worker method for 'clone' method.
    static clone_(res, a) {
        for (e in a) {
            res.add ((e is List) ? clone(e) :
                     (e is Cloneable || e is CloneableSeq) ? e.clone() : e)
        }
    }

    // Creates and returns a new FrozenList from 'a'.
    static freeze(a) { FrozenList.new(a) }

    // Returns a list of scalar elements by recursively flattening any elements
    // which are themselves lists.
    static flatten(a) {
        isList_(a)
        var res = []
        flatten_(res, a)
        return res
    }

    // Private worker method for 'flatten' method.
    static flatten_(res, a) {
        for (e in a) {
            if (e is List) flatten_(res, e) else res.add(e)
        }
    }

    // Applies a function to each element of a list and then flattens and returns the results.
    static flatMap(a, fn) {
        var res = a.map { |e| fn.call(e) }
        flatten(res)
        return res
    }

    // Returns a list of two element lists consisting of each element of a list
    // and the result of applying a function to that element.
    static associate(a, af) { a.map { |e| [e, af.call(e)] } }

    // Returns a list of two element lists consisting of each element of 'a1' and
    // the corresponding element of 'a2' with the same index. If the two lists are of
    // unequal length, then only pairs which have a common index are returned.
    static zip(a1, a2) {
        isList_(a1)
        isList_(a2)
        var c1 = a1.count
        var c2 = a2.count
        var len = (c1 < c2) ? c1 : c2
        var res = []
        for (i in 0...len) res.add([a1[i], a2[i]])
        return res
    }

    // Performs the reverse operation to 'zip' returning the two unzipped lists.
    static unzip(a) {
        isList_(a)
        var a1 = []
        var a2 = []
        for (t in e) {
            a1.add(t[0])
            a2.add(t[1])
        }
        return [a1, a2]
    }
}

/* FrozenList represents a List which cannot be changed after it has been constructed
   provided the underlying scalar type(s) are immutable or inherit from the Cloneable trait.
*/
class FrozenList is CloneableSeq {
    // Constructs a new frozen list from a List.
    construct new(a) {
        if (!(a is List)) Fiber.abort("Argument must be a list.")
        _a = Lst.clone(a) // clone it so it (hopefully) cannot be mutated externally
    }

    // Returns the number of elements in the frozen list.
    count { _a.count }

    // Clones this frozen list.
    clone() { Lst.freeze(_a) }

    // Private helper method which clones an element before allowing access to it.
    cloned_(e) { (e is List) ? Lst.clone(e) :
                 (e is Cloneable || e is CloneableSeq) ? e.clone() : e }

    // Gets the element at 'index.' If index is negative, it counts backwards from the end of
    // the frozen list where -1 is the last element.
    [index] { cloned_(_a[index]) }

    // Iterator protocol methods.
    iterate(iterator) { _a.iterate(iterator) }
    iteratorValue(iterator) { cloned_(_a.iteratorValue(iterator)) }

    // Returns the string representation of the underlying list.
    toString { _a.toString }
}

/* Stack represents a LIFO list of values. */
class Stack is CloneableSeq {
    // Constructs a new empty stack.
    construct new() { _stack = [] }

    // Returns the number of elements in the stack.
    count { _stack.count }

    // Returns whether or not the stack is empty.
    isEmpty { count == 0 }

    // Removes all elements from the stack.
    clear() { _stack.clear() }

    // Returns the last item on the stack without removing it.
    // Returns null if the stack is empty.
    peek() { (!isEmpty) ? _stack[-1] : null }

    // Adds 'item' to the stack and returns it.
    push(item) { _stack.add(item) }

    // Adds a sequence of 'items' (in order) to the stack and returns them.
    pushAll(items) { _stack.addAll(items) }

    // Removes the last item from the stack and returns it.
    // Returns null if the stack is empty.
    pop() {
        var item = peek()
        if (item != null) {
            _stack.removeAt(-1)
        }
        return item
    }

    // Clones the stack.
    clone() {
        var s = Stack.new()
        s.pushAll(Lst.clone(_stack))
        return s
    }

    // Iterator protocol methods.
    iterate(iterator) { _stack.iterate(iterator) }
    iteratorValue(iterator) { _stack.iteratorValue(iterator) }

    // Returns the string representation of the underlying list.
    toString { _stack.toString }
}

// Type aliases for classes in case of any name clashes with other modules.
var Seq_Seq = Seq
var Seq_Lst = Lst
var Seq_FrozenList = FrozenList
var Seq_Stack = Stack
var Seq_Cloneable = Cloneable // in case imported indirectly
var Seq_CloneableSeq = CloneableSeq // ditto
