;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun array-list (x)
  (let result (make-queue)
    (adotimes ((length x) (queue-list result))
      (enqueue result (aref x !)))))

(defun array-copy (arr)
  (do ((ret (make-array))
       (i 0 (++ i)))
      ((integer== i (length arr)) ret)
    (= (aref ret i) (aref arr i))))

(defun array-filter (arr pred)
  (do ((ret (make-array))
       (i 0 (++ i))
       (j 0))
      ((integer== i (length arr)) ret)
    (when (funcall pred (aref arr i))
      (= (aref ret j) (aref arr i))
      (++! j))))
