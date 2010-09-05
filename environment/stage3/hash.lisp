;;;; TRE environment
;;;; Copyright (c) 2005-2006,2008-2010 Sven Klose <pixel@copei.de>
;;;;
;;;; Generalized hash-table

(defvar *default-hash-size* 2048)

(defstruct %hash-table
  test              ; Function for equality test of keys.
  size              ; Initial hash table size.
  hash              ; Internal hash table.
  count             ; Number of elements stored in the table.
  )

(defun hash-table? (x)
  (%hash-table-p x))

(defun make-hash-table (&key (test #'eq)
							 (size *default-hash-size*))
  "Create a new hash table."
  (make-%hash-table :test test :size size
    				:hash (make-array *default-hash-size*)))

(defun %make-hash-index-num (h k)
  "Make hash index from number."
  (mod (abs k) (%hash-table-size h)))

(defun %make-hash-index-string (h str)
  "Make hash index from string."
  (with (k 0
	     l (length str))
    (do ((i 0 (integer-1+ i)))
        ((or (integer< 4 i)
			 (integer= i l))
		 (mod (abs k) (%hash-table-size h)))
      (setf k (integer+ (<< k 4) (elt str i))))))

(defun %make-hash-index (h key)
  (if
    (numberp key)
      (%make-hash-index-num h key)
    (stringp key)
      (%make-hash-index-string h key)
    (%make-hash-index-num h (>> (%id key) 2))))

; Get bucket list and its index.
(defmacro %with-hash-bucket (bucket idx h key &rest body)
  `(with (,idx (%make-hash-index ,h ,key)
	      ,bucket (aref (%hash-table-hash ,h) ,idx))
    ,@body))

(defun href (h key)
  "Get hash value by key."
  (%with-hash-bucket b i h key
    (assoc-value key b :test (%hash-table-test h))))

(defun (setf href) (new-value h key)
  (with (tst (%hash-table-test h))
    (%with-hash-bucket b i h key
      (if (assoc key b :test tst)
        ; Modify existing value.
        (setf (cdr (assoc key b :test tst)) new-value)
        ; Add new value/key pair.
        (setf (aref (%hash-table-hash h) i) (acons key new-value b)))))
  new-value)

(defun hremove (h key)
  "Get hash value by key."
  (%with-hash-bucket b i h key
    (setf (aref (%hash-table-hash h) i)
		      (remove (assoc key b :test (%hash-table-test h))
				      b))))

(defun hashkeys (h)
  (let keys nil
	(dotimes (i (length (%hash-table-hash h)) keys)
	  (push! (carlist (aref (%hash-table-hash h) i))
			 keys))
    (apply #'nconc keys)))
