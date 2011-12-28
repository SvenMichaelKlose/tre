;;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defun compiled-symbol-identifier (x)
  (gensym))
;  ($ 'compiled-symbol- x (aif (symbol-package x)
;                              ($ '-k- (symbol-name !))
;                              "")))
