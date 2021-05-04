// url: https://rosettacode.org/wiki/Category:Wren-set
// source: https://rosettacode.org/mw/index.php?title=Category_talk:Wren-set&action=edit&section=1
// file: set
// name: Wren-set
// author: PureFox
// license: MIT

/* Module "set.wren" */

/* Set represents an unordered collection of unique objects. It is implemented as a Map
   whose keys are the elements of the set but whose values are always 1. Consequently, only
   element types which can be Map keys are supported and iteration order is undefined.
*/
class Set is Sequence {
    // Constructs a new empty Set object.
    construct new() {
        _m = {}
    }

    // Constructs a new Set object and adds the elements of a sequence to it.
    construct new(seq) {
        if (!(seq is Sequence)) Fiber.abort("Argument must be a Sequence.")
        _m = {}
        for (e in seq) _m[e] = 1
    }

    // Returns the number of elements in the current instance.
    count { _m.count }

    // Returns whether or not the current instance is empty.
    isEmpty { _m.count == 0 }

    // Adds an element 'e' to the current instance. If the set already contains 'e'
    // the set remains unchanged.
    add(e) {
        _m[e] = 1
    }

    // Adds all the elements of a sequence to the current instance. Duplicates are
    // effectively ignored.
    addAll(seq) {
        if (!(seq is Sequence)) Fiber.abort("Argument must be a Sequence.")
        for (e in seq) _m[e] = 1
    }

    // Merges all the elements of another Set object into the current instance.
    // Duplicates are effectively ignored. A specialized version of 'addAll'.
    merge(other) {
        if (other.type != Set) Fiber.abort("Argument must be a Set.")
        for (e in other) _m[e] = 1
    }

    // Removes an element 'e' from the current instance if it exists.
    // Returns the element removed or null otherwise.
    remove(e) { _m.remove(e) ? e : null }

    // Removes all elements of a sequence from the current instance if they exist.
    removeAll(seq) {
        if (!(seq is Sequence)) Fiber.abort("Argument must be a Sequence.")
        for (e in seq) _m.remove(e)
    }

    // Removes 'removal' and adds 'addition'.
    replace(removal, addition) {
        remove(removal)
        add(addition)
    }

    // Removes 'removals' and adds 'additions'.
    replaceAll(removals, additions) {
        removeAll(removals)
        addAll(additions)
    }

    // Clears the current instance.
    clear() { _m.clear() }

    // Returns whether or not the current instance contains an element 'e'.
    contains(e) { _m.containsKey(e) }

    // Returns whether or not the current instance contains any element of a sequence.
    containsAny(seq) {
        if (!(seq is Sequence)) Fiber.abort("Argument must be a Sequence.")
        for (e in seq) {
            if (_m.containsKey(e)) return true
        }
        return false
    }

    // Returns whether or not the current instance contains all elements of a sequence.
    containsAll(seq) {
        if (!(seq is Sequence)) Fiber.abort("Argument must be a Sequence.")
        for (e in seq) {
            if (!_m.containsKey(e)) return false
        }
        return true
    }

    // Returns whether or not the current instance contains no elements of a sequence.
    containsNone(seq) { !containsAny(seq) }

    // Copies the elements of the current instance to a List and returns the List.
    toList { _m.keys.toList }

    // Copies the elements of the current instance to a Map, with a value of 1, and
    // returns the Map.
    toMap {
        var m = {}
        for (k in _m.keys) m[k] = 1
        return m
    }

    // Copies the elements of the current instance to a new Set object.
    copy() {
        var s = Set.new()
        for (k in _m.keys) s.add(k)
        return s
    }

    // Copies all unique elements of this instance and another Set to a new Set object.
    union(other) {
        if (other.type != Set) Fiber.abort("Argument must be a Set.")
        var s = Set.new()
        for (k in _m.keys) s.add(k)
        for (k in other) s.add(k)
        return s
    }

