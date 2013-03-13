;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defun array-list (x)
  (let result (make-queue)
    (dotimes (i (length x) (queue-list result))
      (enqueue result (aref x i)))))

(defun array-copy (arr)
  (let ret (make-array)
    (doarray (x arr ret)
      (ret.push x))))

(defun array-filter (arr pred)
  (declare type array arr)
  (let ret (make-array)
    (doarray (v arr ret)
      (when (pred v)
	    (ret.push v)))))

(defun array-merge (a b)
  (declare type array a b)
  (when (| a b)
    (when (not a)
	  (= a (make-array)))
    (? b
       (doarray (x b a)
	     (a.push x))
	   a)))

(defun array-first (x)
  (declare type array x)
  (when (< 0 x.length)
	(aref x 0)))

(defun force-array (x)
  (? (array? x)
     x
     (aprog1 (make-array)
	   (= (aref ! 0) x))))
