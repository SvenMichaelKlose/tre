;;;; TRE  environment
;;;; Copyright (C) 2005-2006,2009-2010 Sven Klose <pixel@copei.de>
;;;;
;;;; Associative lists

(unless (eq t *BUILTIN-ASSOC*)
  (defun assoc (key lst &key (test #'eql))
    "Search value for key in associative list."
    (when lst
	  (unless (consp lst)
	    (%error "list expected"))
      (dolist (i lst)
        (if (consp i)
		    (if (funcall test key (car i))
	  	  	    (return i))
		    (and (print i)
			     (%error "not a pair")))))))

(let lst '((a . d) (b . e) (c . f))
  (unless (eq 'e (cdr (assoc 'b lst)))
	(%error "ASSOC doesn't work with symbols")))

(let lst '((1 . a) (2 . b) (3 . c))
  (unless (eq 'b (cdr (assoc 2 lst)))
	(%error "ASSOC doesn't work with numbers")))

(defun assoc-cons (key lst &key (test #'eql))
  (when lst
	(unless (consp lst)
	  (%error "list expected"))
    (dolist (i lst)
      (if (consp i)
		  (if (funcall test key (car i))
	  	      (return i))
		  (%error "not a pair")))))

(defun %setf-assoc (new-value key x &key (test #'eql))
  (if (listp x)
      (when x
		(if (funcall test key (car x))
            (rplaca x new-value)
			(%setf-assoc new-value key (cdr x) :test test)))
	  (%error "not a pair")))

(defun (setf assoc) (new-value key lst &key (test #'eql))
  (%setf-assoc new-value key lst :test test)
  new-value)

(defun acons (key val lst)
  "Prepend key/value pair to associative list."
  (cons (cons key val) lst))

(defmacro acons! (key val place)
  "Destructively prepend key/value pair to associative list."
  `(setf ,place (acons ,key ,val ,place)))

(defun copy-alist (x)
  "Copy associative list."
  (mapcar (fn cons (car _) (cdr _))
		  x))

(defun aremove (obj lst &key (test #'eql))
  (when lst
    (if (funcall test obj (caar lst))
	    (aremove obj (cdr lst) :test test)
		(cons (cons (car lst.)
					(cdr lst.))
			  (aremove obj (cdr lst) :test test)))))

(defmacro aremove! (obj place &key (test #'eql))
  `(setf ,place (aremove ,obj ,place :test ,test)))
