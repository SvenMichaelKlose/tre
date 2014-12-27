; tré – Copyright (c) 2008–2010,2012–2014 Sven Michael Klose <pixel@copei.de>

(defun bc-expex-initializer (ex)
  (= (expex-setter-filter ex) (compose [mapcan [expex-set-global-variable-value _] _]
                                       #'expex-compiled-funcall)))

(defun make-bc-transpiler ()
  (aprog1 (create-transpiler
              :name                 :bytecode
			  :lambda-export?       t
			  :stack-locals?        t
			  :arguments-on-stack?  t
              :make-text?           nil
              :encapsulate-strings? nil
              :function-prologues?  nil
              :function-name-prefix nil
              :import-variables?    nil
              :expex-initializer    #'bc-expex-initializer
              :postprocessor        #'tree-list)
    (transpiler-add-plain-arg-funs ! *builtins*)))

(defvar *bc-transpiler* (copy-transpiler (make-bc-transpiler)))
