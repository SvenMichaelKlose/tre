;;;;; TRE environment
;;;;; Copyright (c) 2005-2006,2008-2009 Sven Klose <pixel@copei.de>

;tredoc
; (predicate)
; "Checks if atom is an argument keyword."
(%defun %arg-keyword? (x)
  (if
    (eq x '&rest) t
    (eq x '&optional) t
    (eq x '&key) t))
