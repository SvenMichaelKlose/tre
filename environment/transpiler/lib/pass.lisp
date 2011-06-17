;;;;; TRE transpiler
;;;;; Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

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
                                                     (print ',($ '*************************** _.))
                                                     (print (funcall ,._. x)))
                                                 ,._.)))
                                        (reverse (group x 2))))
                      ,cache-var)
             (setf ,cache-var (funcall i ,cache-var))))))))
