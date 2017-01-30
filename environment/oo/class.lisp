(defstruct class
  (name    nil)
  (members nil)
  (methods nil)
  (parent  nil))

(fn class-add-method (cls name code)
  (acons! name code (class-methods cls)))

(fn class-change-method (cls name code)
  (= (assoc-value name (class-methods cls)) code))

(fn class-method (cls name)
  (assoc-value name cls))

(fn class-add-member (cls name)
  (push (list name t) (class-members cls)))
