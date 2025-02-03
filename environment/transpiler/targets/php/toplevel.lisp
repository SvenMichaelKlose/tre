(fn php-prologue ()
  (format nil "<?php // tré revision ~A~%~A"
              *tre-revision* (+ (configuration :native-code)
                                *php-core-native*)))

(fn php-epilogue ()
  (format nil "?>~%"))

(fn php-frontend-init ()
  (add-defined-variable '*keyword-package*))

(fn php-sections-before-import ()
  (unless (configuration :exclude-core?)
    (… (section-from-string 'core-before-import *php-core-before-import*))))

(fn php-sections-after-import ()
  (unless (configuration :exclude-core?)
    (… (section-from-string 'core-after-import *php-core-after-import*))))

(fn php-identifier-char? (x)
  (unless (eql x #\$)
    (c-identifier-char? x)))

(fn make-php-transpiler ()
  (fn make ()
    (create-transpiler
        :name                   :php
        :file-postfix           "php"
        :frontend-init          #'php-frontend-init
        :prologue               #'php-prologue
        :epilogue               #'php-epilogue
        :sections-before-import #'php-sections-before-import
        :sections-after-import  #'php-sections-after-import
        :lambda-export?         t
        :gen-string             [literal-string _ :quote-char #\']
        :identifier-char?       #'php-identifier-char?
        :inline?                #'%slot-value?
        :argument-filter        #'php-argument-filter
        :assignment-filter      #'expex-compile-funcall
        :configurations         '((:exclude-core?     . nil)
                                  (:keep-source?      . nil)
                                  (:keep-argdef-only? . nil)
                                  (:native-code       . nil))))
  (aprog1 (make)
    (transpiler-add-defined-function ! '%cons '(a d) nil)
    (transpiler-add-defined-function ! 'phphash-hash-table '(x) nil)
    (transpiler-add-defined-function ! 'phphash-hashkeys '(x) nil)))

(var *php-transpiler* (make-php-transpiler))
(var *php-separator*  (format nil ";~%"))
(var *php-indent*     "    ")
