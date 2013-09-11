;;;;; tré – Copyright (c) 2005–2006,2009–2013 Sven Michael Klose <pixel@copei.de>

(functional assoc rassoc acons copy-alist force-alist)

(defmacro %define-assoc (name getter)
  `(defun ,name (key lst &key (test #'eql))
     (& lst
        (dolist (i lst)
          (? (cons? i)
             (? (funcall test key (,getter i))
                (return i))
             (error "Pair expected instead of ~A." i))))))

(%define-assoc assoc  car)
(%define-assoc rassoc cdr)

(defun %=-assoc (new-value key x &key (test #'eql))
  (? (list? x)
     (& x
        (? (funcall test key x.)
           (= x. new-value)
           (%=-assoc new-value key .x :test test)))
     (error "Pair expected instead of ~A." x)))

(defun (= assoc) (new-value key lst &key (test #'eql))
  (%=-assoc new-value key lst :test test)
  new-value)

(defun acons (key val lst)
  (cons (cons key val) lst))

(defmacro acons! (key val place)
  `(= ,place (acons ,key ,val ,place)))

(defun copy-alist (x)
  (filter [cons _. ._] x))

(defun aremove (obj lst &key (test #'eql))
  (& lst
     (? (funcall test obj (caar lst))
        (aremove obj .lst :test test)
        (cons (cons (caar lst)
                    (cdar lst))
              (aremove obj .lst :test test)))))

(defmacro aremove! (obj place &key (test #'eql))
  `(= ,place (aremove ,obj ,place :test ,test)))

(defun areplace (x replacements &key (test #'eql))
  (filter [| (assoc _. replacements :test test) _] x))

(defmacro curly (&rest x)
  `(assoc ,@x))

(defun force-alist (x)
  (when x
    (& (atom x)  (= x (list x)))
    (& (atom x.) (= x (list x)))
    x))
