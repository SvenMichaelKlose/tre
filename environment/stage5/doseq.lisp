;;;;; tré – Copyright (c) 2011,2013–2014 Sven Michael Klose <pixel@copei.de>

(defmacro doseq ((iter init &optional (result nil)) &body body)
  (with-gensym g
    `(dolist (,iter (let ,g ,init
                      (? (list? ,g)
                         ,g
                         (array-list ,g)))
              ,result)
       ,@body)))
