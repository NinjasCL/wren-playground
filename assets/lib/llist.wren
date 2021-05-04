// url: https://rosettacode.org/wiki/Category:Wren-llist
// source: https://rosettacode.org/mw/index.php?title=Category_talk:Wren-llist&action=edit&section=2
// file: llist
// name: Wren-llist
// author: PureFox
// license: MIT

/* Module "llist.wren" */

/* Node is a building block for a singly linked list. As such it consists of two fields:
   a data member, which can be of any type, and a link to the next Node_ object.
*/
class Node {
    // Constructs a new Node object.
    construct new(data) {
        _data = data
        _next = null
    }

    // Public properties.
    data { _data }
    data=(d) { _data = d }

    next { _next }
    next=(n) {
        _next = (n.type == Node || n == null) ? n : Fiber.abort("Invalid argument.")
    }

    // Private setters, no checks.
    next_=(n) { _next = n }
    prev_=(n) { _prev = n }

    // Returns the string representation of this instance.
    toString { _data.toString }
}

/* LinkedList represents a singly linked list of Node_ objects.
   The 'elements' of the list generally refer to their data members,
   not the Nodes themselves. Indexing operations support negative
   indices which count backwards from the end of the list.
*/
class LinkedList is Sequence {

    // Constructs a new, empty LinkedList object.
    construct new() {
        _count = 0
        _head = null
        _tail = null
    }

    // Constructs a new LinkedList object and adds the elements of a sequence to it.
    construct new(a) {
        _count = 0
        _head = null
        _tail = null
        addAll(a)
    }

    // Creates a new LinkedList with 'size' elements, all set to 'd'.
    static filled(size, d) {
        if (size.type != Num || !size.isInteger || size < 0) {
            Fiber.abort("Size cannot be negative.")
        }
        var ll = LinkedList.new()
        if (size == 0) return ll
        for (i in 1..size) ll.add(d)
        return ll
    }

    // Copies the current instance to a new LinkedList.
    copy() { LinkedList.new(this) }

    // Basic properties.
    head { _head ? _head.data : null }  // returns the first element
    tail { _tail ? _tail.data : null }  // returns the last element

    count { _count }                    // returns the number of elements

    // Returns whether or not the current instance is empty.
    isEmpty { _count == 0 }

    // Adds an element at the tail of the current instance and returns it.
    add(d) {
        var node = Node.new(d)
        if (!_head) {
            _head = node
            _head.next_ = null
            _count = 1
        } else {
            var n = _tail
            n.next_ = node
            node.next_ = null
            _count = _count + 1
        }
        _tail = node
       return d
    }

    // Adds a sequence of elements at the tail of the current instance and returns them.
    addAll(a) {
        if (!(a is Sequence)) Fiber.abort("Argument must be a Sequence.")
        for (e in a) add(e)
        return a
    }

    // Inserts an element at the head of the current instance and returns it.
    prepend(d) { insert_(0, d) }

    // Inserts a sequence of elements at the head of the current instance and returns them.
    prependAll(a) {
        if (!(a is Sequence)) Fiber.abort("Argument must be a Sequence.")
        var i = 0
        for (e in a) {
            insert_(i, e)
            i = i + 1
        }
        return a
    }

    // Private helper method to check whether an index is valid.
    checkIndex_(index, inc, s) {
        if (index.type != Num || !index.isInteger) Fiber.abort("%(s) must be an integer.")
        var c = _count + inc
        if (index >= c || index < -c) Fiber.abort("%(s) is out of bounds.")
    }

    // Inserts an element at a specified index of the current instance
    // and returns the inserted element.
    insert(index, d) {
        checkIndex_(index, 1, "Index")
        return insert_(index, d)
    }

    // Private helper method for 'insert' which avoids type and bounds checks.
    insert_(index, d) {
        if (index <  0) index = _count + index + 1
        if (index == _count) {
            add(d)
            return d
        }
        var node = Node.new(d)
        if (index == 0) {
            node.next_ = _head
            _head = node
        } else {
            var n = _head
            for (i in 1...index) n = n.next
            node.next_ = n.next
            n.next_ = node
        }
        _count = _count + 1
        return d
    }

    // Inserts an element 'e' immediately after the first occurrence of an element 'd'
    // in the current instance and returns the inserted element. Returns null if 'd'
    // not found.
    insertAfter(d, e) {
        var ix = indexOf_(d, 0)
        return (ix >= 0) ? insert_(ix+1, e) : null
    }

