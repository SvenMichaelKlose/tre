;;;;; tré – Copyright (c) 2005–2006,2008–2009,2012–2013 Sven Michael Klose <pixel@copei.de>

(early-defun %arg-keyword? (x)
  (| (eq x '&rest)
     (eq x '&body)
     (eq x '&optional)
     (eq x '&key)))
