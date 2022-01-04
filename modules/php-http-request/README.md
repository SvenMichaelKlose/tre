# HTTP request for tré (PHP target)

Under construction. No version yet.

```lisp
(HTTP-REQUEST URL ALIST &KEY (HEADER NIL) (ONRESULT NIL) (ONERROR NIL))
```

POSTs with UTF-8 encoding.  Using ONRESULT doesn't make this
call asynchronous.

HEADER is an associative list of string keys and values.
