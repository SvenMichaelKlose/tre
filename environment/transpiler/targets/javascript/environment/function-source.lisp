;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defun function-arguments (fun)
  (? fun
     (aif fun.__source
          !.
          '(&rest unknown-args))
     '(&rest unknown-args)))

(defun function-body (fun)
  (awhen fun.__source
    .!))
