# Wishlist

If a whish becomes fullfilled it immediately gets kids.

## packaging across all platforms

To get rid of identifier prefixing.

## Syntactical sugar

* [args) x] for #'((args) (x))
* (x).      for (car (x)) – CxR dot notation for expression results.
* x."Aa"    for short case-sensitive slot access. (Needs new READ.)
* x.,name   for dynamic slot access. (Needs new READ.)
* #name     Allow denoting variable functions like that.

## Destructuring argument definitions

Great for dealing with JSON objects.

```lisp
#'({:name :surname})
    (format t "Hello ~A ~A!~%" name surname))
```
```
; CAR ;)
#'(x.)
    x)
```

## VAR inside functions instead of LET.

## Warn/error when accessing undefined vars somehow.

## Literal arrays

## Argument definitions: '.' instead of &REST

## Only import target-specific environment functions that are required, like imports from host environment..

## CL target: move DEFVARs (without inits) before imports.
* C parser in Lisp to import code of other languages
