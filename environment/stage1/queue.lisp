;;;; TRE environment
;;;; Copyright (C) 2005-2006, 2008, 2010 Sven Klose <pixel@copei.de>

(defun make-queue ()
  (cons nil nil))

(defun enqueue (queue obj)
  (if (car queue)
      (setf (car queue) (setf (cdar queue) (list obj)))
      (setf (car queue) (setf (cdr queue) (list obj))))
  obj)

(defun enqueue-list (queue x)
  (setf (cdr queue) (nconc (cdr queue) x)
		(car queue) (last x)))

(defun queue-pop (queue)
  (let v (cadr queue)
    (if (eq (car queue) (cdr queue))
        (setf (car queue) nil))
    (if (cdr queue)
        (setf (cdr queue) (cdddr queue)))
    v))

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
