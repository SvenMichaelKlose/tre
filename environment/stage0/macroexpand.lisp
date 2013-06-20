;;;;; tré – Copyright (c) 2006–2009,2012–2013 Sven Michael Klose <pixel@copei.de>

;;;; This is where the Lisp macro magic happens.
;;;; Leaves are expanded first.
;;;; XXX Don't use symbols starting with '%' anywhere else.
;;;; XXX Solve this issue with packaging.

(setq
	*universe*
	(cons '*macrop-diversion*
	(cons '*macroexpand-backquote-diversion*
	(cons '*macrocall-diversion*
	(cons '*current-macro*
	(cons '%macroexpand
	(cons '%macroexpand-backquote
	(cons '%%macrop
	(cons '%%macrocall
	(cons '%%env-macrop
	(cons '%%env-macrocall
	(cons '%macroexpand-rest
	(cons '%macroexpand-xlat
	(cons '%macroexpand-call
		  *universe*))))))))))))))

(setq
	*defined-functions*
	(cons '%macroexpand
	(cons '%macroexpand-backquote
	(cons '%%macrop
	(cons '%%macrocall
	(cons '%%env-macrop
	(cons '%%env-macrocall
	(cons '%macroexpand-rest
	(cons '%macroexpand-xlat
	(cons '%macroexpand-call
		  *defined-functions*))))))))))

(setq
	*variables*
	(cons (cons '*macrop-diversion* nil)
	(cons (cons '*macrocall-diversion* nil)
	(cons (cons '*current-macro* nil)
	(cons (cons '*macroexpand-backquote-diversion* nil)
	(cons (cons '*macroexpand-print?* nil)
				*variables*))))))

(setq *macrop-diversion* nil
      *macrocall-diversion* nil
      *current-macro* nil
      *macroexpand-print?* nil)

(%set-atom-fun %macroexpand-backquote
  #'((%g)
       (?
         (atom %g) %g
         (progn
            (? (cpr %g)
               (setq *default-listprop* (cpr %g)))
            (#'((p c)
                  (rplacp c (setq *default-listprop* p)))
              *default-listprop*
              (?
                (atom (car %g))
	  	          (cons (car %g)
                        (%macroexpand-backquote (cdr %g)))

                (eq (car (car %g)) 'QUASIQUOTE)
	  	          (cons (cons 'QUASIQUOTE
		        	          (%macroexpand (cdr (car %g))))
	                    (%macroexpand-backquote (cdr %g)))

                (eq (car (car %g)) 'QUASIQUOTE-SPLICE)
	  	          (cons (cons 'QUASIQUOTE-SPLICE
		        	          (%macroexpand (cdr (car %g))))
	                    (%macroexpand-backquote (cdr %g)))

                (cons (%macroexpand-backquote (car %g))
	                  (%macroexpand-backquote (cdr %g)))))))))

(setq *macroexpand-backquote-diversion* #'%macroexpand-backquote)

(%set-atom-fun %macroexpand-rest
  #'((%g)
       (? (atom %g)
          %g
          (progn
            (? (cpr %g)
               (setq *default-listprop* (cpr %g)))
            (#'((p c)
                  (rplacp c (setq *default-listprop* p)))
       	      *default-listprop*
              (cons (%macroexpand (car %g))
                    (%macroexpand-rest (cdr %g))))))))

(%set-atom-fun %macroexpand-xlat
  #'((%g)
       (? *macroexpand-print?*
          (progn
            (print '*macroexpand-print?*)
            (print %g)))
       (setq *current-macro* (car %g))
       (#'((%g)
             (? *macroexpand-print?*
                (print %g))
             (setq *current-macro* nil)
             %g)
         (apply *macrocall-diversion* (list %g)))))

(%set-atom-fun %macroexpand-call
  #'((%g)
       (? (? (atom (car %g))
		     (apply *macrop-diversion* (list %g)))
          (%macroexpand-xlat %g)
		  %g)))

(%set-atom-fun %macroexpand
  #'((%g)
       (?
         (atom %g) %g
         (progn
           (? (cpr %g)
              (setq *default-listprop* (cpr %g)))
           (#'((p c)
                 (? (cons? c)
                    (rplacp c (setq *default-listprop* p))
                    c))
             *default-listprop*
             (?
               (eq (car %g) 'QUOTE)             %g
               (eq (car %g) 'BACKQUOTE)         (cons 'BACKQUOTE (apply *macroexpand-backquote-diversion* (list (cdr %g))))
               (eq (car %g) 'QUASIQUOTE)        (cons 'QUASIQUOTE (%macroexpand (cdr %g)))
               (eq (car %g) 'QUASIQUOTE-SPLICE) (cons 'QUASIQUOTE-SPLICE (%macroexpand (cdr %g)))
               (%macroexpand-call (%macroexpand-rest %g))))))))

(%set-atom-fun %%macrop
  #'((%g)
       (? (symbol? (car %g))
          (macrop (symbol-function (car %g))))))

(%set-atom-fun %%macrocall
  #'((%g)
       (apply (symbol-function (car %g)) (cdr %g))))

(%set-atom-fun %%env-macrop
  #'((%g)
       (%%macrop %g)))

(%set-atom-fun %%env-macrocall
  #'((%g)
       (%%macrocall %g)))

(%set-atom-fun *macroexpand-hook*
  #'((%g)
	   (#'((%gp %gc %gcm)
             (setq *macrop-diversion*    #'%%macrop
                   *macrocall-diversion* #'%%macrocall
                   *current-macro*       nil)
	         (#'((%g)
                   (setq *macrop-diversion*    %gp
                         *macrocall-diversion* %gc
                         *current-macro*       %gcm)
				   %g)
	           (%macroexpand %g)))
          *macrop-diversion* *macrocall-diversion* *current-macro*)))
