;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(define-codegen-macro-definer define-bc-macro *bc-transpiler*)

(define-bc-macro function (name &optional (x 'only-name))
  (?
	(eq 'only-name x)	name
    (atom x)			(error "Arguments and body expected instead of ~A." x)
    `(%%%bc-fun ,name
       ,@(lambda-body x))))

(define-bc-macro %function-epilogue (name) '((%%go nil) %%bc-return))

(define-bc-macro %%closure (name)
  `(%closure ,name ,(codegen-closure-lexical name)))

(defun bc-quote-literal (x)
  (? (| (& x (symbol? x))
        (number? x))
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
  (case x. :test #'eq
    'cons                 `(cons ,(bc-quote-literal .x.) ,(bc-quote-literal ..x.))
    '=-symbol-value       `(,x. 2 ,@(bc-quote-literals .x))
    '%symbol-value        `(symbol-value 1 ,(bc-quote-literal .x.))
    '%make-lexical-array  `(make-array 1 ,(bc-quote-literal .x.))
    `(,x. ,(length .x) ,@(bc-quote-literals .x))))

(defun bc-make-value (x)
  (? (atom x)         (bc-quote-literal x)
     (bc-special? x)  x
     (bc-make-funcall x)))

(define-bc-macro %setq (place x)
  `(,(bc-make-value x) ,place))

(define-bc-macro %set-vec (vec index x)
  `(%bc-set-vec ,vec ,index ,(bc-make-value x)))

(define-bc-macro identity (x) x)
