;;;;; tré – Copyright (c) 2008–2010,2012–2014 Sven Michael Klose <pixel@copei.de>

(= *have-environment-tests* t)

(unix-sh-mkdir "compiled")
(make-project "PHP target test"
              `((toplevel . ((environment-tests))))
              :transpiler  *php-transpiler*
              :emitter     [put-file "compiled/test.php" _])
(quit)
