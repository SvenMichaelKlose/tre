(def-php-transpiler-macro defnative (name args &body body)
  (shared-defun name args body :allow-source-memorizer? nil))

(def-php-transpiler-macro %defmacro (name args &body body))

(def-php-transpiler-macro defun (name args &body body)
  (let fn-name (%fn-name name)
    `(%block
       ,(shared-defun name args body)
       (%= nil ((slot-value ',fn-name 'sf) ,(compiled-function-name-string fn-name))))))

(def-php-transpiler-macro define-external-variable (name)
  (print-definition `(define-external-variable ,name))
  (add-defined-variable name)
  nil)

(def-php-transpiler-macro slot-value (place slot)
  (?
    (quote? slot)   ; TODO: Shouldn't be here. (pixel)
      `(%slot-value ,place ,.slot.)
    (string? slot)
      `(%slot-value ,place ,slot)
    (with-gensym g
      `(%block
         (%var ,g)
         (%= ,g ,slot)
         (%aref ,place ,g)))))

(def-php-transpiler-macro undefined? (x)
  `(not (isset ,x)))

(def-php-transpiler-macro defined? (x)
  `(isset ,x))
