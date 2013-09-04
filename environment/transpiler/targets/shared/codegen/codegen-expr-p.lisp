;;;;; tré – Copyright (c) 2010–2013 Sven Michael Klose <pixel@copei.de>

(defun codegen-expr? (x)
  (& (cons? x)
     (| (string? x.)
        (in? x. '%%native '%%string)
        (expander-has-macro? (transpiler-codegen-expander *transpiler*) x.))))

(defun atom|codegen-expr? (x)
  (| (atom x)
     (codegen-expr? x)))
