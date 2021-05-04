// url: https://rosettacode.org/wiki/Category:Wren-ioutil
// source: https://rosettacode.org/mw/index.php?title=Category_talk:Wren-ioutil&action=edit&section=1
// file: ioutil
// name: Wren-ioutil
// author: PureFox
// license: MIT

/* Module "ioutil.wren" */

import "io" for File, FileFlags, Stdin, Stdout
import "os" for Platform

/*
   FileUtil supplements the File class with various other operations on files.
   All methods automatically close any files they have opened before returning.
*/
class FileUtil {
    // Returns the string representing a line break for the current platform.
    static lineBreak { Platform.isWindows ? "\r\n" : "\n" }

    // Returns the default buffer size.
    static bufferSize { 4096 }

    // Returns whether or not two paths refer to the same file. The file(s) must exist.
    static areSameFile(path1, path2) { File.realPath(path1) == File.realPath(path2) }

    // Returns whether or not the contents of the two paths are exactly the same.
    // The files must exist and not be the same file.
    // Use only if the entire contents of both files can be held temporarily in memory.
    static areDuplicates(path1, path2) { !areSamefile(path1, path2) && read(path1) == read(path2) }

    // Private worker method for copying files.
    static copy_(fromPath, toPath, overwrite, checked) {
        if (!checked) {
            if (overwrite.type != Bool) Fiber.abort("Overwrite must be true or false.")
            if (!File.exists(fromPath)) Fiber.abort("'%(fromPath)' does not exist.")
            if (!overwrite && File.exists(toPath)) Fiber.abort("'%(toPath)' already exists.")
            if (fromPath == toPath) return
        }
        var contents = File.read(fromPath)
        File.create(toPath) { |file| file.writeBytes(contents) }
    }

    // Copies a file from 'fromPath' to 'toPath'. If 'toPath' already exists it fails unless
    // 'overwrite' is set to true in which case it is truncated first.
    // Use only if the entire contents of 'fromPath' can be held temporarily in memory.
    static copy(fromPath, toPath, overwrite) { copy_(fromPath, toPath, overwrite, false) }

    // Convenience version of the 'copy' method in which 'overwrite' is always set to false.
    static copy(fromPath, toPath) { copy_(fromPath, toPath, false, false) }

    // Moves a file from 'fromPath' to 'toPath'. If 'toPath' already exists it fails unless.
    // 'overwrite' is set to true in which case it is truncated first.
    // Use only if the entire contents of 'fromPath' can be held temporarily in memory.
    static move(fromPath, toPath, overwrite) {
        if (overwrite.type != Bool) Fiber.abort("Overwrite must be true or false.")
        if (!File.exists(fromPath)) Fiber.abort("'%(fromPath)' does not exist.")
        if (!overwrite && File.exists(toPath)) Fiber.abort("'%(toPath)' already exists.")
        if (fromPath == toPath) return
        copy_(fromPath, toPath, overwrite, true)
        File.delete(fromPath)
    }

    // Convenience version of the 'move' method in which 'overwrite' is always set to false.
    static move(fromPath, toPath) { move(fromPath, toPath, false) }

    // Private worker method for copying large files.
    static copyLarge_(fromPath, toPath, overwrite, checked) {
        if (!checked) {
            if (overwrite.type != Bool) Fiber.abort("Overwrite must be true or false.")
            if (!File.exists(fromPath)) Fiber.abort("'%(fromPath)' does not exist.")
            if (!overwrite && File.exists(toPath)) Fiber.abort("'%(toPath)' already exists.")
            if (fromPath == toPath) return
        }
        var size = File.size(fromPath)
        var chunks = (size/bufferSize).floor
        var rem = size % bufferSize
        if (rem > 0) chunks = chunks + 1
        var offset = 0
        var fout = File.create(toPath)
        File.open(fromPath) { |fin|
            for (i in 1..chunks) {
                var bytes = fin.readBytes(bufferSize, offset)
                fout.writeBytes(bytes)
                var offset = offset + bufferSize
            }
        }
        fout.close()
    }

    // Copies a file from 'fromPath' to 'toPath'. If 'toPath' already exists it fails unless
    // 'overwrite' is set to true in which case it is truncated first.
    // Use if the entire contents of 'fromPath' are too large to be held temporarily in memory.
    static copyLarge(fromPath, toPath, overwrite) { copyLarge_(fromPath, toPath, overwrite, false) }

    // Convenience version of the 'copyLarge' method in which 'overwrite' is always set to false.
    static copyLarge(fromPath, toPath) { copyLarge_(fromPath, toPath, false, false) }

