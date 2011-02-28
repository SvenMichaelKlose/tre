;;;;; TRE transpiler
;;;;; Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

(defun codegen-expr? (x)
  (and (cons? x)
       (or (string? x.)
           (in? x. '%transpiler-string '%transpiler-native)
           (expander-has-macro? (transpiler-macro-expander *current-transpiler*) x.))))
