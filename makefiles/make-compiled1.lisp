;;;;; TRE C transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(setf *show-definitions* t)
(setf *opt-inline?* t)
(setf *opt-inline-max-levels* 3)
(setf *opt-inline-min-size* 0)
(setf *opt-inline-max-size* 16)
(setf *opt-inline-max-repetitions* 0)
(setf *opt-inline-max-small-repetitions* 0)

(let code (c-transpile '("makefiles/make-compiled-1.lisp"))
  (with-open-file out (open "interpreter/_compiled-env.c" :direction 'output)
    (princ code out)))
(quit)
