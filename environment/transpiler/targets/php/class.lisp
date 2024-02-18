(defconstant +php-array-methods+ '("AREF?" "AREF" "=-AREF" "DELETE-AREF"))

(fn php-constructor (class-name unused-base args body)
  (add-defined-function class-name args body)
  `(function __constructor ,args
     (let ~%this this
       (%thisify ,class-name
         (macrolet ((super (&rest args)
                     `((%native "parent::__construct" ,,@args))))
           ,@body)))
     this))

(def-php-transpiler-macro defclass (class-name args &body body)
  (generic-defclass #'php-constructor class-name args body))

(def-php-transpiler-macro defmember (class-name &rest names)
  (generic-defmember class-name names))

(def-php-transpiler-macro defmethod (&rest x)
  (generic-defmethod x))

(fn php-thisified-body (cls x)
  `(let ~%this this
     (%thisify ,(class-name cls)
       ,@(| (%slot-body x) (… nil)))))

(fn php-member (cls x)
  `(,x ,(php-thisified-body cls x)))

(fn php-method (cls x)
  `(,x #'(,($ (class-name cls) "-" (%slot-name x)) (,(%slot-args x)
          ,(php-thisified-body cls x)))))

(def-php-transpiler-macro finalize-class (class-name)
  (!= (| (href (defined-classes) class-name)
         (error "Cannot finalize undefined class ~A." class-name))
    `(%block
       (%collection (:class ,class-name)
         ,(@ [php-member ! _] (class-members !))
         ,(@ [php-method ! _] (class-methods !)))
       (fn ,($ class-name '?) (x)
         (& (object? x)
            (is_a x ,(convert-identifier class-name))
            x)))))
