;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(dont-obfuscate arguments)
(dont-inline %bind)

;; Bind function to an object.
;;
;; ECMAScript doesn't know method references. Functions and their objects
;; are separated.
;;
;; See also macro BIND in 'expand.lisp'.
(defun %bind (obj fun)
  (when-debug
	(unless (function? fun)
	  (js-print fun logwindow.document)))
  (assert (function? fun) "BIND requires a function")
  #'(()
	  ,(if (transpiler-lambda-export? *js-transpiler*)
		   ; Get rid of the ghost argument.
		   '(let a (__manual-array-copy arguments)
			  (a.shift)
    		  (fun.apply obj a))
      	   '(fun.apply obj arguments))))