    // Copies all elements which this instance and another Set have in common
    // to a new Set object.
    intersect(other) {
        if (other.type != Set) Fiber.abort("Argument must be a Set.")
        var s = Set.new()
        for (k in _m.keys) {
           if (other.contains(k)) s.add(k)
        }
        return s
    }

    // Copies all elements of this instance which are not elements of another Set
    // to a new Set object.
    except(other) {
        if (other.type != Set) Fiber.abort("Argument must be a Set.")
        var s = Set.new()
        for (k in _m.keys) {
            if (!other.contains(k)) s.add(k)
        }
        return s
    }

    // Returns whether or not this instance is a subset of another Set.
    subsetOf(other) {
        if (other.type != Set) Fiber.abort("Argument must be a Set.")
        if (_m.count > other.count) return false
        for (k in this) {
            if (!other.contains(k)) return false
        }
        return true
    }

    // Returns whether or not this instance is a proper subset of another Set.
    properSubsetOf(other) {
        if (other.type != Set) Fiber.abort("Argument must be a Set.")
        if (_m.count >= other.count) return false
        for (k in this) {
            if (!other.contains(k)) return false
        }
        return true
    }

    // Returns whether or not this instance is a superset of another Set.
    // A specialized version of 'containsAll'.
    supersetOf(other) {
        if (other.type != Set) Fiber.abort("Argument must be a Set.")
        if (_m.count <= other.count) return false
        for (k in other) {
            if (!this.contains(k)) return false
        }
        return true
    }

    // Returns whether or not the elements of this instance are the same
    // as the elements of another Set and vice versa.
    ==(other) {
       if (other.type != Set) Fiber.abort("Argument must be a Set.")
       if (_m.count != other.count) return false
       for (k in this) {
            if (!other.contains(k)) return false
       }
       return true
    }

    // Returns whether or not the elements of this instance are not all the same
    // as the elements of another Set and vice versa.
    !=(other) { !(this == other) }

    // Returns the string representation of the current instance enclosed in angle brackets
    // to distinguish from Maps and Lists.
    toString {
        var l = _m.keys.toList
        if (l.count == 0) return "<>"
        return "<" + _m.keys.toList.toString[1..-2] + ">"
    }

    // Iterator protocol methods, using keys of the internal map only.
    iterate(iter) { _m.keys.iterate(iter) }

    iteratorValue(iter) { _m.keys.iteratorValue(iter) }
}

/* Bag represents an unordered collection of objects which may be repeated. It is
   implemented as a Map whose keys are the distinct elements of the bag but whose values are
   the numbers of each such element. Consequently, only element types which can be Map keys
   are supported and iteration order is undefined.
*/
class Bag is Sequence {
    // Constructs a new empty Bag object.
    construct new() {
        _m = {}
    }

    // Constructs a new Bag object and adds the elements of a sequence to it.
    construct new(seq) {
        if (!(seq is Sequence)) Fiber.abort("Argument must be a Sequence.")
        _m = {}
        for (e in seq) _m[e] = _m.containsKey(e) ? _m[e] + 1 : 1
    }

    // Returns the number of distinct elements in the current instance.
    distinctCount { _m.count }

    // Returns the total number of elements in the current instance.
    count {
        var total = 0
        for (k in _m.keys) total = total + _m[k]
        return total
    }

    // Returns whether or not the current instance is empty.
    isEmpty { _m.count == 0 }

    // Adds an element 'e' to the current instance. If the set already contains 'e'
    // its value is incremented.
    add(e) {
        _m[e] = _m.containsKey(e) ? _m[e] + 1 : 1
    }

    // Adds all the elements of a sequence to the current instance incrementing their
    // values if they're already present.
    addAll(seq) {
        if (!(seq is Sequence)) Fiber.abort("Argument must be a Sequence.")
        for (e in seq) _m[e] = _m.containsKey(e) ? _m[e] + 1 : 1
    }

