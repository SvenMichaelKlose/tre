;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defun shared-defvar (name &optional (val '%%no-value))
  (when (eq '%%no-value val)
    (= val `',name))
  (let tr *current-transpiler*
    (when *show-definitions*
      (late-print `(defvar ,name)))
    (when (transpiler-defined-variable tr name)
      (redef-warn "redefinition of variable ~A.~%" name))
    (transpiler-add-defined-variable tr name)
    (when *have-compiler?*
      (transpiler-add-delayed-var-init tr `((%setq *variables* (cons (cons ',name ',val) *variables*)))))
    `(progn
       ,@(when (transpiler-needs-var-declarations? tr)
           `((%var ,name)))
	   (%setq ,name ,val))))
