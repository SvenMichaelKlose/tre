;;;;; tré – Copyright (c) 2010–2013 Sven Michael Klose <pixel@copei.de>

(defun shared-opt-filter (fun &rest lsts)
  (with-gensym (q i)
    `(with-queue ,q
       (dolist (,i ,(? .lsts
                       `(append ,@lsts)
                       lsts.)
                (queue-list ,q))
         (enqueue ,q ,(alet (macroexpand fun)
                        (?
                          (literal-symbol-function? !) `(,.!. ,i)
                          (function-expr? !)           `(,! ,i)
                          (| (atom !)
                             (%%closure? !))           `(funcall ,! ,i)
                          (error "Function or variable required instead of ~A." !))))))))

(define-shared-std-macro (bc c js php) filter (&rest x)
  (shared-opt-filter fun lsts))