    // Adds an element 'e' with a value of 'v' to the current instance. If the bag
    // already contains 'e' its value is increased accordingly.
    add(e, v) {
        if (v.type != Num || !v.isInteger || v < 1) {
            Fiber.abort("Value must be a positive integer.")
        }
        _m[e] = _m.containsKey(e) ? _m[e] + v : v
    }

    // Adds an element 'e' with a value of 'v', presented in the form [e, v], to the
    // current instance. If the bag already contains 'e' its value is increased accordingly.
    addPair(p) {
        if (p.type != List || p.count != 2) {
            Fiber.abort("Argument must be an [element, value] pair.")
        }
        add(p[0], p[1])
    }

    // Reduces the value of an element 'e' of the current instance by 'r' if its exists.
    // If this would reduce the value below 1, 'e' is removed completely.
    reduce(e, r) {
        if (r.type != Num || !r.isInteger || r < 1) {
            Fiber.abort("Reduction must be a positive integer.")
        }
        if (_m.containsKey(e)) {
            var v = _m[e] - r
            if (v < 1) {
                _m.remove(e)
            } else {
                _m[e] = v
            }
        }
    }

    // Merges all the elements of another Bag object into the current instance
    // increasing values where necessary. A specialized version of 'addAll'.
    merge(other) {
        if (other.type != Bag) {
            Fiber.abort("Argument must be a Bag.")
        }
        for (e in other.distinct) _m[e] = _m.containsKey(e) ? _m[e] + other[e] : other[e]
    }

    // Removes an element 'e' from the current instance, if it exists and whether distinct
    // or not. Returns the element removed and its value or null otherwise.
    remove(e) {
        var r = _m.remove(e)
        return r ? [e, _m[e]] : null
    }

    // Removes all elements of a sequence from the current instance if they exist
    // and whether distinct or not.
    removeAll(seq) {
        if (!(seq is Sequence)) Fiber.abort("Argument must be a Sequence.")
        for (e in seq) _m.remove(e)
    }

    // Removes 'removal' and adds 'addition'.
    replace(removal, addition) {
        remove(removal)
        add(addition)
    }

    // Removes 'removals' and adds 'additions'.
    replaceAll(removals, additions) {
        removeAll(removals)
        addAll(additions)
    }

    // Clears the current instance.
    clear() { _m.clear() }

    // Returns whether or not the current instance contains an element 'e'.
    contains(e) { _m.containsKey(e) }

    // Returns whether or not the current instance contains any element of a sequence.
    containsAny(seq) {
        if (!(seq is Sequence)) Fiber.abort("Argument must be a Sequence.")
        for (e in seq) {
            if (_m.containsKey(e)) return true
        }
        return false
    }

    // Returns whether or not the current instance contains all distinct elements of
    // a sequence.
    containsAll(seq) {
        if (!(seq is Sequence)) Fiber.abort("Argument must be a Sequence.")
        for (e in seq) {
            if (!_m.containsKey(e)) return false
        }
        return true
    }

    // Returns whether or not the current instance contains no elements of a sequence.
    containsNone(seq) { !containsAny(seq) }

    // Returns a sequence of all distinct elements in the current instance.
    distinct { _m.keys }

    // Copies the elements of the current instance to a List and returns the List.
    // An element with value 'v' is repeated 'v' times.
    toList {
        var l = []
        for (k in _m.keys) {
            var v = _m[k]
            for (i in 1..v) l.add(k)
        }
        return l
    }

    // Copies the elements of the current instance to a Map, with their values, and
    // returns the Map.
    toMap {
        var m = {}
        for (k in _m.keys) m[k] = _m[k]
        return m
    }

    // Copies the elements of the current instance to a new Bag object.
    copy() {
        var b = Bag.new()
        for (k in _m.keys) b.add(k, _m[k])
        return b
    }

    // Copies all elements of this instance and another Bag to a new Bag object.
    union(other) {
        if (other.type != Bag) {
            Fiber.abort("Argument must be a Bag.")
        }
        var b = Bag.new()
        for (k in _m.keys) b.add(k, _m[k])
        for (k in other.distinct) b.add(k, other[k])
        return b
    }

