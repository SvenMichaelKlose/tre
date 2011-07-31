;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Override alternative standard macros.

(defmacro define-c-std-macro (&rest x)
  `(define-transpiler-std-macro *c-transpiler* ,@x))

(define-c-std-macro %defsetq (&rest x)
  `(%setq ,@x))

(define-c-std-macro not (&rest x)
  (? .x
     `(%not2 ,@x)
     `(let ,*not-gensym* t
        (? ,x. (setf ,*not-gensym* nil))
        ,*not-gensym*)))

(define-c-std-macro defun (name args &rest body)
  (apply #'shared-essential-defun name args body))

(define-c-std-macro defmacro (&rest x)
  (apply #'shared-defmacro '*c-transpiler* x))

(define-c-std-macro defvar (name &optional (val '%%no-value))
  (when (eq '%%no-value val)
    (setf name `',name))
  (let tr *c-transpiler*
    (when *show-definitions*
      (late-print `(defvar ,name)))
    (when (transpiler-defined-variable tr name)
      (redef-warn "redefinition of variable ~A" name))
    (transpiler-add-defined-variable tr name)
    (transpiler-obfuscate-symbol tr name)
    `(progn
       (%var ,name)
	   (%setq ,name ,val))))

(functional %eq %not)
(transpiler-wrap-invariant-to-binary define-c-std-macro eq 2 %eq and)
(transpiler-wrap-invariant-to-binary define-c-std-macro %not2 1 %not and)

(mapcan-macro _
    '(car cdr cons? atom number? string? array? function? builtin?)
  (let n ($ '% _)
  `((functional ,n)
    (define-c-std-macro ,_ (x)
	  `(,n ,,x)))))

(define-c-std-macro slot-value (obj slot)
  `(%slot-value ,obj (%quote ,slot)))

(define-c-std-macro %%usetf-slot-value (val obj slot)
  `(%%usetf-%slot-value ,val ,obj (%quote ,slot)))

(define-c-std-macro %%usetf-aref (val arr &rest idx)
  (? (and (= 1 (length idx))
	      (not (%transpiler-native? idx.))
		  (number? idx.))
    `(%set-aref ,val ,arr (%transpiler-native ,idx.))
    `(%set-aref ,val ,arr ,@idx)))

(define-c-std-macro aref (arr &rest idx)
  (? (and (= 1 (length idx))
		  (not (%transpiler-native? idx.))
		  (number? idx.))
	 `(aref ,arr (%transpiler-native ,idx.))
	 `(aref ,arr ,@idx)))
	  
(define-c-std-macro mapcar (fun &rest lsts)
  (apply #'shared-mapcar fun lsts))
