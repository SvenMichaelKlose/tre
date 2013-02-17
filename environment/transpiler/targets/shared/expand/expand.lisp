;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defmacro define-js-php-std-macro (&rest x)
  `(progn
     (define-js-std-macro ,@x)
     (define-php-std-macro ,@x)))

(define-js-php-std-macro dont-obfuscate (&rest symbols)
  (apply #'transpiler-add-obfuscation-exceptions *transpiler* symbols)
  nil)

(define-js-php-std-macro dont-inline (&rest x)
  (adolist (x)
    (transpiler-add-inline-exception *transpiler* !))
  nil)

(define-js-php-std-macro assert (x &optional (txt nil) &rest args)
  (& (transpiler-assert? *transpiler*)
     (make-assertion x txt args)))

(define-js-php-std-macro %lx (lexicals fun)
  (eval (macroexpand `(with ,(mapcan ^(,_ ',_) .lexicals.)
                        ,fun))))

(define-js-php-std-macro functional (&rest x)
  (print-definition `(functional ,@x))
  (!? (member-if [member _ x] *functionals*)
      (error "Redefinition of functional." !.))
  (+! *functionals* x)
  nil)
