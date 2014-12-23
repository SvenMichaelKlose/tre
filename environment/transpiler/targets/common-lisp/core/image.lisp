;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defun sys-image-create (pathname fun)
  (sb-ext:save-lisp-and-die pathname
                            :toplevel #'(lambda ()
                                          (cl:in-package :tre)
                                          (cl:funcall fun))
                            :purify t))

(defun %start-core ()
  (setf *launchfile* (cadr (or
                             #+SBCL sb-ext:*posix-argv*
                             #+LISPWORKS system:*line-arguments-list*
                             #+CMU extensions:*command-line-words*
                             nil))))
