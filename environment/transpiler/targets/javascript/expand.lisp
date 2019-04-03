(defmacro define-js-std-macro (name args &body body)
  `(define-transpiler-std-macro *js-transpiler* ,name ,args ,@body))

(fn js-make-function-with-expander (x)
  (!= (| (lambda-name x)
         (gensym))
    (with-gensym g
      `(%%block
         (%var ,g)
         ,(copy-lambda x :name ! :body (body-with-noargs-tag (lambda-body x)))
         (= (slot-value ,! 'tre-exp) ,(compile-argument-expansion g ! (lambda-args x)))
         ,!))))

(fn js-requires-expander? (x)
  (unless (body-has-noargs-tag? (lambda-body x))
    (| (assert?)
       (not (simple-argument-list? (lambda-args x))))))

(define-js-std-macro function (&rest x)
  (!= (. 'function x)
    (? .x
       (? (js-requires-expander? !)
          (js-make-function-with-expander !)
          !)
       !)))

(var *late-symbol-function-assignments* nil)

(fn js-make-late-symbol-function-assignment (name)
  (push `(= (%slot-value ,name f) ,(compiled-function-name name))
        *late-symbol-function-assignments*))

(fn emit-late-symbol-function-assignments ()
  (reverse *late-symbol-function-assignments*))

(define-js-std-macro defnative (name args &body body)
  (js-make-late-symbol-function-assignment name)
  `{(%var ,(%defun-name name))
    ,(shared-defun name args (body-with-noargs-tag body) :allow-source-memorizer? nil)})

(fn js-early-symbol-maker (g sym)
  `(,@(unless (eq g '~%tfun)
        `((%var ,g)))
    (%= ,g (symbol ,(symbol-name sym)
                   ,(? (keyword? sym)
                       '*keyword-package*
                       (!? (symbol-package sym)
                           (? (& (not (string== "COMMON-LISP" (package-name !)))
                                 (not (invisible-package? !)))
                              `(symbol ,(symbol-name !) nil))))))))

(define-js-std-macro defun (name args &body body)
  (with (dname  (%defun-name name)
         g      '~%tfun)
    `(%%block
       (%var ,dname)
       ,@(js-early-symbol-maker g dname)
       ,(shared-defun dname args body :make-expander? nil)
       (= (symbol-function ,g) ,dname))))

(define-js-std-macro %defun (name args &body body)
  `(fn ,name ,args ,@body))

(define-js-std-macro slot-value (place slot)
  (?
    (quote? slot)   `(%slot-value ,place ,.slot.)
    (string? slot)  `(%slot-value ,place ,slot)
    `(%aref ,place ,slot)))

(define-js-std-macro bind (fun &rest args)
  `(%bind ,(? (slot-value? fun)
              .fun.
              (error "Function must be a SLOT-VALUE, got ~A." fun))
          ,fun))

(define-js-std-macro js-type-predicate (name &rest types)
  `(fn ,name (x)
     (when x
       ,(? (< 1 (length types))
           `(| ,@(@ [`(%%%== (%js-typeof x) ,_)]
                    types))
            `(%%%== (%js-typeof x) ,types.)))))

(define-js-std-macro %href (hash key)
  `(aref ,hash ,key))

(define-js-std-macro undefined? (x)
  `(%%%== "undefined" (%js-typeof ,x)))

(define-js-std-macro defined? (x)
  `(%%%!= "undefined" (%js-typeof ,x)))

(define-js-std-macro invoke-debugger ()
 `(%= nil (%invoke-debugger)))

(define-js-std-macro define-test (&rest x))
