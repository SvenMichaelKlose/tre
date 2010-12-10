;;;;; TRE transpiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun cblock-to-metacode (x)
  (with (blks (cdr (butlast x))
         tags (mapcar (fn cons _ (make-compiler-tag)) blks))
    (mapcan #'((tag cb)
                 (append (list tag)
                         (cblock-code cb)
                         (aif (cblock-conditional-next cb)
                              `((%%vm-go-nil ,(cblock-conditional-place cb)
                                             ,(assoc-value ! tags :test #'eq)))
                              (awhen (assoc-value (cblock-next cb) tags :test #'eq)
                                `((%%vm-go ,!))))))
            (cdrlist tags)
            blks)))
