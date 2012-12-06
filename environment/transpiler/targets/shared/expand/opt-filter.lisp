;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun shared-opt-filter (fun lst)
  (with-gensym (q i)
    `(with-queue ,q
       (dolist (,i ,lst (queue-list ,q))
         (enqueue ,q (funcall ,fun ,i))))))
