;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(= *opt-inline?* nil)

(let code (with-temporary (transpiler-profile? *c-transpiler*) nil
            (compile-files '("makefiles/make-compiled-1.lisp") :target 'c))
  (with-open-file out (open "interpreter/_compiled-env.c" :direction 'output)
    (princ code out)))
(quit)