    // Copies all elements which this instance and another Bag have in common
    // to a new Bag object.
    intersect(other) {
        if (other.type != Bag) {
            Fiber.abort("Argument must be a Bag.")
        }
        var b = Bag.new()
        for (k in _m.keys) {
            if (other.contains(k)) {
                var v1 = _m[k]
                var v2 = other[k]
                var v3 = (v1 < v2) ? v1 : v2
                b.add(k, v3)
            }
        }
        return b
    }

    // Copies all elements of this instance which are not elements of another Bag
    // to a new Bag object.
    except(other) {
        if (other.type != Bag) {
            Fiber.abort("Argument must be a Bag.")
        }
        var b = Bag.new()
        for (k in _m.keys) {
            if (!other.contains(k)) {
                b.add(k, _m[k])
            } else {
                var v1 = _m[k]
                var v2 = other[k]
                if (v1 > v2) b.add(k, v1 - v2)
            }
        }
        return b
    }

    // Returns whether or not this instance is a subbag of another Bag.
    subbagOf(other) {
        if (other.type != Bag) Fiber.abort("Argument must be a Bag.")
        if (_m.count > other.distinctCount) return false
        for (k in _m.keys) {
            if (!other.contains(k)) return false
            var v1 = _m[k]
            var v2 = other[k]
            if (v1 > v2) return false
        }
        return true
    }

    // Returns whether or not this instance is a proper subbag of another Bag.
    properSubbagOf(other) {
        if (other.type != Bag) Fiber.abort("Argument must be a Bag.")
        if (_m.count >= other.distinctCount) return false
        for (k in _m.keys) {
            if (!other.contains(k)) return false
            var v1 = _m[k]
            var v2 = other[k]
            if (v1 >= v2) return false
        }
        return true
    }

    // Returns whether or not this instance is a superbag of another Bag.
    // A specialized version of 'containsAll'.
    superbagOf(other) {
        if (other.type != Bag) Fiber.abort("Argument must be a Bag.")
        if (_m.count <= other.distinctCount) return false
        for (k in other.distinct) {
            if (!_m.containsKey(k)) return false
            var v1 = _m[k]
            var v2 = other[k]
            if (v1 < v2) return false
        }
        return true
    }

    // Returns the value corresponding to 'e' or null if it doesn't exist.
    [e] { _m.containsKey(e) ? _m[e] : null }

    // Sets the value for 'e' creating a new one with that value if it doesn't exist.
    // Setting its value to 0 removes 'e' from the bag.
    [e]=(v) {
        if (v.type != Num || !v.isInteger || v < 0) {
            Fiber.abort("Value must be a non-negative integer.")
        }
        if (_m.containsKey(e)) {
            if (v > 0) {
                _m[e] = v
            } else {
                _m.remove(e)
            }
        } else if (v > 0) {
            _m[e] = v
        }
    }

    // Returns whether or not the elements of this instance are the same
    // as the elements of another Bag and vice versa.
    ==(other) {
       if (other.type != Bag) Fiber.abort("Argument must be a Bag.")
       if (_m.count != other.distinctCount) return false
       for (k in _m.keys) {
            if (!other.contains(k)) return false
            var v1 = _m[k]
            var v2 = other[k]
            if (v1 != v2) return false
       }
       return true
    }

    // Returns whether or not the elements of this instance are not all the same
    // as the elements of another Bag and vice versa.
    !=(other) { !(this == other) }

    // Returns the string representation of the current instance enclosed in angle brackets
    // to distinguish from Maps and List.
    toString {
        if (_m.count == 0) return "<>"
        return "<" + _m.toString[1..-2] + ">"
    }

    // Iterator protocol methods, using the map entries of the internal map.
    iterate(iter) { _m.iterate(iter) }

    iteratorValue(iter) { _m.iteratorValue(iter) }
}

// Type alias for class in case of a name clash with other modules.
var Set_Set = Set
var Set_Bag = Bag
