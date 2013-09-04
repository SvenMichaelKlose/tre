;;;;; tré – Copyright (c) 2008–2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun c-expex-initializer (ex)
  (= (expex-argument-filter ex) #'c-expex-argument-filter
     (expex-setter-filter ex)   (compose [mapcan [expex-set-global-variable-value _] _]
                                         #'expex-compiled-funcall)))
(defun c-identifier-char? (x)
  (| (<= #\a x #\z)
     (<= #\A x #\Z)
     (<= #\0 x #\9)
     (in=? x #\_ #\. #\$ #\#)))

(defun make-c-transpiler ()
  (create-transpiler
      :name                     'c
      :separator                (format nil ";~%")
      :identifier-char?         #'c-identifier-char?
      :lambda-export?           t
      :stack-locals?            t
      :copy-arguments-to-stack? t
      :literal-conversion       #'identity
      :expex-initializer        #'c-expex-initializer))

(defvar *c-transpiler* (copy-transpiler (make-c-transpiler)))
(defvar *c-separator*  (transpiler-separator *c-transpiler*))
(defvar *c-newline*    (format nil "~%"))
(defvar *c-indent*     "    ")
