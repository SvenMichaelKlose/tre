;;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defmacro doseq ((iter init &optional (result nil)) &rest body)
  (with-gensym g
    `(dolist (,iter (let ,g ,init
                      (? (listp ,g)
                         ,g
                         (array-list ,g)))
              ,result)
       ,@body)))
