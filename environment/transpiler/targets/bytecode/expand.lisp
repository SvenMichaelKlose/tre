;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defmacro define-bc-std-macro (&rest x)
  `(define-transpiler-std-macro *bc-transpiler* ,@x))

(define-bc-std-macro %defsetq (&rest x)
  `(%setq ,@x))

(define-bc-std-macro %lx (lexicals fun)                                                                                                                        
  (eval (macroexpand `(with ,(mapcan ^(,_ ',_) .lexicals.)
                        ,fun))))

(define-bc-std-macro defun (name args &rest body)
  (car (apply #'shared-defun name args body)))

(define-bc-std-macro defmacro (&rest x)
  (apply #'shared-defmacro '*current-transpiler* x))

(define-bc-std-macro defvar (name &optional (val '%%no-value))
  (& (eq '%%no-value val)
     (= name `',name))
  (let tr *current-transpiler*
    (print-definition `(defvar ,name))
    (& (transpiler-defined-variable tr name)
       (redef-warn "redefinition of variable ~A.~%" name))
    (transpiler-add-defined-variable tr name)
    (transpiler-obfuscate-symbol tr name)
    `(progn
       (%var ,name)
	   (%setq ,name ,val))))

(define-bc-std-macro %%u=-car (val x)
  (shared-=-car val x))

(define-bc-std-macro %%u=-cdr (val x)
  (shared-=-cdr val x))

(define-bc-std-macro mapcar (fun &rest lsts)
  (apply #'shared-mapcar fun lsts))

(define-bc-std-macro %set-atom-fun (place value)
  `(setq ,place ,value))