    // Moves a file from 'fromPath' to 'toPath'. If 'toPath' already exists it fails unless
    // 'overwrite' is set to true in which case it is truncated first.
    // Use if the entire contents of 'fromPath' are too large to be held temporarily in memory.
    static moveLarge(fromPath, toPath, overwrite) {
        if (overwrite.type != Bool) Fiber.abort("Overwrite must be true or false.")
        if (!File.exists(fromPath)) Fiber.abort("'%(fromPath)' does not exist.")
        if (!overwrite && File.exists(toPath)) Fiber.abort("'%(toPath)' already exists.")
        if (fromPath == toPath) return
        copyLarge_(fromPath, toPath, overwrite, true)
        File.delete(fromPath)
    }

    // Convenience version of the 'moveLarge' method in which 'overwrite' is always set to false.
    static moveLarge(fromPath, toPath) { moveLarge(fromPath, toPath, false) }

    // Reads the entire contents of the file at 'path' and returns it as a string.
    // Use only if the entire contents of 'path' can be held in memory.
    // Works the same as File.read(path) but gives a clearer error message if 'path' does not exist.
    static read(path) {
        if (!File.exists(path)) Fiber.abort("'%(path)' does not exist.")
        return File.read(path)
    }

    // Reads and returns the entire contents of the file at 'path' split into lines.
    // Use only if the entire contents of 'path' can be held in memory.
    static readLines(path) {
        if (!File.exists(path)) Fiber.abort("'%(path)' does not exist.")
        return File.read(path).split(lineBreak)
    }

    // Returns a function which reads a file chunk by chunk and 'yields' each chunk to the calling fiber.
    // Use if the entire contents of 'path' are too large to be held in memory.
    static readLarge(path) {
        if (!File.exists(path)) Fiber.abort("'%(path)' does not exist.")
        return Fn.new {
            var size = File.size(path)
            var chunks = (size/bufferSize).floor
            var rem = size % bufferSize
            if (rem > 0) chunks = chunks + 1
            var offset = 0
            var file = File.open(path)
            for (i in 1..chunks) {
                var bytes = file.readBytes(bufferSize, offset)
                Fiber.yield(bytes)
                var offset = offset + bufferSize
            }
            file.close()
        }
    }

    // Returns a function which reads a file line by line and 'yields' each line to the calling fiber.
    // Use if the entire contents of 'path' are too large to be held in memory.
    static readEachLine(path) {
        if (!File.exists(path)) Fiber.abort("'%(path)' does not exist.")
        return Fn.new {
            var file = File.open(path)
            var offset = 0
            var line = ""
            while(true) {
                var b = file.readBytes(1, offset)
                offset = offset + 1
                if (b == "\n") {
                    Fiber.yield(line)
                    line = "" // reset line variable
                } else if (b == "\r") { // Windows
                    // wait for following "\n"
                } else if (b == "") { // end of stream
                    break
                } else {
                    line = line + b
                }
            }
            file.close()
        }
    }

    // Creates a new file, or truncates an existng one, and writes 'bytes' to it.
    static write(path, bytes) {
        if (bytes.type != String) Fiber.abort("'Bytes' must be a string.")
        File.create(path) { |file| file.writeBytes(bytes) }
    }

    // Creates a new file, or truncates an existng one, and writes 'lines' to it.
    static writeLines(path, lines) {
        if (!(lines is Sequence)) Fiber.abort("'Lines' must be a sequence.")
        File.create(path) { |file|
           for (line in lines) {
                file.writeBytes((line is String) ? line : line.toString)
                file.writeBytes(lineBreak)
           }
        }
    }

    // Appends 'bytes' to the end of the file at 'path'. If 'path' doesn't exist, a new file is created.
    static append(path, bytes) {
        if (bytes.type != String) Fiber.abort("'Bytes' must be a string.")
        var exists = File.exists(path)
        if (exists && bytes == "") return
        var flags = FileFlags.writeOnly
        if (!exists) flags = FileFlags.create | flags
        File.openWithFlags(path, flags) { |file| file.writeBytes(bytes) }
    }

    // Appends 'lines' to the end of the file at 'path'. If 'path' doesn't exist, a new file is created.
    static appendLines(path, lines) {
        if (!(lines is Sequence)) Fiber.abort("'Lines' must be a sequence.")
        var exists = File.exists(path)
        if (exists && lines.isEmpty) return
        var flags = FileFlags.writeOnly
        if (!exists) flags = FileFlags.create | flags
        File.openWithFlags(path, flags) { |file|
            for (line in lines) {
                file.writeBytes((line is String) ? line : line.toString)
                file.writeBytes(lineBreak)
            }
        }
    }

    // Removes up to 'numBytes' bytes from the end of the file at 'path'.
    // Use only if the entire contents of 'path' can be held temporarily in memory.
    static remove(path, numBytes) {
        if (!File.exists(path)) Fiber.abort("'%(path)' does not exist.")
        if (numBytes.type != Num || !numBytes.isInteger || numBytes < 1) {
            Fiber.abort("Number of bytes to be removed must be a positive integer.")
        }
        var size = File.size(path)
        if (size <= number) {
            File.create(path)
            return
        }
        var contents = File.read(path)[0...-number]
        File.create(path) { |file| file.writeBytes(contents) }
    }

