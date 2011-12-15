;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defun function-arguments (fun)
  (let f (? (symbol? fun) (symbol-function fun) fun)
    (? f
       (aif f.__source
            !.
            '(&rest unknown-args))
       '(&rest unknown-args))))

(defun function-body (fun)
  (let f (? (symbol? fun) (symbol-function fun) fun)
    (awhen f.__source
      .!)))
