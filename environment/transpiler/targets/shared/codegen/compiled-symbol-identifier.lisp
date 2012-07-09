;;;;; tré – Copyright (c) 2011–2012 Sven Michael Klose <pixel@copei.de>

(defun compiled-symbol-identifier (x)
  (gensym))
;  ($ 'compiled-symbol- x (!? (symbol-package x)
;         –                   ($ '-k- (symbol-name !))
;                             "")))
