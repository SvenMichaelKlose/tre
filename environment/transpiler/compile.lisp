;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defvar *default-transpiler* nil)

(defun wrap-strings-in-lists (x)
  (filter [? (string? _)
             (list _)
             _]
          x))

(defun compile-sections (sections &key (transpiler nil))
  (generic-compile (| transpiler (copy-transpiler *default-transpiler*))
                   (wrap-strings-in-lists sections)))

(defun compile (expression &key (transpiler nil))
  (compile-sections `((t ,expression)) :transpiler transpiler))

