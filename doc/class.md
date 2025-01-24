tré compiler class system
=========================

These constructs are solely to join JS and PHP's object system, so code can be
exchanged freely between these platforms.  The Common Lisp target has been
largely ignored – it wasn't essential for app building at the time of writing.

# DEFCLASS

~~~lisp
(DEFCLASS (class-name &rest base-classes)
          constructor-args &body constructor-body)
~~~

Defines a new class together with its constructor

# DEFMETHOD

~~~lisp
(DEFMETHOD class-name [:access-type] method-name args &body body))
~~~

Access tyoes may be :STATIC, :PROTECTED and :PRIVATE.  The JS target ignores
:PROTECTED and :PRIVATE.[^js-protected-private]

[^js-protected-private]:
  Either generate native class expressions to use those keywords or rename
  methods to make them inaccessible.

# DEFMEMBER

~~~lisp
(DEFMEMBER class-name member-names)
(DEFMEMBER class-name [:access-types…] member-name)
~~~

# FINALIZE-CLASS

~~~lisp
(FINALIZE-CLASS class-name)
~~~

Generates the actual class from all gathered information.
