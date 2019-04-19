(var *keyword-package* (find-package "KEYWORD"))
(var *package* "TRE")

(defbuiltin make-symbol (x &optional (package nil))
  (cl:intern x (?
                 (cl:not package)       *package*
                 (cl:packagep package)  (cl:package-name package)
                 (cl:symbolp package)   (cl:symbol-name package)
                 package)))

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
  (cl:symbol-package x))

(defbuiltin =-symbol-function (v x)
  (cl:setf (cl:symbol-function x) v))

(defbuiltin find-symbol (x &optional (pkg *package*))
  (cl:find-symbol x *package*))

(fn tre-symbol (x)
  (cl:intern (symbol-name x) "TRE"))

(defbuiltin defpackage (name &rest options)
  (print-definition `(defpackage ,name ,@options))
  (cl:eval `(cl:defpackage ,name ,@options))
  nil)

(defbuiltin in-package (name)
  (print-definition `(in-package ,name ,@options))
  (= *package* (symbol-name name))
  nil)
