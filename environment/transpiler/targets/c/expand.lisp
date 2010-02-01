;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Expansion of alternative standard macros.

;; Define macro that is expanded _before_ standard macros.
(defmacro define-c-std-macro (&rest x)
  `(define-transpiler-std-macro *c-transpiler* ,@x))

;; (DEFUN ...)
;;
;; Assign function to global variable.
;; XXX This could be generic if there wasn't *JS-TRANSPILER*.
(defun c-essential-defun (name args &rest body)
  (when *show-definitions*
    (late-print `(defun ,name ,@args)))
  (with (n (%defun-name name)
		 tr *c-transpiler*
		 fi-sym (when (eq '%FUNINFO args.)
				  (second args))
		 a (if fi-sym
			   (cddr args)
			   args))
    (transpiler-obfuscate-symbol tr n)
    (transpiler-add-function-args tr n a)
	(transpiler-add-defined-function tr n)
    `(%setq ,n
	        #'(,@(awhen fi-sym
				   `(%funinfo ,!))
			   ,a
   		         ,@(if (and (not *transpiler-assert*)
		    	            (stringp body.))
				       .body
				       body)))))

(define-c-std-macro defun (&rest x)
  (apply #'c-essential-defun x))

(define-c-std-macro defmacro (name &rest x)
  (when *show-definitions*
    (late-print `(defmacro ,name ,@x.)))
  (eval (transpiler-macroexpand *c-transpiler*
								`(define-c-std-macro ,name ,@x)))
  nil)

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

(define-c-std-macro cons (a d) `(_trelist_get ,a ,d))
(define-c-std-macro eq (a b) `(%eq ,a ,b))

(mapcan-macro _
    '(car cdr not
	  consp atom numberp stringp arrayp functionp builtinp)
  `((define-c-std-macro ,_ (x)
	  `(,($ '% _) ,,x))))

;(define-c-std-macro %lx (lexicals fun)
;  (eval (macroexpand `(with ,(mapcan (fn `(,_ ',_)) .lexicals.)
;                        ,fun))))

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
	  
; Convert MAPCAR to faster FILTER if possible.
(define-c-std-macro mapcar (fun &rest lsts)
  `(,(if (= 1 (length lsts))
         'filter
         'mapcar)
        ,fun ,@lsts))
