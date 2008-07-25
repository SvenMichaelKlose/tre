;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>

(defmacro while (test result &rest body)
  "Loops over body unless test evaluates to NIL and returns result."
  (let ((tag (gensym)))
    `(block nil
       (tagbody
         ,tag
         (when ,test
           ,@body
           (go ,tag))
         (return-from nil ,result)))))
