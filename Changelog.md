# Changelog

All notable changes to this project will be documented in
this file.

The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

[Lisp manual](src/bin/lisp/doc/manual.md)


## [current]

### Fixed

  * Unified SLOT-VALUE handling in JS nad PHP target.
  * COPYING-STREAM: Fix end-of-stream detection.
  * MAKE-PHP-PROJECT: Load php-db-mysql and http-funcall.
  * %PRINT-OBJECT: Same for all targets.
  * When dumping compiler passes, print headers before calling the passes.

### Changed

  * In literal JSON objects, translate keywords to C identifier
    name strings, like Lisp symbol names to C/JS/PHP names.
  * JS/PHP: Unified class handling in the frontend.
  * JS: Generates native 'class' statements.

## [v0.0.21]

### Fixed

  * Fixed first time install.
  * Examples: Updated docker-compose configurations to version 3.
  * JS/PHP: SLOT-VALUE works correctly with objects of both worlds.

### Changed

  * PHP: JSON-DECODE: Make stdClass objects, not arrays.
  * HTTP-FUNCALL: Use JSON instead of XML weirdness.


## Former NEWS entries

Changes relative to tre-0.19:
  * CL: *ARGV* has the command-line arguments.
  * DEFSTRUCT: Generated macro DEF-name does not require the first argument
    to be of the structs name any more.
  * Inside methods package "GLOBAL" now tells that a symbol should not be
    thisified, allowing to access the symbol of the same name outside the
    class if it's being used as a method name already.
    E.g.: If you have a method named AREF and you want to access the global
    AREF function, just write 'global:aref' in the function call.
  * NEW without arguments does not create a JSON object but a standard object.
    Use MAKE-JSON-OBJECT.
  * AREF does not work an strings anymore. Use CHAR.
  * New abbreviating macros:
       …: LIST
      *>: APPLY
      ~>: FUNCALL
      +@: MAPCAN
      @n: MAPTIMES
  * PHP classes: array accessors may be overloaded by members AREF, =-AREF and
    DELETE-AREF.  PHP requires them all to be there if used.
  * Added VECTOR?.
  * EVERY much faster on lists.
  * Added DIRECTORY to get directory lists.
  * Added DUMP to CL target.
  * Added GETENV.
  * Added standard set functions SET-DIFFERENCE,
    SET-EXCLUSIVE-OR and SUBSET?.
  * New ARGUMENTS returns command-line arguments.
  * New GETENV returns environment variables.
  * File ~/.tre.sh is shell evaluated to update environment variables
    before launching tré.
  * JS class methods may be declared static.
  * PHP class members and methods may be declared static,
    protected or private.
  * Return values of constructors are ignored.
  * PHP classes may inherit.
  * Removed obsolete JavaScript DOM features:
    * GET-CANVAS-BY-CLASS-NAME
    * ancestor getters
    * FORM, IFRAME and VIDEO element utilities.
  * TRE-ELEMENT:
    * All event methods have been replaced by method ON, like
      done in jQuery.
    * Historic class, ID and name attribute methods have been
      removed.
    * General attribute accessors have been replaced by methods
      ATTR, ATTR? and ATTRS.
    * Removed opacity setter and rotation.
    * Accessor CSS replaces all other style accessors.
  * LOAD-STRING is now READ-FROM-STRING.
  * CONCAT-STRINGTREE is now FLATTEN.
  * QUASIQUOTE-SPLICE turns JavaScript objects into keyword/
    value lists.
  * New MAKE-JS-PROJECT and MAKE-PHP-PROJECTS compile with
    all available modules for each target.
  * READ-SYMBOL: Vertical bar '|' starts symbols with no
    case conversion, also allowing special characters until
    the next vertical bar.  '\' is the escape character.
  * Fixed(?) base64 functions.
  * Fixed =-REF.
  * Set *ASSERT?* to T by default.
  * Moved external modules back in.  Their separate
    repositories on Github will be removed.
  * Works with PHP-8.
  * SUBSEQ (JS/PHP): Allow strings of any length.  (Ugly
    hack from the old days.)
  * @, DYNAMIC-MAP return lists of arguments are arrays.
  * PAD accepts arrays.
  * Function definitions: single argument does not have to
    be put in a list.
  * REF: New functions to look up from alists, arrays, hash
    tables and objects.
  * ^ is now synonymous for REF.  (It was for FN.)
  * ACCCENT-CIRCONFLEX has been removed.
  * ENSURE-LIST: Do not put NIL into a list.
  * ENSURE-ARRAY: New function to convert lists into arrays.
  * =-ELT has been fixed.
  * FORMAT supports ~X to print hexadecimals. (Not complete.)

