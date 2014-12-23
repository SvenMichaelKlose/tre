;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defvar *keyword-package* (find-package "KEYWORD"))

(defun make-symbol (x &optional (package nil))
  (cl:intern x (? package
                  (? (cl:packagep package)
                     (cl:package-name package)
                     x)
                  "TRE")))

(defun symbol-name (x)
  (? (cl:packagep x)
     (cl:package-name x)
     (cl:symbol-name x)))

(defun symbol-value (x)
  (? (cl:boundp x)
     (cl:symbol-value x)
     x))

(defun symbol-function (x)
  (? (cl:fboundp x)
     (cl:symbol-function x)))

(defun symbol-package (x)
  (? (cl:boundp x)
     (cl:symbol-package x)))

(defun =-symbol-function (v x)
  (cl:setf (cl:symbol-function x) v))
