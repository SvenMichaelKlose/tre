Introduction to LISP Syntax
===========================

Lisp has the same data types as your programming lanugage: booleans, numbers,
strings, arrays, objects and so on.  The most obvious and probably as
intensively off-putting difference to better-know programming languages and
LISP is its syntax.  Let's compare a mainstream programming language statement
to a LISP one:

In Lisp the first parenthesis slips in front of the function name and the
commas and the semicolon is left out.  Semicolons start a line comment in LISP:

~~~
// C
print ("Hello ");
print ("World!");
; LISP
(print "Hello ")
(print "World!")
~~~

Operators are function calls with no precedence:

~~~
a = (b + c) * 3;
(= (\* (+ b c)) 3)
~~~

A conditional is written like a call to function ? with at least two arguments:

~~~
if (hungry)
   print "Go to Rudi's!";
else
   print "I'm good!";
(? hungry
   (print "Go to Rudi's!")
   (print "I'm good!"))
~~~

Every expression (and function) in LISP has a return value.  Functions return
the result of the last expression executed, so there is no requirement to use
'return'.

~~~
function plus1 (x)
{
    return ++x;
}
(fn plus1 (x)
  (++ x))
~~~

Instead of 'true' and 'false' LISP has T and NIL.  And of most urgent
importance is: numbers with value 0 are T, not NIL.

~~~
return true;    // Return from function.
(return T)      ; Early return from function.
~~~
