;;;;; TRE C transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(setf *show-definitions* t)
(setf *opt-inline?* t)
(setf *opt-inline-max-levels* 3)
(setf *opt-inline-min-size* 0)
(setf *opt-inline-max-size* 16)
(setf *opt-inline-max-repetitions* 0)
(setf *opt-inline-max-small-repetitions* 0)

(with-open-file out (open "interpreter/_compiled-env.c" :direction 'output)
  (c-transpile out
    '("makefiles/make-compiled-0.lisp")))
(quit)
