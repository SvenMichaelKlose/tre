;;;;; TRE environment
;;;;; Copyright (c) 2006-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Macro expansion.
;;;;;
;;;;; Macros are expanded from the leaves to the root.

(setq *universe* (cons '*macrop-diversion*
                 (cons '*macroexpand-backquote-diversion*
                 (cons '*macrocall-diversion*
				 (cons '%macroexpand
				 (cons '*expanded-macro?*
				 (cons %macroexpand-backquote
				 (cons %%macrop
				 (cons %%macrocall
				 (cons %macroexpand-list
				 (cons %macroexpand-call *universe*)))))))))))

(setq *macrop-diversion* nil
      *macrocall-diversion* nil
      *expanded-macro?* nil
      *current-macro* nil)
(setq *variables* (cons (cons '*macrop-diversion* nil)
      			  (cons (cons '*macrocall-diversion* nil)
      			  (cons (cons '*current-macro* nil)
                  (cons (cons '*macroexpand-backquote-diversion* nil)
				  *variables*)))))

;;;; Expand macros in BACKQUOTE expression.
;;;;
;;;; This algorithm is incomplete - it doesn't handle
;;;; nested backquotes.
(%set-atom-fun %macroexpand-backquote
  #'((%g)
       (if
         (atom %g)
           %g

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
	           (%macroexpand-backquote (cdr %g))))))

(setq *macroexpand-backquote-diversion* #'%macroexpand-backquote)

(%set-atom-fun %macroexpand-rest
  #'((%g)
       (if (atom %g)
           %g
       	   (cons (%macroexpand (car %g))
                 (%macroexpand-rest (cdr %g))))))

(%set-atom-fun %macroexpand-xlat
  #'((%g)
       (setq *expanded-macro?* t)
       (setq *current-macro* (car %g))
       (#'((%g)
             (setq *current-macro* nil)
             %g)
         (apply *macrocall-diversion* (list %g)))))

(%set-atom-fun %macroexpand-call
  #'((%g)
       (if (if (atom (car %g))
			   (apply *macrop-diversion* (list %g)))
           (%macroexpand-xlat %g)
		   %g)))

(%set-atom-fun %macroexpand
  #'((%g)
       (if
         (atom %g)
           %g

         (eq (car %g) 'QUOTE)
           %g

         (eq (car %g) 'BACKQUOTE)
           (cons 'BACKQUOTE
                 (apply *macroexpand-backquote-diversion* (list (cdr %g))))

         (%macroexpand-call (%macroexpand-rest %g)))))

(%set-atom-fun %%macrop
  #'((%g)
       (macrop (symbol-function (car %g)))))

(%set-atom-fun %%macrocall
  #'((%g)
       (%macrocall (symbol-function (car %g)) (cdr %g))))

(%set-atom-fun *macroexpand-hook*
  #'((%g)
	   (#'((%gp %gc %gcm)
             (setq *macrop-diversion* #'%%macrop
                   *macrocall-diversion* #'%%macrocall
                   *current-macro* nil)
	         (#'((%g)
                   (setq *macrop-diversion* %gp
                         *macrocall-diversion* %gc
                         *current-macro* %gcm)
				   %g)
	           (%macroexpand %g)))
          *macrop-diversion* *macrocall-diversion* *current-macro*)))
