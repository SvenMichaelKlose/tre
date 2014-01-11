;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defvar *default-transpiler* nil)

(define-filter wrap-strings-in-lists (x)
  (? (string? x)
     (list x)
     x))

(defun compile-sections (sections &key (transpiler nil))
  (generic-compile (| transpiler
                      (copy-transpiler *default-transpiler*))
                   (wrap-strings-in-lists sections)))

(defun compile (expression &key (transpiler nil))
  (compile-sections `((t ,expression)) :transpiler transpiler))

