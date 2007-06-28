;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>
;;;;
;;;; Searching sequences

(defmacro xchg (a b)
  "Swaps values of the arguments."
  (with-gensym g
    `(setf ,g ,a
	   ,a ,b
	   ,b ,g)))

(defmacro with-find-parameters (&rest body)
  `(let ((e (or end (1- (length seq))))
	 (s (or start 0))
	 (tst (or test
		  (if test-not
		    #'(lambda (x y)
		        (not (funcall test-not x y))))
		  #'eql)))
    ; Make sure the start and end indices are sane.
    (if (or (and (> s e) (not from-end))
            (and (< s e) from-end))
      (xchg s e))
    (do ((i s (if from-end (1- i) (1+ i))))
        ((if from-end
	  (< i e) (> i e)))
      (when seq
        ,@body))))
 
(defun find (val seq &key start end from-end test test-not)
  "Return element in sequence."
    (with-find-parameters
      (let ((el (elt seq i)))
        (when (funcall tst val el)
          (return el)))))

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

(defun find-if (pred seq &key start end from-end)
  "Return first element in sequence that matches the predicate function."
  (let ((e (or end (1- (length seq))))
	(s (or start 0)))
    ; Make sure the start and end indices are sane.
    (if (or (and (> s e) (not from-end))
            (and (< s e) from-end))
      (xchg s e))
    (do ((i s (if from-end (1- i) (1+ i))))
        ((if from-end
	   (< i e) (> i e)))
      (let ((el (elt seq i)))
        (when (funcall pred el)
          (return el))))))

(define-test "FIND-IF finds elements"
  ((find-if #'numberp '(l i 5 p)))
  5)

(defun position (val seq &key start end from-end test test-not)
  (with-find-parameters
    (when (funcall tst val (elt seq i))
      (return i))))

(define-test "POSITION works"
  ((position 's '(l i s p)))
  2)

(defun some (pred &rest seqs)
  "OR predicate over list elements."
  (dolist (seq seqs)
    (dotimes (i (length seq) nil)
      (when (funcall pred (elt seq i))
        (return-from some t)))))

(define-test "SOME works"
  ((and (some #'numberp '(a b 3)))
        (not (some #'numberp '(a b c))))
  t)

(defun every (pred &rest seqs)
  "AND predicate over list elements."
  (dolist (seq seqs)
    (dotimes (i (length seq) t)
      (unless (funcall pred (elt seq i))
        (return-from every nil)))))

(define-test "EVERY works"
  ((and (every #'numberp '(1 2 3)))
        (not (every #'numberp '(1 2 a))))
  t)