    // Inserts an element 'e' immediately before the first occurrence of an element 'd'
    // in the current instance and returns the inserted element. Returns null if 'd'
    // not found.
    insertBefore(d, e) {
        var ix = indexOf_(d, 0)
        return (ix >= 0) ? insert_(ix, e) : null
    }

    // Removes the element at the specified index of the current instance and returns it.
    removeAt(index) {
        checkIndex_(index, 0, "Index")
        return removeAt_(index)
    }

    // Private helper method for 'removeAt' which avoids type and bounds checks.
    removeAt_(index) {
        if (index < 0) index = _count + index
        var removed
        if (index == 0) {
            removed = _head.data
            _head = _head.next
        } else {
            var n = _head
            var pred = null
            for (i in 0...index) {
                pred = n
                n = n.next
            }
            removed = n.data
            pred.next_ = n.next
        }
        _count = _count - 1
        return removed
    }

    // Removes the first 'k' elements of the current instance and returns a list of them.
    removeFirst(k) {
        if (k.type != Num || !k.isInteger || k < 0) {
            Fiber.abort("Argument must be a non-negative integer.")
        }
        if (k == 0) return []
        if (k >= _count) {
            var removed = this.toList
            clear()
            return removed
        }
        var removed = this.take(k).toList
        var n = _head
        for (i in 1..k) n = n.next
        _head = n
        _count = _count - k
        return removed
    }

    // Removes the last 'k' elements of the current instance and returns a list of them.
    removeLast(k) {
        if (k.type != Num || !k.isInteger || k < 0) {
            Fiber.abort("Argument must be a non-negative integer.")
        }
        if (k == 0) return []
        if (k >= _count) {
            var removed = this.toList
            clear()
            return removed
        }
        var removed = this.skip(_count - k).toList
        var n = _head
        for (i in 1..._count-k) n = n.next
        _tail = n
        _tail.next_ = null
        _count = _count - k
        return removed
    }

    // Removes all occurrences of the element 'd' from the current instance
    // and returns the number of occurrences.
    remove(d) {
        var ixs = indicesOf_(d, 0)[-1..0]
        if (ixs.count > 0) {
            for (ix in ixs) {
                removeAt_(ix)
            }
        }
        return ixs.count
    }

    // Clears the current instance of all its elements.
    clear() {
        _count = 0
        _head = null
        _tail = null
    }

    // Replaces all occurrences of the element 'd' in the current instance
    // by 'e' and returns the number of occurrences.
    replace(d, e) {
        if (d == e) return 0
        var ixs = indicesOf_(d, 0)
        if (ixs.count > 0) {
            for (ix in ixs) {
                this[ix] = e
            }
        }
        return ixs.count
    }

    // Exchanges the elements at indices 'i' and 'j' of the current instance.
    exchange(i, j) {
        if (i == j) return
        var t = this[i]
        this[i] = this[j]
        this[j] = t
    }

    // Returns the index of the first occurrence of 'd' in the current instance starting
    // from index 'start'.
    indexOf(d, start) {
        checkIndex_(start, 0, "Start")
        return indexOf_(d, start)
    }

    // Private helper method for 'indexOf' which avoids type and bounds checks.
    indexOf_(d, start) {
        if (start < 0) start = _count + start
        var seq = (start == 0) ? this : this.skip(start)
        var i = start
        for (e in seq) {
            if (e == d) return i
            i = i + 1
        }
        return -1
    }

    // Convenience version of 'indexOf' which starts from 0.
    indexOf(d) { indexOf(d, 0) }

    // Returns the index of the first occurrence of any element of the sequence 'ds'
    // in the current instance starting from index 'start'.
    indexOfAny(ds, start) {
        checkIndex_(start, 0, "Start")
        if (start < 0) start = _count + start
        if (!(ds is Sequence)) Fiber.abort("First argument must be a Sequence.")
        var i
        for (d in ds) {
            if ((i = indexOf_(d, start)) >= 0) return i
        }
        return -1
    }

    // Convenience version of 'indexOfAny' which starts from 0.
    indexOfAny(ds) { indexOf(ds, 0) }

    // Returns a list of the indices of all occurrences of 'd' in the current instance
    // starting from index 'start'.
    indicesOf(d, start) {
        checkIndex_(start, 0, "Start")
        return indicesOf_(d, start)
    }

