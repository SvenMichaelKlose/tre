; tré – Copyright (c) 2008–2010,2012–2015 Sven Michael Klose <pixel@copei.de>

(defun bc-expex-initializer (ex)
  (= (expex-setter-filter ex) (compose [mapcan [expex-set-global-variable-value _] _]
                                       #'expex-compiled-funcall)))

(defun make-bc-transpiler ()
  (aprog1 (create-transpiler
              :name                 :bytecode
			  :lambda-export?       t
			  :stack-locals?        t
			  :arguments-on-stack?  t
              :disabled-passes      '(:encapsulate-strings
                                      :convert-identifiers)
              :function-prologues?  nil
              :function-name-prefix nil
              :import-variables?    nil
              :expex-initializer    #'bc-expex-initializer
              :postprocessor        #'tree-list
              :configurations       '((:save-sources? . nil)
                                      (:save-argument-defs-only? . nil)))
    (transpiler-add-plain-arg-funs ! *builtins*)))

(defvar *bc-transpiler* (make-bc-transpiler))
