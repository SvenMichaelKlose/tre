;;;;; tré – Copyright (c) 2010–2012 Sven Michael Klose <pixel@copei.de>

(defun codegen-expr? (x)
  (& (cons? x)
     (| (string? x.)
        (in? x. '%transpiler-string '%transpiler-native)
        (expander-has-macro? (transpiler-codegen-expander *current-transpiler*) x.))))
