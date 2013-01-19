;;;;; tré – Copyright (c) 2010–2013 Sven Michael Klose <pixel@copei.de>

(defun shared-opt-filter (fun &rest lsts)
  (with-gensym (q i)
    `(with-queue ,q
       (dolist (,i ,(? .lsts
                       `(append ,@lsts)
                       lsts.)
                (queue-list ,q))
         (enqueue ,q ,(?
                        (static-symbol-function? fun) `(,.fun. ,i)
                        (function-expr? fun)          `(,fun ,i)
                        (atom fun)                    `(funcall ,fun ,i)
                        (error "function or variable required instead of ~A" fun)))))))
