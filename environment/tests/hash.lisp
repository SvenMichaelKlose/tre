(deftest "HREF symbol key"
  ((let h (make-hash-table :test #'eq)
     (= (href h 'a) 'x)
     (= (href h 'b) 'y)
     (& (eq (href h 'a) 'x)
        (eq (href h 'b) 'y))))
  t)

(deftest "HREF symbol key missing"
  ((let h (make-hash-table :test #'eq)
     (= (href h 'a) 'x)
     (href h 'b)))
  nil)

(deftest "HREF number key"
  ((let h (make-hash-table :test #'eql)
     (= (href h 1) 'x)
     (= (href h 2) 'y)
     (& (eq (href h 1) 'x)
        (eq (href h 2) 'y))))
  t)

(deftest "HREF number key missing"
  ((let h (make-hash-table :test #'eql)
     (= (href h 1) 'x)
     (href h 2)))
  nil)

(deftest "HREF string key"
  ((let h (make-hash-table :test #'string==)
     (= (href h "str") 'x)
     (eq (href h "str") 'x)))
  t)

(deftest "HREF string key missing"
  ((let h (make-hash-table :test #'string==)
     (= (href h "str") 'x)
     (href h "STR")))
  nil)

(deftest "HREF empty string key"
  ((let h (make-hash-table :test #'string==)
     (= (href h "") 'x)
     (eq (href h "") 'x)))
  t)

(deftest "HREF character key"
  ((let h (make-hash-table :test #'eql)
     (= (href h #\a) 'x)
     (eq (href h #\a) 'x)))
  t)

(deftest "HREF character key missing"
  ((let h (make-hash-table :test #'eql)
     (= (href h #\a) 'x)
     (href h #\b)))
  nil)

(deftest "HREF hashtable key"
  ((with (h (make-hash-table :test #'eq)
          k (make-hash-table))
     (= (href h k) 'x)
     (eq (href h k) 'x)))
  t)

(deftest "HREF hashtable key missing"
  ((with (h (make-hash-table :test #'eq)
          k (make-hash-table))
     (= (href h k) 'x)
     (href h t)))
  nil)

(deftest "HREF array key"
  ((with (h (make-hash-table :test #'eq)
          k (make-array 10))
     (= (href h k) 'x)
     (eq (href h k) 'x)))
  t)

(deftest "HREF array key missing"
  ((with (h (make-hash-table :test #'eq)
          k (make-array 10))
     (= (href h k) 'x)
     (href h t)))
  nil)

;(deftest "HASHKEYS symbols" ; TODO: Make this work in the PHP back end.
;  ((let h (make-hash-table :test #'eq)
;     (= (href h 'a) 'x)
;     (= (href h 'b) 'x)
;     (= (href h 'c) 'x)
;     (sort (hashkeys h) :test #'((a b) (string<= (symbol-name a) (symbol-name b))))))
;  '(a b c))
