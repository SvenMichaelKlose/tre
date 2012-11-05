;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defmacro assert-slot (place slot)
  (& *transpiler-assert*
     (with-gensym p
       `(let ,p ,place
          (| (is_object ,p)
             (error "tried to access slot on non-object ~A" ,p))
          (| (method_exists ,p ,(string-downcase (symbol-name slot)))
             (error "tried to access an undefined slot on object ~A" ,p))))))

(defmacro assert-slot-if-not-nil (place slot)
  `(& *transpiler-assert*
      (with-gensym p
        `(let ,p ,place
           (unless ,p
             (assert-slot ,p ,slot))))))
