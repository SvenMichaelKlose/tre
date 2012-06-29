;;;;; tré – Copyright (c) 2007,2011–2012 Sven Michael Klose <pixel@copei.de>

(functional group-head group-tail group)

(defun group-head (l size)
  (let result (make-queue)
    (while (& l (< 0 size))
           (queue-list result)
      (enqueue result (car l))
      (= l (cdr l))
      (1-! size))))

(defun group-tail (l size)
  (dotimes (i size l)
    (= l (cdr l))))

(defun group (l size)
  (let result (make-queue)
    (while l
           (queue-list result)
      (enqueue result (group-head l size))
      (= l (group-tail l size)))))
