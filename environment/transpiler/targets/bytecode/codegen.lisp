;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(define-codegen-macro-definer define-bc-macro *bc-transpiler*)

(define-bc-macro function (name &optional (x 'only-name))
  (?
	(eq 'only-name x)	name
    (atom x)			(error "codegen: arguments and body expected: ~A" x)
    (alet (lambda-args x) ; XXX Should be in FUNINFO.
      `(%%%bc-fun ,(lambda-funinfo x) ,(length !) ,@(& ! (list !))
        ,@(lambda-body x)))))

(define-bc-macro %function-prologue (fi-sym) '(%setq nil nil))
(define-bc-macro %function-epilogue (fi-sym) '((%%vm-go nil) %%bc-return))

(define-bc-macro %%funref (name fi-sym)
  `(%funref ,name ,(codegen-funref-lexical fi-sym)))

(define-bc-macro %setq (place x)
  `(%bc-set ,(? (& (cons? x)
                   (not (%%funref? x)
                        (%funref? x)
                        (%stack? x)
                        (%vec? x)))
                `(%bc-funcall
                   ,@(?
                       (eq 'cons x.) `(%bc-builtin cons ,.x. ,..x.)
                       (eq 'apply x.) `(%bc-special apply 1 ,@.x) ; XXX APPLYs inserted in expex
                       (in? x. '%bc-builtin '%bc-special) `(,x. ,(cadr .x.) ,@..x)
                       (eq '%make-lexical-array x.) `(%bc-builtin make-array 1 ,.x.)
                       `(,x. ,(length .x) ,@.x)))
                x)
            ,place))

(define-bc-macro identity (x) x)
