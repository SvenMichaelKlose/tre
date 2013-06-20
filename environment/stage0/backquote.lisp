;;;;; tré – Copyright (c) 2006–2013 Sven Michael Klose <pixel@copei.de>

;;;; XXX Never use %GSBQ anywhere within your QUASIQUOTEs.
;;;; XXX Solve this issue with packaging.

(setq *UNIVERSE*
	  (cons 'any-quasiquote?
      (cons '%quasiquote-eval
      (cons '%backquote-quasiquote
	  (cons '%backquote-quasiquote-splice
	  (cons '%backquote
	  (cons 'backquote
	  (cons 'quasiquote
	  (cons 'quasiquote-splice
		    *UNIVERSE*)))))))))

(setq *defined-functions*
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
       (? (cons? x)
          (?
            (eq (car x) 'quasiquote)         t
            (eq (car x) 'quasiquote-splice)  t))))

(%set-atom-fun %quasiquote-eval
  #'((%gsbq)
       (eval (car (cdr (car %gsbq))))))

(%set-atom-fun %backquote-quasiquote
  #'((%gsbq)
       (? (cpr %gsbq)
          (setq *default-listprop* (cpr %gsbq)))
       (#'((p c)
             (rplacp c p))
         *default-listprop*
         (cons (? (any-quasiquote? (car (cdr (car %gsbq))))
                  (%backquote (car (cdr (car %gsbq))))
                  (copy-tree (%quasiquote-eval %gsbq)))
               (%backquote (cdr %gsbq))))))

(%set-atom-fun %backquote-quasiquote-splice
  #'((%gsbq)
       (? (any-quasiquote? (car (cdr (car %gsbq))))
          (progn
            (? (cpr %gsbq)
               (setq *default-listprop* (cpr %gsbq)))
            (#'((p c)
                  (rplacp c p))
              *default-listprop*
              (cons (copy-tree (car (cdr (car %gsbq))))
                    (%backquote (cdr %gsbq)))))
          (#'((%gstmp)
                (?
                  (not %gstmp)  (%backquote (cdr %gsbq))
                  (atom %gstmp) (%error "QUASIQUOTE-SPLICE: list expected")
                  (%nconc (copy-tree %gstmp)
                          (%backquote (cdr %gsbq)))))
            (%quasiquote-eval %gsbq)))))

;; Expand BACKQUOTE arguments.
(%set-atom-fun %backquote
  #'((%gsbq)
       (?
         (atom %gsbq) %gsbq
         (progn
           (? (cpr %gsbq)
              (setq *default-listprop* (cpr %gsbq)))
           (#'((p c)
                 (? (cons? c)
                    (rplacp c (setq *default-listprop* p))))
             *default-listprop*
             (?
               (atom (car %gsbq))                        (cons (car %gsbq)
                                                               (%backquote (cdr %gsbq)))
               (eq 'QUASIQUOTE (car (car %gsbq)))        (%backquote-quasiquote %gsbq)
               (eq 'QUASIQUOTE-SPLICE (car (car %gsbq))) (%backquote-quasiquote-splice %gsbq)
               (cons (%backquote (car %gsbq))
                     (%backquote (cdr %gsbq)))))))))

(%set-atom-fun backquote
  (special (%gsbq) (%backquote %gsbq)))

(%set-atom-fun quasiquote
  #'((x)
	   (%error "QUASIQUOTE (or ',' for short) outside backquote.")))

(%set-atom-fun quasiquote-splice
  #'((x)
	   (%error "QUASIQUOTE-SPLICE (or ',@' for short) outside backquote.")))
