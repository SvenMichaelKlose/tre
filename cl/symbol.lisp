; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

(defvar *keyword-package* (find-package "KEYWORD"))

(defun %make-symbol (x package)
  (intern x (? package
               (? (packagep package)
                  (package-name package)
                  x)
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
  (symbol-package x))

(defun =-symbol-function (v x)
  (setf (symbol-function x) v))
