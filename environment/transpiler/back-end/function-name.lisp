;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defvar *compiled-function-names* (make-hash-table :test #'eq))

(defun compiled-function-name (name)
  (aprog1 (make-symbol (+ (transpiler-function-name-prefix *transpiler*) (symbol-name name)) (symbol-package name))
    (= (href *compiled-function-names* !) name)))

(defun real-function-name (x)
  (href *compiled-function-names* x))

(defun compiled-function-name-string (name)
  (obfuscated-identifier (compiled-function-name name)))
