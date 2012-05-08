;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate apply call function_exists call_user_func_array array)

(defun apply (&rest lst)
  (with (fun lst.
         l (last .lst)
         args (%nconc (butlast .lst) l.)
         funref? (is_a fun "__funref")
         fun-name (? funref? fun.n fun)
         expander-name (%%%string+ fun-name "_treexp"))
    (when funref?
      (setf args (cons fun.g args)))
	(?
      (function_exists expander-name) (call_user_func_array expander-name (%transpiler-native "array ($" args ")"))
	  (function_exists fun-name) (call_user_func_array fun-name (list-phparray args))
      (error (+ "Function '" fun-name "' does not exist.")))))

(defmacro cps-wrap (x) x)
(defun cps-return-dummy (&rest x))

(defun funcall (fun &rest args)
  (apply fun args))
