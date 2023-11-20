(var *keyword-package* (CL:FIND-PACKAGE "KEYWORD"))
(var *package* "TRE")

(defbuiltin make-symbol (x &optional (package nil))
  (CL:INTERN x (?
                 (CL:NOT package)       *package*
                 (CL:PACKAGEP package)  (CL:PACKAGE-NAME package)
                 (CL:SYMBOLP package)   (CL:SYMBOL-NAME package)
                 package)))

(defbuiltin symbol-name (x)
  (? (CL:PACKAGEP x)
     (CL:PACKAGE-NAME x)
     (CL:SYMBOL-NAME x)))

(defbuiltin symbol-value (x)
  (? (CL:BOUNDP x)
     (CL:SYMBOL-VALUE x)
     x))

(defbuiltin symbol-function (x)
  (? (CL:FBOUNDP x)
     (CL:SYMBOL-FUNCTION x)))

(defbuiltin symbol-package (x)
  (CL:SYMBOL-PACKAGE x))

(defbuiltin =-symbol-function (v x)
  (CL:SETF (CL:SYMBOL-FUNCTION x) v))

(defbuiltin find-symbol (x &optional (pkg *package*))
  (CL:FIND-SYMBOL x pkg))

(fn tre-symbol (x)
  (CL:INTERN (symbol-name x) "TRE"))

(defspecial defpackage (name &rest options)
  (print-definition `(defpackage ,name ,@options))
  (CL:EVAL `(CL:DEFPACKAGE ,name ,@options))
  nil)

(defspecial in-package (name)
  (print-definition `(in-package ,name))
  (CL:IN-PACKAGE name)
  (= *package* (symbol-name name))
  nil)

(defbuiltin export (x &optional (pkg *package*))
  (CL:EXPORT x pkg))
