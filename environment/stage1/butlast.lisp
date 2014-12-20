;;;;; tré – Copyright (c) 2006,2012–2014 Sven Michael Klose <pixel@copei.de>

(functional butlast)

(defun butlast (plist)
  (? .plist
     (. plist. (butlast .plist))))

(define-test "BUTLAST basically works"
  ((butlast '(1 2 3)))
  '(1 2))

(define-test "BUTLAST returns NIL for single cons"
  ((butlast '(1)))
  nil)
