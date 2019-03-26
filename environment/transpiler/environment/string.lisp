;;;;; tré – Copyright (c) 2013–2014 Sven Michael Klose <pixel@copei.de>

(defun %=-elt-string (val seq idx)
  (error "Cannot modify strings."))

(defun string (x)
  (?
    (string? x)    x
    (character? x) (char-string x)
    (symbol? x)    (symbol-name x)
    (number? x)    (number-string x)
    (not x)        "NIL"))
