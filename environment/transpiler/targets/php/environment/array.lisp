;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate is_array)

(defun array? (x)
  (| (is_a x "__array")
     (is_array x)))

(defun %array-length (x)
  ((%transpiler-native count) (? (is_a x "__array")
                                 (x.a)
                                 x)))

(defun %array-push (arr x)
  (%setq (%transpiler-native "$" arr "[]") x)
  x)

(defun array-push (arr x)
  (? (is_a x "__array")
     (arr.p x)
     (%array-push arr x))
  x)

(defun list-array (x)
  (let a (make-array)
    (dolist (i x a)
      (a.p i))))

(defun list-phparray (x)
  (let a (%%%make-hash-table)
    (dolist (i x a)
      (%setq (%transpiler-native "$" a "[]") i))))
