;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(= *show-definitions?* t)
(= *opt-inline?* nil)

(let code (compile-files '("makefiles/make-compiled-bytecode-1.lisp") :target 'bytecode)
  (with-open-file out (open "bytecode-image" :direction 'output)
    (dolist (i code)
      (late-print i out))))

(fnord 1)
