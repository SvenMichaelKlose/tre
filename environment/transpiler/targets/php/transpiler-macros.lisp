(def-php-transpiler-macro defnative (name args &body body)
  (shared-defun name args body :keep-source? nil))

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

(def-php-transpiler-macro undefined? (x)
  `(not (isset ,x)))

(def-php-transpiler-macro defined? (x)
  `(isset ,x))

;;;;;;;;;;;;;
;;; CLASS ;;;
;;;;;;;;;;;;;

(def-php-transpiler-macro %class-predicate (class-name)
 `(fn ,($ class-name '?) (x)
    (& (object? x)
       (is_a x ,(convert-identifier class-name))
       x)))

(def-php-transpiler-macro %method-body (class-name &body body)
  `(let ~%this this
     (%thisify ,class-name
       (macrolet ((super (&rest args)
                   `((%native "parent::__construct" ,,@args))))
         ,@body))))

(def-php-transpiler-macro %constructor-body (class-name &rest body)
  `(%block
     ,@body))