    // Private helper method for 'indicesOf' which avoids type and bounds checks.
    indicesOf_(d, start) {
        if (start < 0) start = _count + start
        var ixs = []
        var seq = (start == 0) ? this : this.skip(start)
        var i = start
        for (e in seq) {
            if (e == d) ixs.add(i)
            i = i + 1
        }
        return ixs
    }

    // Convenience version of 'indicesOf' which starts from 0.
    indicesOf(d) { indicesOf(d, 0) }

    // Returns the element at a specified index or the elements within a specified
    // index range of the current instance. In the latter case, the elements
    // are copied to a new LinkedList instance.
    [index] {
        if (index is Range) {
            if (index.from > index.to) Fiber.abort("Index range cannot be decreasing.")
            var inc = index.isInclusive ? 0 : 1
            if (index.from < 0 || (index.isInclusive && index.to >= _count + inc)) {
                Fiber.abort("Index range is out of bounds.")
            }
            inc = index.isInclusive ? 1 : 0
            var ll = LinkedList.new()
            for (e in this.skip(index.from).take(index.to-index.from + inc)) ll.add(e)
            return ll
        }
        checkIndex_(index, 0, "Index")
        if (index < 0) index = _count + index
        var i = 0
        for (e in this) {
            if (index == i) return e
            i = i + 1
        }
    }

    // Changes the element at the specified index of the current instance to 'd'.
    [index]=(d) {
        checkIndex_(index, 0, "Index")
        var i = 0
        var n = _head
        for (e in this) {
            if (index == i) {
                n.data = d
                return
            }
            i = i + 1
            n = n.next
        }
    }

     // Returns true if this instance contains ALL the values of a sequence, false otherwise.
    containsAll(ds) {
        if (!(ds is Sequence)) Fiber.abort("First argument must be a Sequence.")
        for (d in ds) {
            if (!contains(d)) return false
        }
        return true
    }

    // Returns true if this instance contains ANY of the values, false otherwise.
    containsAny(ds) { indexOfAny(ds, 0) >= 0 }

    // Returns true if this instance contains NONE of the values, false otherwise.
    containsNone(ds) { !containsAny(ds) }

    // Combines the elements of this instance plus those of another LinkedList object
    // into a new LinkedList and returns it.
    +(other) {
        if (other.type != LinkedList) Fiber.abort("Addend must be another LinkedList.")
        var ll = LinkedList.new()
        ll.addAll(this)
        ll.addAll(other)
        return ll
    }

    // Iterator protocol methods.
    iterate(iterator) {
        if (!iterator) {
            return !_head ? false : _head
        }
        return iterator.next
    }

    iteratorValue(iterator) { iterator.data }

    // Iterates through the nodes of this instance and returns for each one
    // a list containing the current and next data members.
    nodes {
        class N is Sequence {
            construct new(head) {
                _head = head
            }

            iterate(iterator) {
                if (!iterator) {
                    return !_head ? false : _head
                }
                return iterator.next
            }

            iteratorValue(iterator) {
                var n = iterator.next
                var next = (n) ? n.data : null
                return [iterator.data, next]
            }
        }
        return N.new(_head)
    }

    // Prints the consecutive elements of the current instance to stdout
    // separated by a single space and followed by a new line.
    print() {
        for (e in this) System.write("%(e) ")
        System.print()
    }

    // Returns the string representation of the current instance.
    toString { "[" + toList.join(" -> ") +"]" }
}

/* DNode is a building block for a doubly linked list. As such it consists of three fields:
   a data member, which can be of any type, and links to the next and previous Node objects.
*/
class DNode {
    // Constructs a new DNode object.
    construct new(data) {
        _data = data
        _next = null
        _prev = null
    }

    // Public properties.
    data { _data }
    data=(d) { _data = d }

    next { _next }
    next=(n) {
        _next = (n.type == DNode || n == null) ? n : Fiber.abort("Invalid argument.")
    }

    prev { _prev }
    prev=(n) {
        _prev = (n.type == DNode || n == null) ? n : Fiber.abort("Invalid argument.")
    }

    // Private setters, no checks.
    next_=(n) { _next = n }
    prev_=(n) { _prev = n }

    // Returns the string representation of this instance.
    toString { _data.toString }
}

/* DLinkedList represents a doubly linked list of DNode objects.
   The 'elements' of the list generally refer to their data members,
   not the DNodes themselves. Indexing operations support negative
   indices which count backwards from the end of the list.
*/
class DLinkedList is Sequence {

