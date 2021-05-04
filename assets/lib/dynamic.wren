// url: https://rosettacode.org/wiki/Category:Wren-dynamic
// source: https://rosettacode.org/mw/index.php?title=Category_talk:Wren-dynamic&action=edit&section=2
// file: dynamic
// name: Wren-dynamic
// author: PureFox
// license: MIT

/* Module "dynamic.wren" */

import "meta" for Meta

/* Enum creates an enum with any number of read-only static members.
   Members are assigned in order an initial integer value (often 0), incremented by 1 each time.
   The enum has:
   1. static property getters for each member,
   2. a static 'startsFrom' property, and
   3. a static 'members' property which returns a list of its members as strings.
*/
class Enum {
    // Creates a class for the Enum (with an underscore after the name) and
    // returns a reference to it.
    static create(name, members, startsFrom) {
        if (name.type != String || name == "") Fiber.abort("Name must be a non-empty string.")
        if (members.isEmpty) Fiber.abort("An enum must have at least one member.")
        if (startsFrom.type != Num || !startsFrom.isInteger) {
            Fiber.abort("Must start from an integer.")
        }
        name = name +  "_"
        var s = "class %(name) {\n"
        for (i in 0...members.count) {
            var m = members[i]
            s = s + "    static %(m) { %(i + startsFrom) }\n"
        }
        var mems = members.map { |m| "\"%(m)\"" }.join(", ")
        s = s + "    static startsFrom { %(startsFrom) }\n"
        s = s + "    static members { [%(mems)] }\n}\n"
        s = s + "return %(name)"
        return Meta.compile(s).call()
     }

     // Convenience version of above method which always starts from 0.
     static create(name, members) { create(name, members, 0) }
}

/* Flags creates a 'flags' enum with up to 32 read-only static members.
   Members are assigned in order an integer value starting from 1 and multiplying by 2 each time.
   The flags enum has:
   1. static property getters for each member, and
   2. a static 'members' property which returns a list of its members as strings.
*/
class Flags {
    // Creates a class for the Flags enum (with an underscore after the name) and
    // returns a reference to it.
    static create(name, members) {
        if (name.type != String || name == "") Fiber.abort("Name must be a non-empty string.")
        if (members.isEmpty ||members.count > 32) {
            Fiber.abort("A flags enum must have between 1 and 32 members.")
        }
        name = name + "_"
        var s = "class %(name) {\n"
        for (i in 0...members.count) {
            var m = members[i]
            s = s + "    static %(m) { %(1 << i) }\n"
        }
        var mems = members.map { |m| "\"%(m)\"" }.join(", ")
        s = s + "    static members { [%(mems)] }\n}\n"
        s = s + "return %(name)"
        return Meta.compile(s).call()
     }

     // Returns the zero based index into the Fields property for a given Flags enum member.
     static indexOf(member) { (member.log / 2.log).round }
}

/* Struct creates a structure with any number of read/write fields of any type.
   The structure has:
   1. a constructor 'new' whose parameters are the initial field values,
   2. a property getter for each field,
   3. a property setter for each field,
   4. a 'toString' method to create a string representation of the structure, and
   5. a static 'fields' property which returns a list of its fields as strings.
*/
class Struct {
    // Creates a class for the Struct (with an underscore after the name) and
    // returns a reference to it.
    static create(name, fields) {
        if (name.type != String || name == "") Fiber.abort("Name must be a non-empty string.")
        if (fields.isEmpty) Fiber.abort("A struct must have at least one field.")
        name = name +  "_"
        var s = "class %(name) {\n"
        var flds = fields.map { |f| "\"%(f)\"" }.join(", ")
        s = s + "    static fields { [%(flds)] }\n"
        s = s + "    construct new(%(fields.join(", "))) {\n"
        for (i in 0...fields.count) {
            var f = fields[i]
            s = s + "        _%(f) = %(f)\n"
        }
        s = s + "    }\n"
        s = s + fields.map { |f| "    %(f) { _%(f) }" }.join("\n") + "\n"
        s = s + fields.map { |f| "    %(f)=(v) { _%(f) = v }" }.join("\n") + "\n"
        s = s + "    toString { \"(" + fields.map { |f| "\%(_%(f))" }.join(", ") + ")\" }\n}\n"
        s = s + "return %(name)"
        return Meta.compile(s).call()
     }
}

/* Tuple creates a tuple with any number of read-only fields of any type.
   The tuple has:
   1. a constructor 'new' whose parameters are the field values,
   2. a property getter for each field,
   3. a 'toString' method to create a string representation of the tuple, and
   4. a static 'fields' property which returns a list of its fields as strings.
*/
class Tuple {
    // Creates a class for the Tuple (with an underscore after the name) and
    // returns a reference to it.
    static create(name, fields) {
        if (name.type != String || name == "") Fiber.abort("Name must be a non-empty string.")
        if (fields.isEmpty) Fiber.abort("A tuple must have at least one field.")
        name = name +  "_"
        var s = "class %(name) {\n"
        var flds = fields.map { |f| "\"%(f)\"" }.join(", ")
        s = s + "    static fields { [%(flds)] }\n"
        s = s + "    construct new(%(fields.join(", "))) {\n"
        for (i in 0...fields.count) {
            var f = fields[i]
            s = s + "        _%(f) = %(f)\n"
        }
        s = s + "    }\n"
        s = s + fields.map { |f| "    %(f) { _%(f) }" }.join("\n") + "\n"
        s = s + "    toString { \"(" + fields.map { |f| "\%(_%(f))" }.join(", ") + ")\" }\n}\n"
        s = s + "return %(name)"
        return Meta.compile(s).call()
     }
}

/* Union creates a union whose read/write value must be a value of a given list of types.
   The union has:
   1. a constructor 'new' whose parameter is the initial value,
   2. a property getter for the value,
   3. a property setter for the value,
   4. a property getter for the kind (i.e. type) of the current value
   5. a 'toString' method to create a string representation of the current value, and
   6. a static 'types' property which returns a list of its allowable types.
*/
class Union {
    // Creates a class for the Union (with an underscore after the name) and
    // returns a reference to it.
    static create(name, types) {
        if (name.type != String || name == "") Fiber.abort("Name must be a non-empty string.")
        if (types.isEmpty) Fiber.abort("A union must have at least one type.")
        name = name + "_"
        var s =
"class %(name) {
    static types { %(types) }
    construct new(value) {
        if (!%(name).types.contains(value.type)) Fiber.abort(\"Invalid type.\")
        _value = value
    }
    value { _value }
    value=(v) {
        if (!%(name).types.contains(v.type)) Fiber.abort(\"Invalid type.\")
        _value = v
    }
    kind { _value.type }
    toString { _value.toString }
}
"
        s = s + "return %(name)"
        return Meta.compile(s).call()
    }
}

// Type aliases for classes in case of any name clashes with other modules.
var Dynamic_Enum   = Enum
var Dynamic_Flags  = Flags
var Dynamic_Struct = Struct
var Dynamic_Tuple  = Tuple
var Dynamic_Union  = Union
