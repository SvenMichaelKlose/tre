(fn js-gen-predicate (class-name)
  `(fn ,($ class-name '?) (x)
     (%%native x " instanceof " ,(compiled-function-name-string class-name))))

(fn js-gen-constructor (class-name base args body)
  `(progn
     (fn ,class-name ,args
       (%thisify ,class-name
         (macrolet ((super (&rest args)
                      `((slot-value ,base 'call) this ,,@args)))
           ,@body)
         this))
     ,(js-gen-predicate class-name)))

(def-js-transpiler-macro defclass (class-name args &body body)
  (generic-defclass #'js-gen-constructor class-name args body))

(def-js-transpiler-macro defmethod (class-name name args &body body)
  (generic-defmethod class-name name args body))

(def-js-transpiler-macro defmember (class-name &rest names)
  (generic-defmember class-name names))

(fn js-emit-method (class-name x)
  (!= ($ class-name '- x.)
    (. `(,(convert-identifier x.) #',!)
       `(fn ,! ,.x.
          (%thisify ,class-name
            ,@(| ..x. (list nil)))))))

(fn js-gen-inherit-methods (class-name base-name)
  `((= (slot-value ,class-name 'prototype)
       (*object.create (slot-value ,base-name 'prototype)))))

(fn js-emit-methods (class-name cls)
  (!= (@ [js-emit-method class-name _]
         (reverse (class-methods cls)))
      `(,@(cdrlist !)
        ,@(!? (class-parent cls)
              (js-gen-inherit-methods class-name (class-name !)))
        (js-merge-props! (slot-value ,class-name 'prototype)
                         (%%%make-json-object ,@(apply #'+ (carlist !)))))))

(def-js-transpiler-macro finalize-class (class-name)
  (print-definition `(finalize-class ,class-name))
  (!? (href (defined-classes) class-name)
      `(progn
         ,(apply (car (class-constructor-maker !))
                 class-name (class-base !)
                 (cdr (class-constructor-maker !)))
         ,@(js-emit-methods class-name !)
         (= (slot-value (slot-value ,(compiled-function-name class-name)
                                    'prototype) 'constructor)
            ,class-name))
      (error "Cannot finalize undefined class ~A." class-name)))