    // Constructs a new, empty DLinkedList object.
    construct new() {
        _count = 0
        _head = null
        _tail = null
    }

    // Constructs a new DLinkedList object and adds the elements of a sequence to it.
    construct new(a) {
        _count = 0
        _head = null
        _tail = null
        addAll(a)
    }

    // Creates a new DLinkedList with 'size' elements, all set to 'd'.
    static filled(size, d) {
        if (size.type != Num || !size.isInteger || size < 0) {
            Fiber.abort("Size cannot be negative.")
        }
        var ll = DLinkedList.new()
        if (size == 0) return ll
        for (i in 1..size) ll.add(d)
        return ll
    }

    // Copies the current instance to a new DLinkedList.
    copy() { DLinkedList.new(this) }

    // Basic properties.
    head { _head ? _head.data : null }  // returns the first element
    tail { _tail ? _tail.data : null }  // returns the last element

    count { _count }                    // returns the number of elements

    // Returns whether or not the current instance is empty.
    isEmpty { _count == 0 }

    // Adds an element at the tail of the current instance and returns it.
    add(d) {
        var node = DNode.new(d)
        if (!_head) {
            _head = node
            _head.next_ = null
            _head.prev_ = null
            _count = 1
        } else {
            var n = _tail
            n.next_ = node
            node.next_ = null
            node.prev_ = n
            _count = _count + 1
        }
        _tail = node
        return d
    }

    // Adds a sequence of elements at the tail of the current instance and returns them.
    addAll(a) {
        if (!(a is Sequence)) Fiber.abort("Argument must be a Sequence.")
        for (e in a) add(e)
        return a
    }

    // Inserts an element at the head of the current instance and returns it.
    prepend(d) { insert_(0, d) }

    // Inserts a sequence of elements at the head of the current instance and returns them.
    prependAll(a) {
        if (!(a is Sequence)) Fiber.abort("Argument must be a Sequence.")
        var i = 0
        for (e in a) {
            insert_(i, e)
            i = i + 1
        }
        return a
    }

    // Private helper method to check whether an index is valid.
    checkIndex_(index, inc, s) {
        if (index.type != Num || !index.isInteger) Fiber.abort("%(s) must be an integer.")
        var c = _count + inc
        if (index >= c || index < -c) Fiber.abort("%(s) is out of bounds.")
    }

    // Inserts an element at a specified index of the current instance
    // and returns the inserted element.
    insert(index, d) {
        checkIndex_(index, 1, "Index")
        return insert_(index, d)
    }

    // Private helper method for 'insert' which avoids type and bounds checks.
    insert_(index, d) {
        if (index <  0) index = _count + index + 1
        if (index == _count) {
            add(d)
            return d
        }
        var node = DNode.new(d)
        if (index == 0) {
            node.next_ = _head
            node.prev_ = null
            _head = node
        } else {
            var mid = (_count/2).floor
            var n
            if (index < mid) {
                n = _head
                for (i in 1...index) n = n.next
            } else {
                n = _tail
                for (i in _count...index) n = n.prev
            }
            node.next_ = n.next
            n.next.prev_ = node
            node.prev_ = n
            n.next_ = node
        }
        _count = _count + 1
        return d
    }

    // Inserts an element 'e' immediately after the first occurrence of an element 'd'
    // in the current instance and returns the inserted element. Returns null if 'd'
    // not found.
    insertAfter(d, e) {
        var ix = indexOf_(d, 0)
        return (ix >= 0) ? insert_(ix+1, e) : null
    }

    // Inserts an element 'e' immediately before the first occurrence of an element 'd'
    // in the current instance and returns the inserted element. Returns null if 'd'
    // not found.
    insertBefore(d, e) {
        var ix = indexOf_(d, 0)
        return (ix >= 0) ? insert_(ix, e) : null
    }

    // Removes the element at the specified index of the current instance and returns it.
    removeAt(index) {
        checkIndex_(index, 0, "Index")
        return removeAt_(index)
    }

    // Private helper method for 'removeAt' which avoids type and bounds checks.
    removeAt_(index) {
        if (index < 0) index = _count + index
        var removed
        if (index == 0) {
            removed = _head.data
            _head = _head.next
            if (_head) _head.prev_ = null
        } else if (index == _count - 1) {
            removed = _tail.data
            _tail = _tail.prev
            _tail.next_ = null
        } else {
            var mid = (_count/2).floor
            var n
            if (index < mid) {
                n = _head
                for (i in 0...index) n = n.next
            } else {
                n = _tail
                for (i in _count-1...index) n = n.prev
            }
            removed = n.data
            n.prev.next_ = n.next
            n.next.prev_ = n.prev
        }
        _count = _count - 1
        return removed
    }

