;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun copy-array (arr)
  (do ((ret (make-array))
       (i 0 (++ i)))
      ((integer== i (length arr)) ret)
    (= (aref ret i) (aref arr i))))

(defun array-list (x)
  (let result (make-queue)
    (adotimes ((length x) (queue-list result))
      (enqueue result (aref x !)))))
