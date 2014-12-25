; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defun cl-expex-initializer (ex)
  (= (expex-argument-filter ex) #'identity
     (expex-setter-filter ex)   #'identity))

(defun make-cl-transpiler ()
  (create-transpiler
      :name               :common-lisp
      :frontend-only?     t
      :import-variables?  t
      :lambda-export?     nil
      :stack-locals?      nil
      :expex-initializer  #'cl-expex-initializer
      :postprocessor      #'tre2cl))

(defvar *cl-transpiler* (copy-transpiler (make-cl-transpiler)))
