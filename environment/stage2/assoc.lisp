(functional assoc assoc-value rassoc acons copy-alist ensure-alist pairlist)

(defmacro %define-assoc (name getter)
  `(fn ,name (key lst &key (test #'eql))
     (& lst
        (@ (i lst)
          (? (cons? i)
             (? (~> test key (,getter i))
                (return i))
             (error "Pair expected instead of ~A." i))))))

(%define-assoc assoc  car)
(%define-assoc rassoc cdr)

(fn (= assoc) (new-value key lst &key (test #'eql))
  (with (f [? (list? _)
              (& _
                 (? (~> test key _.)
                    (= _. new-value)
                    (f ._)))
              (error "Pair expected instead of ~A." _)])
    (f lst)
    new-value))

(fn assoc-value (key lst &key (test #'eql))
  (cdr (assoc key lst :test test)))

(fn (= assoc-value) (val key lst &key (test #'eql))
  (!? (assoc key lst :test test)
      (= .! val)
      (acons! key val lst)))

(fn acons (key val lst)
  (. (. key val) lst))

(defmacro acons! (key val place)
  `(= ,place (acons ,key ,val ,place)))

(fn copy-alist (x)
  (@ [. _. ._] x))

(fn aremove (obj lst &key (test #'eql))
  (& lst
     (? (~> test obj (caar lst))
        (aremove obj .lst :test test)
        (. (. (caar lst)
              (cdar lst))
           (aremove obj .lst :test test)))))

(defmacro aremove! (obj place &key (test #'eql))
  `(= ,place (aremove ,obj ,place :test ,test)))

(fn areplace (x replacements &key (test #'eql))
  (@ [| (assoc _. replacements :test test) _] x))

(fn ensure-alist (x)
  (when x
    (& (atom x)  (= x (… x)))
    (& (atom x.) (= x (… x)))
    x))

(fn pairlist (keys vals)
  (@ #'cons keys vals))
