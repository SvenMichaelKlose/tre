;;;;; tré - Copyright (c) 2011-2012 Sven Michael Klose <pixel@copei.de>

(setf *macroexpand-backquote-diversion* #'%macroexpand-backquote)
(define-expander 'standard-macros)
(set-expander-macros 'standard-macros *macros*)
