;;;;; tré – Copyright (c) 2006–2009,2012 Sven Michael Klose <pixel@copei.de>

(defvar'*macrop-diversion* nil)
(defvar'*macrocall-diversion* nil)
(defvar'*current-macro* nil)
(defvar'*macroexpand-backquote-diversion* nil)
(defvar'*macroexpand-print?* nil)

(defun %macroexpand-backquote (x)
  (?
    (atom x) x

    (atom (car x))
  	    (cons (car x)
              (%macroexpand-backquote .x))

    (eq (caar x) 'QUASIQUOTE)
	    (cons (cons 'QUASIQUOTE (%macroexpand (cdar x)))
	          (%macroexpand-backquote .x))

    (eq (caar x) 'QUASIQUOTE-SPLICE)
	    (cons (cons 'QUASIQUOTE-SPLICE (%macroexpand (cdar x)))
              (%macroexpand-backquote .x))

    (cons-r %macroexpand-backquote x)))

(setq *macroexpand-backquote-diversion* #'%macroexpand-backquote)

(defun %macroexpand-rest (x)
  (? (cons? x)
     (cons (%macroexpand x.)
           (%macroexpand-rest .x))
     x))

(defun %macroexpand-xlat (x)
  (when *macroexpand-print?*
    (print '*macroexpand-print?*)
    (print x))
  (with-temporary *current-macro* x.
    (aprog1 (apply *macrocall-diversion* (list x))
      (& *macroexpand-print?* (print x)))))

(defun %macroexpand-call (x)
  (? (& (atom x.) (apply *macrop-diversion* (list x)))
     (%macroexpand-xlat x)
	 x))

(defun %macroexpand (x)
  (? (cons? x)
     (case x. :test #'eq
       'QUOTE x
       'BACKQUOTE  (cons 'BACKQUOTE (apply *macroexpand-backquote-diversion* (list .x)))
       'QUASIQUOTE (cons 'QUASIQUOTE (%macroexpand .x))
       'QUASIQUOTE-SPLICE (cons 'QUASIQUOTE-SPLICE (%macroexpand .x))
       (%macroexpand-call (%macroexpand-rest x)))
     x))

(defun %%macrop (x)
  (macrop (symbol-function x.)))

(defun %%macrocall (x)
  (%macrocall (symbol-function x.) .x))

(defun %%env-macrop (x)
  (%%macrop x))

(defun %%env-macrocall (x)
  (%%macrocall x))

(defun *macroexpand-hook* (x)
  (with-temporary (*macrop-diversion* #'%%macrop
                   *macrocall-diversion* #'%%macrocall
                   *current-macro* nil)
    (%macroexpand x)))
