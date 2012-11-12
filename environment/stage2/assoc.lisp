;;;;; tré – Copyright (c) 2005–2006,2009–2012 Sven Michael Klose <pixel@copei.de>

(functional assoc rassoc acons copy-alist)

(defmacro %define-assoc (name getter-fun-name)
  `(defun ,name (key lst &key (test #'eql))
     (& lst
        (dolist (i lst)
          (? (cons? i)
             (? (funcall test key (,getter-fun-name i))
                (return i))
             (progn
               (print i)
               (%error "not a pair")))))))

(%define-assoc rassoc cdr)

(let lst '((a . d) (b . e) (c . f))
  (| (eq 'e (cdr (assoc 'b lst)))
     (%error "ASSOC doesn't work with symbols")))

(let lst '((1 . a) (2 . b) (3 . c))
  (| (eq 'b (cdr (assoc 2 lst)))
     (%error "ASSOC doesn't work with numbers")))

(defun %=-assoc (new-value key x &key (test #'eql))
  (? (listp x)
     (& x
        (? (funcall test key (car x))
           (rplaca x new-value)
           (%=-assoc new-value key (cdr x) :test test)))
     (%error "not a pair")))

(defun (= assoc) (new-value key lst &key (test #'eql))
  (%=-assoc new-value key lst :test test)
  new-value)

(defun acons (key val lst)
  (cons (cons key val) lst))

(defmacro acons! (key val place)
  `(= ,place (acons ,key ,val ,place)))

(defun copy-alist (x)
  (filter [cons (car _) (cdr _)] x))

(defun aremove (obj lst &key (test #'eql))
  (& lst
     (? (funcall test obj (caar lst))
        (aremove obj (cdr lst) :test test)
        (cons (cons (caar lst)
                    (cdar lst))
              (aremove obj (cdr lst) :test test)))))

(defmacro aremove! (obj place &key (test #'eql))
  `(= ,place (aremove ,obj ,place :test ,test)))

(defun areplace (x replacements &key (test #'eql))
  (filter [!? (assoc _. replacements :test test) ! _] x))

(defmacro curly (&rest x)
  `(assoc ,@x))

(defun force-assoc (x)
  (when x
    (& (atom x)  (= x (list x)))
    (& (atom x.) (= x (list x)))
    x))
