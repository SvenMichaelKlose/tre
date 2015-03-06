; tré – Copyright (c) 2013–2015 Sven Michael Klose <pixel@copei.de>

(defun accumulate-toplevel-expressions (x)
   (remove-if #'not
              (@ [? (| (named-lambda? _)
                       (%var? _))
                    _
                    (& (add-toplevel-expression _)
                       nil)]
                 x)))
