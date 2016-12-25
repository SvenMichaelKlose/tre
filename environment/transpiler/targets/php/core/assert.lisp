(defmacro assert-method (place slot)
  (& (assert?)
     (with-gensym p
       `(let ,p ,place
          (| (is_object ,p)
             (error "Tried to access method on non-object ~A." ,p))
          (| (method_exists ,p ,(downcase (symbol-name slot)))
             (error "Tried to access an undefined method on object ~A." ,p))))))
