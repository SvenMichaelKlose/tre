;;;;; TRE transpiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defvar *transpiler-debug-dump* nil)

(defmacro transpiler-pass (&rest x)
  `(compose ,@(mapcan (fn if *transpiler-debug-dump*
                             `((fn (print ',($ '*************************** _.))
                                   (print (funcall ,._. _))))
                             `(,._.))
                      (group x 2))))
