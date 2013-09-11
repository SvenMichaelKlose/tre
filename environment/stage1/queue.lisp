;;;;; tré – Copyright (c) 2005–2006,2008,2010,2012 Sven Michael Klose <pixel@copei.de>

(defun make-queue ()
  (cons nil nil))

(defun enqueue (queue &rest x)
  (rplaca queue
          (cdr (rplacd (| (car queue) queue)
                       x)))
  x)

(defun enqueue-list (queue x)
  (rplacd queue (nconc (cdr queue) x))
  (rplaca queue (last x)))

(defun queue-pop (queue)
  (prog1 (cadr queue)
    (? (not (cddr queue))
       (rplaca queue nil))
    (? (cdr queue)
       (rplacd queue (cddr queue)))))

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
