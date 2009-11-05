;;;;; TRE to ECMAScript transpiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun hash-table? (x)
  (and (objectp x)
       (undefined? x.__class)))

(defun hash-assoc (x)
  (let lst nil
    (maphash #'((k v)
				  (push! (cons k v) lst))
         	 x)
    (reverse lst)))

;; XXX test is ignored.
(defun assoc-hash (x &key (test nil))
  (let h (make-hash-table)
    (dolist (i x h)
      (setf (href h i.) .i))))
