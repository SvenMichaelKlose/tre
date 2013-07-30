;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defmacro assert-method (place slot)
  (& (transpiler-assert? *transpiler*)
     (with-gensym p
       `(let ,p ,place
          (| (is_object ,p)
             (error "Tried to access method on non-object ~A." ,p))
          (| (method_exists ,p ,(string-downcase (symbol-name slot)))
             (error "Tried to access an undefined method on object ~A." ,p))))))
