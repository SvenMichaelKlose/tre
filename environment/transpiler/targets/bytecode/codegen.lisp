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

(defun bc-quote-literal (x)
  (? (| (symbol? x)
        (number? x)
        (string? x))
     `(%quote ,x)
     x))

(define-filter bc-quote-literals #'bc-quote-literal)

(defun bc-special? (x)
  (| (%%closure? x)
     (%closure? x)
     (%stack? x)
     (%vec? x)
     (%quote? x)))

(defun bc-make-funcall (x)
  (?
    (eq 'cons x.)                `(cons ,(bc-quote-literal .x.) ,(bc-quote-literal ..x.))
    (eq '=-symbol-value x.)      `(,x. 2 ,@(bc-quote-literals .x))
    (eq '%symbol-value x.)       `(symbol-value 1 ,(bc-quote-literal .x.))
    (eq '%make-lexical-array x.) `(make-array 1 ,(bc-quote-literal .x.))
    `(,x. ,(length .x) ,@(bc-quote-literals .x))))

(defun bc-make-value (x)
  (?
    (atom x)         `(%quote nil)
    (bc-special? x)  x
    (bc-make-funcall x)))

(define-bc-macro %setq (place x)
  `(,(bc-make-value x) ,place))

(define-bc-macro %set-vec (vec index x)
  `(%bc-set-vec ,vec ,index ,(bc-make-value x)))

(define-bc-macro identity (x) x)
