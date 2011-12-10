;;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defun copy-array (x &key (copy-elements? nil))
  (with (size (length x)
         new-array (make-array size))
    (dotimes (i size new-array)
      (let v (aref x i)
        (setf (aref new-array i) (? (cons? v)
                                    (copy-tree v)
                                    v))))))