    // Removes the first 'k' elements of the current instance and returns a list of them.
    removeFirst(k) {
        if (k.type != Num || !k.isInteger || k < 0) {
            Fiber.abort("Argument must be a non-negative integer.")
        }
        if (k == 0) return []
        if (k >= _count) {
            var removed = this.toList
            clear()
            return removed
        }
        var removed = this.take(k).toList
        var n = _head
        for (i in 1..k) n = n.next
        n.prev_ = null
        _head = n
        _count = _count - k
        return removed
    }

    // Removes the last 'k' elements of the current instance and returns a list of them.
    removeLast(k) {
        if (k.type != Num || !k.isInteger || k < 0) {
            Fiber.abort("Argument must be a non-negative integer.")
        }
        if (k == 0) return []
        if (k >= _count) {
            var removed = this.toList
            clear()
            return removed
        }
        var removed = this.skip(_count - k).toList
        var n = _tail
        for (i in 1..k) n = n.prev
        _tail = n
        _tail.next_ = null
        _count = _count - k
        return removed
    }

    // Removes all occurrences of the element 'd' from the current instance
    // and returns the number of occurrences.
    remove(d) {
        var ixs = indicesOf_(d, 0)[-1..0]
        if (ixs.count > 0) {
            for (ix in ixs) {
                removeAt_(ix)
            }
        }
        return ixs.count
    }

    // Clears the current instance of all its elements.
    clear() {
        _count = 0
        _head = null
        _tail = null
    }

    // Replaces all occurrences of the element 'd' in the current instance
    // by 'e' and returns the number of occurrences.
    replace(d, e) {
        if (d == e) return 0
        var ixs = indicesOf_(d, 0)
        if (ixs.count > 0) {
            for (ix in ixs) {
                this[ix] = e
            }
        }
        return ixs.count
    }

    // Exchanges the elements at indices 'i' and 'j' of the current instance.
    exchange(i, j) {
        if (i == j) return
        var t = this[i]
        this[i] = this[j]
        this[j] = t
    }

    // Returns the index of the first occurrence of 'd' in the current instance starting
    // from index 'start'.
    indexOf(d, start) {
        checkIndex_(start, 0, "Start")
        return indexOf_(d, start)
    }

    // Private helper method for 'indexOf' which avoids type and bounds checks.
    indexOf_(d, start) {
        if (start < 0) start = _count + start
        var seq = (start == 0) ? this : this.skip(start)
        var i = start
        for (e in seq) {
             if (e == d) return i
             i = i + 1
        }
        return -1
    }

    // Convenience version of 'indexOf' which starts from 0.
    indexOf(d) { indexOf(d, 0) }

    // Returns the index of the last occurrence of 'd' in the current instance.
    lastIndexOf(d) {
        var i = _count - 1
        for (e in this.reversed) {
             if (e == d) return i
             i = i - 1
        }
        return -1
    }

    // Returns the index of the first occurrence of any element of the sequence 'ds'
    // in the current instance starting from index 'start'.
    indexOfAny(ds, start) {
        checkIndex_(start, 0, "Start")
        if (start < 0) start = _count + start
        if (!(ds is Sequence)) Fiber.abort("First argument must be a Sequence.")
        var i
        for (d in ds) {
            if ((i = indexOf_(d, start)) >= 0) return i
        }
        return -1
    }

    // Convenience version of 'indexOfAny' which starts from 0.
    indexOfAny(ds) { indexOf(ds, 0) }

    // Searches for the indices of all occurrences of 'd' in the current instance
    // starting from index 'start' and returns a list of three items:
    // The first item is a Bool indicating whether the value was found.
    // The second item is the number of times the value was found.
    // The third item is a list of indices at which the value was found.
    indicesOf(d, start) {
        checkIndex_(start, 0, "Start")
        var res = indicesOf_(d, start)
        var c = res.count
        return [c > 0, c, res]
    }

    // Private helper method for 'indicesOf' which avoids type and bounds checks and
    // just returns a list of indices at which the value was found.
    indicesOf_(d, start) {
        if (start < 0) start = _count + start
        var ixs = []
        var seq = (start == 0) ? this : this.skip(start)
        var i = start
        for (e in seq) {
            if (e == d) ixs.add(i)
            i = i + 1
        }
        return ixs
    }

