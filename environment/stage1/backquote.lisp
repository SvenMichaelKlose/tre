;;;; TRE environment
;;;; Copyright (c) 2006-2008 Sven Klose <pixel@copei.de>
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

;(%set-atom-fun eql
;  #'((x y)
;	  (block eql
;	    (cond
;		  ((numberp x)
;		     (cond
;			   ((numberp y)
;			      (return-from eql (= x y))))))
;	    (eq x y))))

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

(%set-atom-fun quasiquote?
  #'((x)
    (cond
	  ((consp x)
    	 (cond
	       ((eq (car x) 'quasiquote)	     t)
	       ((eq (car x) 'quasiquote-splice)  t))))))

(%set-atom-fun %quasiquote-eval
  #'((%gsbq)
       (eval (car (cdr (car %gsbq))))))

;; Expand QUASIQUOTE.
(%set-atom-fun %backquote-quasiquote
  #'((%gsbq)
    (cond
      ((not(quasiquote? (car (cdr (car %gsbq)))))
          (cons (copy-tree (%quasiquote-eval %gsbq))
                (%backquote-1 (cdr %gsbq))))

      (t  (cons (%backquote (car (cdr (car %gsbq))))
                (%backquote-1 (cdr %gsbq)))))))

;; Expand QUASIQUOTE-SPLICE.
(%set-atom-fun %backquote-quasiquote-splice
  #'((%gsbq)
    (cond
      ((not(quasiquote? (car (cdr (car %gsbq)))))
          (#'((%gstmp)
               (cond
                 ; Ignore NIL evaluation.
                 ((not %gstmp)
                      (%backquote (cdr %gsbq)))
                 ((atom %gstmp)
                      (%error "QUASIQUOTE-SPLICE: list expected"))
                 (t   (%nconc (copy-tree %gstmp)
                      		  (%backquote-1 (cdr %gsbq))))))
              (%quasiquote-eval %gsbq)))

      (t  (cons (copy-tree (car (cdr (car %gsbq))))
                (%backquote-1 (cdr %gsbq)))))))

;; Expand BACKQUOTE arguments.
(%set-atom-fun %backquote-1
  #'((%gsbq)
    (cond
      ; Return atom as is.
      ((atom %gsbq)
          %gsbq)

      ; Return element if it's not a cons.
      ((atom (car %gsbq))
          (cons (car %gsbq)
                (%backquote-1 (cdr %gsbq))))

      ; Do QUASIQUOTE expansion.
      ((eq (car (car %gsbq)) 'QUASIQUOTE)
          (%backquote-quasiquote %gsbq))

      ; Do QUASIQUOTE-SPLICE expansion.
      ((eq (car (car %gsbq)) 'QUASIQUOTE-SPLICE)
          (%backquote-quasiquote-splice %gsbq))

      ; Expand sublist and rest.
      (t  (cons (%backquote (car %gsbq))
                (%backquote-1 (cdr %gsbq)))))))

;; Expand BACKQUOTE, check for nested BACKQUOTE first.
(%set-atom-fun %backquote
  #'((%gsbq)
    (cond
      ; Return atom as is.
      ((atom %gsbq)
          %gsbq)

      ; Enter new backquote level.
      ((eq (car %gsbq) 'BACKQUOTE)
     	  (cons 'BACKQUOTE
                (%backquote (cdr %gsbq))))

      ; No new backquote level, continue normally.
      (t  (%backquote-1 %gsbq)))))

;; Initialise expansion.
(%set-atom-fun backquote
  (special (%gsbq) (%backquote %gsbq)))
