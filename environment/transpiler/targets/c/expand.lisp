;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Override alternative standard macros.

(defmacro define-c-std-macro (&rest x)
  `(define-transpiler-std-macro *c-transpiler* ,@x))

(define-c-std-macro %defsetq (&rest x)
  `(%setq ,@x))

(define-c-std-macro defun (name args &rest body)
  (apply #'shared-essential-defun name name args body))

(define-c-std-macro defmacro (&rest x)
  (apply #'shared-defmacro '*c-transpiler* x))

(define-c-std-macro defvar (name val)
  (let tr *c-transpiler*
    (when *show-definitions*
      (late-print `(defvar ,name)))
    (when (transpiler-defined-variable tr name)
      (error "variable ~A already defined" name))
    (transpiler-add-defined-variable tr name)
    (transpiler-obfuscate-symbol tr name)
    `(progn
       (%var ,name)
	   (%setq ,name ,val))))

(define-c-std-macro eq (a b) `(%eq ,a ,b))

(mapcan-macro _
    '(car cdr not
	  consp atom numberp stringp arrayp functionp builtinp)
  `((define-c-std-macro ,_ (x)
	  `(%inline (,($ '% _) ,,x)))))

(define-c-std-macro slot-value (obj slot)
  `(%slot-value ,obj (%quote ,slot)))

(define-c-std-macro %%usetf-slot-value (val obj slot)
  `(%%usetf-%slot-value ,val ,obj (%quote ,slot)))

(define-c-std-macro %%usetf-aref (val arr &rest idx)
  (if (and (= 1 (length idx))
		   (not (%transpiler-native? idx.))
		   (numberp idx.))
    `(%set-aref ,val ,arr (%transpiler-native ,idx.))
    `(%set-aref ,val ,arr ,@idx)))

(define-c-std-macro aref (arr &rest idx)
  (if (and (= 1 (length idx))
		   (not (%transpiler-native? idx.))
		   (numberp idx.))
	  `(aref ,arr (%transpiler-native ,idx.))
	  `(aref ,arr ,@idx)))
	  
(define-c-std-macro mapcar (fun &rest lsts)
  (apply #'shared-mapcar fun lsts))
