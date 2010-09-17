;;;;; TRE C transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(setf *show-definitions* t)
(setf *opt-inline?* t)

(let code (c-transpile '("makefiles/make-compiled-0.lisp"))
  (with-open-file out (open "interpreter/_compiled-env.c" :direction 'output)
	(princ code out)))
(quit)
