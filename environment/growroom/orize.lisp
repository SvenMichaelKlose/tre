; Caroshi – Copyright (c) 2012,2015 Sven Michael Klose <pixel@copei.de>

(defun |? (x)
  (& (cons? x)
     (eq '| x.)))

(defun find-first-or (x)
  (?
    (atom x)   nil
    (|? x.)    (cdr x.)
    (cons? x.) (| (find-first-or x.)
                  (find-first-or .x))
    (find-first-or .x)))

(defun replace-first-or (x replacement)
  (with (found?     nil
         or?        [& (not found?)
                       (|? _.)]
         process-or [(= found? t)
                     (cons replacement (r ._))]
         r [?
             (atom _)   _
             (or? _)    (process-or _)
             (cons? _.) (cons (r _.) (r ._))
             (cons _. (r ._))])
    (r x)))

(defun orize-0 (x)
  (!? (find-first-or x)
      (@ [replace-first-or x _] !)
      (list x)))

(defun orize (x)
  (repeat-while-changes [mapcan #'orize-0 _] x))
