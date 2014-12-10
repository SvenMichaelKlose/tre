;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

(defvar *keyword-package* (find-package "KEYWORD"))

(defun %make-symbol (x package)
  (intern x (? package
               (package-name package)
               "TRE")))

(defun %symbol-name (x)
  (? (packagep x)
     (package-name x)
     (symbol-name x)))

(defun %symbol-value (x)
  (? (boundp x)
     (symbol-value x)
     x))

(defun %symbol-function (x)
  (? (fboundp x)
     (symbol-function x)))

(defun %symbol-package (x)
  (? (boundp x)
     (symbol-package x)))
