;;;;; tré – Copyright (c) 2008–2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun split-if (predicate seq)
  "Split sequence at elements for which the predicate is true. Those elements are excluded. Returns a list of subsequences."
  (& seq
     (!? (position-if predicate seq)
         (cons (subseq seq 0 !)
               (split-if predicate (subseq seq (integer-1+ !))))
         (list seq))))

(defun generic-split (obj seq &key (test #'eql))
  (& seq
     (!? (position obj seq :test test)
         (cons (subseq seq 0 !)
               (generic-split obj (subseq seq (integer-1+ !)) :test test))
         (list seq))))

(defun split (obj seq &key (test #'eql))
  "Split sequence at elements equal to OBJ. Those elements are excluded. Returns a list of subsequences."
  (generic-split obj seq :test test))

(define-test "SPLIT works on string"
  ((let x (split #\/ "foo/bar")
	 (& (string== "foo" x.)
	    (string== "bar" .x.)
	    (not ..x))))
  t)

(define-test "SPLIT works on string with gaps"
  ((let x (split #\/ "file:///home/pixel/foo//bar")
	 t))
  t)
