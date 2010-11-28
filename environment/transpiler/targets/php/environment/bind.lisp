;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(dont-obfuscate arguments array_shift)
(dont-inline %bind)

(defun %bind (obj fun)
  (when-debug
	(unless (functionp fun)
	  (js-print fun logwindow.document)))
  (assert (functionp fun) "BIND requires a function")
  #'(()
	  ,(if (transpiler-lambda-export? *php-transpiler*)
		   ; Get rid of the ghost argument.
		   '(let a (__manual-array-copy arguments)
			  (array_shift a)
    		  (apply fun obj a))
      	   '(apply fun obj arguments))))
