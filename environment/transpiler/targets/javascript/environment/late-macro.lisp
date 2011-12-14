;;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

(setf *macroexpand-backquote-diversion* #'%macroexpand-backquote)
(define-expander 'standard-macros)
(setf *std-macro-expander* (expander-get 'standard-macros))
(set-expander-macros 'standard-macros *macros*)
