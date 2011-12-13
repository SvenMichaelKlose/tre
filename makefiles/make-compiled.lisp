;;;;; tré - Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(setf *show-definitions* t)
(setf *opt-inline?* t)

(let code (compile-files '("makefiles/make-compiled-0.lisp") :target 'c)
  (with-open-file out (open "interpreter/_compiled-env.c" :direction 'output)
	(princ code out)))
(quit)
