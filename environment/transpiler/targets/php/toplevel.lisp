(fn php-prologue ()
  (format nil "<?php // tré revision ~A~%~A"
              *tre-revision* (+ (configuration :native-code) *php-core-native*)))

(fn php-epilogue ()
  (format nil "?>~%"))

(fn php-decl-gen ()
  (codegen (frontend (@ #'list (compiled-inits))))) ; TODO: Double in JS target.

(fn php-frontend-init ()
  (add-defined-variable '*keyword-package*))

(fn php-sections-before-import ()
  (+ (list (. 'core-0 (load-string *php-core0*)))
     (& (not (configuration :exclude-core?))
        (list (. 'core (load-string *php-core*))))))

(fn php-sections-after-import ()
  (+ (& (not (configuration :exclude-core?))
        (list (. 'core-2 (load-string *php-core2*))))
     (& (eq t *have-environment-tests*)
        (list (. 'env-tests (make-environment-tests))))))

(fn php-identifier-char? (x)
  (unless (eql #\$ x)
    (c-identifier-char? x)))

(fn php-expex-initializer (ex)
  (= (expex-inline? ex)          #'%slot-value?
     (expex-setter-filter ex)    (compose [@ #'php-setter-filter _] #'expex-compiled-funcall)
     (expex-argument-filter ex)  #'php-argument-filter))

(fn make-php-transpiler-0 ()
  (create-transpiler
      :name                     :php
      :frontend-init            #'php-frontend-init
      :prologue-gen             #'php-prologue
      :epilogue-gen             #'php-epilogue
      :decl-gen                 #'php-decl-gen
      :sections-before-import   #'php-sections-before-import
      :sections-after-import    #'php-sections-after-import
      :lambda-export?           t
      :stack-locals?            nil
      :gen-string               [literal-string _ #\" (list #\$)]
      :identifier-char?         #'php-identifier-char?
      :literal-converter        #'expand-literal-characters
      :expex-initializer        #'php-expex-initializer
      :configurations           '((:exclude-core?            . nil)
                                  (:save-sources?            . nil)
                                  (:save-argument-defs-only? . nil)
                                  (:native-code              . nil))))

(fn make-php-transpiler ()
  (aprog1 (make-php-transpiler-0)
    (transpiler-add-defined-function ! '%cons '(a d) nil)
    (transpiler-add-defined-function ! 'phphash-hash-table '(x) nil)
    (transpiler-add-defined-function ! 'phphash-hashkeys '(x) nil)
    (transpiler-add-plain-arg-funs ! *builtins*)))

(var *php-transpiler* (make-php-transpiler))
(var *php-separator*  (format nil ";~%"))
(var *php-indent*     "    ")
