(fn car (x)
  (? x
     x._
     (assert (not x) "Cons or NIL expected instead of ~A." x)))

(fn cdr (x)
  (? x
     x.__
     (assert (not x) "Cons or NIL expected instead of ~A." x)))

(fn rplaca (x val)
  (declare type cons x)
  (= x._ val)
  x)

(fn rplacd (x val)
  (declare type cons x)
  (= x.__ val)
  x)

(fn cons? (x)
  (& (object? x)
     x.__class
     (%%%== x.__class ,(obfuscated-identifier 'cons))))
