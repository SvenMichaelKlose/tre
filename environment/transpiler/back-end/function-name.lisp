(defvar *compiled-function-names* (make-hash-table :test #'eq))

(fn real-function-name (x)
  (href *compiled-function-names* x))

(fn compiled-function-name (name)
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

(fn compiled-function-name-string (name)
  (obfuscated-identifier (compiled-function-name name)))
