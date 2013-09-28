;;;;; tré – Copyright (c) 2008–2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun bc-expex-initializer (ex)
  (= (expex-argument-filter ex) #'bc-expex-argument-filter
     (expex-setter-filter ex) (compose [mapcan [expex-set-global-variable-value _] _]
                                       #'expex-compiled-funcall)))

(defun make-bc-transpiler ()
  (aprog1 (create-transpiler
              :name                 'bytecode
			  :lambda-export?       t
			  :stack-locals?        t
			  :arguments-on-stack?  t
              :make-text?           nil
              :encapsulate-strings? nil
              :function-prologues?  nil
              :function-name-prefix nil
              :import-variables?    nil
              :code-concatenator    #'tree-list
              :expex-initializer    #'bc-expex-initializer)
    (transpiler-add-plain-arg-funs ! *builtins*)))

(defvar *bc-transpiler* (copy-transpiler (make-bc-transpiler)))
