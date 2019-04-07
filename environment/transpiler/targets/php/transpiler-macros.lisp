(def-php-transpiler-macro defnative (name args &body body)
  (shared-defun name args body :allow-source-memorizer? nil))

(def-php-transpiler-macro %defmacro (name args &body body))

(def-php-transpiler-macro defun (name args &body body)
  (let fun-name (%defun-name name)
    `(%%block
       ,(shared-defun name args body)
       (%= nil ((slot-value ',fun-name 'sf) ,(compiled-function-name-string fun-name))))))

(def-php-transpiler-macro define-external-variable (name)
  (print-definition `(define-external-variable ,name))
  (& (defined-variable name)
     (warn "Redefinition of variable ~A." name))
  (add-defined-variable name)
  nil)

(def-php-transpiler-macro slot-value (place slot)
  (?
    (quote? slot)  `(%slot-value ,place ,.slot.)
    (string? slot) `(%slot-value ,place ,slot)
    (symbol? slot) `(prop-value ,place ,slot)
    (with-gensym g
      `(%%block
         (%var ,g)
         (%= ,g ,slot)
         (prop-value ,place ,g)))))

(def-php-transpiler-macro undefined? (x)
  `(not (isset ,x)))

(def-php-transpiler-macro defined? (x)
  `(isset ,x))

(def-php-transpiler-macro %%%nanotime ()
  '(microtime t))