Changes of tre-0.19 relative to tre-0.18:
  * Bug-fix: jump tag optimizer translated any number.
  * Braces '{}' cannot be used as an alias for PROGN anymore.
    Now property names may be variables.
  * READ: Reads literal arrays. '#(…)'.
  * PERMUTATE: Takes &REST argument instead of list of lists.
  * DEFINE-SLOT-SETTER*: Weird idea removed.
  * DEFINE-GENSYM-GENERATOR -> DEF-GENSYM.
  * SIMPLE-OBJECT? -> JSON-OBJECT?.
  * LML2XML allows to print standalone attributes (with NIL
    values).  Assigned an empty string before.
  * CL: NANOTIME replaced by MILLISECONDS-SINCE-1970, albeit
    with precision of seconds only.
    "js" and "php".
  * PRINT-HTML-SCRIPT: Old browsers not supported anymore.
    Removed strict mode.
  * CL: FIND-SYMBOL takes strings instead of symbols.
  * PHP: versions older than 7.0 are not supported anymore.
         In return, code size has been reduced by ~10% and
         overall performance has been greatly improved as
         well.
  * PHP: Does not deal with magic quotes anymore.
  * PHP: Faster array access.
  * PHP: Native arrays are recognized as hash tables if they
         are not sequential.
  * PHP: MAKE-HASH-TABLE is a regular function, not a macro.
  * JS: STRING? also checks if object is an instance of
        class "String".
  * JS/PHP: Code size reduction by ~30%.
  * JS/PHP: MILLISECONDS-SINCE-1970 moved here from modules
  * JS/PHP: DEFPACKAGE, IN-PACKAGE and EXPORT added.
  * JS/PHP: OREF added for object access.
  * JS/PHP: Slightly shorter generated identifiers for alien
            characters.
  * JS/PHP: MAKE-ARRAY is a regular function which does not
            take a list of initial elements but a list of
            dimensions.

Changes of tre-0.18 relative to tre-0.17:
  * Slightly improved optimizer.
  * NONE? renamed to NOTANY.
  * AADJOIN moved to outside project "phitamine".
  * Removed STRING-ARRAY.
  * Beautified compiler dumps.

Changes of tre-0.17 relative to tre-0.16:
  * COUNT now has :TEST argument.
  * COMPILE lists unused functions.
  * SUBSEQ: Doesn't claim error if sequence is NIL anymore.
  * ELT: Returns NIL if object is NIL.
  * Another thorough cleanup took place.

Changes of tre-0.16 relative to tre-0.15:
  * Transpiler cleaned up thoroughly.  Lots of stale code has
    been removed.
  * GENSYM now takes optional symbol name prefix.
  * Added ready-made project directories in example/ to make
    it easier to start projects.
  * REMOVE-PROP is now REMOVE-PROPS and works on an arbitrarily
    number of keys to remove.
  * PROPERTY-VALUES: New function to return the values of the
    keys PROPERTY-NAMES returns.
  * Identifier obfuscation is not supported anymore.
  * Macros MAPCAR-MACRO and MAPCAN-MACRO have been removed.
  * ASSOC-URL and MAKE-SYMBOLS have been removed.
  * *ENGLISH-NUMBERS* has been removed.
  * Removed transpiler pass INJECT-DEBUGGING.
  * Pseudo-profiler has been removed.

