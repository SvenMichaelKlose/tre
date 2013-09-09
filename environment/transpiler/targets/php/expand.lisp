;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defmacro define-php-std-macro (&rest x)
  `(define-transpiler-std-macro *php-transpiler* ,@x))

(define-php-std-macro define-native-php-fun (name args &body body)
  (shared-defun name args body))

(define-php-std-macro eq (&rest x)
  (? ..x
     `(& (eq ,x. ,.x.)
         (eq ,x. ,@..x))
     `(eq ,@x)))

(define-php-std-macro defun (name args &body body)
  (let fun-name (%defun-name name)
    `(%%block
       ,(shared-defun name args body)
       (%setq nil ((slot-value ',fun-name 'sf) ,(compiled-function-name-string *transpiler* fun-name))))))

(define-php-std-macro define-external-variable (name)
  (print-definition `(define-external-variable ,name))
  (& (transpiler-defined-variable *transpiler* name)
     (redef-warn "redefinition of variable ~A." name))
  (transpiler-add-defined-variable *transpiler* name)
  nil)

(define-php-std-macro make-string (&optional len)
  "")

;; Translate SLOT-VALUE to unquoted variant.
(define-php-std-macro slot-value (place slot)
  `(%slot-value ,place ,(cadr slot)))

(define-php-std-macro new (&rest x)
  (unless x
	(error "Argument(s) expected."))
  (unless (& x. (| (symbol? x.) (string? x.)))
    (error "NEW expects first argument to be a non-NIL symbol or string instead of ~A." x.))
  (? (| (keyword? x.)
        (string? x.))
     `(%%make-hash-table ,@x)
     `(%new ,@x)))

(define-php-std-macro undefined? (x)
  `(isset ,x))

(define-php-std-macro defined? (x)
  `(not (isset ,x)))

(define-php-std-macro in-package (n)
  (= (transpiler-current-package *js-transpiler*) (& n (make-package (symbol-name n))))
  `(%%in-package ,n))

(define-php-std-macro string-concat (&rest x)
  `(%%%string+ ,@x))

(define-php-std-macro %%%nanotime ()
  '(microtime t))
