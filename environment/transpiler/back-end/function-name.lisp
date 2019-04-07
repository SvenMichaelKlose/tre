(fn real-function-name (x)
  (href (transpiler-real-function-names *transpiler*) x))

(fn compiled-function-name (name)
  (aprog1 (make-symbol (+ (function-name-prefix)
                          (!= (symbol-name (symbol-package name))
                            (? (| (eql "TRE" !)
                                  (eql "TRE-CORE" !)
                                  (eql "COMMON-LISP" !))
                               ""
                               (+ ! "_P_")))
                          (symbol-name name)))
    (let-when n (real-function-name name)
      (| (eq n name)
         (funinfo-error "Compiled function name clash ~A for ~A and ~A." ! name n)))
    (= (href (transpiler-real-function-names *transpiler*) !) name)))

(fn compiled-function-name-string (name)
  (convert-identifier (compiled-function-name name)))
