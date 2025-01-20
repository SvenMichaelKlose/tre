(fn js-gen-predicate (class-name)
  `(fn ,($ class-name '?) (x)
     (& (%native x " instanceof " ,(compiled-function-name-string class-name))
        x)))

(fn js-gen-constructor (class-name base args body)
  `(progn
     (fn ,class-name ,args
       (%thisify ,class-name
         (macrolet ((super (&rest args)
                     `((%slot-value ,base call) this ,,@args)))
           ,@body)
         this))
     ,(js-gen-predicate class-name)))

(def-js-transpiler-macro defclass (class-name args &body body)
  (generic-defclass #'js-gen-constructor class-name args body))

(def-js-transpiler-macro defmethod (&rest x)
  (generic-defmethod x))

(def-js-transpiler-macro defmember (class-name &rest names)
  (generic-defmember class-name names))

(fn js-method (class-name x)
  (!= ($ class-name '- (%slot-name x))
    (. `(,(convert-identifier (%slot-name x)) #',!)
       `(fn ,! ,(%slot-args x)
          (%thisify ,class-name
            ,@(| (%slot-body x) (… nil)))))))

(fn js-gen-inherit-methods (class-name base-name)
  `((= (%slot-value ,class-name prototype)
       ((%slot-value *object create) (%slot-value ,base-name prototype)))))

(fn js-methods (class-name cls)
  (!= (@ [js-method class-name _]
         (remove-if [%slot-flag? _ :static] (class-methods cls)))
      `(,@(cdrlist !)
        ,@(!? (class-parent cls)
              (js-gen-inherit-methods class-name (class-name !)))
        ,(!? (@ [js-method class-name _]
                (remove-if-not [%slot-flag? _ :static] (class-methods cls)))
             `(js-merge-props! ,class-name
                               (%make-json-object ,@(*> #'+ (carlist !)))))
        (js-merge-props! (%slot-value ,class-name prototype)
                         (%make-json-object ,@(*> #'+ (carlist !)))))))

(fn js-constructor (class-name x)
  (*> (car (class-constructor-maker x))
      class-name (class-base x)
      (cdr (class-constructor-maker x))))

(def-js-transpiler-macro finalize-class (class-name)
  (print-definition `(finalize-class ,class-name))
  (!? (href (defined-classes) class-name)
      `(progn
         ,(js-constructor class-name !)
         ,@(js-methods class-name !)
         (= (%slot-value (%slot-value ,(compiled-function-name class-name) prototype) constructor)
            ,class-name))
      (error "Cannot finalize undefined class ~A." class-name)))
