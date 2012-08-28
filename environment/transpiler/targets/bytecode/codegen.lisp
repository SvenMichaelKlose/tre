;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(define-codegen-macro-definer define-bc-macro *bc-transpiler*)

(define-bc-macro function (name &optional (x 'only-name))
  (?
	(eq 'only-name x)	name
    (atom x)			(error "codegen: arguments and body expected: ~A" x)
    (alet (lambda-args x) ; XXX Should be in FUNINFO.
      `(%%%bc-fun ,(lambda-funinfo x)
        ,@(lambda-body x)))))

(define-bc-macro %function-prologue (fi-sym) '(%setq nil nil))
(define-bc-macro %function-epilogue (fi-sym) '((%%vm-go nil) %%bc-return))

(define-bc-macro %%funref (name fi-sym)
  `(%funref ,name ,(codegen-funref-lexical fi-sym)))

(defun bc-make-value (x)
  (? (& (cons? x)
        (not (%%funref? x)
             (%funref? x)
             (%stack? x)
             (%vec? x)))
     `(%bc-funcall
         ,@(?
             (eq 'cons x.) `(%bc-builtin cons ,.x. ,..x.)
             (eq '%bc-builtin x.) `(,x. ,(cadr .x.) ,@..x)
             (eq '%make-lexical-array x.) `(%bc-builtin make-array 1 ,.x.)
             `(,x. ,(length .x) ,@.x)))
     x))

(define-bc-macro %setq (place x)
  `(%bc-set ,(bc-make-value x) ,place))

(define-bc-macro %set-vec (vec index x)
  `(%bc-set-vec ,vec ,index ,(bc-make-value x)))

(define-bc-macro identity (x) x)
