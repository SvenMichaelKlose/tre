;;;;; TRE transpiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun codegen-expr? (x)
  (and (consp x)
       (or (stringp x.)
           (in? x. '%transpiler-string '%transpiler-native))))
