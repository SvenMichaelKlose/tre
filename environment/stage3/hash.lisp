;;;;; tré - Copyright (c) 2005-2006,2008-2012 Sven Klose <pixel@copei.de>

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
  (let i k
    (setf k (>> k 8))
    (setf i (logxor i k))
    (setf k (>> k 8))
    (setf i (logxor i k))
    (setf k (>> k 8))
    (mod (logxor i k) (%hash-table-size h))))

(defun %make-hash-index-string (h str)
  (with (k 0
	     l (length str))
    (do ((i 0 (integer-1+ i)))
        ((or (integer< 4 i)
			 (integer= i l))
		 (mod (abs k) (%hash-table-size h)))
      (setf k (logxor k (elt str i))))))

(defun %make-hash-index (h key)
  (?
    (number? key) (%make-hash-index-num h key)
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

(defun (setf href) (new-value h key)
  (declare type hash-table h)
  (let tst (%hash-table-test h)
    (%with-hash-bucket b i h key
      (? (assoc key b :test tst)
         (setf (cdr (assoc key b :test tst)) new-value)
         (setf (aref (%hash-table-hash h) i) (acons key new-value b)))))
  new-value)

(defun hremove (h key)
  (declare type hash-table h)
  (%with-hash-bucket b i h key
    (setf (aref (%hash-table-hash h) i)
		  (remove (assoc key b :test (%hash-table-test h)) b))))

(defun hashkeys (h)
  (declare type hash-table h)
  (let keys nil
	(dotimes (i (length (%hash-table-hash h)) keys)
	  (push (carlist (aref (%hash-table-hash h) i)) keys))
    (apply #'nconc keys)))

(defun copy-hash-table (h)
  (declare type hash-table h)
  (with (tst (%hash-table-test h)
         n (make-hash-table :test tst))
    (dolist (i (hashkeys h) n)
      (setf (href n i) (href h i)))))
