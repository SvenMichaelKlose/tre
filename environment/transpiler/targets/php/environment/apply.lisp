;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(dont-obfuscate apply call function_exists user_call_function)

(defun apply (&rest lst)
  (with (fun lst.
         l (last .lst)
         args (%nconc (butlast .lst) l.)
         expander-name (+ "treexp_" fun))
    (when-debug
      (unless (functionp fun)
        (error "APPLY: first argument is not a function: ~A" fun))
	  (unless (listp l)
	    (error "APPLY: last argument is not a cell")))
	(aif (function_exists expander-name)
	     (user_call_function expander-name (%transpiler-native "array (" args ")"))
         (user_call_function fun (list-array args)))))

(defmacro cps-wrap (x) x)
(defun cps-return-dummy (&rest x))

(defun funcall (fun &rest args)
  (apply fun args))
