;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(define-codegen-macro-definer define-bc-macro *bc-transpiler*)

(define-bc-macro function (name &optional (x 'only-name))
  (?
    (eq 'only-name x)  `(symbol-function 1 %quote ,name)
    (atom x)           (error "Arguments and body expected instead of ~A." x)
    `(%%%bc-fun ,name
       ,@(lambda-body x))))

(define-bc-macro %function-epilogue (name)
  '((%%go nil) %%bc-return))

(define-bc-macro %%closure (name)
  `(%closure ,name ,(codegen-closure-scope name)))

(defun bc-quote-literal (x)
  (? (| (& x (symbol? x))
        (number? x))       `(%quote ,x)
     (%global? x)          (bc-make-value x)
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
    'cons         `(. ,(bc-quote-literal .x.) ,(bc-quote-literal ..x.))
    '%make-scope  `(make-array 1 ,(bc-quote-literal .x.))
    `(,x. ,(length .x) ,@(bc-quote-literals .x))))

(defun bc-make-value (x)
  (? (atom x)         (bc-quote-literal x)
     (bc-special? x)  x
     (bc-make-funcall (? (%global? x)
                         `(symbol-value ,.x)
                         x))))

(define-bc-macro %= (place x)
  `(,(bc-make-value x) ,place))

(define-bc-macro %set-vec (vec index x)
  `(%bc-set-vec ,vec ,index ,(bc-make-value x)))

(define-bc-macro identity (x)       x)
(define-bc-macro %%native (&rest x) x)

(define-bc-macro return-from (block-name x)
  (error "Cannot return from unknown BLOCK ~A." block-name))
