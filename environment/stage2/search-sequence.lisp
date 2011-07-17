;;;;; TRE environment
;;;;; Copyright (c) 2005-2006,2008-2009,2011 Sven Klose <pixel@copei.de>

(functional find position)

(defmacro xchg (a b)
  (with-gensym g
    `(let ,g ,a
	   (setf ,a ,b
	   		 ,b ,g))))

(defun find-if (pred seq &key (start nil) (end nil) (from-end nil) (with-index nil))
  (when (and seq (integer< 0 (length seq)))
    (let* ((e (or end (integer-1- (length seq))))
	 	   (s (or start 0)))
      ; Make sure the start and end indices are sane.
      (when (or (and (integer> s e)
				     (not from-end))
                (and (integer< s e)
				     from-end))
        (xchg s e))
      (do ((i s (? from-end
				   (integer-1- i)
				   (integer-1+ i))))
          ((? from-end
	          (integer< i e)
			  (integer> i e)))
	    (let elm (elt seq i)
          (when (apply pred (cons elm
                                  (when with-index
								    (list i))))
		    (return elm)))))))
 
(defun find (obj seq &key (start nil) (end nil) (from-end nil) (test #'eql))
  (find-if (fn funcall test _ obj) seq :start start :end end :from-end from-end))

(define-test "FIND finds elements"
  ((find 's '(l i s p)))
  's)

(define-test "FIND accepts :FROM-END"
  ((find 's '(l i s p) :from-end t))
  's)

(define-test "FIND accepts :END"
  ((find 's '(l i s p) :end 1))
  nil)

(define-test "FIND accepts :START"
  ((find 'l '(l i s p) :start 1))
  nil)

(define-test "FIND accepts :START, :END, :FROM-END"
  ((find 'l '(l i s p) :start 1 :end 2 :from-end 1))
  nil)

(define-test "FIND-IF finds elements"
  ((find-if #'number? '(l i 5 p)))
  5)

(defun position (obj seq &key (start nil) (end nil) (from-end nil) (test #'eql))
  (let idx nil
    (find-if #'((x i)
				  (when (funcall test x obj)
					(setf idx i)))
			 seq :start start :end end :from-end from-end :with-index t)
	idx))

(define-test "POSITION works with character list"
  ((position 's '(l i s p)))
  2)

(define-test "POSITION works with strings"
  ((position #\/ "lisp/foo/bar"))
  4)

(defun position-if (pred seq &key (start nil) (end nil) (from-end nil))
  (let idx nil
    (find-if #'((x i)
				  (when (funcall pred x)
					(setf idx i)))
			 seq :start start :end end :from-end from-end :with-index t)
	idx))

(defun some (pred &rest seqs)
  (find-if pred (apply #'append seqs)))

(define-test "SOME works"
  ((and (some #'number? '(a b 3)))
        (not (some #'number? '(a b c))))
  t)

(defun every (pred &rest seqs)
  (dolist (seq seqs t)
    (dotimes (i (length seq))
      (unless (funcall pred (elt seq i))
        (return-from every nil)))))

(define-test "EVERY works"
  ((and (every #'number? '(1 2 3))
        (not (every #'number? '(1 2 a)))))
  t)
