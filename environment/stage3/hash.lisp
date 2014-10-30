;;;;; tré – Copyright (c) 2005–2006,2008–2014 Sven Michael Klose <pixel@copei.de>

(defvar *default-hash-size* 2039)

(defstruct hash-table
  (:constructor %make-hash-table)
  test
  size
  buckets)

(defun %make-hash-index-num (h k)
  (mod k (hash-table-size h)))

(defun %make-hash-index-string (h str)
  (with (k 0
	     l (length str))
    (do ((i 0 (integer++ i)))
        ((| (integer== ,(* 8 *pointer-size*) i)
            (integer== i l))
		 (mod (abs k) (hash-table-size h)))
      (= k (logxor (<< k 1) (elt str i))))))

(defun %make-hash-index (h key)
  (?
    (number? key) (%make-hash-index-num h (abs (integer key)))
    (string? key) (%make-hash-index-string h key)
    (%make-hash-index-num h (%%id key))))

(defmacro %with-hash-bucket (bucket idx h key &body body)
  `(with (,idx    (%make-hash-index ,h ,key)
	      ,bucket (aref (hash-table-buckets ,h) ,idx))
    ,@body))

(defun href (h key)
  (%with-hash-bucket b i h key
    (assoc-value key b :test (hash-table-test h))))

(defun (= href) (new-value h key)
  (let tst (hash-table-test h)
    (%with-hash-bucket b i h key
      (? (assoc key b :test tst)
         (= (cdr (assoc key b :test tst)) new-value)
         (= (aref (hash-table-buckets h) i) (acons key new-value b)))))
  new-value)

(defun hremove (h key)
  (%with-hash-bucket b i h key
    (= (aref (hash-table-buckets h) i)
	   (remove (assoc key b :test (hash-table-test h)) b))))

(defun hashkeys (h)
  (let keys nil
	(dotimes (i (length (hash-table-buckets h)) keys)
	  (push (carlist (aref (hash-table-buckets h) i)) keys))
    (apply #'append keys)))

(defun copy-hash-table (h)
  (when h
    (with (n  (make-hash-table :test (hash-table-test h)
                               :size (hash-table-size h))
           nb (hash-table-buckets n)
           hb (hash-table-buckets h))
      (dotimes (i size n)
        (= (aref nb i) (copy-alist (aref hb i)))))))

(defun hash-merge (&rest lst)
  (let l (remove-if #'not lst)
    (& l (let h (copy-hash-table l.)
           (dolist (b .l h)
             (dolist (j (hashkeys b))
               (= (href h j) (href b j))))))))

(defun hash-alist (h)
  (with-queue alist
    (dolist (i (hashkeys h) (queue-list alist))
      (enqueue alist (cons i (href h i))))))

(defun alist-hash (x &key (test #'eql))
  (let h (make-hash-table :test test)
    (dolist (i x h)
      (= (href h i.) .i))))

(defun make-hash-table (&key (test #'eq) (size *default-hash-size*))
  (%make-hash-table :test test :size size :buckets (make-array size)))

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
