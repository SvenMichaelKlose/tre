;;;;; tré - Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

(defvar *transpiler-debug-dump* nil)

(defmacro transpiler-pass (name args &rest x)
  (let cache-var ($ '* name '*)
    `(progn
       (defvar ,cache-var nil)
       (defun ,name ,args
         #'((init)
             (setf ,cache-var init)
             (dolist (i (list ,@(mapcan (fn `((? *transpiler-debug-dump*
                                                 #'((x)
                                                     (format t ,(string-concat "******************** before " (symbol-name _.) "~%"))
                                                     (prog1
                                                       (print (funcall ,._. x))
                                                       (format t ,(string-concat "******************** after " (symbol-name _.) "~%"))
                                                       (force-output)))
                                                 ,._.)))
                                        (reverse (group x 2))))
                      ,cache-var)
             (setf ,cache-var (funcall i ,cache-var))))))))
