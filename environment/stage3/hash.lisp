;;;;; tré – Copyright (c) 2005–2006,2008–2012 Sven Michael Klose <pixel@copei.de>

(defvar *default-hash-size* 2039)

(defstruct %hash-table
  test              ; Function for equality test of keys.
  size              ; Initial hash table size.
  hash              ; Internal hash table.
  count)            ; Number of elements stored in the table.

(defun hash-table? (x)
  (%hash-table? x))

(defun make-hash-table (&key (test #'eq) (size *default-hash-size*))
  (make-%hash-table :test test :size size :hash (make-array *default-hash-size*)))

(defun %make-hash-index-num (h k)
  (mod k (%hash-table-size h)))

(defun %make-hash-index-string (h str)
  (with (k 0
	     l (length str))
    (do ((i 0 (integer-1+ i)))
        ((| (integer== ,(* 8 *pointer-size*) i)
            (integer== i l))
		 (mod (abs k) (%hash-table-size h)))
      (= k (logxor (<< k 1) (elt str i))))))

(defun %make-hash-index (h key)
  (?
    (number? key) (%make-hash-index-num h (abs (integer key)))
    (string? key) (%make-hash-index-string h key)
    (%make-hash-index-num h (%%id key))))

(defmacro %with-hash-bucket (bucket idx h key &rest body)
  `(with (,idx (%make-hash-index ,h ,key)
	      ,bucket (aref (%hash-table-hash ,h) ,idx))
    ,@body))

(defun href (h key)
  (declare type hash-table h)
  (%with-hash-bucket b i h key
    (assoc-value key b :test (%hash-table-test h))))

(defun (= href) (new-value h key)
  (declare type hash-table h)
  (let tst (%hash-table-test h)
    (%with-hash-bucket b i h key
      (? (assoc key b :test tst)
         (= (cdr (assoc key b :test tst)) new-value)
         (= (aref (%hash-table-hash h) i) (acons key new-value b)))))
  new-value)

(defun hremove (h key)
  (declare type hash-table h)
  (%with-hash-bucket b i h key
    (= (aref (%hash-table-hash h) i)
	   (remove (assoc key b :test (%hash-table-test h)) b))))

(defun hashkeys (h)
  (declare type hash-table h)
  (let keys nil
	(dotimes (i (length (%hash-table-hash h)) keys)
	  (push (carlist (aref (%hash-table-hash h) i)) keys))
    (apply #'nconc keys)))

(defun copy-hash-table (h)
  (declare type hash-table h)
  (let n (make-hash-table :test (%hash-table-test h)
                          :size (%hash-table-size h))
    (dolist (i (hashkeys h) n)
      (= (href n i) (href h i)))))

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
