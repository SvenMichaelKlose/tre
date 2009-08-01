;;;;; TRE C transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(setf *show-definitions* t)
(setf *opt-inline?* t)

(with-open-file out (open "interpreter/_compiled-env.c" :direction 'output)
  (c-transpile out
    '("makefiles/make-compiled-0.lisp")))
(quit)