    // Removes up to 'numLines' lines from the end of the file at 'path'.
    // Use only if the entire contents of 'path' can be held temporarily in memory.
    static removeLines(path, numLines) {
        if (numLines.type != Num || !numLines.isInteger || numLines < 1) {
            Fiber.abort("Number of lines to be removed must be a positive integer.")
        }
        var lines = readLines(path)
        var count = lines.count
        if (count <= numLines) {
            File.create(path)
            return
        }
        File.create(path) { |file|
            for (line in lines.take(count - numLines)) {
                file.writeBytes(line)
                file.writeBytes(lineBreak)
            }
        }
    }

    // Truncates the file at 'path' to the specified size in bytes.
    // If the old size is not greater than the new size, the file is left unchanged.
    // Use only if the entire contents of 'path' can be held temporarily in memory.
    static truncate(path, newSize) {
        if (!File.exists(path)) Fiber.abort("'%(path)' does not exist.")
        if (newSize.type != Num || !newSize.isInteger || newSize < 0) {
            Fiber.abort("New size must be a non-negative integer.")
        }
        var oldSize = File.size(path)
        if (oldSize <= newSize) return
        var contents = File.read(path)[0...newSize]
        File.create(path) { |file| file.writeBytes(contents) }
    }

    // Truncates the file at 'path' to the specified number of lines.
    // If the old length is not greater than the new length, the file is left unchanged.
    // Use only if the entire contents of 'path' can be held temporarily in memory.
    static truncateLines(path, newLen) {
        if (newLen.type != Num || !newLen.isInteger || newLen < 0) {
            Fiber.abort("New length must be a non-negative integer.")
        }
        var lines = readLines(path)
        if (lines.count <= newLen) return
        File.create(path) { |file|
            for (line in lines.take(newLen)) {
                file.writeBytes(line)
                file.writeBytes(lineBreak)
            }
        }
    }
}

/* Input supplements Stdin with some additional methods for reading user input. */
class Input {
    // Prompts the user to enter some text and returns it.
    static text(prompt) {
        Output.fwrite(prompt)
        return Stdin.readLine()
    }

    // Prompts the user to enter some text of a minimum length and returns it.
    static text(prompt, minLen) {
        if (minLen.type != Num || !minLen.isInteger || minLen < 0) {
            Fiber.abort("Minimum length must be a non-negative integer.")
        }
        if (minLen == 0) return text(prompt)
        while (true) {
            Output.fwrite(prompt)
            var text = Stdin.readLine()
            if (text.count < minLen) {
                System.print("Must have a minimum length of %(minLen) characters, try again.")
            } else return text
        }
    }

    // Prompts the user to enter some text with a minimum/maximum length and returns it.
    static text(prompt, minLen, maxLen) {
        if (minLen.type != Num || !minLen.isInteger || minLen < 0) {
            Fiber.abort("Minimum length must be a non-negative integer.")
        }
        if (maxLen.type != Num || !maxLen.isInteger || maxLen < minLen) {
            Fiber.abort("Maximum length must not be less than minimum length.")
        }
        while (true) {
            Output.fwrite(prompt)
            var text = Stdin.readLine()
            if (text.count < minLen || text.count > maxLen) {
                if (maxLen > minLen) {
                    System.print("Must have a length between %(minLen) and %(maxLen) characters, try again.")
                } else {
                    System.print("Must have a length of exactly %(minLen) characters, try again.")
                }
            } else return text
        }
    }

    // Prompts the user to enter a number and returns it.
    static number(prompt) {
        while (true) {
            Output.fwrite(prompt)
            var number = Num.fromString(Stdin.readLine())
            if (!number) {
                System.print("Must be a number, try again.")
            } else return number
        }
    }

    // Prompts the user to enter a number with a minimum value and returns it.
    static number(prompt, min) {
        if (min.type != Num) Fiber.abort("Minimum value must be a number.")
        while (true) {
            Output.fwrite(prompt)
            var number = Num.fromString(Stdin.readLine())
            if (!number || number < min) {
                System.print("Must be a number no less than %(min), try again.")
            } else return number
        }
    }

    // Prompts the user to enter a number with a minimum/maximum value and returns it.
    static number(prompt, min, max) {
        if (min.type != Num) Fiber.abort("Minimum value must be a number.")
        if (max.type != Num || max <= min) {
            Fiber.abort("Maximum value must be a number greater than minimum value.")
        }
        while (true) {
            Output.fwrite(prompt)
            var number = Num.fromString(Stdin.readLine())
            if (!number || number < min || number > max) {
                System.print("Must be a number between %(min) and %(max), try again.")
            } else return number
        }
    }

