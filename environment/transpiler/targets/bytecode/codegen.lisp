;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(define-codegen-macro-definer define-bc-macro *bc-transpiler*)

(define-bc-macro function (name &optional (x 'only-name))
  (?
	(eq 'only-name x)	name
    (atom x)			(error "codegen: arguments and body expected: ~A" x)
    `(%%%bc-fun ,name ,(lambda-funinfo x)
      ,@(lambda-body x))))

(define-bc-macro %function-prologue (fi-sym)
  (codegen-copy-arguments-to-locals (get-funinfo-by-sym fi-sym)))

(define-bc-macro %function-epilogue (fi-sym)
  '%%bc-return)

(define-bc-macro %%funref (name fi-sym)
  `(%funref ,name ,(place-assign (place-expand-funref-lexical (get-funinfo-by-sym fi-sym)))))

(define-bc-macro %setq (place x)
  `(%bc-setq ,place ,(? (cons? x)
                        `(%bc-funcall ,x. ,(length .x) ,@.x)
                        x)))

(define-bc-macro identity (x)
  x)

(define-bc-macro %quote (x)
  x)
