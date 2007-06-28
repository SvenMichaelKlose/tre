;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (c) 2006-2007 Sven Klose <pixel@copei.de>
;;;;
;;;; BACKQUOTE expansion
;;;;
;;;; The funny argument names are used to avoid collisions with symbols
;;;; during evaluation.

(setq *universe* (cons '%backquote-quasiquote
                 (cons '%backquote-quasiquote-splice
                 (cons '%backquote-1
                 (cons '%backquote
                 (cons 'backquote
                 (cons 'not
                 (cons 'last
                 (cons '%nconc
                 (cons 'copy-tree *universe*))))))))))

(%set-atom-fun not
  #'(lambda (x)
    (eq x nil)))

(%set-atom-fun copy-tree
  #'(lambda (x)
    (cond
      (x (cond
           ((atom x)
               x)
           (t  (cons (copy-tree (car x))
                     (copy-tree (cdr x)))))))))

(%set-atom-fun last
  #'(lambda (x)
    (cond
      (x  (cond
            ((cdr x)
                (last (cdr x)))
            (t  x))))))

(%set-atom-fun %nconc
  #'(lambda (a b)
    (rplacd (last a) b)
    a))

(%set-atom-fun %backquote-quasiquote
  #'(lambda (%gsbq %gsbqsub)
    (cond
      ; No sublevel. Insert evaluated QUASIQUOTE value.
      ((= %gsbqsub 0)
          (cons (copy-tree (eval (car (cdr (car %gsbq)))))
		(%backquote-1 (cdr %gsbq) %gsbqsub)))

      ; Expand QUASIQUOTE expression with decremented sublevel.
      (t  (cons (cons 'QUASIQUOTE
		      (%backquote (cdr (car %gsbq)) (- %gsbqsub 1)))
	        (%backquote-1 (cdr %gsbq) %gsbqsub))))))

(%set-atom-fun %backquote-quasiquote-splice
  #'(lambda (%gsbq %gsbqsub)
    (cond
      ; No sublevel. Splice evaluated QUASIQUOTE-SPLICE expression.
      ((= %gsbqsub 0)
          (#'(lambda (%gstmp)
               (cond
                 (%gstmp (%nconc (copy-tree %gstmp)
		         (%backquote-1 (cdr %gsbq) %gsbqsub)))
                 (t      (%backquote (cdr %gsbq) %gsbqsub))))
  	    (eval (car (cdr (car %gsbq))))))

      ; Return QUASIQUOTE-SPLICE with decremented sublevel.
      (t  (cons (cons 'QUASIQUOTE-SPLICE
		      (%backquote (cdr (car %gsbq)) (- %gsbqsub 1)))
		(%backquote-1 (cdr %gsbq) %gsbqsub))))))

(%set-atom-fun %backquote-1
  #'(lambda (%gsbq %gsbqsub)
    (cond
      ; Return atom as is.
      ((atom %gsbq)
          %gsbq)

      ; Return element if it's not a cons.
      ((atom (car %gsbq))
	  (cons (car %gsbq)
                (%backquote-1 (cdr %gsbq) %gsbqsub)))

      ; Do QUASIQUOTE expansion.
      ((eq (car (car %gsbq)) 'QUASIQUOTE)
	  (%backquote-quasiquote %gsbq %gsbqsub))

      ; Do QUASIQUOTE-SPLICE expansion.
      ((eq (car (car %gsbq)) 'QUASIQUOTE-SPLICE)
	  (%backquote-quasiquote-splice %gsbq %gsbqsub))

      ; Expand sublist and rest.
      (t  (cons (%backquote (car %gsbq) %gsbqsub)
	        (%backquote-1 (cdr %gsbq) %gsbqsub))))))

(%set-atom-fun %backquote
  #'(lambda (%gsbq %gsbqsub)
    (cond
      ; Return atom as is.
      ((atom %gsbq)
          %gsbq)

      ; Enter new backquote level.
      ((eq (car %gsbq) 'BACKQUOTE)
     	  (cons 'BACKQUOTE
                (%backquote (cdr %gsbq) (+ %gsbqsub 1))))

      ; No new backquote level, continue normally.
      (t  (%backquote-1 %gsbq %gsbqsub)))))

(%set-atom-fun backquote
  (special (%gsbq) (%backquote %gsbq 0)))
