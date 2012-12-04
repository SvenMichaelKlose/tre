;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(let code (compile-files '("makefiles/make-compiled-0.lisp") :target 'c)
  (with-open-file out (open "interpreter/_compiled-env.c" :direction 'output)
	(princ code out)))
(quit)
