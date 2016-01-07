; tré – Copyright (c) 2005–2006,2008–2015 Sven Michael Klose <pixel@copei.de>

(define-test "HREF symbol key"
  ((let h (make-hash-table :test #'eq)
     (= (href h 'a) 'x)
     (eq (href h 'a) 'x)))
  t)

(define-test "HREF number key"
  ((let h (make-hash-table :test #'eql)
     (= (href h 1) 'x)
     (eq (href h 1) 'x)))
  t)

(define-test "HREF string key"
  ((let h (make-hash-table :test #'string==)
     (= (href h "str") 'x)
     (eq (href h "str") 'x)))
  t)

(define-test "HREF empty string key"
  ((let h (make-hash-table :test #'string==)
     (= (href h "") 'x)
     (eq (href h "") 'x)))
  t)

(define-test "HREF character key"
  ((let h (make-hash-table :test #'eql)
     (= (href h #\a) 'x)
     (eq (href h #\a) 'x)))
  t)

(define-test "HREF hashtable key"
  ((with (h (make-hash-table :test #'eq)
          k (make-hash-table))
     (= (href h k) 'x)
     (eq (href h k) 'x)))
  t)

(define-test "HREF array key"
  ((with (h (make-hash-table :test #'eq)
          k (make-array 10))
     (= (href h k) 'x)
     (eq (href h k) 'x)))
  t)
