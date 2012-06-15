;;;;; tré – Copyright (c) 2010–2012 Sven Michael Klose <pixel@copei.de>

(defmacro transpiler-pass (name args &rest x)
  (with (cache-var ($ '*pass- name '*)
         init (gensym)
         tr '*current-transpiler*)
    `(progn
       (defvar ,cache-var nil)
       (defun ,name (,@args ,init)
         (setf ,cache-var ,init)
         (dolist (i (list ,@(mapcan (fn `((with-temporary (transpiler-current-pass ,tr) ,(list 'quote _.)
                                            (? (transpiler-dump-passes? ,tr)
                                               #'((x)
                                                    (format t ,(string-concat "; **** before " (symbol-name _.) "~%"))
                                                    (prog1
                                                      (print (funcall ,._. x))
                                                      (format t ,(string-concat "; **** after " (symbol-name _.) "~%"))
                                                      (force-output)))
                                               ,._.))))
                                    (reverse (group x 2))))
                   ,cache-var)
           (setf ,cache-var (setf (transpiler-last-pass-result ,tr) (funcall i ,cache-var))))))))
