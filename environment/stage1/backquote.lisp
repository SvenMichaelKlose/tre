;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (c) 2006-2007 Sven Klose <pixel@copei.de>
;;;;
;;;; BACKQUOTE expansion
;;;;
;;;; The funny argument names are used to avoid collisions with symbols
;;;; in the caller's environment during evaluation.

(setq *universe* (cons 'not
                 (cons 'last
                 (cons '%nconc
                 (cons 'copy-tree *universe*)))))

;;; Helper functions (helping us to stay sane).

(%set-atom-fun not
  #'((x)
    (eq x nil)))

(%set-atom-fun copy-tree
  #'((x)
    (cond
      (x (cond
           ((atom x)
               x)
           (t  (cons (copy-tree (car x))
                     (copy-tree (cdr x)))))))))

(%set-atom-fun last
  #'((x)
    (cond
      (x  (cond
            ((cdr x)
                (last (cdr x)))
            (t  x))))))

(%set-atom-fun %nconc
  #'((a b)
    (rplacd (last a) b)
    a))

;;; BACKQUOTE evaluation

;; BACKQUOTE-expand argument list with decremented sublevel.
(%set-atom-fun %quasiquote-subexpand
  #'((%gstype %gsbq %gsbqsub)
      (cons (cons %gstype
                  (%backquote (cdr (car %gsbq)) (- %gsbqsub 1)))
            (%backquote-1 (cdr %gsbq) %gsbqsub))))

;; Expand QUASIQUOTE.
(%set-atom-fun %backquote-quasiquote
  #'((%gsbq %gsbqsub)
    (cond
      ; No sublevel. Insert evaluated QUASIQUOTE value.
      ((= %gsbqsub 0)
          (cons (copy-tree (eval (car (cdr (car %gsbq)))))
                (%backquote-1 (cdr %gsbq) %gsbqsub)))

      (t  (%quasiquote-subexpand 'QUASIQUOTE %gsbq %gsbqsub)))))

;; Expand QUASIQUOTE-SPLICE.
(%set-atom-fun %backquote-quasiquote-splice
  #'((%gsbq %gsbqsub)
    (cond
      ; No sublevel. Splice evaluated QUASIQUOTE-SPLICE expression.
      ((= %gsbqsub 0)
          (#'((%gstmp)
               (cond
                 ; Ignore NIL evaluation.
                 ((not %gstmp)
                      (%backquote (cdr %gsbq) %gsbqsub))
                 ((atom %gstmp)
                      (%error "QUASIQUOTE-SPLICE: list expected"))
                 (t   (%nconc (copy-tree %gstmp)
                      (%backquote-1 (cdr %gsbq) %gsbqsub)))))
              (eval (car (cdr (car %gsbq))))))

      (t  (%quasiquote-subexpand 'QUASIQUOTE-SPLICE %gsbq %gsbqsub)))))

;; Expand BACKQUOTE arguments.
(%set-atom-fun %backquote-1
  #'((%gsbq %gsbqsub)
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

;; Expand BACKQUOTE, check for nested BACKQUOTE (and increment sublevel) first.
(%set-atom-fun %backquote
  #'((%gsbq %gsbqsub)
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

;; Initialise expansion with sublevel of 0.
(%set-atom-fun backquote
  (special (%gsbq) (%backquote %gsbq 0)))
