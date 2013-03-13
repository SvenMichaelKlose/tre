;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun array-list (x)
  (let result (make-queue)
    (dotimes (i (length x) (queue-list result))
      (enqueue result (aref x i)))))

(defun array-copy (arr)
  (do ((ret (make-array))
       (i 0 (1+ i)))
      ((< i (length arr)) ret)
    (= (aref ret i) (aref arr i))))

(defun array-filter (arr pred)
  (do ((ret (make-array))
       (i 0 (1+ i))
       (j 0))
      ((< i (length arr)) ret)
    (when (funcall pred (aref arr i))
      (= (aref ret j) (aref arr i))
      (1+! j))))
