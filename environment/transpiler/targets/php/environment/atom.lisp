;;;;; tré – Copyright (c) 2011–2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate is_object isset function_exists)

(defun object? (x)
  (is_object x))

(defun function? (x)
  (?
    (is_a x "__closure") (function_exists x.n)
    (string? x)          (function_exists x)))

(defun builtin? (x))
