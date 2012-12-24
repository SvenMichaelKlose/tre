;;;;; Caroshi – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun find-first-or (x)
  (when x
    (?
      (atom x) nil
      (& (cons? x.) (eq '| x..)) (cdr x.)
      (cons? x.) (| (find-first-or x.)
                    (find-first-or .x))
      (find-first-or .x))))

(defun replace-first-or (x replacement)
  (with (found? nil
         r [when _
             (?
               (atom _) _
               (& (not found?)
                  (cons? _.)
                  (eq '| _..)) (progn
                                 (= found? t)
                                 (cons replacement (r ._)))
               (cons? _.)      (cons (r _.) (r ._))
               (cons _. (r ._)))])
    (r x)))

(defun orize-0 (x)
  (!? (find-first-or x)
      (filter [replace-first-or x _] !)
      (list x)))

(defun orize (x)
  (repeat-while-changes [mapcan #'orize-0 _] x))
