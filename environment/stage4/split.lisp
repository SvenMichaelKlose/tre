;;;;; tré – Copyright (c) 2008–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun split-if (predicate seq &key (include? nil))
  (& seq
     (!? (position-if predicate seq)
         (. (subseq seq 0 (? include?
                             (integer++ !)
                             !))
            (split-if predicate (subseq seq (integer++ !)) :include? include?))
         (list seq))))

(defun generic-split (obj seq &key (test #'eql) (include? nil))
  (& seq
     (!? (position obj seq :test test)
         (. (subseq seq 0 (? include?
                             (integer++ !)
                             !))
            (generic-split obj (subseq seq (integer++ !)) :test test :include? include?))
         (list seq))))

(defun split (obj seq &key (test #'eql) (include? nil))
  (generic-split obj seq :test test :include? include?))

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
