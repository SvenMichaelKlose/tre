;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun %compile-environment-add-functions (transpiler funs)
  (transpiler-add-wanted-functions transpiler (| funs (reverse *universe-functions*))))

(defun compile-c-environment (&optional (funs nil))
  (let transpiler (copy-transpiler *c-transpiler*)
    (%compile-environment-add-functions transpiler funs)
    (let code (compile-files nil :target 'c :transpiler transpiler)
      (with-open-file out (open "interpreter/_compiled-env.c" :direction 'output)
	    (princ code out))))
  nil)

(defun compile-bytecode-environment (&optional (funs nil))
  (let transpiler (copy-transpiler *bc-transpiler*)
    (%compile-environment-add-functions transpiler funs)
    (compile-files nil :target 'bytecode :transpiler transpiler))
  nil)
