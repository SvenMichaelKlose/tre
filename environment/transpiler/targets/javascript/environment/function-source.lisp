;;;; tré - Copyright (c) 2011–2012 Sven Michael Klose <pixel@copei.de>

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

(defun function-source (fun)
  (let f (? (symbol? fun) (symbol-function fun) fun)
    (awhen f.__source
      `#(,(function-arguments f)
         ,@(function-body f)))))
