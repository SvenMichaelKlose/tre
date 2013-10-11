;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun php-expex-add-global (x)
  (funinfo-var-add (transpiler-global-funinfo *transpiler*) x)
  (adjoin! x (funinfo-globals *funinfo*))
  x)

(defun php-argument-filter (x)
  (?
    (character? x)  (php-expex-add-global (php-compiled-char x))
    (%quote? x)     (php-expex-add-global (php-compiled-symbol .x.))
    (keyword? x)    (php-expex-add-global (php-compiled-symbol x))
    x))
