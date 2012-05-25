;;;;; tré – Copyright (c) 2008-2011-2012 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate constructor)

(defvar *js-array-constructor* (make-array).constructor)

(defun array? (x)
  (when x
    (eq *js-array-constructor* x.constructor)))

(dont-obfuscate push)

(defun list-array (x)
  (let a (make-array)
    (dolist (i x a)
      (a.push i))))

(dont-obfuscate *array)
(dont-inline array-find)

(defun array-find (arr obj)
  (declare type array arr)
  (%setq nil (%transpiler-native "return " arr ".indexOf (" obj ") != -1;"))
  nil)
