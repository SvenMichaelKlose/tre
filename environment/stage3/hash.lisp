;;;; TRE environment
;;;; Copyright (c) 2005-2006,2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Generalized hash-table

(defstruct %hash-table
  test              ; Function for equality test of keys.
  size              ; Initial hash table size.
  rehash-size       ; Minimum amount of elements to grow.
  rehash-threshold  ; Maximum table size until it must grow.
  hash              ; Internal hash table.
  count             ; Number of elements stored in the table.
  )

(defun make-hash-table (&key test size rehash-size rehash-threshold)
  "Create a new hash table."
  (make-%hash-table
    :test (or test #'eq) :size 4096
    :rehash-size rehash-size :rehash-threshold rehash-threshold
    :hash (make-array 4096)))

(defun %make-hash-index-num (h k)
  "Make hash index from number."
  (mod (abs k) (%hash-table-size h)))

(defun %make-hash-index-string (h str)
  "Make hash index from string."
  (with (k 0
	     l (length str))
    (do ((i 0 (1+ i)))
        ((or (< 4 i)
			 (= i l))
		 (mod k (%hash-table-size h)))
      (setf k (+ (<< k 4) (elt str i))))))

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

(defun href (key h)
  "Get hash value by key."
  (%with-hash-bucket b i h key
    (cdr (assoc key b :test (%hash-table-test h)))))

(defun (setf href) (new-value key h)
  (with (tst (%hash-table-test h))
    (%with-hash-bucket b i h key
      (if (assoc key b :test tst)
        ; Modify existing value.
        (setf (cdr (assoc key b :test tst)) new-value)
        ; Add new value/key pair.
        (setf (aref (%hash-table-hash h) i) (acons key new-value b)))))
  new-value)

(defun hashkeys (h)
  (with (keys nil)
	(dotimes (i (length (%hash-table-hash h)) keys)
	  (setf keys (append (carlist (aref (%hash-table-hash h) i)) keys)))))
