;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>
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
    :test (or test eq) :size 157
    :rehash-size rehash-size :rehash-threshold rehash-threshold
    :hash (make-array 157)))

(defun %make-hash-index-num (h k)
  "Make hash index from number."
  (mod k (%hash-table-size h)))

(defun %make-hash-index-string (h str)
  "Make hash index from string."
  (let ((k 0)
	(l (length str)))
    (do ((i 0 (1+ i)))
        ((or (= i l) (> i 7)) (mod k (%hash-table-size h)))
      (setf k (+ k (elt str i))))))

(defun %make-hash-index (h key)
  (if (numberp key)
    (%make-hash-index-num h key)
    (if (stringp key)
      (%make-hash-index-string h key)
      (error "key type unsupported"))))

; Get bucket list and its index.
(defmacro %with-hash-bucket (bucket idx h key &rest body)
  `(let* ((,idx (%make-hash-index ,h ,key))
	  (,bucket (aref (%hash-table-hash ,h) ,idx)))
    ,@body))

(defun gethash (key h &optional default)
  "Get hash value by key."
  (%with-hash-bucket b i h key
    (assoc key b :test (%hash-table-test h))))

(defun (setf gethash) (new-value key h &optional default)
  (let ((t (%hash-table-test h)))
    (%with-hash-bucket b i h key
      (if (assoc key b :test t)
        ; Modify existing value.
        (setf (assoc key b :test t) new-value)
        ; Add new value/key pair.
        (setf (aref (%hash-table-hash h) i) (acons key new-value b)))))
  new-value)
