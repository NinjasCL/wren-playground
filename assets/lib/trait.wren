// url: https://rosettacode.org/wiki/Category:Wren-trait
// source: https://rosettacode.org/mw/index.php?title=Category_talk:Wren-trait&action=edit&section=1
// file: trait
// name: Wren-trait
// author: PureFox
// license: MIT

/* Module "trait.wren" */

/* Cloneable is an abstract class which enables child classes to automatically be
   recognized as 'cloneable' by overriding the 'clone' method.
*/
class Cloneable {
    clone() { this } /* to be overridden by child class */
}

/* CloneableSeq is an abstract class which enables child classes to automatically be
   recognized as both Sequences and 'cloneable' by overriding the 'clone' method.
*/
class CloneableSeq is Sequence {
    clone() { this } /* to be overridden by child class */
}

/*
    Comparable is an abstract class which enables child classes to automatically
    inherit the comparison operators by just overriding the 'compare' method.
    Comparable itself inherits from Cloneable though if one does not wish to override
    the 'clone' method, it will just return the current object by default.
*/
class Comparable is Cloneable {
    compare(other) {
        // This should be overridden in child classes to return -1, 0 or +1
        // depending on whether this < other, this == other or this > other.
    }

    < (other) { compare(other) <  0 }
    > (other) { compare(other) >  0 }
    <=(other) { compare(other) <= 0 }
    >=(other) { compare(other) >= 0 }
    ==(other) { compare(other) == 0 }
    !=(other) { compare(other) != 0 }
}

/* Stepped wraps a Sequence so it can be iterated by steps other than 1. */
class Stepped is Sequence {
    // Constructs a new stepped sequence.
    construct new(seq, step) {
        if (!(seq is Sequence)) Fiber.abort("First argument must be a sequence.")
        _seq = seq
        _step = (step < 1) ? 1 : step // minimum step of 1
    }

    // Ensures a range is ascending before passing it to the constructor.
    // If it isn't, returns an empty range. Useful when bounds are variable.
    static ascend(range, step) {
        if (!(range is Range)) Fiber.abort("First argument must be a range.")
        return (range.from <= range.to) ? new(range, step) : 0...0
    }

    // Ensures a range is descending before passing it to the constructor.
    // If it isn't, returns an empty range. Useful when bounds are variable.
    static descend(range, step) {
        if (!(range is Range)) Fiber.abort("First argument must be a range.")
        return (range.from >= range.to) ? new(range, step) : 0...0
    }

    // Convenience versions of the above methods which call them with a step of 1.
    static ascend(range)  { ascend(range,  1) }
    static descend(range) { descend(range, 1) }

    // Iterator protocol methods.
    iterate(iterator) {
        if (!iterator) {
            return _seq.iterate(iterator)
        } else {
            var count = _step
            while (count > 0 && iterator) {
               iterator = _seq.iterate(iterator)
               count = count - 1
            }
            return iterator
        }
    }

    iteratorValue(iterator) { _seq.iteratorValue(iterator) }
}

/*
    Reversed wraps a Sequence (other than a range) so it can be iterated in reverse
    and by steps other than 1.
*/
class Reversed is Sequence {
    // Constructs a new reversed sequence.
    construct new(seq, step) {
        if (!(seq is Sequence) || seq is Range) {
            Fiber.abort("First argument must be a sequence other than a range.")
        }
        _seq = seq
        _step = (step < 1) ? 1 : step // minimum step of 1
    }

    // Convenience method which calls the constructor with a step of 1.
    static new(seq) { Reversed.new(seq, 1) }

    // Iterator protocol methods.
    iterate(iterator) {
        var it = _seq.iterate(iterator)
        if (it == null || it == 0) {
            it = _seq.count - 1
        } else if (it == false) {
            it = _seq.count - 1 - _step
        } else {
            it = it - 1 - _step
        }
        return (it >= 0) ? it : false
    }

    iteratorValue(iterator) { _seq.iteratorValue(iterator) }
}

// Type aliases for classes in case of any name clashes with other modules.
var Trait_Cloneable = Cloneable
var Trait_CloneableSeq = CloneableSeq
var Trait_Comparable = Comparable
var Trait_Stepped = Stepped
var Trait_Reversed = Reversed
