; tré – Copyright (c) 2005–2006,2008–2015 Sven Michael Klose <pixel@copei.de>

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
    (do ((i 0 (++ i)))
        ((| (== ,(* 8 *pointer-size*) i)
            (== i l))
		 (mod (abs k) (hash-table-size h)))
      (= k (bit-xor (<< k 1) (elt str i))))))

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
    (with (size  (hash-table-size h)
           n     (make-hash-table :test (hash-table-test h)
                                  :size size)
           nb    (hash-table-buckets n)
           hb    (hash-table-buckets h))
      (dotimes (i size n)
        (= (aref nb i) (copy-alist (aref hb i)))))))

(defun hash-merge (&rest lst)
  (let l (remove-if #'not lst)
    (& l (let h (copy-hash-table l.)
           (@ (b .l h)
             (@ (j (hashkeys b))
               (= (href h j) (href b j))))))))

(defun make-hash-table (&key (test #'eq) (size *default-hash-size*))
  (%make-hash-table :test test :size size :buckets (make-array size)))
