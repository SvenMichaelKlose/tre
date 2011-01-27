;;;; TRE environment
;;;; Copyright (c) 2005-2006,2008-2011 Sven Klose <pixel@copei.de>

(defvar *default-hash-size* 2048)

(defstruct %hash-table
  test              ; Function for equality test of keys.
  size              ; Initial hash table size.
  hash              ; Internal hash table.
  count)            ; Number of elements stored in the table.

(defun hash-table? (x)
  (%hash-table? x))

(defun make-hash-table (&key (test #'eq)
							 (size *default-hash-size*))
  (make-%hash-table :test test :size size
    				:hash (make-array *default-hash-size*)))

(defun %make-hash-index-num (h k)
  (mod (abs k) (%hash-table-size h)))

(defun %make-hash-index-string (h str)
  (with (k 0
	     l (length str))
    (do ((i 0 (integer-1+ i)))
        ((or (integer< 4 i)
			 (integer= i l))
		 (mod (abs k) (%hash-table-size h)))
      (setf k (integer+ (<< k 4) (elt str i))))))

(defun %make-hash-index (h key)
  (if
    (number? key)
      (%make-hash-index-num h key)
    (stringp key)
      (%make-hash-index-string h key)
    (%make-hash-index-num h (>> (%id key) 2))))

(defmacro %with-hash-bucket (bucket idx h key &rest body)
  `(with (,idx (%make-hash-index ,h ,key)
	      ,bucket (aref (%hash-table-hash ,h) ,idx))
    ,@body))

(defun href (h key)
  (%with-hash-bucket b i h key
    (assoc-value key b :test (%hash-table-test h))))

(defun (setf href) (new-value h key)
  (let tst (%hash-table-test h)
    (%with-hash-bucket b i h key
      (if (assoc key b :test tst)
          (setf (cdr (assoc key b :test tst)) new-value)
          (setf (aref (%hash-table-hash h) i) (acons key new-value b)))))
  new-value)

(defun hremove (h key)
  (%with-hash-bucket b i h key
    (setf (aref (%hash-table-hash h) i)
		  (remove (assoc key b :test (%hash-table-test h))
				  b))))

(defun hashkeys (h)
  (let keys nil
	(dotimes (i (length (%hash-table-hash h)) keys)
	  (push (carlist (aref (%hash-table-hash h) i))
		    keys))
    (apply #'nconc keys)))
