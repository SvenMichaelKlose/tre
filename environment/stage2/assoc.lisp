(functional assoc rassoc acons copy-alist ensure-alist)

(defmacro %define-assoc (name getter)
  `(defun ,name (key lst &key (test #'eql))
     (& lst
        (@ (i lst)
          (? (cons? i)
             (? (funcall test key (,getter i))
                (return i))
             (error "Pair expected instead of ~A." i))))))

(%define-assoc assoc  car)
(%define-assoc rassoc cdr)

(defun (= assoc) (new-value key lst &key (test #'eql))
  (with (f [? (list? _)
              (& _
                 (? (funcall test key _.)
                    (= _. new-value)
                    (f ._)))
              (error "Pair expected instead of ~A." _)])
    (f lst)
    new-value))

(defun acons (key val lst)
  (. (. key val) lst))

(defmacro acons! (key val place)
  `(= ,place (acons ,key ,val ,place)))

(defun copy-alist (x)
  (@ [. _. ._] x))

(defun aremove (obj lst &key (test #'eql))
  (& lst
     (? (funcall test obj (caar lst))
        (aremove obj .lst :test test)
        (. (. (caar lst)
              (cdar lst))
           (aremove obj .lst :test test)))))

(defmacro aremove! (obj place &key (test #'eql))
  `(= ,place (aremove ,obj ,place :test ,test)))

(defun areplace (x replacements &key (test #'eql))
  (@ [| (assoc _. replacements :test test) _] x))

(defun ensure-alist (x)
  (when x
    (& (atom x)  (= x (list x)))
    (& (atom x.) (= x (list x)))
    x))
