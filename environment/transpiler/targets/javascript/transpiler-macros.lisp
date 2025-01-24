(fn js-make-function-with-expander (x)
  (!= (| (lambda-name x)
         (gensym))
    (with-gensym g
      `(%block
         (%var ,g)
         ,(copy-lambda x :name ! :body (. 'has-argexp! (lambda-body x)))
         (= (%slot-value ,! tre-exp) ,(compile-argument-expansion g ! (lambda-args x)))
         ,!))))

(fn js-requires-expander? (x)
  (unless (eq 'has-argexp! (car (lambda-body x)))
    (| (assert?)
       (not (simple-argument-list? (lambda-args x))))))

(def-js-transpiler-macro function (&rest x)
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

(def-js-transpiler-macro defnative (name args &body body)
  (js-make-late-symbol-function-assignment name)
  `(progn
     (%var ,(%fn-name name))
     ,(shared-defun name args (. 'has-argexp! body) :allow-source-memorizer? nil)))

(fn js-early-symbol-maker (g sym)
  `(,@(unless (eq g '~%tfun)
        `((%var ,g)))
    (%= ,g (symbol ,(symbol-name sym)
                   ,(? (keyword? sym)
                       '*keyword-package*
                       '(symbol "TRE" nil))))))

(def-js-transpiler-macro defun (name args &body body)
  (with (dname  (%fn-name name)
         g      '~%tfun)
    `(%block
       (%var ,dname)
       ,@(js-early-symbol-maker g dname)
       ,(shared-defun dname args body :make-expander? nil)
       (= (symbol-function ,g) ,dname))))

(def-js-transpiler-macro %fn (name args &body body)
  `(fn ,name ,args ,@body))

(def-js-transpiler-macro bind (fun &rest args)
  `(%bind ,(? (slot-value? fun)
              .fun.
              (error "Function must be a SLOT-VALUE, got ~A." fun))
          ,fun))

(def-js-transpiler-macro %class-predicate (class-name)
  `(fn ,($ class-name '?) (x)
     (& (%native x " instanceof " ,(compiled-function-name-string class-name))
        x)))

(def-js-transpiler-macro js-type-predicate (name &rest types)
  `(fn ,name (x)
     (when x
       (| ,@(@ [`(%== (%js-typeof x) ,_)]
               (ensure-list types))))))

;(def-js-transpiler-macro %href (hash key)
;  `(aref ,hash ,key))

(def-js-transpiler-macro undefined? (x)
  `(%== "undefined" (%js-typeof ,x)))

(def-js-transpiler-macro defined? (x)
  `(%!= "undefined" (%js-typeof ,x)))

(def-js-transpiler-macro invoke-debugger ()
 `(%= nil (%invoke-debugger)))

(def-js-transpiler-macro deftest (&rest x))
