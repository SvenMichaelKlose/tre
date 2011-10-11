;;;;; tré - Copyright (c) 2005-2006,2009-2011 Sven Klose <pixel@copei.de>

(functional assoc rassoc acons copy-alist)

(defmacro %define-assoc (name getter-fun-name)
  `(defun ,name (key lst &key (test #'eql))
     (when lst
	   (unless (cons? lst)
	     (%error "list expected"))
       (dolist (i lst)
         (? (cons? i)
		    (? (funcall test key (,getter-fun-name i))
	  	  	   (return i))
		    (and (print i)
			     (%error "not a pair")))))))

(unless (eq t *BUILTIN-ASSOC*)
  (%define-assoc assoc car))

(%define-assoc rassoc cdr)

(let lst '((a . d) (b . e) (c . f))
  (unless (eq 'e (cdr (assoc 'b lst)))
	(%error "ASSOC doesn't work with symbols")))

(let lst '((1 . a) (2 . b) (3 . c))
  (unless (eq 'b (cdr (assoc 2 lst)))
	(%error "ASSOC doesn't work with numbers")))

(defun %setf-assoc (new-value key x &key (test #'eql))
  (? (listp x)
     (when x
	   (? (funcall test key (car x))
          (rplaca x new-value)
		  (%setf-assoc new-value key (cdr x) :test test)))
	 (%error "not a pair")))

(defun (setf assoc) (new-value key lst &key (test #'eql))
  (%setf-assoc new-value key lst :test test)
  new-value)

(defun acons (key val lst)
  (cons (cons key val) lst))

(defmacro acons! (key val place)
  `(setf ,place (acons ,key ,val ,place)))

(defun copy-alist (x)
  (mapcar (fn cons (car _) (cdr _)) x))

(defun aremove (obj lst &key (test #'eql))
  (when lst
    (? (funcall test obj (caar lst))
	   (aremove obj (cdr lst) :test test)
	   (cons (cons (caar lst)
				   (cdar lst))
			 (aremove obj (cdr lst) :test test)))))

(defmacro aremove! (obj place &key (test #'eql))
  `(setf ,place (aremove ,obj ,place :test ,test)))
