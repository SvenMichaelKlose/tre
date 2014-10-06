;;;;; tré – Copyright (c) 2008–2010,2012–2014 Sven Michael Klose <pixel@hugbox.org>

(defun c-expex-initializer (ex)
  (= (expex-argument-filter ex) #'c-argument-filter
     (expex-setter-filter ex)   (compose [mapcan #'expex-set-global-variable-value _]
                                         #'expex-compiled-funcall)))

(defun c-identifier-char? (x)
  (| (<= #\a x #\z)
     (<= #\A x #\Z)
     (<= #\0 x #\9)
     (in=? x #\_ #\. #\$ #\#)))

(defun make-c-transpiler ()
  (create-transpiler
      :name                     'c
      :prologue-gen             #'c-header-includes
      :decl-gen                 #'c-decl-gen
      :lambda-export?           t
      :stack-locals?            t
      :copy-arguments-to-stack? t
      :import-variables?        nil
      :separator                (format nil ";~%")
      :identifier-char?         #'c-identifier-char?
      :expex-initializer        #'c-expex-initializer
      :backtrace?		t))

(defvar *c-transpiler* (copy-transpiler (make-c-transpiler)))
(= *default-transpiler* *c-transpiler*)
(defvar *c-separator*  (transpiler-separator *c-transpiler*))
(defvar *c-indent*     "    ")
