;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(define-codegen-macro-definer define-bc-macro *bc-transpiler*)

(define-bc-macro function (name &optional (x 'only-name))
  (?
	(eq 'only-name x)	name
    (atom x)			(error "codegen: arguments and body expected: ~A" x)
    `(%%%bc-fun ,name
       ,@(lambda-body x))))

(define-bc-macro %function-prologue (name) '(%setq nil nil))
(define-bc-macro %function-epilogue (name) '((%%go nil) %%bc-return))

(define-bc-macro %%closure (name)
  `(%closure ,name ,(codegen-closure-lexical name)))

(defun bc-make-value (x)
  (? (& (cons? x)
        (not (%%closure? x)
             (%closure? x)
             (%stack? x)
             (%vec? x)
             (%quote? x)))
     `(%bc-funcall
         ,@(?
             (| (eq 'cons x.)
                (eq '%%%cons x.))         `(cons ,.x. ,..x.)
             (eq '=-symbol-value x.)      `(,x. 2 ,@.x)
             (eq '%bc-builtin x.)         `(,(cadr .x.) ,@..x)
             (eq '%make-lexical-array x.) `(make-array 1 ,.x.)
             `(,x. ,(length .x) ,@.x)))
     x))

(define-bc-macro %setq (place x)
  `(,(bc-make-value x) ,place))

(define-bc-macro %set-vec (vec index x)
  `(%bc-set-vec ,vec ,index ,(bc-make-value x)))

(define-bc-macro identity (x) x)
