;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defmacro define-shared-std-macro (targets &rest x)
  `(progn
     ,@(filter ^(,($ 'define- _ '-std-macro) ,@x) targets)))

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
  (!? (member-if [member _ x] *functionals*)
      (error "Redefinition of functional." !.))
  (+! *functionals* x)
  nil)

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
