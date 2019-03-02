# Major efforts

* packaging across all platforms

# Syntactical sugar

* [args) x] for #'((args) (x))
* (x).      for (car (x)) – CxR dot notation for expression results.
* x."Aa"    for short case-sensitive slot access. (Needs new READ.)
* x.,name   for dynamic slot access. (Needs new READ.)
* #name     Allow denoting variable functions like that.

# Destructuring argument definitions

Great for dealing with JSON objects.

```lisp
#'({:name :surname})
    (format t "Hello ~A ~A!~%" name surname))
```
