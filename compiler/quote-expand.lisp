;;;;; TRE compiler
;;;;; Copyright (c) 2006-2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Convert BACKQUOTE-expressions into run-time consing code.

;; BACKQUOTE-expand argument list with decremented sublevel.
(defun quasiquote-subexpand (typ e sublevel)
      `(cons (cons ',typ
                   ,(quote-expand-0 (cdar e) (1- sublevel)))
             ,(quote-expand-1 .e sublevel)))

;; Expand QUASIQUOTE.
(defun quote-expand-quasiquote (e sublevel)
    (if (= sublevel 0)
        ; No sublevel. Insert evaluated QUASIQUOTE value.
        `(cons ,(cadar e)
               ,(quote-expand-1 .e sublevel))
        (quasiquote-subexpand 'QUASIQUOTE e sublevel)))

;; Expand QUASIQUOTE-SPLICE.
(defun quote-expand-quasiquote-splice (e sublevel)
    (if (= sublevel 0)
        ; No sublevel. Splice evaluated QUASIQUOTE-SPLICE expression.
        `(append ,(cadar e)
                 ,(quote-expand-1 .e sublevel))
         (quasiquote-subexpand 'QUASIQUOTE-SPLICE e sublevel)))

;; Expand BACKQUOTE arguments.
(defun quote-expand-1 (e sublevel)
    (if
	  (endp e)
	    nil

      ; Return atom as is.
      (atom e)
        `(%quote ,e)

      ; Return element if it's not a cons.
      (atom e.)
        `(cons (%quote ,e.)
               ,(quote-expand-1 .e sublevel))

      ; Do QUASIQUOTE expansion.
      (eq (caar e) 'QUASIQUOTE)
        (quote-expand-quasiquote e sublevel)

      ; Do QUASIQUOTE-SPLICE expansion.
      (eq (caar e) 'QUASIQUOTE-SPLICE)
        (quote-expand-quasiquote-splice e sublevel)

      ; Expand sublist and rest.
      `(cons ,(quote-expand-0 e. sublevel)
             ,(quote-expand-1 .e sublevel))))

;; Expand BACKQUOTE, check for nested BACKQUOTE (and increment sublevel) first.
(defun quote-expand-0 (e sublevel)
    (if
      ; Return atom as is.
      (atom e)
        `(%quote e)

      ; Enter new backquote level.
      (eq e. 'BACKQUOTE)
        (quote-expand-0 .e (1+ sublevel))

      ; No new backquote level, continue normally.
      (quote-expand-1 e sublevel)))

;; Initialise expansion with sublevel of 0.
(defun quote-expand (e)
  (quote-expand-0 e 0))

(defun simple-quote-expand (x)
  (when x
	(if (atom x)
		(if (not (or (stringp x) (numberp x)))
			`(%quote ,x)
			x)
		`(cons ,(simple-quote-expand x.)
		       ,(simple-quote-expand .x)))))

(defun backquote-expand (l)
  (tree-walk l
	:ascending
	  #'((x)
		   (if (quote? x)
			   (if (eq '%stack (cadr x))
				   '(%quote %stack)
			   	   (simple-quote-expand (cadr x)))
		   	   (if (backquote? x)
			  	   (quote-expand .x)
			       x)))))
