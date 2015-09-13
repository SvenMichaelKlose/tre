; tré – Copyright (c) 2011–2013,2015 Sven Michael Klose <pixel@copei.de>

(define-expander 'standard-macros)
(set-expander-macros 'standard-macros *macros*)
(= *standard-macro-expander* (expander-get 'standard-macros))

(defun %%macro? (x)
  (expander-has-macro? 'standard-macros x.))

(defun %%macrocall (x)
  (funcall (expander-call *standard-macro-expander*) x))

; XXX I assume this is some work-around for some fixed xhost
; macroexpansion issue and can be removed safely. (pixel)

(defvar *environment-macros* (copy-alist *macros*))
(define-expander 'environment-macros)
(set-expander-macros 'environment-macros *environment-macros*)
(defvar *environment-macro-expander* (expander-get 'environment-macros))

(defun %%env-macro? (x)
  (expander-has-macro? 'environment-macros x.))

(defun %%env-macrocall (x)
  (funcall (expander-call *environment-macro-expander*) x))

(= *macroexpand-backquote* #'%macroexpand-backquote)
