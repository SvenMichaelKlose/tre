;;;;; tré – Copyright (c) 2008–2010,2012–2013 Sven Michael Klose <pixel@copei.de>

;;;; Bind function to an object.
;;;;
;;;; ECMAScript doesn't know method references. Functions and their objects
;;;; are separated.
;;;;
;;;; See also macro BIND in 'expand.lisp'.

(dont-obfuscate arguments)

(defun %bind (obj fun)
  (when-debug
	(unless (function? fun)
	  (js-print fun logwindow.document)))
  (assert (function? fun) "BIND requires a function")
  #'(()
      (fun.apply obj arguments)))
