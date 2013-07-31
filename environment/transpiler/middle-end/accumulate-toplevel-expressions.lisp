;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defun accumulate-toplevel-expressions (tr x)
  (? (transpiler-accumulate-toplevel-expressions? tr)
     (remove-if #'not
                (print
                (filter [? (| (lambda-expr? _)
                              (%var? _))
                           _
                           (& (transpiler-add-toplevel-expression tr _)
                              nil)]
                        (print
                        x))
                ))
     x))
