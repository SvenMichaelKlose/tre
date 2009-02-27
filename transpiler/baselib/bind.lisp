;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

;; Bind function to an object.
;;
;; ECMAScript doesn't know method references. Functions and their objects
;; are separated.
;;
;; See also macro BIND in 'expand.lisp'.
(defun %bind (obj fun)
  (assert (functionp fun) "BIND requires a function")
  #'(()
	  ,(if *exported-lambdas*
		   ; Get rid of the ghost argument.
		   '(let a (array-copy arguments)
			  (a.shift)
    		  (fun.apply obj a))
      	   '(fun.apply obj arguments))))
