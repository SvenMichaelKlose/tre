;;;;; TRE compiler
;;;;; Copyright (c) 2006-2011 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Convert BACKQUOTE-expressions into run-time consing code.

;; Expand QUASIQUOTE.
(defun backquote-cons-quasiquote (x)
  (? (any-quasiquote? (second x.))
     `(cons ,(backquote-cons (second x.))
            ,(backquote-cons-1 .x))
     `(cons ,(copy-tree (second x.))
            ,(backquote-cons-1 .x))))

;; Expand QUASIQUOTE-SPLICE.
(defun backquote-cons-quasiquote-splice (x)
  (? (any-quasiquote? (second x.))
     `(cons ,(copy-tree (second x.))
            ,(backquote-cons-1 .x))
     `(%nconc ,(copy-tree (second x.))
      		  ,(backquote-cons-1 .x))))

(defun backquote-cons-atom (x)
  (when x
	(? (string= "" (symbol-name x))
	   x
	   `(%quote ,x))))

;; Expand BACKQUOTE arguments.
(defun backquote-cons-1 (x)
  (?
    ; Return atom as is.
    (atom x)
	  (backquote-cons-atom x)

    ; Return element if it's not a cons.
    (atom x.)
      `(cons ,(backquote-cons-atom x.)
             ,(backquote-cons-1 .x))

    ; Do QUASIQUOTE expansion.
    (quasiquote? x.)
      (backquote-cons-quasiquote x)

    ; Do QUASIQUOTE-SPLICE expansion.
    (quasiquote-splice? x.)
      (backquote-cons-quasiquote-splice x)

    ; Expand sublist and rest.
    `(cons ,(backquote-cons x.)
           ,(backquote-cons-1 .x))))

;; Expand BACKQUOTE, check for nested BACKQUOTE first.
(defun backquote-cons (x)
  (?
    ; Return atom as is.
    (atom x)
	  (backquote-cons-atom x)

    ; Enter new backquote level.
    (backquote? x)
	  `(cons 'BACKQUOTE
             ,(backquote-cons .x))

    ; No new backquote level, continue normally.
    (backquote-cons-1 x)))

(defun simple-quote-expand (x)
  (when x
	(? (atom x)
	   (? (or (string? x)
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
			 (quote? x)
			   (simple-quote-expand .x.)
		   	 (backquote? x)
			   (backquote-cons .x.)
			 x))))
