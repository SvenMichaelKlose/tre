; tré – Copyright (c) 2008–2010,2012–2014 Sven Michael Klose <pixel@copei.de>

(defun make-cl-transpiler ()
  (create-transpiler
      :name               :common-lisp
      :frontend-only?     t
      :import-variables?  t
      :lambda-export?     nil
      :stack-locals?      nil
      :postprocessor      #'tre2cl))

(defvar *cl-transpiler* (copy-transpiler (make-cl-transpiler)))
