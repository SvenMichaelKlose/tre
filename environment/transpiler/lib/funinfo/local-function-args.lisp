;;;;; tré – Copyright (c) 2011,2013 Sven Michael Klose <pixel@copei.de>

(defun funinfo-add-local-function-args (fi fun-name args)
  (when (assoc fun-name (funinfo-local-function-args fi) :test #'eq)
    (error "Local function arguments for ~A are already set." (symbol-name fun-name)))
  (acons! fun-name args (funinfo-local-function-args fi)))

(defun funinfo-get-local-function-args (fi fun-name)
  (awhen (funinfo-var-or-lexical? fi fun-name)
    (assoc-value fun-name (funinfo-local-function-args !) :test #'eq)))
