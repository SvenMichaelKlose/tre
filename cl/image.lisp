;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

(defun sys-image-create (pathname fun)
  (sb-ext:save-lisp-and-die pathname :toplevel #'(lambda ()
                                                   (in-package :tre)
                                                   (funcall fun))))
