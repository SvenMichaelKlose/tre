; tré – Copyright (c) 2013–2015 Sven Michael Klose <pixel@copei.de>

(defun add-toplevel-expression (x)
  (push (copy-tree x) (accumulated-toplevel-expressions)))

(defun accumulate-toplevel-expressions (x)
   (remove-if #'not
              (@ [| (named-lambda? _)
                    (%var? _)
                    (& (add-toplevel-expression _)
                       nil)]
                 x)))
