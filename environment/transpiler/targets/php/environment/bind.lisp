;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(dont-obfuscate arguments array_shift)
(dont-inline %bind)

(defun %bind (obj fun)
  (when-debug
	(unless (function? fun)
	  (js-print fun logwindow.document)))
  (assert (function? fun) "BIND requires a function")
  #'(()
	  ,(if (transpiler-lambda-export? *php-transpiler*)
		   ; Get rid of the ghost argument.
		   '(let a (__manual-array-copy arguments)
			  (array_shift a)
    		  (apply fun obj a))
      	   '(apply fun obj arguments))))
