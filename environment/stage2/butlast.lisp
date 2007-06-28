;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2006 Sven Klose <pixel@copei.de>

(defun butlast (plist)
  "Return list without its last element."
  (if (cdr plist)
      (cons (car plist) (butlast (cdr plist)))))

(define-test "BUTLAST basically works"
  ((butlast '(1 2 3)))
  '(1 2))

(define-test "BUTLAST returns NIL for single cons"
  ((butlast '(1)))
  nil)
