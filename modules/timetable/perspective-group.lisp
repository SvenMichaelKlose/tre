(defclass (perspective-group perspective) (width height)
  (super)
  (clr _elements))

(defmember perspective-group _elements)

(defmethod perspective-group add (x)
  (push x _elements))

(fn perspective-group-remove (grp x)
  (remove! x grp._elements :test #'eq))

(defmethod perspective-group remove (x)
  (perspective-group-remove this x))

(defmethod perspective-group update (x)
  (@ (i _elements)
    (i.set-position (+ (i.get-static-x) (get-x))
                    (+ (i.get-static-y) (get-y))
                    (+ (i.get-static-z) (get-z)))
    (i.update)))

(finalize-class perspective-group)
