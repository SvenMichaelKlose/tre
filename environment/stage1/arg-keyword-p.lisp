;;;;; tré - Copyright (c) 2005-2006,2008-2009,2012 Sven Michael Klose <pixel@copei.de>

(%defun %arg-keyword? (x)
  (if
    (eq x '&rest) t
    (eq x '&body) t
    (eq x '&optional) t
    (eq x '&key) t))
