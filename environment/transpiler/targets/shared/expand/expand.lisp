;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defmacro define-shared-std-macro (targets &rest x)
  `(progn
     ,@(filter ^(,($ 'define- _ '-std-macro) ,@x)
               (? *have-c-compiler?*
                  targets
                  (remove 'c targets)))))

(define-shared-std-macro (js php) dont-obfuscate (&rest symbols)
  (apply #'transpiler-add-obfuscation-exceptions *transpiler* symbols)
  nil)

(define-shared-std-macro (js php) dont-inline (&rest x)
  (adolist (x)
    (transpiler-add-inline-exception *transpiler* !))
  nil)

(define-shared-std-macro (js php) assert (x &optional (txt nil) &rest args)
  (& (transpiler-assert? *transpiler*)
     (make-assertion x txt args)))

(define-shared-std-macro (js php) functional (&rest x)
  (print-definition `(functional ,@x))
  (adolist (x)
    (? (transpiler-functional? *transpiler* !)
       (warn "Redefinition of functional ~A." !))
    (transpiler-add-functional *transpiler* !))
  nil)

(define-shared-std-macro (js php) when-debug (&body x)
  (when (transpiler-assert? *transpiler*)
	`(progn
	   ,@x)))

(define-shared-std-macro (js php) unless-debug (&body x)
  (unless (transpiler-assert? *transpiler*)
	`(progn
	   ,@x)))

(define-shared-std-macro (js php) if-debug (consequence alternative)
  (? (transpiler-assert? *transpiler*)
	 consequence
	 alternative))

(define-shared-std-macro (c js php) not (&rest x)
   `(? ,x. nil ,(!? .x
                    `(not ,@!)
                    t)))

(define-shared-std-macro (bc c js php) %lx (lexicals fun)
  (eval (macroexpand `(with ,(mapcan ^(,_ ',_) .lexicals.)
                        ,fun))))

(define-shared-std-macro (bc c js php) mapcar (fun &rest lsts)
  `(,(? .lsts
        'mapcar
        'filter)
        ,fun ,@lsts))

(define-shared-std-macro (bc c js php) defmacro (&rest x)
  (print-definition `(defmacro ,x. ,.x.))
  (eval (macroexpand `(define-transpiler-std-macro *transpiler* ,@x)))
  (when *have-compiler?*
    `(define-std-macro ,@x)))

(define-shared-std-macro (bc c js php) defconstant (&rest x)
  `(defvar ,@x))

(define-shared-std-macro (bc c js php) defvar (name &optional (val '%%no-value))
  (when (eq '%%no-value val)
    (= val `',name))
  (let tr *transpiler*
    (print-definition `(defvar ,name))
    (when (transpiler-defined-variable tr name)
      (redef-warn "redefinition of variable ~A.~%" name))
    (transpiler-add-defined-variable tr name)
    (when *have-compiler?*
      (transpiler-add-delayed-var-init tr `((%setq *variables* (cons (cons ',name ',val) *variables*)))))
    `(progn
       ,@(when (transpiler-needs-var-declarations? tr)
           `((%var ,name)))
	   (%setq ,name ,val))))

(define-shared-std-macro (bc c js php) =-car (val x)
  (with-gensym g
    `(let ,g ,val
       (rplaca ,x ,g)
       ,g)))

(define-shared-std-macro (bc c js php) =-cdr (val x)
  (with-gensym g
    `(let ,g ,val
       (rplacd ,x ,g)
       ,g)))
