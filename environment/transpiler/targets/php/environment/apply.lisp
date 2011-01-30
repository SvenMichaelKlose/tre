;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(dont-obfuscate apply call function_exists call_user_func_array array)

(defun %apply-0 (fun-name args)
  (let expander-name (%%%string+ fun-name "_treexp")
  (?
    (function_exists expander-name)
	  (call_user_func_array expander-name (%transpiler-native "array ($" args ")"))
	(function_exists fun-name)
      (call_user_func_array fun-name (or (list-array args)
                                         (make-array)))
    (error (+ "Function '" fun-name "' does not exist.")))))

(defun apply (&rest lst)
  (with (fun lst.
         l (last .lst)
         args (%nconc (butlast .lst) l.)
         funref? (is_a fun "__funref")
         fun-name (? funref?
                     (%%%string+ "userfun_" fun.n)
                     fun))
    (%apply-0 fun-name (? funref?
                          (cons fun.g args)
                          args))))

(defmacro cps-wrap (x) x)
(defun cps-return-dummy (&rest x))

(defun funcall (fun &rest args)
  (apply fun args))
