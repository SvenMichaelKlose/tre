;;;; TRE environment
;;;; Copyright (c) 2006-2011 Sven Klose <pixel@copei.de>

(setq
	*UNIVERSE*
	(cons 'any-quasiquote?
    (cons '%quasiquote-eval
    (cons '%backquote-quasiquote
	(cons '%backquote-quasiquote-splice
	(cons '%backquote
	(cons 'backquote
	(cons 'quasiquote
	(cons 'quasiquote-splice
		  *UNIVERSE*)))))))))

(setq
	*defined-functions*
	(cons 'any-quasiquote?
    (cons '%quasiquote-eval
    (cons '%backquote-quasiquote
	(cons '%backquote-quasiquote-splice
	(cons '%backquote
	(cons 'quasiquote
	(cons 'quasiquote-splice
		  *defined-functions*))))))))

(%set-atom-fun any-quasiquote?
  #'((x)
       (if (cons? x)
    	   (if
	          (eq (car x) 'quasiquote)	       t
	          (eq (car x) 'quasiquote-splice)  t))))

(%set-atom-fun %quasiquote-eval
  #'((%gsbq)
       (eval (car (cdr (car %gsbq))))))

(%set-atom-fun %backquote-quasiquote
  #'((%gsbq)
      (cons (if (not (any-quasiquote? (car (cdr (car %gsbq)))))
                (copy-tree (%quasiquote-eval %gsbq))
                (%backquote (car (cdr (car %gsbq)))))
            (%backquote (cdr %gsbq)))))

(%set-atom-fun %backquote-quasiquote-splice
  #'((%gsbq)
       (if (not (any-quasiquote? (car (cdr (car %gsbq)))))
           (#'((%gstmp)
                 (if
                   (not %gstmp) (%backquote (cdr %gsbq))
                   (atom %gstmp) (%error "QUASIQUOTE-SPLICE: list expected")
                   (%nconc (copy-tree %gstmp)
                  		   (%backquote (cdr %gsbq)))))
                (%quasiquote-eval %gsbq))

           (cons (copy-tree (car (cdr (car %gsbq))))
                 (%backquote (cdr %gsbq))))))

;; Expand BACKQUOTE arguments.
(%set-atom-fun %backquote
  #'((%gsbq)
       (if
         (atom %gsbq) %gsbq
         (atom (car %gsbq)) (cons (car %gsbq)
                                  (%backquote (cdr %gsbq)))
         (eq 'QUASIQUOTE (car (car %gsbq))) (%backquote-quasiquote %gsbq)
         (eq 'QUASIQUOTE-SPLICE (car (car %gsbq))) (%backquote-quasiquote-splice %gsbq)
         (cons (%backquote (car %gsbq))
               (%backquote (cdr %gsbq))))))

(%set-atom-fun backquote
  (special (%gsbq) (%backquote %gsbq)))

(%set-atom-fun quasiquote
  #'((x)
	   (%error "',' outside backquote")))

(%set-atom-fun quasiquote-splice
  #'((x)
	   (%error "',@' outside backquote")))
