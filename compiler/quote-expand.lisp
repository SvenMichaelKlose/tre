;;;;; TRE compiler
;;;;; Copyright (c) 2006-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Convert BACKQUOTE-expressions into run-time consing code.

;; Expand QUASIQUOTE.
(defun backquote-cons-quasiquote (x)
  (if (quasiquote? (cadar x))
      `(cons ,(backquote-cons (cadar x))
             ,(backquote-cons-1 .x))
      `(cons ,(copy-tree (cadar x))
             ,(backquote-cons-1 .x))))

;; Expand QUASIQUOTE-SPLICE.
(defun backquote-cons-quasiquote-splice (x)
  (if (quasiquote? (cadar x))
      `(cons ,(copy-tree (cadar x))
             ,(backquote-cons-1 .x))
      `(%nconc ,(copy-tree (cadar x))
       		   ,(backquote-cons-1 .x))))

(defun backquote-cons-atom (x)
  (when x
	(if (string= "" (symbol-name x))
		x
		`(%quote ,x))))

;; Expand BACKQUOTE arguments.
(defun backquote-cons-1 (x)
  (if
    ; Return atom as is.
    (atom x)
	  (backquote-cons-atom x)

    ; Return element if it's not a cons.
    (atom x.)
      `(cons ,(backquote-cons-atom x.)
             ,(backquote-cons-1 .x))

    ; Do QUASIQUOTE expansion.
    (eq (caar x) 'QUASIQUOTE)
      (backquote-cons-quasiquote x)

    ; Do QUASIQUOTE-SPLICE expansion.
    (eq (caar x) 'QUASIQUOTE-SPLICE)
      (backquote-cons-quasiquote-splice x)

    ; Expand sublist and rest.
    `(cons ,(backquote-cons x.)
           ,(backquote-cons-1 .x))))

;; Expand BACKQUOTE, check for nested BACKQUOTE first.
(defun backquote-cons (x)
  (if
    ; Return atom as is.
    (atom x)
	  (backquote-cons-atom x)

    ; Enter new backquote level.
    (eq x. 'BACKQUOTE)
	  `(cons 'BACKQUOTE
             ,(backquote-cons .x))

    ; No new backquote level, continue normally.
    (backquote-cons-1 x)))

(defun simple-quote-expand (x)
  (when x
	(if (atom x)
		(if (or (stringp x)
				(numberp x))
			x
			`(%quote ,x))
		`(cons ,(simple-quote-expand x.)
		       ,(simple-quote-expand .x)))))

(defun backquote-expand (l)
  (tree-walk l
	:ascending
	  #'((x)
		   (if
			 (quote? x)
			   (if (eq '%stack (cadr x))
				   '(%quote %stack)
			   	   (simple-quote-expand (cadr x)))
		   	 (backquote? x)
			   (backquote-cons (second x))
			 x))))
