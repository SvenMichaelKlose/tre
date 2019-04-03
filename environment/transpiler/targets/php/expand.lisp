(defmacro define-php-std-macro (&rest x)
  `(define-transpiler-macro *php-transpiler* ,@x))

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

(define-php-std-macro slot-value (place slot)
  (?
    (quote? slot)  `(%slot-value ,place ,.slot.)
    (string? slot) `(%slot-value ,place ,slot)
    (symbol? slot) `(prop-value ,place ,slot)
    (with-gensym g
      `(%%block
         (%var ,g)
         (%= ,g ,slot)
         (prop-value ,place ,g)))))

(define-php-std-macro undefined? (x)
  `(not (isset ,x)))

(define-php-std-macro defined? (x)
  `(isset ,x))

(define-php-std-macro %%%nanotime ()
  '(microtime t))
