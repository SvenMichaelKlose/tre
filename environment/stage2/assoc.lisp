;;;; TRE  environment
;;;; Copyright (C) 2005-2006,2009 Sven Klose <pixel@copei.de>
;;;;
;;;; Associative lists

(unless (eq t *BUILTIN-ASSOC*)
  (defun assoc (key lst &key (test nil))
    "Search value for key in associative list."
    (when lst
	  (unless (consp lst)
	    (%error "list expected"))
      (dolist (i lst)
        (if (consp i)
		    (if (funcall (or test #'eql) key (car i))
	  	  	    (return i))
		    (and (print i)
			     (%error "not a pair")))))))

(let lst '((a . d) (b . e) (c . f))
  (unless (eq 'e (cdr (assoc 'b lst)))
	(%error "ASSOC doesn't work with symbols")))

(let lst '((1 . a) (2 . b) (3 . c))
  (unless (eq 'b (cdr (assoc 2 lst)))
	(%error "ASSOC doesn't work with numbers")))

(defun assoc-cons (key lst &key test)
  (when lst
	(unless (consp lst)
	  (%error "list expected"))
    (dolist (i lst)
      (if (consp i)
		  (if (funcall (or test #'eql) key (car i))
	  	      (return i))
		  (%error "not a pair")))))

(defun %setf-assoc (new-value key x &key test)
  (if (listp x)
      (when x
		(if (funcall (or test #'eql) key (car x))
            (rplaca x new-value)
			(%setf-assoc new-value key (cdr x) :test test)))
	  (%error "not a pair")))

(defun (setf assoc) (new-value key lst &key test)
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
  (mapcar (fn cons _. ._)
		  x))
