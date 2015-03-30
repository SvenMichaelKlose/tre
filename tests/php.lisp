; tré – Copyright (c) 2008–2010,2012–2015 Sven Michael Klose <pixel@copei.de>

(= *have-environment-tests* t)
;(= (transpiler-dump-passes? *php-transpiler*) t)

(unix-sh-mkdir "compiled" :parents t)
(make-project "PHP target test"
              `((toplevel . ((environment-tests))))
              :transpiler  *php-transpiler*
              :emitter     [put-file "compiled/test.php" _])
(quit)
