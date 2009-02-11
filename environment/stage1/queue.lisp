;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006, 2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Queue functions
;;;;
;;;; Queues are reversed stacks where the first cons' CAR points to the last
;;;; and its CDR to the first element.

(defmacro make-queue ()
  '(cons nil nil))

(defmacro enqueue (queue obj)
  "Append element to end of queue."
  (let* ((q (gensym))
	     (o (gensym)))
  `(let* ((,q ,queue)
	      (,o ,obj))
     (if (car ,q)
       (setf (car ,q) (setf (cdar ,q) (list ,o)))
       (setf (car ,q) (setf (cdr ,q) (list ,o))))
     ,o)))

(defmacro queue-pop (queue)
  "Pop first element off a queue and return it."
  (let q (gensym)
    `(let ,q ,queue
       (prog1
	     (second ,q)
	     (setf (cdr ,q) (cddr ,q))))))

(defmacro queue-list (queue)
  `(cdr ,queue))

(defun enqueue-list (queue x)
  (setf (cdr queue) (nconc (cdr queue) x)
		(car queue) (last x)))

(define-test "ENQUEUE and QUEUE-LIST work"
  ((let q (make-queue)
     (enqueue q 'a)
     (enqueue q 'b)
     (queue-list q)))
  '(a b))
