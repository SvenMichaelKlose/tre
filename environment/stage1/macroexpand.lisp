;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (c) 2006-2007 Sven Klose <pixel@copei.de>
;;;;
;;;; Macro expansion

(setq *universe* (cons '*macrop-diversion*
                 (cons '*macroexpand-backquote-diversion*
                 (cons '*macrocall-diversion* *universe*))))

(setq *macrop-diversion* nil
      *macrocall-diversion* nil
      *macroexpand-backquote-diversion* nil
      *current-macro* nil)

;;;; Expand macros in BACKQUOTE expression.
;;;;
;;;; This algorithm is incomplete - it doesn't handle
;;;; nested backquotes.
(%set-atom-fun %macroexpand-backquote
  #'((%gsme)
    (cond
      ((not %gsme))
      ((not (consp %gsme))
          %gsme)
      ((not (consp (car %gsme)))
	  (cons (car %gsme)
                (%macroexpand-backquote (cdr %gsme))))
      ((eq (car (car %gsme)) 'QUASIQUOTE)
	  (cons (cons 'QUASIQUOTE
		      (%macroexpand (cdr (car %gsme))))
	        (%macroexpand-backquote (cdr %gsme))))

      ((eq (car (car %gsme)) 'QUASIQUOTE-SPLICE)
	  (cons (cons 'QUASIQUOTE-SPLICE
		      (%macroexpand (cdr (car %gsme))))
	        (%macroexpand-backquote (cdr %gsme))))

      (t  (cons (%macroexpand-backquote (car %gsme))
	        (%macroexpand-backquote (cdr %gsme)))))))

(%set-atom-fun %macroexpand-list
  #'((%gsme)
    (cond
      ((not %gsme))
      ((not (consp %gsme))
          %gsme)
      (t  (cons (%macroexpand (car %gsme))
                (%macroexpand-list (cdr %gsme)))))))

(%set-atom-fun %macroexpand-call
  #'((%gsme)
    (cond
      ((consp (car %gsme))
          (cons (%macroexpand (car %gsme))
                (cdr %gsme)))
      ((apply *macrop-diversion* (list (car %gsme)))
          (setq *current-macro* (car %gsme))
          (#'((%gsmt)
               (setq *current-macro* nil)
               %gsmt)
            (apply *macrocall-diversion* (list (car %gsme) (cdr %gsme)))))
      (t  %gsme))))

(%set-atom-fun %macroexpand
  #'((%gsme)
    (cond
      ((not %gsme))
      ((not (consp %gsme))
          %gsme)
      ((eq (car %gsme) 'QUOTE)
          %gsme)
      ((eq (car %gsme) 'BACKQUOTE)
          (cons 'BACKQUOTE
                (apply *macroexpand-backquote-diversion* (list (cdr %gsme)))))
      (t  (%macroexpand-call (cons (car %gsme)
                                   (%macroexpand-list (cdr %gsme))))))))

(%set-atom-fun %%macrop
  #'((%gsme)
    (macrop (symbol-function %gsme))))

(%set-atom-fun %%macrocall
  #'((%gsme %gsmp)
    (%macrocall (symbol-function %gsme) %gsmp)))

(%set-atom-fun *macroexpand-hook*
  #'((%gsme)
    (setq *macrop-diversion* #'%%macrop
          *macrocall-diversion* #'%%macrocall
          *macroexpand-backquote-diversion* #'%macroexpand-backquote
          *current-macro* nil)
    (%macroexpand %gsme)))
