;;;;; tré - Copyright (c) 2008-2009,2011-2012 Sven Michael Klose <pixel@copei.de>

(defun split-if (test seq)
  (and seq
       (!? (position-if test seq)
           (cons (subseq seq 0 !)
                 (split-if test (subseq seq (integer-1+ !))))
           (list seq))))

(defun generic-split (obj seq &key (test #'eql))
  "Split sequence where element is equal to 'obj' and excluding them."
  (and seq
       (let pos (position obj seq :test test)
	     (? pos
		    (cons (subseq seq 0 pos)
		          (split obj
					     (subseq seq (integer-1+ pos))
				         :test test))
		     (list seq)))))

(defun split (obj seq &key (test #'eql))
  (generic-split obj seq :test test))

(define-test "SPLIT works on string"
  ((let x (split #\/ "foo/bar")
	 (and (string= "foo" x.)
	 	  (string= "bar" .x.)
		  (not ..x))))
  t)

(define-test "SPLIT works on string with gaps"
  ((let x (split #\/ "file:///home/pixel/foo//bar")
	 t))
  t)
