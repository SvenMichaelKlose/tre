;;;; TRE environment
;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun split (obj seq &key (test #'eql))
  "Split sequence where element is equal to 'obj' and excluding them."
  (and seq
       (let pos (position obj seq :test test)
	     (if pos
		     (cons (subseq seq 0 pos)
			       (split obj
						  (subseq seq (1+ pos))
					      :test test))
		     (list seq)))))

(define-test "SPLIT works on string"
  ((let x (split #\/ "foo/bar")
	 (and (string= "foo" (first x))
	 	  (string= "bar" (second x))
		  (not (cddr x)))))
  t)
