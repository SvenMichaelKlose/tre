(functional adjoin interset union unique set-difference set-exclusive-or
            subseq?)

(fn unique (x &key (test #'eql))
  "Unique elements of a list."
  (when x
    (? (member x. .x :test test)
       (unique .x :test test)
       (. x. (unique .x :test test)))))

(fn adjoin (obj lst &rest args)
  "Add an element to a set."
  (? (apply #'member obj lst args)
     lst
     (. obj lst)))

(defmacro adjoin! (obj &rest place)
  "Destructively add an element to set in place."
  `(= ,place. (adjoin ,obj ,@place)))

(macro set-op (name &rest body)
  `(fn ,name (a b &key (test #'eql))
     ,@body ))

(set-op intersect
  "Elements that are in both lists."
  (& a b
     (? (member a. b :test test)
        (. a. (intersect .a b :test test))
        (intersect .a b :test test))))

(set-op set-difference
  "Elements in list b that are not in list a."
  (& b
     (? (member b. a :test test)
        (set-difference a .b :test test)
        (. b. (set-difference a .b :test test)))))

(set-op union
  "Unique elements from both lists."
  (unique (append a b)))

(set-op set-exclusive-or
  "Elements that are not in both lists."
  (!= (intersect a b :test test)
    (+ (remove-if [member _ !] a)
       (remove-if [member _ !] b))))

(set-op subseq?
  "Check if list a is a subset of list b."
  (every [member _ a :test test] b))
