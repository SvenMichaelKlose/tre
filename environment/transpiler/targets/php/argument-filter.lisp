; tré – Copyright (c) 2009–2014 Sven Michael Klose <pixel@copei.de>

(defun php-expex-add-global (x)
  (funinfo-var-add (global-funinfo) x)
  (adjoin! x (funinfo-globals *funinfo*))
  x)

(defun php-argument-filter (x)
  (?
    (character? x)  (php-expex-add-global (php-compiled-char x))
    (%quote? x)     (php-expex-add-global (php-compiled-symbol .x.))
    (keyword? x)    (php-expex-add-global (php-compiled-symbol x))
    x))
