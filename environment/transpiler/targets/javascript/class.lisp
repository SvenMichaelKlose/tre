(fn js-gen-constructor (class-name bases args body)
  `(progn
     (fn ,class-name ,args
       (%thisify ,class-name
         (macrolet ((super (&rest args)
                      `((slot-value ,bases. 'call) this ,,@args)))
           ,@body)))
     (fn ,($ class-name '?) (x)
       (%%native x " instanceof " ,(compiled-function-name-string class-name)))))

(def-js-transpiler-macro defclass (class-name args &body body)
  (apply #'generic-defclass #'js-gen-constructor class-name args body))

(fn js-method-name (name)
  (? (eq 'ref name)
     'at
     name))

(def-js-transpiler-macro defmethod (class-name name args &body body)
  (apply #'generic-defmethod class-name (js-method-name name) args body))

(def-js-transpiler-macro defmember (class-name &rest names)
  (apply #'generic-defmember class-name names))

(fn js-emit-method (class-name x)
  (!= ($ class-name '- x.)
    (. `(,(convert-identifier x.) #',!)
       `(fn ,! ,.x.
          (%thisify ,class-name
            ,@(| ..x. (list nil)))))))

(fn js-gen-inherit-methods (class-name base-name)
  (!? base-name
      `((= (slot-value ,(compiled-function-name class-name) 'prototype)
           (*object.create (slot-value ,! 'prototype))))))

(fn js-emit-methods (class-name cls)
  (!= (@ [js-emit-method class-name _]
         (reverse (class-methods cls)))
      `(,@(cdrlist !)
        ,@(js-gen-inherit-methods class-name (!? (class-parent cls)
                                                 (class-name !)))
        (js-merge-props! (slot-value ,class-name 'prototype)
                         (%%%make-json-object ,@(apply #'+ (carlist !)))))))

(def-js-transpiler-macro finalize-class (class-name)
  (print-definition `(finalize-class ,class-name))
  (!? (href (defined-classes) class-name)
      `(progn
         ,(assoc-value class-name *delayed-constructors*)
         ,@(js-emit-methods class-name !)
         (= (slot-value (slot-value ,(compiled-function-name class-name) 'prototype) 'constructor) ,class-name))
      (error "Cannot finalize undefined class ~A." class-name)))
