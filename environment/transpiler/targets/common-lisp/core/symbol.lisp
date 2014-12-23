; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defvar *keyword-package* (find-package "KEYWORD"))

(defbuiltin make-symbol (x &optional (package nil))
  (cl:intern x (? package
                  (? (cl:packagep package)
                     (cl:package-name package)
                     x)
                  "TRE")))

(defbuiltin symbol-name (x)
  (? (cl:packagep x)
     (cl:package-name x)
     (cl:symbol-name x)))

(defbuiltin symbol-value (x)
  (? (cl:boundp x)
     (cl:symbol-value x)
     x))

(defbuiltin symbol-function (x)
  (? (cl:fboundp x)
     (cl:symbol-function x)))

(defbuiltin symbol-package (x)
  (? (cl:boundp x)
     (cl:symbol-package x)))

(defbuiltin =-symbol-function (v x)
  (cl:setf (cl:symbol-function x) v))