    // Convenience version of 'indicesOf' which starts from 0.
    indicesOf(d) { indicesOf(d, 0) }

    // Returns the element at a specified index or the elements within a specified
    // index range of the current instance. In the latter case, the elements
    // are copied to a new DLinkedList instance.
    [index] {
        if (index is Range) {
            if (index.from > index.to) Fiber.abort("Index range cannot be decreasing.")
            var inc = index.isInclusive ? 0 : 1
            if (index.from < 0 || (index.isInclusive && index.to >= _count + inc)) {
                Fiber.abort("Index range is out of bounds.")
            }
            inc = index.isInclusive ? 1 : 0
            var ll = DLinkedList.new()
            for (e in this.skip(index.from).take(index.to-index.from + inc)) ll.add(e)
            return ll
        }
        checkIndex_(index, 0, "Index")
        if (index < 0) index = _count + index
        var mid = (_count/2).floor
        if (index < mid) {
            var i = 0
            for (e in this) {
                if (index == i) return e
                i = i + 1
            }
        } else {
            var i = _count - 1
            for (e in this.reversed) {
                if (index == i) return e
                i = i - 1
            }
        }
    }

    // Changes the element at the specified index of the current instance to 'd'.
    [index]=(d) {
        checkIndex_(index, 0, "Index")
        var mid = (_count/2).floor
        if (index < mid) {
            var i = 0
            var n = _head
            for (e in this) {
                if (index == i) {
                    n.data = d
                    return
                }
                i = i + 1
                n = n.next
            }
        } else {
            var i = _count - 1
            var n = _tail
            for (e in this.reversed) {
                if (index == i) {
                    n.data = d
                    return
                }
                i = i - 1
                n = n.prev
            }
        }
    }

     // Returns true if this instance contains ALL the values of a sequence, false otherwise.
    containsAll(ds) {
        if (!(ds is Sequence)) Fiber.abort("First argument must be a Sequence.")
        for (d in ds) {
            if (!contains(d)) return false
        }
        return true
    }

    // Returns true if this instance contains ANY of the values, false otherwise.
    containsAny(ds) { indexOfAny(ds, 0) >= 0 }

    // Returns true if this instance contains NONE of the values, false otherwise.
    containsNone(ds) { !containsAny(ds) }

    // Combines the elements of this instance plus those of another DLinkedList object
    // into a new DLinkedList and returns it.
    +(other) {
        if (other.type != DLinkedList) Fiber.abort("Addend must be another DLinkedList.")
        var ll = DLinkedList.new()
        ll.addAll(this)
        ll.addAll(other)
        return ll
    }

    // Iterator protocol methods.
    iterate(iterator) {
        if (!iterator) {
            return !_head ? false : _head
        }
        return iterator.next
    }

    iteratorValue(iterator) { iterator.data }

    // Reverses the iteration order.
    reversed {
        class R is Sequence {
            construct new(tail) {
                _tail = tail
            }

            iterate(iterator) {
                if (!iterator) {
                    return !_tail ? false : _tail
                }
                return iterator.prev
            }

            iteratorValue(iterator) { iterator.data }
        }
        return R.new(_tail)
    }

    // Iterates through the nodes of this instance and returns for each one
    // a list containing the previous, current and next data members.
    nodes {
        class N is Sequence {
            construct new(head) {
                _head = head
            }

            iterate(iterator) {
                if (!iterator) {
                    return !_head ? false : _head
                }
                return iterator.next
            }

            iteratorValue(iterator) {
                var p = iterator.prev
                var prev = (p) ? p.data : null
                var n = iterator.next
                var next = (n) ? n.data : null
                return [prev, iterator.data, next]
            }
        }
        return N.new(_head)
    }

    // Prints the consecutive elements of the current instance to stdout
    // separated by a single space and followed by a new line.
    print() {
        for (e in this) System.write("%(e) ")
        System.print()
    }

    // As 'print' method but prints the elements in reverse.
    rprint() {
        for (e in this.reversed) System.write("%(e) ")
        System.print()
    }

    // Returns the string representation of the current instance.
    toString { "[" + toList.join(" <-> ") +"]" }
}

// Type aliases for classes in case of any name clashes with other modules.
var LList_Node        = Node
var LList_LinkedList  = LinkedList
var LList_DNode       = DNode
var LList_DLinkedList = DLinkedList
