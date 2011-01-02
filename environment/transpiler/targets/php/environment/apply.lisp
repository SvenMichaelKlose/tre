;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(dont-obfuscate apply call function_exists call_user_func_array array)

(defun apply (&rest lst)
  (with (fun lst.
         l (last .lst)
         args (%nconc (butlast .lst) l.)
         funref? (is_a fun "__funref")
         fun-name (if funref?
                      (%%%string+ "userfun_" fun.n)
                      fun)
         expander-name (%%%string+ fun-name "_treexp"))
    (when funref?
      (setf args (cons fun.g args)))
	(if (function_exists expander-name)
	    (call_user_func_array expander-name (%transpiler-native "array ($" args ")"))
        (call_user_func_array fun-name (list-array args)))))

(defmacro cps-wrap (x) x)
(defun cps-return-dummy (&rest x))

(defun funcall (fun &rest args)
  (apply fun args))
