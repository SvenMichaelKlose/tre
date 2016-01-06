; tré – Copyright (c) 2011–2013,2015 Sven Michael Klose <pixel@copei.de>

(= *standard-macro-expander* (define-expander 'standard-macros))
(set-expander-macros *standard-macro-expander* *macros*)

(defun %%macro? (x)
  (expander-has-macro? *standard-macro-expander* x.))

(defun %%macrocall (x)
  (funcall (expander-call *standard-macro-expander*) x))

; XXX I assume this is some work-around for some fixed xhost
; macroexpansion issue and can be removed safely. (pixel)

(defvar *environment-macros* (copy-alist *macros*))
(defvar *environment-macro-expander* (define-expander 'environment-macros))
(set-expander-macros *environment-macro-expander* *environment-macros*)

(defun %%env-macro? (x)
  (expander-has-macro? *environment-macro-expander* x.))

(defun %%env-macrocall (x)
  (funcall (expander-call *environment-macro-expander*) x))

(= *macroexpand-backquote* #'%macroexpand-backquote)
