;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defmacro define-shared-std-macro (targets &rest x)
  `(progn
     ,@(filter ^(,($ 'define- _ '-std-macro) ,@x)
               (? *have-c-compiler?*
                  targets
                  (remove 'bc (remove 'c targets))))))

(define-shared-std-macro (js php) defvar-native (&rest x)
  (print-definition `(defvar-native ,@x))
  (+! (transpiler-predefined-symbols *transpiler*) x)
  (apply #'transpiler-add-obfuscation-exceptions *transpiler* x)
  nil)

(define-shared-std-macro (js php) dont-obfuscate (&rest symbols)
  (apply #'transpiler-add-obfuscation-exceptions *transpiler* symbols)
  nil)

(define-shared-std-macro (js php) declare-cps-exception (&rest symbols)
  (print-definition `(declare-cps-exception ,@symbols))
  (adolist symbols
    (transpiler-add-cps-exception *transpiler* !))
  nil)

(define-shared-std-macro (js php) assert (x &optional (txt nil) &rest args)
  (& (transpiler-assert? *transpiler*)
     (make-assertion x txt args)))

(define-shared-std-macro (js php) functional (&rest x)
  (print-definition `(functional ,@x))
  (adolist x
    (? (transpiler-functional? *transpiler* !)
       (warn "Redefinition of functional ~A." !))
    (transpiler-add-functional *transpiler* !))
  nil)

(define-shared-std-macro (js php) when-debug (&body x)
  (& (transpiler-assert? *transpiler*)
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
  (& *have-compiler?*
     `(define-std-macro ,@x)))

(define-shared-std-macro (bc c js php) defconstant (&rest x)
  `(defvar ,@x))

(define-shared-std-macro (bc c js php) defvar (name &optional (val '%%no-value))
  (& (eq '%%no-value val)
     (= val `',name))
  (let tr *transpiler*
    (print-definition `(defvar ,name))
    (& (transpiler-defined-variable tr name)
       (redef-warn "redefinition of variable ~A.~%" name))
    (transpiler-add-defined-variable tr name)
    (& *have-compiler?*
       (transpiler-add-delayed-var-init tr `((= *variables* (cons (cons ',name ',val) *variables*)))))
    `(progn
       ,@(& (transpiler-needs-var-declarations? tr)
            `((%var ,name)))
	   (%= ,name ,val))))
