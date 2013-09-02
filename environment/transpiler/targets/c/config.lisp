;;;;; tré – Copyright (c) 2008–2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun make-c-transpiler ()
  (create-transpiler
      :name 'c
      :backtrace? nil
      :separator (format nil ";~%")
      :identifier-char?  [| (<= #\a _ #\z)
                            (<= #\A _ #\Z)
                            (<= #\0 _ #\9)
                            (in=? _ #\_ #\. #\$ #\#)]
      :lambda-export? t
      :stack-locals? t
      :copy-arguments-to-stack? t
      :rename-all-args? t
      :literal-conversion #'identity
      :expex-initializer #'((ex)
                              (= (expex-argument-filter ex) #'c-expex-argument-filter
                                 (expex-setter-filter ex)   (compose [mapcan [expex-set-global-variable-value _] _]
                                                                     #'expex-compiled-funcall)))))

(defvar *c-transpiler* (copy-transpiler (make-c-transpiler)))
(defvar *c-separator*  (transpiler-separator *c-transpiler*))
(defvar *c-newline*    (format nil "~%"))
(defvar *c-indent*     "    ")