    // Prompts the user to enter an integer and returns it.
    static integer(prompt) {
        while (true) {
            Output.fwrite(prompt)
            var integer = Num.fromString(Stdin.readLine())
            if (!integer || !integer.isInteger) {
                System.print("Must be an integer, try again.")
            } else return integer
        }
    }

    // Prompts the user to enter an integer with a minimum value and returns it.
    static integer(prompt, min) {
        if (min.type != Num || !min.isInteger) Fiber.abort("Minimum value must be an integer.")
        while (true) {
            Output.fwrite(prompt)
            var integer = Num.fromString(Stdin.readLine())
            if (!integer || !integer.isInteger || integer < min) {
                System.print("Must be an integer no less than %(min), try again.")
            } else return integer
        }
    }

    // Prompts the user to enter an integer with a minimum/maximum value and returns it.
    static integer(prompt, min, max) {
        if (min.type != Num || !min.isInteger) Fiber.abort("Minimum value must be an integer.")
        if (max.type != Num || !max.isInteger || max <= min) {
            Fiber.abort("Maximum value must be an integer greater than minimum value.")
        }
        while (true) {
            Output.fwrite(prompt)
            var integer = Num.fromString(Stdin.readLine())
            if (!integer || !integer.isInteger || integer < min || integer > max) {
                System.print("Must be an integer between %(min) and %(max), try again.")
            } else return integer
        }
    }

    // Prompts the user to enter a single character option from a string of options and returns it.
    // Only the first character entered is significant, any others are ignored.
    // Where both lower and upper case characters are permitted both must be specified.
    static option(prompt, options) {
        if (options.type != String || options.count < 2) {
            Fiber.abort("Options must be a string of minimum length 2.")
        }
        while (true) {
            Output.fwrite(prompt)
            var option = Stdin.readLine()
            if (option.count == 0) {
                System.print("Option must have (at least) one character, try again")
            } else {
                option = option[0]
                if (!options.contains(option)) {
                    System.print("Must be one of '%(options)', try again.")
                } else return option
            }
        }
    }

    // Prompts the user to enter an option from a list of textual options and returns it.
    // The text entered, after any whitespace is trimmed off, must match an option exactly.
    static txtOpt(prompt, options) {
        if (options.type != List || options.count < 2 || options[0].type != String) {
            Fiber.abort("Options must be a list of strings of minimum length 2.")
        }
        while (true) {
            Output.fwrite(prompt)
            var option = Stdin.readLine().trim()
            if (!options.contains(option)) {
                System.print("Must be one of %(options), try again.")
            } else return option
        }
    }

    // Prompts the user to enter an option from a list of numeric options and returns it.
    // The number entered must match an option exactly.
    static numOpt(prompt, options) {
        if (options.type != List || options.count < 2 || options[0].type != Num) {
            Fiber.abort("Options must be a list of numbers of minimum length 2.")
        }
        while (true) {
            Output.fwrite(prompt)
            var option = Num.fromString(Stdin.readLine())
            if (!option || !options.contains(option)) {
                System.print("Must be one of %(options), try again.")
            } else return option
        }
    }

    // Prompts the user to enter an option from a list of integral options and returns it.
    // The integer entered must match an option exactly.
    static intOpt(prompt, options) {
        if (options.type != List || options.count < 2 || options[0].type != Num || !options[0].isInteger) {
            Fiber.abort("Options must be a list of integers of minimum length 2.")
        }
        while (true) {
            Output.fwrite(prompt)
            var option = Num.fromString(Stdin.readLine())
            if (!option || !option.isInteger || !options.contains(option)) {
                System.print("Must be one of %(options), try again.")
            } else return option
        }
    }
}

/* Output supplements Stdout with some additional methods to flush output automatically. */
class Output {
    // Prints a single value to the console, but does not print a newline character afterwards.
    // Converts the value to a string by calling toString on it and flushes output immediately.
    static fwrite(object) {
        System.write(object)
        Stdout.flush()
    }

    // Iterates over sequence and prints each element, but does not print a single newline at the end.
    // Each element is converted to a string by calling toString on it and output is flushed immediately.
    static fwriteAll(sequence) {
        System.writeAll(sequence)
        Stdout.flush()
    }
}

// Type aliases for classes in case of any name clashes with other modules.
var IOutil_FileUtil  = FileUtil
var IOutil_Input     = Input
var IOutil_Output    = Output
var IOutil_File      = File        // in case imported indirectly
var IOUtil_FileFlags = FileFlags   // ditto
var IOUtil_Stdin     = Stdin       // ditto
var IOUtil_Stdout    = Stdout      // ditto
var IOUtil_Platform  = Platform    // ditto
