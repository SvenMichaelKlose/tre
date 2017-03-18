(defmacro define-php-std-macro (&rest x)
  `(define-transpiler-std-macro *php-transpiler* ,@x))

(define-php-std-macro defnative (name args &body body)
  (shared-defun name args body :allow-source-memorizer? nil))

(define-php-std-macro eq (&rest x)
  (? ..x
     `(& (eq ,x. ,.x.)
         (eq ,x. ,@..x))
     `(eq ,@x)))

(define-php-std-macro %defmacro (name args &body body))

(define-php-std-macro defun (name args &body body)
  (let fun-name (%defun-name name)
    `(%%block
       ,(shared-defun name args body)
       (%= nil ((slot-value ',fun-name 'sf) ,(compiled-function-name-string fun-name))))))

(define-php-std-macro define-external-variable (name)
  (print-definition `(define-external-variable ,name))
  (& (defined-variable name)
     (redef-warn "redefinition of variable ~A." name))
  (add-defined-variable name)
  nil)

(define-php-std-macro make-string (&optional len)
  "")

;; Translate SLOT-VALUE to unquoted variant.
(define-php-std-macro slot-value (place slot)
  `(%slot-value ,place ,(cadr slot)))

(define-php-std-macro new (&rest x)
  (? (| (keyword? x.)
        (string? x.))
     `(%%make-hash-table ,@x)
     `(%new ,@x)))

(define-php-std-macro undefined? (x)
  `(isset ,x))

(define-php-std-macro defined? (x)
  `(not (isset ,x)))

(define-php-std-macro string-concat (&rest x)
  `(%%%string+ ,@x))

(define-php-std-macro %%%nanotime ()
  '(microtime t))
