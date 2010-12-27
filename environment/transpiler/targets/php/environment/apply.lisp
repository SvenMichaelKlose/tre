;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(dont-obfuscate apply call function_exists call_user_func_array
                get-name get-ghost array)

(defun apply (&rest lst)
  (with (fun lst.
         l (last .lst)
         args (%nconc (butlast .lst) l.)
         funref? (is_a fun "__funref")
         fun-name (if funref?
                      (%%%string+ "userfun_" (fun.get-name))
                      fun)
         expander-name (%%%string+ "treexp_" fun-name))
    (when funref?
      (setf args (cons (fun.get-ghost) args)))
	(aif (function_exists expander-name)
	     (call_user_func_array (%%%string+ "userfun_" expander-name) (%transpiler-native "array (" args ")"))
         (call_user_func_array fun-name (list-array args)))))

(defmacro cps-wrap (x) x)
(defun cps-return-dummy (&rest x))

(defun funcall (fun &rest args)
  (apply fun args))
