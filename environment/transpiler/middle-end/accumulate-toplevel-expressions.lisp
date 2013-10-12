;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defun accumulate-toplevel-expressions (x)
   (remove-if #'not
              (filter [? (| (named-lambda? _)
                            (%var? _))
                         _
                         (& (transpiler-add-toplevel-expression *transpiler* _)
                            nil)]
                      x)))
