(functional adjoin)
(fn adjoin (obj lst &rest args)
  "Add an element to a set."
  (? (apply #'member obj lst args)
     lst
     (. obj lst)))

(defmacro adjoin! (obj &rest place)
  "Destructively add an element to set in place."
  `(= ,place. (adjoin ,obj ,@place)))

(fn intersect (a b &key (test #'eql))
  "Elements that are in both lists."
  (& a b
     (? (member a. b :test test)
        (. a. (intersect .a b))
        (intersect .a b))))

(fn set-difference (a b &key (test #'eql))
  "Remove elements in list a from list b."
  (& a b
     (? (member b. a :test test)
        (set-difference a .b)
        (. b. (set-difference .a b)))))

(fn union (a b)
  "Unique elements from both lists."
  (unique (append a b)))

(fn unique (x &key (test #'eql))
  "Unique elements of a list."
  (when x
    (? (member x. .x :test test)
       (unique .x :test test)
       (. x. (unique .x :test test)))))

(fn set-exclusive-or (a b)
  "Remove elements that are in both lists."
  (!= (intersect a b)
    (append (remove-if [member _ !] a)
            (remove-if [member _ !] b))))

(fn subset? (a b)
  "Check if list a is a subset of list b."
  (every [member _ b] a))
