// url: https://rosettacode.org/wiki/Category:Wren-queue
// source: https://rosettacode.org/mw/index.php?title=Category_talk:Wren-queue&action=edit&section=2
// file: queue
// name: Wren-queue
// author: PureFox
// license: MIT

/* Module "queue.wren" */

/* Queue represents a FIFO list of values. */
class Queue is Sequence {
     // Constructs a new empty queue.
    construct new() { _queue = [] }

    // Returns the number of elements in the queue.
    count { _queue.count }

    // Returns whether or not the queue is empty.
    isEmpty { count == 0 }

    // Removes all elements from the queue.
    clear() { _queue.clear() }

    // Returns the first item of the queue without removing it.
    // Returns null if the queue is empty.
    peek() { (!isEmpty) ? _queue[0] : null }

    // Adds 'item' to the queue and returns it.
    push(item) { _queue.add(item) }

    // Adds a sequence of 'items' (in order) to the queue and returns them.
    pushAll(items) {
        if (!(items is Sequence)) Fiber.abort("Argument must be a Sequence.")
        return _queue.addAll(items)
    }

    // Removes the first item from the queue and returns it.
    // Returns null if the queue is empty.
    pop() {
        var item = peek()
        if (item != null) {
            _queue.removeAt(0)
        }
        return item
    }

    // Copies the elements of the queue to a list and returns it.
    toList { _queue.toList }

    // Copies the elements of the queue to a new Queue object and returns it.
    copy() {
        var q = Queue.new()
        q.pushAll(_queue)
        return q
    }

    // Iterator protocol methods.
    iterate(iterator) { _queue.iterate(iterator) }
    iteratorValue(iterator) { _queue.iteratorValue(iterator) }

    // Returns the string representation of the queue's underlying list.
    toString { _queue.toString }
}

/* Deque represents a doubled-ended queue. */
class Deque is Sequence {
     // Constructs a new empty deque.
    construct new() { _deque = [] }

    // Returns the number of elements in the deque.
    count { _deque.count }

    // Returns whether or not the deque is empty.
    isEmpty { count == 0 }

    // Removes all elements from the deque.
    clear() { _deque.clear() }

    // Returns the first item of the deque without removing it.
    // Returns null if the deque is empty.
    peekFront() { (!isEmpty) ? _deque[0] : null }

    // Returns the last item of the deque without removing it.
    // Returns null if the deque is empty.
    peekBack() { (!isEmpty) ? _deque[-1] : null }

    // Adds 'item' to the front of the deque and returns it.
    pushFront(item) { _deque.insert(0, item) }

    // Adds a sequence of 'items' (in order) to the front of the deque and returns them.
    pushAllFront(items) {
        if (!(items is Sequence)) Fiber.abort("Argument must be a Sequence.")
        var i = 0
        for (item in items) {
            _deque.insert(i, item)
            i = i + 1
        }
        return items
    }

    // Adds 'item' to the back of the deque and returns it.
    pushBack(item) { _deque.add(item) }

    // Adds a sequence of 'items' (in order) to the back of the deque and returns them.
    pushAllBack(items) {
        if (!(items is Sequence)) Fiber.abort("Argument must be a Sequence.")
        return _deque.addAll(items)
    }

    // Removes the first item from the deque and returns it.
    // Returns null if the deque is empty.
    popFront() {
        var item = peekFront()
        if (item != null) {
            _deque.removeAt(0)
        }
        return item
    }

    // Removes the last item from the deque and returns it.
    // Returns null if the deque is empty.
    popBack() {
        var item = peekBack()
        if (item != null) {
            _deque.removeAt(-1)
        }
        return item
    }

    // Copies the elements of the deque to a list and returns it.
    toList { _deque.toList }

    // Copies the elements of the deque to a new Deque object and returns it.
    copy() {
        var d = Deque.new()
        d.pushAllBack(_deque)
        return d
    }

    // Iterator protocol methods.
    iterate(iterator) { _deque.iterate(iterator) }
    iteratorValue(iterator) { _deque.iteratorValue(iterator) }

    // Returns the string representation of the deque's underlying list.
    toString { _deque.toString }
}


/* PriorityQueue represents a queue in which each element has an associated priority
   which can be any number. An element with a higher priority is 'popped'
   before an element with a lower priority. Elements with the same priority
   are popped in order of addition. Elements are stored as pairs viz: [value, priority]
   and are sorted after each addition or group thereof in descending order of priority.
 */
class PriorityQueue is Sequence {
    // Private static method which provides a comparison algorithm for the sort_ method.
    static cmp_(e1, e2) { (e2[1] - e1[1]).sign }

    // Private static method which sorts a list of elements 'a' by descending order
    // of priority using the insertion sort algorithm.
    static sort_(a) {
        var c = a.count
        if (c < 2) return
        for (i in 1..c-1) {
            var v = a[i]
            var j = i - 1
            while (j >= 0 && cmp_(a[j], v) > 0) {
                a[j+1] = a[j]
                j = j - 1
            }
            a[j+1] = v
        }
    }

    // Constructs a new empty priority queue.
    construct new() { _pqueue = [] }

    // Returns the number of elements in the priority queue.
    count { _pqueue.count }

    // Returns whether or not the priority queue is empty.
    isEmpty { count == 0 }

    // Removes all elements from the priority queue.
    clear() { _pqueue.clear() }

    // Returns the first element of the priority queue without removing it.
    // Returns null if the priority queue is empty.
    peek() { (!isEmpty) ? _pqueue[0] : null }

    // Adds 'value' with priority 'p' to the priority queue and returns it.
    push(value, p) {
        var e = [value, p]
        _pqueue.add(e)
        PriorityQueue.sort_(_pqueue)
        return e
    }

    // Adds a non-empty sequence of [value, priority] pairs (in order)
    // to the priority queue and returns them.
    pushAll(pairs) {
        if (!((pairs is Sequence) && pairs.count > 0 &&
            pairs.take(1).toList[0].count == 2)) {
            Fiber.abort("Argument must be a non-empty sequence of [value, priority] pairs.")
        }
        _pqueue.addAll(pairs)
        PriorityQueue.sort_(_pqueue)
        return pairs
    }

    // Removes the first element from the priority queue and returns it.
    // Returns null if the priority queue is empty.
    pop() {
        var e = peek()
        if (e != null) {
            _pqueue.removeAt(0)
        }
        return e
    }

    // Copies the elements of the priority queue to a list and returns it.
    toList { _pqueue.toList }

    // Returns a list of the values of each element in priority order.
    values {
        var v = []
        for (e in _pqueue) v.add(e[0])
        return v
    }

    // Copies the elements of the priority queue to a new PriorityQueue object and returns it.
    copy() {
        var pq = PriorityQueue.new()
        pq.pushAll(_pqueue)
        return pq
    }

    // Iterator protocol methods.
    iterate(iterator) { _pqueue.iterate(iterator) }
    iteratorValue(iterator) { _pqueue.iteratorValue(iterator) }

    // Returns the string representation of the priority queue's underlying list.
    toString { _pqueue.toString }
}

// Type aliases for classes in case of any name clashes with other modules.
var Queue_Queue = Queue
var Queue_Deque = Deque
var Queue_PriorityQueue = PriorityQueue
