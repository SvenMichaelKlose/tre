;;;;; tré - Copyright (c) 2005-2006,2008,2010,2012 Sven Michael Klose <pixel@copei.de>

(defun make-queue ()
  (cons nil nil))

(defun enqueue (queue obj)
  (? (car queue)
     (setf (car queue) (setf (cdar queue) (list obj)))
     (setf (car queue) (setf (cdr queue) (list obj))))
  obj)

(defun enqueue-list (queue x)
  (setf (cdr queue) (nconc (cdr queue) x)
		(car queue) (last x)))

(defun queue-pop (queue)
  (let v (cadr queue)
    (? (eq (car queue) (cdr queue))
       (setf (car queue) nil))
    (? (cdr queue)
       (setf (cdr queue) (cddr queue)))
    v))

(functional queue-list queue-front)

(defun queue-list (queue)
  (cdr queue))

(defun queue-front (queue)
  (car (cdr queue)))

(define-test "ENQUEUE and QUEUE-LIST work"
  ((let q (make-queue)
     (enqueue q 'a)
     (enqueue q 'b)
     (queue-list q)))
  '(a b))
