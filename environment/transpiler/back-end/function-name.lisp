(defvar *compiled-function-names* (make-hash-table :test #'eq))

(defun real-function-name (x)
  (href *compiled-function-names* x))

(defun compiled-function-name (name)
  (aprog1 (make-symbol (+ (function-name-prefix)
                          (alet (symbol-name (symbol-package name))
                            (? (| (eql "TRE" !)
                                  (eql "TRE-CORE" !)
                                  (eql "COMMON-LISP" !))
                               ""
                               (+ ! "_p_")))
                          (symbol-name name)))
    (let-when n (real-function-name name)
      (| (eq n name)
         (funinfo-error "Compiled function name clash ~A for ~A and ~A." ! name n)))
    (= (href *compiled-function-names* !) name)))

(defun compiled-function-name-string (name)
  (obfuscated-identifier (compiled-function-name name)))
