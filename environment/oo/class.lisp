(defstruct %slot
  flags ; (:static :protected :private)
  type  ; (:method :member)
  name
  args
  body)

(fn %slot-flag? (slot flag)
  (member flag (%slot-flags slot)))

(defstruct class
  (name   nil)
  (base   nil)
  (slots  nil)
  (parent nil)
  (constructor-maker nil))

(fn class-slot? (cls name)
  (member [eq name (%slot-name _)] (class-slots cls)))

(fn class-slots-by-type (cls type)
  (remove-if-not [eq type (%slot-type _)] (class-slots cls)))

(fn class-methods (cls)
  (class-slots-by-type cls :method))

(fn class-members (cls)
  (class-slots-by-type cls :member))
