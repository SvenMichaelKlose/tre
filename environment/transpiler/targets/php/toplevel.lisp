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
    (+ (list (section-from-string 'core-0 *php-core0*))
       (list (section-from-string 'core *php-core*)))))

(fn php-sections-after-import ()
  (unless (configuration :exclude-core?)
    (list (section-from-string 'core-2 *php-core2*))))

(fn php-identifier-char? (x)
  (unless (eql #\$ x)
    (c-identifier-char? x)))

(fn %make-php-transpiler-0 ()
  (create-transpiler
      :name                   :php
      :file-postfix           "php"
      :frontend-init          #'php-frontend-init
      :prologue-gen           #'php-prologue
      :epilogue-gen           #'php-epilogue
      :sections-before-import #'php-sections-before-import
      :sections-after-import  #'php-sections-after-import
      :lambda-export?         t
      :stack-locals?          nil
      :gen-string             [literal-string _ :chars-to-escape '(#\$)]
      :identifier-char?       #'php-identifier-char?
      :inline?                #'%slot-value?
      :argument-filter        #'php-argument-filter
      :assignment-filter      (compose [@ #'php-assignment-filter _]
                                       #'expex-compile-funcall)
      :configurations         '((:exclude-core?     . nil)
                                (:keep-source?      . nil)
                                (:keep-argdef-only? .  nil)
                                (:native-code       . nil))))

(fn make-php-transpiler ()
  (aprog1 (%make-php-transpiler-0)
    (transpiler-add-defined-function ! '%cons '(a d) nil)
    (transpiler-add-defined-function ! 'phphash-hash-table '(x) nil)
    (transpiler-add-defined-function ! 'phphash-hashkeys '(x) nil)))

(var *php-transpiler* (make-php-transpiler))
(var *php-separator*  (format nil ";~%"))
(var *php-indent*     "    ")