Changes of tre-0.15 relative to tre-0.14:
  * MAP has been removed.  It has been the same as MAPCAR.
  * MERGE!, HASH-MERGE and OPTIONAL-DOWNCASE have been removed.
  * PATHNAME-FILENAME has been renamed to PATH-FILENAME.
  * LML keyword attributes are translated to camel notation when
    XML or DOM nodes are being generated.  Affects
    https://github.com/SvenMichaelKlose/tre-lml/
  * Empty curly braces {} became literal empty JSON objects.
  * PHP: ROUND, FLOOR, CEILING: New functions.
  * JS: ROUND, FLOOR, CEILING: More accurate implementations.
  * JS/PHP: FIXED-POINT: New function to format numbers.
  * JS: STRING== with more than two arguments fixed.
  * @: The functional version now deals with arrays and strings.
       as well.  The types will be checked at run-time and must
       not be mixed.  The result type is the argument type.
       (You'll get a string for strings.)  This version of @ is
       also available as function DYNAMIC-MAP.
  * JS: Accidently didn't inherit base class methods when no
        methods have been defined in the derived class.  Fixed.
  * PHP: Closures are converted to regular functions again, if
         that's possible.

Changes of tre-0.14 relative to tre-0.13:
  * Don't miss functions that need to get imported from the host
    environment anymore.
  * Only convert keywords that are keys in literal JSON objects
    to camel notation, not literal strings.

Changes of tre-0.13 relative to tre-0.12:
  * REMOVE-PROPERTY: New, non-destructive function.
  * PROPERTY-LIST has been renamed to PROPERTIES-LIST.
  * DEFCLASS fails on re-definitions or if a base class has
    not been defined.
  * FILTER functions aren't inlined anymore.  Caused nasty bugs.
  * JS: LENGTH: Works with objects.
  * JS/PHP: Curly brackets now produce real literal objects, not
            calls of MAKE-OBJECT. Keyword keys are now actually
            converted to camel notation as stated in the README.

Changes of tre-0.12 relative to tre-0.11:
  * LML2XML: Don't generate string for attribute values of NIL.
  * PHP: OBJECT-PHPARRAY, PHPARRAY-OBJECT: New functions.
  * PHP: PROPERTY-NAMES now supports native objects.
  * PHP: HASHKEYS fixed for native arrays.

Changes of tre-0.11 relative to tre-0.10:
  * Moved platform-specific functions into separate repositories
    'tre-php', 'tre-js' and 'tre-shared'.
  * Path/URI functions and READ-BINARY added to the environment.

Changes of tre-0.10 relative to tre-0.9:
  * PHP: DEFINED? and UNDEFINED? had reversed effects.
  * WITH-STRUCT: Most embarassing bug removed.  Did not
    introduce a GENSYM to evaluate the STRUCT's origin only
    once.

Changes of tre-0.9 relative to tre-0.8:
  * SLOT-VALUE can get and set by names passed as symbol or string,
    also by variable.
  * JSON obects must not be accessed like arrays. Use SLOT-VALUE instead
    of AREF.
  * PHP: TRANSPILER-CONFIGURATION :NATIVE-CODE holds a string of native code
         without opening or closing angle brackets to insert in the prologue.
  * PHP: GET-CURRENT-TIME has been replaced by MILLISECONDS-SINCE-1970.
  * PHP: JSON objects are treated as objects, not arrays.
  * PHP: NEW returns a stdClass.
  * JS: ATAN2: New math function.
  * CL: ASIN and ACOS added.

Changes of tre-0.8 relative to tre-0.7:
  * WITHOUT-HEAD, WITHOUT-TAIL: New functions.
  * PHP: AREF returns NIL for undefined indexes instead of breaking with an
         error message.

Changes of tre-0.7 relative to tre-0.6:
  * (%NEW): Accidentally converted to (%NEW NIL) – fixed.
  * PHP: Debugged property and associative array functions.
  * JS: Methods are also available as functions whose identifier is
        ($ class-name "-" method-name).

Changes of tre-0.6 relative to tre-0.5:
  * PHP: PROPERTY-NAMES fixed for associative arrays.
  * PHP: ASSOC-ARRAY? test if first key is a string.
  * Curly brackets {} denote MAKE-OBJECT if the first element is a string or
    keyword.
  * MAKE-OBJECT, NEW, {}: Also takes keywords whose symbol names are converted
    to downcase as property names.
  * JS/PHP: COPY-PROPERTIES, MERGE-PROPERTIES, UPDATE-PROPERTIES: New
    functions.

Changes of tre-0.5 relative to tre-0.4:
  * LOG-MESSAGE returns its argument if logging has been switched off.
  * LML: Attribute names must be keywords.
  * PHP: NEW create a native object when used witout arguments.
  * PHP: PROPERTY-NAME, PROPERTY-ALIST, ALIST-PROPERTIES, MAKE-OBJECT: New
         core functions.
  * PHP: ARRAY? returns T for indexed arrays only.
  * JS/PHP: ASSOC-ARRAY?: New predicate.
  * JS/PHP: JSON-ENCODE, JSON-DECODE added.

Changes of tre-0.4 relative to tre-0.3:
  * PHP: LENGTH returns correct value for wrapped arrays.
  * PHP: Issue an error when trying to convert a cons into string.
  * JS/PHP: %%%MAKE-HASH-TABLE is now %%%MAKE-OBJECT.
  * JS: MAKE-OBJECT: New function to use dynamically generated keys.

RELEASES:

Changes of tre-0.3 relative to tre-0.2:
  * JS: PROPERTY-NAME, PROPERTY-ALIST, ALIST-PROPERTIES: New core functions.
  * JS: PROPERTY-REMOVE: New core codegen macro.
  * JS: NEW returns an empty object when used without arguments.

Changes of tre-0.2 relative to tre-0.1:
  * Major cleanup.
  * Additional basic optimisations.
  * Forbids use of macro names as argument names.
  * DEFUN is now FN.
  * DEVAR is now VAR.
  * ALET is now !=.
  * EQL is converted to EQ for literal symbols.
  * In DEFCLASS Macro SUPER denotes the parent class constructor.
  * Macro MACROLET added.

Changes of tre-0.1 relative to tre-0.0:
  * Removed parts that are not working anymore.
  * Compiler cannot translate itself to JS, C or bytecode anymore.
