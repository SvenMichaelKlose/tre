;;;;; TRE transpiler
;;;;; Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

(defvar *transpiler-debug-dump* nil)

(defmacro transpiler-pass (name args &rest x)
  (let cache-var ($ '* name '*)
    `(progn
       (defvar ,cache-var nil)
       (defun ,name ,args
         (setf ,cache-var (compose ,@(mapcan (fn ? *transpiler-debug-dump*
                                                   `((fn (print ',($ '*************************** _.))
                                                         (print (funcall ,._. _))))
                                                    `(,._.))
                                             (group x 2))))))))
