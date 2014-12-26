; tré – Copyright (c) 2013–2014 Sven Michael Klose <pixel@copei.de>

(defun accumulate-toplevel-expressions (x)
   (remove-if #'not
              (filter [? (| (named-lambda? _)
                            (%var? _))
                         _
                         (& (add-toplevel-expression _)
                            nil)]
                      x)))
