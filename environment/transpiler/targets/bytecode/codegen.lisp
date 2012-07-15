;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

;;;; GENERAL CODE GENERATION

(define-codegen-macro-definer define-bc-macro *bc-transpiler*)

;;;; SYMBOL TRANSLATIONS

(transpiler-translate-symbol *bc-transpiler* nil "treptr_nil")
(transpiler-translate-symbol *bc-transpiler* t "treptr_t")

;;;; FUNCTIONS

(define-bc-macro function (name &optional (x 'only-name))
  (?
	(eq 'only-name x)	name
    (atom x)			(error "codegen: arguments and body expected: ~A" x)
    `(%%%bc-fun ,name ,(argument-expand-names 'unnamed-bc-function (lambda-args x))
      ,@(lambda-body x))))

(define-bc-macro %function-prologue (fi-sym)
  (bc-codegen-function-prologue-for-local-variables (get-funinfo-by-sym fi-sym)))

;;;; FUNCTION REFERENCE

;; Convert from lambda-expanded funref to one with lexical.
(define-bc-macro %%funref (name fi-sym)
  `(%funref ,name ,(place-assign (place-expand-funref-lexical (get-funinfo-by-sym fi-sym)))))

;;;; ASSIGNMENT

(define-bc-macro %setq (place x)
  `(%bc-setq ,place ,(? (cons? x)
                        `(%bc-funcall ,x. ,(length .x) ,@.x)
                        x)))

;;;; STACK

(define-bc-macro %stack (x)
  `(%bc-stack ,x))

;;;; CONTROL FLOW

(define-bc-macro %%tag (tag)
  `(%bc-tag ,tag))
 
(define-bc-macro %%vm-go (tag)
  `(%bc-go ,tag))

(define-bc-macro %%vm-go-nil (val tag)
  `(%bc-go-nil ,val ,tag))
