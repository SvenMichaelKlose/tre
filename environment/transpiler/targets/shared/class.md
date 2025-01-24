Generic CLASS macros
====================

The macros DEFCLASS, DEFMEMBER, DEFMETHOD and FINALIZE-CLASS
build a list lof CLASS structs in TRANSPILER-DEFINED-CLASSES.
CLASS-SLOTS contains list of %SLOT structs for each class.
FINALIZE-CLASS emits a %COLLECTION of slot/body pairs whose
bodies go through the compiler passes like regular code.
