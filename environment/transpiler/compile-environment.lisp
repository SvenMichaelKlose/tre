;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun %compile-environment-configure-transpiler (tr funs)
  (= (transpiler-dot-expand? (copy-transpiler tr)) nil)
  (transpiler-add-wanted-functions tr (| (!? funs
                                             (force-list !))
                                         (+ *universe-functions* *macros*)))
  tr)

(defun compile-c-environment (&optional (funs nil))
  (let tr (%compile-environment-configure-transpiler *c-transpiler* funs)
    (let code (compile-files nil :target 'c :transpiler tr)
      (with-open-file out (open "interpreter/_compiled-env.c" :direction 'output)
	    (princ code out))))
  nil)

(defun compile-bytecode-environment (&optional (funs nil))
  (let tr (%compile-environment-configure-transpiler *bc-transpiler* funs)
    (compile-files nil :target 'bytecode :transpiler tr)))

(defun compile-c-compiler ()
  (compile-c-environment '(c-transpile)))

(defun compile-bytecode-compiler ()
  (compile-bytecode-environment '(bc-transpile)))
