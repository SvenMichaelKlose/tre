;;;;; tré – Copyright (c) 2006–2012 Sven Klose <pixel@copei.de>

(defun backquote-cons-quasiquote (x)
  (? (any-quasiquote? (cadr x.))
     `(cons ,(backquote-cons (cadr x.))
            ,(backquote-cons-1 .x))
     `(cons ,(copy-tree (cadr x.))
            ,(backquote-cons-1 .x))))

(defun backquote-cons-quasiquote-splice (x)
  (? (any-quasiquote? (cadr x.))
     `(cons ,(copy-tree (cadr x.))
            ,(backquote-cons-1 .x))
     (!? (backquote-cons-1 .x)
         `(%nconc ,(copy-tree (cadr x.))
                  ,(backquote-cons-1 .x))
          (copy-tree (cadr x.)))))

(defun backquote-cons-atom (x)
  (when x
	(? (| (number? x)
          (string? x)
          (array? x)
          (hash-table? x)
          (eq t x))
          ;(string== "" (symbol-name x)) ; XXX?
	   x
	   `(%quote ,x))))

(defun backquote-cons-1 (x)
  (?
    (atom x) (backquote-cons-atom x)
    (atom x.) `(cons ,(backquote-cons-atom x.)
                     ,(backquote-cons-1 .x))
    (quasiquote? x.) (backquote-cons-quasiquote x)
    (quasiquote-splice? x.) (backquote-cons-quasiquote-splice x)
    `(cons ,(backquote-cons x.)
           ,(backquote-cons-1 .x))))

(defun backquote-cons (x)
  (?
    (atom x) (backquote-cons-atom x)
    (backquote? x) `(cons 'BACKQUOTE ,(backquote-cons .x))
    (backquote-cons-1 x)))

(defun simple-quote-expand (x)
  (when x
	(? (atom x)
	   (? (| (in? x nil t)
             (string? x)
		  (number? x))
		  x
		  `(%quote ,x))
	   `(cons ,(simple-quote-expand x.)
		      ,(simple-quote-expand .x)))))

(defun backquote-expand (l)
  (tree-walk l
	:ascending
	  #'((x)
		   (?
			 (quote? x) (simple-quote-expand .x.)
		   	 (backquote? x) (backquote-cons .x.)
			 x))))
