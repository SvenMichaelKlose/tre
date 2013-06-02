;;;;; tré – Copyright (c) 2010–2013 Sven Michael Klose <pixel@copei.de>

(defmacro transpiler-pass (name args &rest x)
  (with (cache-var ($ '*pass- name '*)
         init (gensym)
         tr '*transpiler*)
    `(progn
       (defvar ,cache-var nil)
       (defun ,name (,@args ,init)
         (= ,cache-var ,init)
         (dolist (i (list ,@(mapcan ^((with-temporary (transpiler-current-pass ,tr) ,(list 'quote _.)
                                        (? (transpiler-dump-passes? ,tr)
                                           #'((x)
                                               (format t ,(string-concat "; **** " (symbol-name _.) "~%"))
                                               (prog1
                                                 (print (funcall ,._. x))
                                                 (format t ,(string-concat "; **** " (symbol-name _.) " (end)~%"))
                                                 (force-output)))
                                           ,._.)))
                                    (group x 2)))
                   ,cache-var)
           (= ,cache-var (= (transpiler-last-pass-result ,tr) (funcall i ,cache-var))))))))
