;;;; TRE environment
;;;; Copyright (c) 2006-2008 Sven Klose <pixel@copei.de>
;;;;
;;;; BACKQUOTE expansion
;;;;
;;;; The funny argument names are used to avoid collisions with symbols
;;;; in the caller's environment during evaluation.

(setq *UNIVERSE* (cons 'quasiquote?
				 (cons '%quasiquote-eval
				 (cons '%backquote-quasiquote
				 (cons %backquote-quasiquote-splice
				 (cons %backquote-1
				 (cons %backquote
				 (cons backquote *UNIVERSE*))))))))

(%set-atom-fun quasiquote?
  #'((x)
       (if (consp x)
    	   (if
	          (eq (car x) 'quasiquote)	       t
	          (eq (car x) 'quasiquote-splice)  t))))

(%set-atom-fun %quasiquote-eval
  #'((%gsbq)
       (eval (car (cdr (car %gsbq))))))

;; Expand QUASIQUOTE.
(%set-atom-fun %backquote-quasiquote
  #'((%gsbq)
      (if (not (quasiquote? (car (cdr (car %gsbq)))))
          (cons (copy-tree (%quasiquote-eval %gsbq))
                (%backquote-1 (cdr %gsbq)))
          (cons (%backquote (car (cdr (car %gsbq))))
                (%backquote-1 (cdr %gsbq))))))

;; Expand QUASIQUOTE-SPLICE.
(%set-atom-fun %backquote-quasiquote-splice
  #'((%gsbq)
       (if (not (quasiquote? (car (cdr (car %gsbq)))))
           (#'((%gstmp)
                 (if
                   ; Ignore NIL evaluation.
                   (not %gstmp)
                     (%backquote (cdr %gsbq))
                   (atom %gstmp)
                     (%error "QUASIQUOTE-SPLICE: list expected")
                   (%nconc (copy-tree %gstmp)
                  		   (%backquote-1 (cdr %gsbq)))))
                (%quasiquote-eval %gsbq))

           (cons (copy-tree (car (cdr (car %gsbq))))
                 (%backquote-1 (cdr %gsbq))))))

;; Expand BACKQUOTE arguments.
(%set-atom-fun %backquote-1
  #'((%gsbq)
       (if
         ; Return atom as is.
         (atom %gsbq)
           %gsbq

         ; Return element if it's not a cons.
         (atom (car %gsbq))
           (cons (car %gsbq)
                 (%backquote-1 (cdr %gsbq)))

         ; Do QUASIQUOTE expansion.
         (eq (car (car %gsbq)) 'QUASIQUOTE)
           (%backquote-quasiquote %gsbq)

         ; Do QUASIQUOTE-SPLICE expansion.
         (eq (car (car %gsbq)) 'QUASIQUOTE-SPLICE)
           (%backquote-quasiquote-splice %gsbq)

         ; Expand sublist and rest.
         (cons (%backquote (car %gsbq))
               (%backquote-1 (cdr %gsbq))))))

;; Expand BACKQUOTE, check for nested BACKQUOTE first.
(%set-atom-fun %backquote
  #'((%gsbq)
       (if
         ; Return atom as is.
         (atom %gsbq)
           %gsbq

         ; Enter new backquote level.
         (eq (car %gsbq) 'BACKQUOTE)
     	     (cons 'BACKQUOTE
                   (%backquote (cdr %gsbq)))

         ; No new backquote level, continue normally.
         (%backquote-1 %gsbq))))

;; Initialise expansion.
(%set-atom-fun backquote
  (special (%gsbq) (%backquote %gsbq)))
