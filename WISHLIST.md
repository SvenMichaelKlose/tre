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
