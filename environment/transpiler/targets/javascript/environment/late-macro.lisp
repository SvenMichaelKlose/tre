;;;;; tré - Copyright (c) 2011-2012 Sven Michael Klose <pixel@copei.de>

(setf *macroexpand-backquote-diversion* #'%macroexpand-backquote)

(define-expander 'standard-macros)
(set-expander-macros 'standard-macros *macros*)
(defvar *standard-macro-expander* (expander-get 'standard-macros))

(defun %%macrop (x)
  (expander-has-macro? 'standard-macros x))

(defun %%macrocall (x)
  (funcall (expander-call *standard-macro-expander*) x))
