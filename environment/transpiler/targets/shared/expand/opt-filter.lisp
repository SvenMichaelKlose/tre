; tré – Copyright (c) 2010–2013,2015 Sven Michael Klose <pixel@copei.de>

(defun function-to-funcall (x i)
  (alet (macroexpand x)
    (?
      (literal-function? !)  `(,.!. ,@i)
      (function-expr? !)     `(,! ,@i)
      (| (atom !)
         (%closure? !))      `(funcall ,! ,@i)
      (error "Function or variable required instead of ~A." !))))

(define-shared-std-macro (bc c js php) filter (fun &rest lsts)
  (with-gensym (q i)
    `(with-queue ,q
       (dolist (,i ,(? .lsts
                       `(append ,@lsts)
                       lsts.)
                (queue-list ,q))
         (enqueue ,q ,(function-to-funcall fun (list i)))))))
