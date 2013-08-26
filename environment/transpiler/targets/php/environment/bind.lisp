;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate arguments array_shift)

(defun %bind (obj fun)
  (when-debug
	(unless (function? fun)
	  (js-print fun logwindow.document)))
  (assert (function? fun) "BIND requires a function")
  #'(()
	  ,(? (transpiler-lambda-export? *transpiler*)
		  ; Get rid of the ghost argument.
		  '(let a (__manual-array-copy arguments)
		     (array_shift a)
    	     (apply fun obj a))
      	  '(apply fun obj arguments))))
