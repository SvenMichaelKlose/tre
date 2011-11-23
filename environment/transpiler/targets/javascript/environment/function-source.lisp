;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defun function-arguments (fun)
  (awhen fun.__source
    !.))

(defun function-body (fun)
  (awhen fun.__source
    .!))
